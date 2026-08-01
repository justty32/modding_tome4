# CODE_MAP — 程式碼導航 index

修改前先在這裡定位。只列會幫助定位的檔案，不寫百科。
若 CODE_MAP 缺資料，以程式碼為準補上。

## 工具鏈（`tools/`）

**入口說明與決策表在 [`tools/README.md`](../../../../tools/README.md)**，每支腳本也都吃 `-h`
（說明從檔頭生成，不會與實作脫節）。這裡只給定位用的一句話。

分工線：bash 只做**行程與檔案系統編排**，一切**判讀與邏輯**在 Lua——
因為本機沒有 `lfs`／`luaposix`，純 Lua 做不到 spawn/signal/目錄列舉。

### 進入口（只有這層該被直接執行）

| 檔案 | 職責 |
|------|------|
| `lint.sh` | 每個 `.lua` 過 `luajit -b` 語法檢查，再跑 `lua/check_init.lua` |
| `build.sh` | 打包成 `.teaa`（zip）。會先跑 lint |
| `deploy.sh` | 冪等佈署到 `~/.t-engine/4.0/addons/`。`--home` 指向 scratch、`--undeploy` 移除 |
| `verify.sh` | Xvfb 無頭啟動遊戲，判定 addon 真的載入（判讀交給 `lua/verdict.lua`）|
| `playtest.sh` | Xvfb 裡**實際遊玩**。只留狀態路徑與派發，實作在 `lib/playtest/`。子命令 `start/probe/lua/log/do/shot/zoom/status/stop`；`start --birth` 自動建角 |
| `run.sh` | 在**使用者真實桌面**開遊戲（先問過才准跑）|

### bash 共用層（`tools/lib/`，`source lib.sh` 會照相依順序全載入）

| 檔案 | 職責 |
|------|------|
| `lib/log.sh` | `die`/`info`/`ok`/`warn`；`--help` 從檔頭生成 |
| `lib/paths.sh` | 所有路徑常數，皆可用同名環境變數覆寫；`MODKIT_ROOT` 由檔案位置推導 |
| `lib/deps.sh` | `require_lua` / `require_game` / `require_headless_tools` / `require_screenshot_tools` |
| `lib/addon.sh` | `resolve_addon_dir` / `addon_names`（推 `ADDON_DIR/BASE/SHORT/UPPER`）/ `addon_field` |
| `lib/scratch.sh` | 拋棄式 t-engine home：跳彈窗的 cfg、`enable_cheat_mode`、`write_autobirth_spec` |
| `lib/game.sh` | `pick_free_display` / `start_xvfb` / `launch_game` / `stop_game`（殺 process group）/ `wait_log` |

### playtest 專屬層（`tools/lib/playtest/`，只由 `playtest.sh` 自己 source）

刻意不進 `lib.sh` 聚合入口——`lint.sh`、`build.sh` 沒理由載入這些。

| 檔案 | 職責 |
|------|------|
| `playtest/session.sh` | `start` / `status` / `stop`：scratch home、autobirth 夾具、過主選單、等建角完成 |
| `playtest/screen.sh` | `shot` / `do` / `zoom`：截圖與 X11 輸入。**產物是給使用者看的** |
| `playtest/console.sh` | `probe` / `lua` / `log`：ctrl+L 進 Lua console、送單行 ASCII、從 `run.log` 撈回。**AI 取得狀態的唯一通道** |

### Lua 邏輯層（`tools/lua/`）

| 檔案 | 職責 |
|------|------|
| `check_init.lua` | `init.lua` 欄位語意：必填、版本相容、`weight`、旗標↔目錄一致、`data/` 是否有對應的 `loadDefinition` |
| `verdict.lua` | 判讀 `run.log` 決定驗收成敗（Lua Error 一票否決 → 自報 hook → 通用載入痕跡）|
| `addon_field.lua` | 用 `loadfile`+`setfenv` 求值取 `init.lua` 欄位，不是 grep |
| `flatten_probe.lua` | 把探測壓成單行 ASCII，並擋掉行尾註解、非 ASCII、語法錯誤 |

