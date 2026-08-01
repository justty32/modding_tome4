# 引擎事實：讓 NPC 照腳本演出（cutscene）

> 路徑代號見 [README.md](README.md)。2026-08-01 建立並在同日實機回報後改寫，全部實機驗過。
> 實作：`self_mods/tome-director/`（可重用框架，38 項自我驗證通過）。

## 0. 前提：引擎沒有這個東西，要自己造

- `grep -i cinematic E/` **零命中**。
- `M/data/general/events/` 的 31 個事件，**沒有任何一個做 NPC 走位**。
- 原版最接近「演出」的寫法是 `M/data/zones/reknor/npcs.lua:111` 的
  `game:onTickEnd(...)`——只是在 boss 死後生一個信使出來，沒有分鏡。

所以劇情只靠四種載體（chat / quest / lore / zone 事件，見
[quests-and-lore.md](quests-and-lore.md)）的話，就只能是「站著對話」。
要分鏡就得自己建一層。**好消息是承重零件都在。**

## 1. ★ 最重要的一件事：演出**不要**推遊戲回合

這一節是本頁的重點，因為第一版做錯了，而且錯得很貴。

### 1.1 錯誤示範（v1 的做法，別再走這條）

第一版把演出掛在玩家的回合鏈上：superload `Player:act`，每推進一步演出就
`useEnergy()`，靠 `Player:useEnergy`（`M/mod/class/Player.lua:433-439`）把
`game.paused` 設回 false 讓回合繼續跑。

看起來很聰明，因為它只依賴兩個很穩定的行為（act 會 pause、useEnergy 會 unpause）。
**實機一測就爆了：一段過場動畫跑掉幾千甚至上萬回合。**

原因是回合推進的速度只受引擎 tick 快慢限制——沒有任何節流。
而「台詞停 1.5 秒」這種真實時間的等待，在 60fps 下就是幾百個回合。
附帶災難：中毒、流血、天賦冷卻、飢餓、buff 全部在過場動畫裡飛速流逝。

### 1.2 正解：改用**顯示幀**驅動，全程不碰回合

```lua
-- E/Game.lua:216-219
function _M:registerTimer(seconds, cb)
    self._timers_cb = self._timers_cb or {}
    self._timers_cb[cb] = seconds * 30
end
```

這些 timer 是在 **`Game:display`** 裡遞減的（`E/Game.lua:196-208`），
而 **`display` 在 `game.paused == true` 時照樣每幀跑**——`paused` 只擋 `tick()`。
這就是「畫面在動、回合不動」的那把鑰匙。

```lua
function D:schedule()
    game:registerTimer(1/30, function() D:pump() end)   -- 下一幀再回來
end
```

於是計時單位只有一種：**真實毫秒**。回合數不再是演出的詞彙。

三個附帶的好處，都是實測確認的：

- **NPC 走位不需要回合。** `Actor:move(x, y, true)` 直接搬；移動動畫是
  `Entity:setMoveAnim`（`E/Entity.lua:567`）在 C 層按幀播的。
- **地圖照樣重繪。** `Map:add` / `Map:remove` 各自呼叫 `updateMap`
  （`E/Map.lua:566, 588`），跟 tick 無關。
- **粒子照樣播。** 也是 display 驅動。

### 1.3 ⚠️ 三個一起處理才算做完

| 要處理的 | 為什麼 | 怎麼做 |
|---|---|---|
| **不要自己設 `game.paused = true`** | 玩家當下若沒能量，引擎不 tick、玩家也永遠拿不回能量 → **直接卡死**，按什麼都沒反應 | 讓引擎自己收斂：`Player:act`（`M/mod/class/Player.lua:415-426`）在玩家有能量且沒輸入時會自己 pause。整段演出頂多吃掉開場不到一個回合 |
| **鎖住輸入** | 沒鎖的話玩家可以在過場動畫裡走路施法，而一動就 `useEnergy` → `paused = false` → 回合開始跑 | 掛一個 dialog（見 §3） |
| **掐掉休息／跑步** | `restStep`/`runStep` 的迴圈（同上 :415-419）會讓引擎持續 tick，是回合暴衝的另一個來源 | 開場 `player:runStop()` + `player:restStop()` |

存檔安全性也順便確認過：`_timers_cb` **不在 `defaultSavedFields` 白名單**裡
（`E/Game.lua:122-131`，`Game:save` 在 `M/mod/class/Game.lua:747` 把它當白名單用），
所以那些閉包不會被序列化。

