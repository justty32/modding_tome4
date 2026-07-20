# 引擎事實：無頭（Xvfb）測試

> 目標版本 **ToME 1.7.6**，Linux / Manjaro。全部經實測驗證。
> 遊戲 `G = ~/.steam/steam/steamapps/common/TalesMajEyal`

## 0. 最重要的一條

**`t-engine64` 沒有 `--help`。任何參數都會直接開一個遊戲視窗。**

在真實桌面執行過一次，會在使用者畫面上彈出「是否真的要退出？」的對話框並卡住。
一律：

```bash
Xvfb :97 -screen 0 1024x768x24 &
DISPLAY=:97 LIBGL_ALWAYS_SOFTWARE=1 timeout 180 "$G/t-engine64" \
    --no-steam --no-web --flush-stdout --no-debug --home <scratch> 2>&1 | tee run.log
```

只需要 `LIBGL_ALWAYS_SOFTWARE=1`。不用 `GALLIUM_DRIVER`、`SDL_VIDEODRIVER`、`MESA_GL_VERSION_OVERRIDE`。

### 三個會讓你查半天的旗標／環境陷阱（實測踩過）

1. **不要加 `--no-debug`。** 它會讓引擎吞掉 Lua `print` 的輸出。
   於是 addon 的 `[X] selfcheck ... = OK` 一行都不會出現，引擎自己的
   `Checking addon` / `* with data` 也一起消失——但遊戲其實跑得好好的。
   症狀是「addon 明明載入成功，verify 卻永遠逾時」，且 log 裡看不到任何 addon 痕跡。
   **辨識方式**：log 裡有 tome 的內容（例如戰術權重表 `[mana] = 1`），
   卻沒有任何 `Checking addon`——那就是 print 被關了，不是 addon 沒載入。

2. **cwd 必須是遊戲安裝目錄。** 執行檔靠相對路徑找 `game/` 資料。
   從別的目錄啟動會停在啟動早期，連主選單都到不了（log 只有數十行）。

3. **不要用 `--logtofile`。** 它把輸出轉去 `te4_log.txt` 並改變啟動行為，
   連 `Switching to realtime` 這個主選單就緒標記都不會出現。

### `--home` 的真實語意

`--home <dir>` 只覆寫 `fs.getUserPath()`；引擎**無條件再接上 `/.t-engine/4.0`**。
所以真正的 settings / profiles / addons 根目錄是：

```
<dir>/.t-engine/4.0/{settings,addons,profiles}/
```

不是 `<dir>/4.0/...`。

啟動到主選單約 **18 秒**。可用的進度標記（依序出現在 stdout）：

| log 字串 | 意義 |
|---|---|
| `Available video driver: x11` | SDL 起來了 |
| `OpenGL max texture size: 16384` | 軟體 GL 可用 |
| `[for_modules] = {[1]=boot,[2]=tome}` | 模組掃描完成 |
| Discord state `"Main Menu"` | boot 主選單已完整渲染 |

## 1. 沒有辦法跳過 boot 主選單

要載入哪個模組，由 `game/loader/init.lua:24-42` 的 `__load_module` 決定（args[3]，預設 `"boot"`）。
那些 varargs 由 C 端傳入，**沒有任何 CLI 旗標對應**（`strings t-engine64` 掃過：
`--home --no-steam --no-web --no-debug --flush-stdout --safe-mode --logtofile --xpos --ypos
--ignore-window-change-pos --no-sandbox`，全都不是）。

`engine/init.lua:220` 初次啟動結尾固定呼叫 `util.showMainMenu(true)`。
換模組的唯一機制是**已在運行的 Lua state** 呼叫 `core.game.reboot(...)`
（`engine/utils.lua:2984-3011` → `engine/Module.lua:931-937`），丟掉當前 state 用新參數重跑 `loader/init.lua`。
這正是 boot 選單按 Play 進 tome 的實際原理。

**結論**：自動化只能用 `xdotool` 在 Xvfb 裡真的點過主選單。這是引擎架構決定的，不是我們偷懶。

