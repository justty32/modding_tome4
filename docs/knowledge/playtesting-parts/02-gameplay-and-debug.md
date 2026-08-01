# 實機遊玩測試（AI 自己開遊戲玩）

> 目標版本 **ToME 1.7.6**，Linux / Manjaro。全部經實測驗證。
> 工具：`tools/playtest.sh`。先讀 [headless-testing.md](../headless-testing.md) 的 Xvfb 鐵律。

## 3. 遊戲內

- 資源條在左上：生命 / 法力 / 自訂資源，由上而下。用 `zoom 400 240 110 90` 看清數字。
- 技能提示：在升級畫面點圖示會展開完整說明，適合檢查 `info()` 的字串與數值縮放。
- 目標指定：按快捷鍵進入瞄準模式後，**用左鍵點格子**確認。`Return` 在沒有合法目標
  （例如敵人超出射程）時會**靜默取消**，看起來像什麼都沒發生。

### 快捷鍵的限制（已被 Lua console 取代，見 §3.5）

- 預設**只有 1–5 綁定**。按 6 以上會跳「按鍵未定義」對話框，擋住畫面。
- 起手就有的天賦與銘文佔滿 1–5；**升級後新學的天賦落在 slot 6+，鍵盤按不到**。
- Minimalist UI **不顯示快捷鍵列**，所以也沒辦法用滑鼠點圖示施放。

以前的結論是「新學的天賦無法在自動化中施放」。**現在改用 `playtest.sh lua` 直接呼叫**：

```bash
tools/playtest.sh lua 'game.player:useTalent(game.player.T_你的天賦短名)'
```

## 3.5 Developer Mode 與 Lua console（最強的一把工具）

> 實際可用的一行 probe 全部收在 [03-state-probes.md](03-state-probes.md)——
> 讀地圖、列生物、讀配天賦、操控移動、攔截 `game.log` 觀察回合結果。本節只講機制。

`tools/playtest.sh start <addon> --cheat` 會在 scratch home 寫下 `settings/cheat.cfg`
（`cheat = true`，遊戲自己也是這樣存的，見 `E/dialogs/GameMenu.lua:117`）。
開了之後多兩個鍵（`E/data/keybinds/debug.lua:20-33`）：

| 鍵 | 功能 | handler |
|---|---|---|
| `ctrl+L` | Lua console | `M/mod/class/Game.lua:2405` |
| `ctrl+A` | Debug 選單（換關／召喚／發物品／改任務／全殺）| `M/mod/class/Game.lua:2411` |

`E/DebugConsole.lua:140-151`：Return 就直接 `loadstring(line)` + `pcall`。
**執行結果只寫進 console 畫面的 history，不會進 stdout。要拿值就自己 `print()`**
——`print` 走 stdout 進 `run.log`，用 `playtest.sh log` 撈。

```bash
tools/playtest.sh lua 'print("[T] hp="..game.player.life.." zone="..game.zone.short_name)'
tools/playtest.sh lua 'game.player:grantQuest("myaddon+myquest")'
tools/playtest.sh lua 'game:changeLevel(2, "myaddon+myzone")'
tools/playtest.sh lua 'for _,e in pairs(game.level.entities) do if e.unique then e:die(game.player) end end'
tools/playtest.sh log '\[T\]'
```

`e:die(game.player)` 走的是 `E/interface/ActorLife.lua:91` 的 `self:check("on_die", src)`，
**跟玩家真的把它砍死是同一條路徑**，所以拿來驗 `on_die` 掛的任務推進是有效的。

### 四個實測出來的坑

1. **`xdotool key --clearmodifiers ctrl+l` 在 Xvfb 下時靈時不靈。**
   它會在按鍵送達前就放掉 Ctrl，遊戲只收到一個 `l`（變成一個遊戲指令，畫面上看起來像亂動）。
   必須拆成 `keydown ctrl` → `key l` → `keyup ctrl`。實測這樣 3/3 穩定。

2. **console 要好幾秒才畫出來**（軟體 GL）。太早打字，字元會被遊戲本體收走。
   所以 `cmd_lua` 先送一行 sentinel 並等它出現在 `run.log`，確認拿到焦點才送真正的程式碼。
   **sentinel 必須放在使用者程式碼之前**——像 `grantQuest` 這種會跳彈窗的程式碼，
   彈窗會蓋在 console 上把後續輸入吃掉，sentinel 放後面就會誤判成失敗。