## 2. 另外兩個承重機制

### 2.1 怎麼讓 NPC 不跑自己的 AI

```lua
-- E/interface/ActorAI.lua:136
function _M:doAI()
    if self.dead or not self.ai then return end
```

**清掉 `actor.ai`，`doAI()` 直接空轉**，NPC 變成不會自己行動的木偶。
演出結束把 `ai` 設回去。

⚠️ **原值要存在 actor 自己身上**（例如 `a.__director_ai_saved`），那樣才會跟著存檔走。
導演物件本身不該被序列化，否則讀檔後狀態機是壞的。

### 2.2 鏡頭

`game.level.map:centerViewAround(x, y)`（`E/Map.lua:864`）、
`moveViewSurround(x, y, mx, my)`（`:872`）。

## 3. 台詞用**原生對話框**，不要往訊息列丟字

第一版把台詞 `game.log` 出去再等一段毫秒。實機回報一句話就否決了：
「台詞這塊照理來說應該要用對話框」。訊息列那行會被戰鬥訊息推走、字級小，
而且**沒有「玩家已經讀完了」這個訊號**——你只能猜他讀多久。

正解是借 ToME 自己的對話框（左右各一張立繪、有邊框）：

```lua
-- M/mod/load.lua:246  →  engine.Chat.chat_dialog = "mod.dialogs.Chat"
local Chat = require "engine.Chat"
local ch = Chat.new("<addon>+_line", npc, game.player, { __director_text = "台詞" })
ch:invoke("line")
```

關鍵是 `Chat.new` 的**第四個參數**：它會成為 chat 檔執行環境的 `__index`
（`E/Chat.lua:51, 61-68`），所以檔案裡直接寫變數名就讀得到。
於是「一句動態台詞」可以用一個通用 chat 檔表達，不必為每句話寫一個檔。

答案**不給 `action` 也不給 `jump`** 時，`E/dialogs/Chat.lua:118-124` 會自己
`unregisterDialog`。續演就靠覆寫該 dialog 實例的 `unload`（`unregisterDialog` 會呼叫它，
`E/Game.lua:475`）——玩家用選答案／Escape／滑鼠關掉都會走到，這點很重要。

範本檔：`self_mods/tome-director/data/chats/_line.lua`。

**副作用是節奏問題自動消失**：演出停在對話框等玩家按鍵，不需要估「停幾毫秒才讀得完」。
不想打斷節奏的環境敘述另開一個 `log` step（只寫訊息列、不阻斷）。

## 4. 輸入鎖與跳過鍵

演出期間一定要有一個 dialog 掛著——它同時是輸入鎖（見 §1.3）與跳過鍵的載體。

### ⚠️ 跳過鍵綁 **Escape**，絕對不要綁 Enter

台詞是對話框，玩家會**連按 Enter 翻頁**。Enter 若也能跳過，那在兩句台詞之間的
走位空檔連按就會把整段演出跳掉。

這也代表**不能用 `Dialog:simplePopup`**：它會塞一顆 focus 在上面的 Close 按鈕
（`E/ui/Dialog.lua:117-119`），於是 Enter 等於 EXIT。要自己搭：

```lua
local d = Dialog.new(title, 1, 1)
d.absolute = true                       -- ★ 見下
d:loadUI{{left=3, top=3, ui=Textzone.new{width=260, auto_height=true, text=hint}}}
d.key:addBind("EXIT", on_skip)          -- 只綁 Escape
d.force_y = 8 - math.min(0, d.frame.oy1 or 0)   -- ★ 見下
d:setupUI(true, true)
game:registerDialog(d)
```

- ⚠️ **`absolute = true` 是必要的。** 非 absolute 的 dialog 會註冊「點畫面任一處就 EXIT」
  的滑鼠區（`E/ui/Dialog.lua:508`），滑鼠隨便一點就把演出跳掉了。
- ⚠️ **`force_y` 定的是內容區的 y，裝飾外框會往上多長 `-frame.oy1`**
  （`E/ui/Dialog.lua:400, 451`）。直接寫 `force_y = 8` 會把外框頂端連標題一起推出畫面，
  實測標題被切掉一半。

## 5. 四個實測踩到的坑

### 5.1 ⚠️ 木偶移動要「自己擋牆 + force」

```lua
-- M/mod/class/Actor.lua:1392
if force or self:enoughEnergy() then
-- E/Actor.lua:243
if not force and map:checkAllEntities(x, y, "block_move", self, true) then return true end
```