## 2. `.cfg` 設定檔可以寫任意設定

`game/thirdparty/config.lua:5-45` 用 `setfenv(fct, config.settings)` 執行檔案內容。
所以 `.cfg` 裡寫**裸的** `cheat = true`，就等於 `config.settings.cheat = true`——不要加 `config.settings.` 前綴。

- `engine/init.lua:47`：啟動時自動 `mkdir <home>/4.0/settings/`
- `engine/init.lua:90-95`：把該目錄下**所有** `*.cfg` 都 `config.load`，**檔名任意**

`cheat = true` 的效果（`engine/Module.lua:538, 574, 589, 1022`）：跳過 MD5 驗證、允許 `cheat_only` addon、允許 beta addon。

**這是無頭測試的主要槓桿**：能用 cfg 預先設定的，就不要用點擊去設。每少一個彈窗，腳本就少一個脆弱點。

## 3. 這台機器的地雷：預裝 45 個 Auto-Activate addon

`$G/game/addons/` 底下有 45 個第三方 `.teaa`，全部預設啟用。直接 New Game **100% 重現**：

```
Lua Error: /engine/interface/ActorTemporaryEffects.lua:59: effect already exists with id EFF_EXHAUSTION
  At .../neka_therianthropy_summoner/timed_effects/fire-drake.lua:216
  At /hooks/neka_therianthropy_summoner/load.lua:33
```

元凶是 `tome-neka_therianthropy_summoner.teaa`（Odyssey of The Summoner，作者自述「There WILL be errors」）。
**與無頭無關，桌面版一樣會炸。**

**繞法**：在 scratch home 的 `4.0/settings/addons.cfg` 把第三方 addon 全設 `false`：

```lua
addons = {}
addons["tome"] = {}
addons["tome"]["neka_therianthropy_summoner"] = false
-- ...其餘全部 false
```

判定邏輯在 `engine/Module.lua:583-590`：列在 cfg 且為 `false` → 移除；
**未列出的走 else 分支 → 預設載入**。所以**待測 addon 不要列進 cfg**。

不要去動 `$G/game/addons/`——那是唯讀的遊戲安裝。

## 4. 不要在主選單按 Escape

`mod/class/Game.lua:571-577` 的 quit 彈窗，在 boot 主選單按 `Escape` 曾讓整個 process `dumped core`。
自動化腳本一律用**滑鼠點選單項目**。

## 5. 讓 addon 自報，不要判讀畫面

最穩的驗證方式不是截圖比對，而是讓 addon 在 `hooks/load.lua` 結尾把可驗證的事實 `print` 到 stdout
（配 `--flush-stdout`），再 grep。本工具鏈的慣例格式：

```
[RUNEWRIGHT] selfcheck resource = OK
[RUNEWRIGHT] selfcheck subclass = OK
[RUNEWRIGHT] hook complete
```

判定：
- **失敗**：log 出現 `Lua Error` 或 `stack traceback`
- **成功**：出現 `[X] hook complete` 且沒有任何 `selfcheck ... = FAIL`

實作範例見 `mods/tome-runewright/hooks/load.lua` 結尾。

## 6. 已驗證可跑完的完整路徑

前置：scratch home + `addons.cfg` 全關第三方 + 待測 addon 佈署進 `<scratch>/4.0/addons/`。

開機 → GDPR「Disable all online features」→「Disable all!」→ 主選單「New Game」
→ 關閉數個 DLC 宣傳彈窗「Close」→「Random!」→「Play!」→ Levelup 畫面 `Escape` 接受預設
→ 開場劇情 `Return` → 進入地圖（log 出現 `Saving done.`）
→ `Escape` 開選單 →「Save Game」→ `Escape` →「Exit Game」→「Yes」

process 自行結束，log 尾端 `Cleaning up! Terminating! ... Thanks for having fun!`（非 timeout 強殺）。
存檔落在 `<scratch>/4.0/tome/save/<name>/game.teag`。

**驗證 addon 載入其實不必走完全程**——走到 New Game 觸發 tome 模組 instanciate、hooks 執行完就夠了。