3. **`--cheat` 會讓主選單多一個「重啓遊戲」項，並讓載入時序偏移**，
   於是 `start` 送出的第一個 Return 可能落在選單畫出來之前而完全沒生效。
   `cmd_start` 已改成「按了沒反應就重按，最多 4 次」——這個競態在非 cheat 模式下也一直存在，
   只是以前運氣好。

4. **後續按鍵全部「失效」＝多半是殘留的對話框在吃鍵盤。**
   `lua` 送完程式碼後那個收尾的 Escape 有時沒把 console 關掉（xdotool 不穩），
   `game.dialogs` 裡就留著一個 `engine.DebugConsole`，之後所有
   `do <名字> key <鍵>` 都被它吞掉——**表現是「按鍵沒反應」，不是報錯**。
   送鍵前先清乾淨：

   ```lua
   while #game.dialogs > 0 do game:unregisterDialog(game.dialogs[#game.dialogs]) end
   ```

   （2026-08-01 pi 做 orario 市集時實測。同一類問題還有一種變形：**演出系統的跳過彈窗**
   會吃掉 `lua` 收尾的那個 Return，害你剛啟動的場景瞬間被跳過——
   見 [scripted-scenes.md](../scripted-scenes.md) §5。）

### 什麼時候**不要**開 cheat

`verify.sh` 刻意不開。cheat 會改變引擎行為（例如 `E/Particles.lua:61,81` 對缺檔粒子的處理），
而 verify 的職責是「在最接近使用者的環境下確認 addon 載入」。cheat 只給 playtest 用。

## 4. 看不到狀態時，讓 addon 自己講

畫面看不到的東西（內部欄位、計算結果），**不要猜**。在 superload 或 hook 裡塞暫時的 `print`，
跑一輪，用 `tools/playtest.sh log` 撈出來，看完就刪。這比截圖判讀可靠得多：

```lua
-- TEMP-DEBUG
print("[MYMOD] dbg inscriptions: " .. table.concat(names, " | "))
-- /TEMP-DEBUG
```

盧恩術士那三個 bug 全都是這樣抓到的。第一行輸出就把問題講明白了：

```
[RUNEWRIGHT] dbg inscriptions(3): infusions/紋身：回覆 | infusions/紋身：狂暴 | runes/符文：法力風暴
[RUNEWRIGHT] dbg resonances(0):
```

銘文明明有三個、共鳴卻是 0 個——因為判定拿英文名去比對已翻譯的中文名。

**收工前記得把 TEMP-DEBUG 拿掉，再跑一次 `lint` + `verify`。**

## 4.5 對話與大地圖

- 從出生的關卡按 `<` 可以直接上大地圖（角色出生在入口格上）。方向鍵移動，撞上 NPC 開對話。
- **對話框的位置會隨 NPC 在畫面上的位置浮動**，同一個選項在不同回合的螢幕座標不一樣。
  每次點擊前重新截圖確認，不要沿用上一步的座標。
- 選項太多時對話框會被擠出畫面底部。第一個選項預設 highlight，按 `Return` 可以選到
  看不見的它——所以導航選項要放最前面。

## 5. 陷阱

- **`stop` 之後立刻檢查會誤判有殘留**：`kill` 是非同步的。`playtest.sh stop` 會等它死透才返回。
- **遊戲要 `setsid` 啟動**，否則背景行程會讓呼叫端的 shell 卡住不返回。
- **不要在主選單按 `Escape`**（退出確認彈窗，實測會 core dump）。建角與遊戲內按 Escape 是安全的。
- 軟體 GL 很慢，每個畫面切換都要 `wait 2` 以上；等 log 字串比固定 `sleep` 可靠。
- **改了 addon 的檔案後，執行中的遊戲不會看到**：PhysFS 掛載的是啟動時的目錄。
  `deploy.sh` 到 scratch 之後必須 `playtest.sh stop` + `start` 重來。
- `magick`（ImageMagick）與 `xdotool` 是必要相依。