- **不帶 `force`**：要求 `enoughEnergy()`。演出期間沒有回合在跑，木偶永遠沒能量 →
  每次都失敗、原地不動。
- **帶 `force`**：跳過 `block_move` 檢查 → **木偶穿牆**。

正解是自己先查地形再 force：

```lua
if not map:checkAllEntities(nx, ny, "block_move", a, true) then a:move(nx, ny, true) end
```

### 5.2 ⚠️⚠️ 走位一定要用 A\*，而且要有**節奏閘門**

實測（trollmire）：天真的「朝目標踏一步」第一步就撞牆，接下來一直原地不動直到超時。
演出要能放在任意地圖上跑就必須真的會繞路。用法抄原版護送 AI
（`M/mod/ai/escort.lua:68-80`）：

```lua
local Astar = require "engine.Astar"
local path = Astar.new(game.level.map, a):calc(a.x, a.y, tx, ty)   -- {{x=,y=}, ...}
```

路徑要快取，**頭節點不再相鄰時重算**（`escort.lua:70`）。

**還有一個一定會遇到的狀況**：要走到「某個 NPC 旁邊」時，目標格被那個 NPC 佔住，
**A\* 直接回 nil**。要改成找目標周圍最近的空格當終點。

⚠️ 改成幀驅動之後多一個坑：**不能每幀走一格**（60fps 下就是一秒 60 格，看起來是瞬移）。
要自己記上一步的時間戳，每 `speed_ms`（實用值 150）才踏一格。

### 5.3 ⚠️ 粒子的 radius 要傳兩次

`particleEmitter(x, y, radius, def, args)` 的第 3 參是 radius，
但粒子檔讀的是 **args 裡的同名鍵**。有些粒子檔沒有預設值
（`local radius = radius`），少傳就拋 Lua Error——實測 `ball_earth` 就是這樣炸的。
完整對照表見
[visuals-and-sounds-parts/01](visuals-and-sounds-parts/01-effects-api-and-pitfalls.md)。

### 5.4 ⚠️ `require "engine.colors"` 會回傳 `true`

那個模組沒有 `return`，Lua 的 `require` 於是回傳 `true`，
接著 `colors.LIGHT_BLUE` 就變成「index a boolean」而崩。
**`colors` 本來就是全域表，不要 require。**

## 6. 其他不能省的事

| 必備 | 為什麼 | 怎麼做 |
|---|---|---|
| **演出中無敵** | 玩家不能動的時候被打死是最糟的體驗 | 進場 `player.invulnerable = (player.invulnerable or 0) + 1`，收場還原 |
| **走位超時** | 地形變動、目標被圍死、A\* 找不到路 | 到時間還沒到就直接 force 瞬移到位並繼續。**寧可醜也不要卡死整段演出** |
| **讀檔殘骸清理** | 演出中途存檔離開 → 木偶的 `ai` 永遠是 nil，那些 NPC 再也不會動 | 掛 `Game:changeLevel` hook 掃全場還原 `__director_ai_saved` |
| **`on_end` 的呼叫順序** | 在 `on_end` 裡接播下一場是劇情最常見的需求 | **先清掉「進行中」旗標，再呼叫 `on_end`**，否則會被「已有演出進行中」擋掉 |

## 7. 怎麼驗證（不看畫面）

`verify.sh` 只能證明定義註冊成功，證明不了演出會跑。做一個**會自我斷言的場景**，
把結果印成可 grep 的行：

```bash
tools/playtest.sh start director --cheat --birth default
tools/playtest.sh probe director_selftest && sleep 24   # 21 項
tools/playtest.sh probe director_say      && sleep 16   # 7 項：台詞對話框
tools/playtest.sh probe director_recovery && sleep 6    # 6 項：模擬讀檔還原
tools/playtest.sh log | grep 'DIRECTOR.TEST\|DIRECTOR.RECOVERY'
tools/playtest.sh probe director                        # 隨時查殘留木偶／粒子／dialogs
```

| 場景／探測 | 項數 | 驗什麼 |
|---|---|---|
| `selftest` | 21 | spawn 是否真的在場上、木偶 ai 是否被清、**每一種步驟是否真的都不吃回合**、`wait` 的真實毫秒是否準、`walk` 是否真的走到（而非瞬移）、超時是否不中斷演出、結束後 ai／無敵／控制權／旗標是否全部還原 |
| `selftest-say` | 7 | 台詞是否真的開出 `mod.dialogs.Chat`、演出是否被阻斷、關掉後是否續演 |
| `director_recovery` | 6 | **模擬讀檔**：把 `D.cur` 清掉再 `restoreAll()`，確認木偶的 ai 真的被還原 |
| `selftest-skip` | 4 | 跳過鍵走**真實 Escape 路徑**，且不該跑到的步驟真的沒跑到 |

