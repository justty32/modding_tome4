# tools/ — 工具鏈入口

冷啟動的 agent 只要讀這一頁就能正確做完一輪開發。每支腳本都支援 `-h`，
說明直接從該檔檔頭生成，**永遠不會和實作對不上**。

## 我想做什麼 → 跑哪支

| 我想…… | 指令 | 要多久 |
|---|---|---|
| 改完程式碼，先確認沒打錯字 | `tools/lint.sh <addon>` | 秒 |
| 確認 addon 真的會被引擎載入 | `tools/verify.sh <addon>` | 1–3 分 |
| 確認遊戲邏輯真的對 | `tools/playtest.sh start <addon> --cheat --birth default` | 3–5 分 |
| 取得遊戲內狀態（地圖／生物／天賦／戰鬥結果） | `tools/playtest.sh probe --list` | 每次 ~15 秒 |
| 打包成可發佈的 `.teaa` | `tools/build.sh <addon>` | 秒 |
| 裝進自己的遊戲來玩 | `tools/deploy.sh <addon>` | 秒 |
| 在**真實桌面**開遊戲（需先問使用者） | `tools/run.sh` | 30 秒 |

`<addon>` 三種寫法都吃：`runewright`、`tome-runewright`、完整路徑。

## 驗證分層：越後面越貴也越真

```
lint  →  verify（載入 + selfcheck）  →  playtest（建角 + 程式化操控 + 文字斷言）  →  使用者看畫面
靜態      無頭，1-3 分鐘               無頭，3-5 分鐘                              人眼判斷手感/渲染
```

**不要跳級**。lint 沒過就別跑 verify——啟動一次遊戲要好幾分鐘，而語法錯誤一秒就抓得到。
反過來也一樣：**lint 與 verify 全綠不代表 addon 是對的**。2026-07-10 就抓到三個
「verify 全綠但行為錯誤」的 bug，只有真的玩才看得到。

## 鐵律

- **絕不在真實桌面裸跑 `t-engine64`。** 它沒有 `--help`，任何參數都直接開遊戲視窗。
  自動化一律走 `verify.sh` / `playtest.sh`（它們自己開 Xvfb）。要用 `run.sh` 先問使用者。
- **要宣稱「能動」必須跑過 `verify.sh` 並貼出輸出。沒跑就說沒跑。**
- **AI 取得狀態一律用 `probe` / `lua`（純文字）；截圖是產給使用者看的。**
  畫面、渲染、手感、平衡由使用者判斷——那是人眼比 AI 可靠的地方，而且圖片很吃 token。

## 目錄佈局

```
tools/
  lint.sh build.sh deploy.sh verify.sh playtest.sh run.sh   ← 6 個進入口，只有這層該被直接執行
  lib/      bash 共用層：只做行程與檔案系統編排
  lua/      Lua 邏輯層：判讀、檢查、壓平
  probes/   探測庫：給 playtest.sh probe 用
```

### 為什麼是 bash + Lua 混編

分工線是**能力邊界**，不是喜好：

- 本機沒有 `lfs` / `luaposix`（只有 LuaJIT 的 `ffi`）。純 Lua 5.1 沒有目錄列舉、
  沒有 mkdir、沒有 spawn/signal/process group。這些硬搬到 Lua 只會變成一堆
  `os.execute("cp -r ...")`，比 bash 更糟也更難除錯。
- 所以：**行程與檔案系統編排留在 bash；一切判讀與邏輯放 Lua。**

| 層 | 檔案 | 職責 |
|---|---|---|
| bash 共用 | `lib/log.sh` | `die`/`info`/`ok`/`warn`；`--help` 從檔頭生成 |
| | `lib/paths.sh` | 所有路徑常數，全部可用同名環境變數覆寫 |
| | `lib/deps.sh` | `require_lua` / `require_game` / `require_headless_tools` … |
| | `lib/addon.sh` | `resolve_addon_dir` / `addon_names` / `addon_field` |
| | `lib/scratch.sh` | 拋棄式 t-engine home：跳彈窗的 cfg、cheat 開關、autobirth 規格 |
| | `lib/game.sh` | Xvfb、啟動遊戲、等 log、殺 process group |
| Lua 邏輯 | `lua/check_init.lua` | init.lua 欄位語意（引擎行號都在檔頭） |
| | `lua/verdict.lua` | 判讀 run.log 決定驗收成敗 |
| | `lua/addon_field.lua` | 用 Lua 求值取 init.lua 欄位（不是 grep） |
| | `lua/flatten_probe.lua` | 把探測壓成單行 ASCII，並擋掉非 ASCII 與語法錯誤 |
| 探測 | `probes/*.lua` | 見下 |

`lib.sh` 是聚合入口，`source` 它就會照相依順序載入整個 `lib/`。

## 探測庫（probes/）

```bash
tools/playtest.sh probe --list           # 列出全部
tools/playtest.sh probe state            # 我是誰、我在哪
tools/playtest.sh probe logmirror        # ★ 先裝這支，之後每條遊戲訊息都變成純文字
tools/playtest.sh probe map              # 周圍地形 ASCII 圖
tools/playtest.sh probe actors           # 本層生物（名稱/座標/血量/距離）
tools/playtest.sh probe talents          # 天賦與剩餘點數
tools/playtest.sh probe learn T_WEAPONS_MASTERY      # 加一點天賦
tools/playtest.sh probe attack "large white snake"   # 走過去打它，印前後血量
```

`probe` 會自動把該次執行新增的輸出撈回來，不用再跑一次 `log`。

### 寫新探測

在 `probes/` 放一個 `.lua`，第一行的 `-- 註解`會成為 `--list` 的說明。三條規矩
（訂得死是為了讓壓平器可以很笨、很可預測，完整理由見 `lua/flatten_probe.lua` 檔頭）：

1. **註解只能整行寫**，不准行尾註解——壓平器不解析字串，分不出 `--` 是註解還是內容。
2. **每行是完整敘述**，壓平就只是用空白把行接起來。
3. **`print()` 裡只能寫 ASCII**（註解可以寫中文，會被剝掉）。中文送不進 xdotool，
   那一行會靜默消失。壓平器會擋下來並告訴你是哪個字元。

需要參數就寫裸識別字 `ARG1`、`ARG2`，會被換成加好引號的 Lua 字串。

## 環境覆寫

所有路徑都能用同名環境變數蓋掉（定義在 `lib/paths.sh`）：

```bash
TOME_GAME_DIR=/opt/tome tools/verify.sh tome-relics
```

`MODKIT_ROOT` 由腳本自身位置推導，所以整包 modkit 搬到哪都不用改設定。