### 探測庫（`tools/probes/`）

給 `playtest.sh probe <名字>` 用。`state` / `map` / `actors` / `talents` /
`logmirror`（攔 `game.log` 鏡射到 stdout）/ `learn <天賦>` / `attack <生物名>`。
寫法規矩見 `tools/README.md`。

## 知識層（`docs/knowledge/`）

每條都附 `檔案:行號`。**這裡是本專案對引擎行為的真相層**，比 `~/repo/moddings/tome4/docs/analysis/` 可信。

| 檔案 | 內容 |
|------|------|
| `README.md` | 索引 + 路徑代號 + 「這個引擎很愛靜默失敗」總表 |
| `addon-loading.md` | init.lua 欄位、`/data-<name>/` 私有掛載、版本相容、weight、hook 要自己 require |
| `class-and-talents.md` | Birther、newTalent、自訂資源、i18n、`t.name` 已翻譯、沒有 postUseTalent hook |
| `visuals-and-sounds.md` | 粒子／音效／圖示的三套 API 與常見誤用 |
| `npc-and-chats.md` | `<addon>+<chat>` 路徑慣例、對話檔要 return、大地圖放 NPC、授予技能樹 |
| `headless-testing.md` | Xvfb 啟動、為何跳不過 boot 主選單、預裝 addon 地雷、addon 自報格式 |
| `playtesting.md` | 為何 verify 綠燈不等於做完、建角座標速查、TEMP-DEBUG 手法、陷阱 |

## Addon（`self_mods/tome-talent-tutor/`）

| 檔案 | 職責 |
|------|------|
| `hooks/load.lua` | `Game:changeLevel` → 在大地圖德斯城旁放置 NPC（避開 `change_zone` 入口格）；結尾印 selfcheck |
| `data/chats/tutor.lua` | 對話。每次開啟重新執行 → 技能樹清單動態產生。**結尾必須 `return "welcome"`** |

## Addon（`self_mods/tome-runewright/`）

| 檔案 | 職責 |
|------|------|
| `init.lua` | 旗標與版本。`weight` 不可省 |
| `hooks/load.lua` | **一切的入口**。`ToME:load` 裡手動 `loadDefinition` 所有定義，順序有依賴。結尾印 selfcheck 供 `verify.sh` 判定 |
| `data/lib/resonance.lua` | 共鳴判定，**純函數**。之後的 UI 面板靠 `M.predict()` 做預測提示——不要把它變成 actor 方法 |
| `data/resources.lua` | `defineResource("Rune Charge", "runecharge", ...)` |
| `data/talents/misc/pool.lua` | `T_RUNE_CHARGE_POOL`。沒學會它，`getRunecharge()` 恆回 0 |
| `data/talents/spells/*.lua` | 三個技能樹（runecraft / runic-mastery / inscription-lore） |
| `data/timed_effects.lua` | `newEffect`，被 runecraft 引用 |
| `data/birth/classes/mage.lua` | `newBirthDescriptor` + 加進 Mage 子職業白名單 |
| `superload/mod/class/Actor.lua` | 包住 `postUseTalent`，攔截銘文使用累積充能 |
| `data/locales/zh_hant.lua` | **`data/` 底下唯一會自動載入的檔** |

## 唯讀外部素材（不准寫）

| 路徑 | 用途 |
|------|------|
| `~/repo/moddings/tome4/vendor/t-engine4/engines/te4-1.7.6/` | 引擎原始碼（權威） |
| `~/repo/moddings/tome4/vendor/t-engine4/modules/tome/` | ToME 模組原始碼（權威） |
| `~/.steam/steam/steamapps/common/TalesMajEyal/` | 遊戲安裝、執行檔、45 個既有 addon |
| `~/repo/moddings/tome4/vendor/orig/` | arcanum / nullpack / midnight 等實裝職業包 |
| `~/repo/moddings/tome4/docs/analysis/` | 舊分析，**只當索引，非權威** |