★ **`*.no_turn_cost` 那幾項是 §1 那個 bug 的回歸測試**，別為了讓測試好過就放寬它們。
框架自己在收場時也會算總帳：吃掉超過 2 個回合就在 log 印警告。

### ⚠️ `playtest.sh` 自己會把演出跳掉——測試要**延後開演**

`playtest.sh lua`／`probe` 打完 Lua 之後會補一個 **Escape** 去關 Lua console，
而 Escape 正是跳過鍵。實測：馬上開演的話那個 Escape 會打在 blocker dialog 上，
場景在第 10～15 步被跳掉（`19 PASS / 1 FAIL`，唯一的 FAIL 是 `end.reason_finish` 拿到 `skip`）。

解法是**讓探測延後開演**，讓那個 Escape 空砍在沒有演出的畫面上：

```lua
game:registerTimer(6, function() game.director:play("selftest") end)
```

反過來說，這也是驗證「跳過鍵真的有效」最省事的方法——
`selftest-skip` 就是靠 `tools/playtest.sh do <名字> key Escape` 走真實鍵路徑。

（v1 時代這個坑是 Enter 版本的，因為當時跳過鍵是 Enter。換成 Escape 之後
`lua` 收尾的 Return 不再有害，但 Escape 變成新的加害者——**這個坑跟著跳過鍵搬家，不會消失**。）

### ⚠️ 探測程式碼的兩條硬限制

1. **只能用 ASCII**——`playtest.sh` 走 `xdotool type`。
   註解可以寫中文（送出前會被剝掉），**字串字面值不行**。
2. **底線越少越好。** 實測 xdotool 會**間歇性把底線打成空白**：
   `rawget(_G, "__tome_director")` 變成 `rawget(_G, "  tome director")`，
   於是探測讀到 nil、**靜默什麼都不做**——而 DebugConsole 的錯誤只進 console 畫面、
   不進 stdout，連錯誤訊息都看不到，非常難查。

   對策：把入口與所有長欄位名包成短方法，讓探測只按按鈕。
   `tome-director` 為此 superload `Game:run` 掛了 `game.director`
   （`Game:run` 是新開遊戲與讀檔**兩條路都會跑**的地方；`director` 不在存檔白名單所以不會被序列化）：

   ```lua
   game.director:play("demo")     -- 好打，人也用得上
   game.director:report()         -- 狀態報告，取代一堆 __ 欄位存取
   ```

## 8. 照抄範本

`self_mods/tome-director/data/scenes/demo.lua` 是刻意寫給人／agent 照抄的：
一名劍士跑來、說話、野獸破土、斬殺、留話走人。用行內 `entity` 定義生成 NPC，
**不依賴 zone 的 npc_list，任何地圖都能跑**。

step 種類刻意設得少——超出這幾種的敘事寫不出來，設計時就會被逼著把小說語言
轉換成遊戲事件，這是特性不是缺陷。**沒有任何一種會推遊戲回合。**

| step | 阻斷？ | 用途 |
|---|---|---|
| `camera` | 否（零時間）| 鏡頭移到某人／某格 |
| `say` | **是** | 一句台詞，開原生對話框等玩家按鍵 |
| `log` | 否（零時間）| 往訊息列丟一行環境敘述，不打斷節奏 |
| `banner` | 否（`ms`）| 畫面中央大字（章節標題）|
| `wait` | 否（`ms`）| 讓真實時間過去 |
| `walk` | 否（`ms`）| A\* 走到目標，`speed_ms` 控制每格幾毫秒 |
| `spawn` | 否（零時間）| 生一個 actor（`define_as` 或行內 `entity`），落點會自動找可站的格 |
| `puppet` | 否（零時間）| 把既有 NPC 收為木偶 |
| `fx` | 否（零時間）| 放一個粒子 |
| `chat` | **是** | 有分支選項的完整對話，等它關閉才續跑 |
| `fn` | 否（零時間）| 逃生口。**每多一個 fn，這段演出就少一分可被照抄的價值** |
| `release` | — | 提前結束，交還控制權 |
