# 狀態探測（不用滑鼠鍵盤，只拿純文字）

> **這些手法都已經固化成 `tools/probes/*.lua`，日常用 `tools/playtest.sh probe <名字>` 就好**
> （`probe --list` 看清單，它會自動把輸出撈回來）。
> 本檔保留每一則的**原理、實測輸出與踩過的坑**——要寫新探測或除錯時讀這裡。
> 寫新探測的格式規矩在 `tools/README.md`。

> 目標版本 **ToME 1.7.6**，Linux / Manjaro。本檔每一則都在 2026-08-01 實測跑過，輸出照抄。
> 前置：`tools/playtest.sh start <addon> --cheat`（沒有 `--cheat` 就沒有 Lua console）。

## 為什麼要有這一層

`do click/key` + 截圖判讀有兩個問題：**貴**（圖片吃 token）與**弱**（看得到的只有畫面上有的東西）。
Lua console 這條路回傳的是純文字，而且能讀到畫面上根本不顯示的內部欄位。

**分工鐵律**：AI 要的狀態一律走本檔的探測；截圖只在要給使用者看時才產生，
**畫面好不好看、手感對不對，由使用者判斷，AI 不自己讀圖**。

```
AI 負責：程式化操控 + 純文字狀態斷言   ← 本檔
人 負責：畫面、渲染、手感、平衡         ← 截圖給使用者看
```

## 通用限制（`cmd_lua` 的硬性約束）

| 限制 | 原因 | 對策 |
|---|---|---|
| **只能一行** | `xdotool type` 不吃換行 | 用 `local x=1 local y=2` 串接，不要分號亂用 |
| **輸入只能 ASCII** | 中文送不進去，該行會靜默消失 | 要比對中文就用 `a.name=="large white snake"` 這種內部英文名；要印中文讓 addon 自己 print |
| **回傳值不進 stdout** | `E/DebugConsole.lua:140-151` 只寫 console history | **一定要自己 `print()`**，再用 `playtest.sh log '<regex>'` 撈 |
| 一次呼叫約 10–15 秒 | console 開啟 + sentinel 等待 + 軟體 GL | 一次 probe 盡量問完，不要拆成很多次 |

輸出**可以**是中文（`print` 走 stdout 進 `run.log`，UTF-8 沒問題），只有輸入受限。

慣例：每則 probe 都加自己的標籤前綴（`[T]` / `[MAP]` / `[ATK]`…），方便 `log` 用 regex 撈。

## 1. 我是誰、我在哪

```bash
tools/playtest.sh lua 'local p=game.player print("[T] zone="..tostring(game.zone and game.zone.short_name).." lev="..tostring(game.level and game.level.level).." pos="..p.x..","..p.y.." turn="..game.turn.." hp="..math.floor(p.life).."/"..math.floor(p.max_life).." unspent_tal="..tostring(p.unused_talents).." gen="..tostring(p.unused_generics))'
tools/playtest.sh log '\[T\]'
```

```
[T] zone=trollmire lev=1 pos=0,26 turn=0 hp=132/132 unspent_tal=2 gen=2
```

也是最好用的「我現在到底在哪個畫面」判斷：`game.level` 是 nil 就代表還沒進遊戲。

## 2. 讀地圖（ASCII 化）

`game.level.map` 是 `engine.Map` 實例，常數（`ACTOR` / `TERRAIN` / `OBJECT` / `TRAP`）
可直接從實例取，**不需要 `require "engine.Map"`**。

```bash
tools/playtest.sh lua 'local p=game.player local m=game.level.map local s="" for j=p.y-4,p.y+4 do local r="" for i=p.x-4,p.x+4 do local a=m(i,j,m.ACTOR) local t=m(i,j,m.TERRAIN) local c="." if not t then c="?" elseif t.does_block_move then c="#" end if a then c=(a==p) and "@" or "M" end r=r..c end s=s..r.."/" end print("[MAP] "..s)'
tools/playtest.sh log '\[MAP\]'
```

```
[MAP] ????#..##/????...#./????###.#/????##..#/????@#.##/????....#/????#..../????.#..#/????..#../
```

`/` 分行，`?` = 出界，`#` = 阻擋移動，`.` = 可走，`@` = 玩家，`M` = 其他生物。
上例玩家在 `x=0`，所以左側四欄出界。

⚠️ 撈的時候 `[MAP]` 會混到引擎自己的 `Reseting tiles caches`（它也被歸到同前綴的行），
用 `tail -1` 或換個更獨特的前綴。

## 3. 關卡上有哪些生物

```bash
tools/playtest.sh lua 'local p=game.player local n=0 local s="" for _,a in pairs(game.level.entities) do if a.life and a~=p then n=n+1 local d=math.max(math.abs(a.x-p.x),math.abs(a.y-p.y)) if n<=8 then s=s..a.name.."@"..a.x..","..a.y.." hp"..math.floor(a.life).." d"..d.." | " end end end print("[ACT] total="..n.." :: "..s)'
```

```
[ACT] total=25 :: giant eel@38,11 hp32 d38 | red ooze@42,24 hp7 d42 | forest troll@53,19 hp100 d53 | large white snake@9,19 hp8 d9 | ...
```

`game.level.entities` 含非生物實體，用 `a.life` 過濾出 actor。
**注意 `a.name` 這裡是英文**（未經 `_t()`），所以可以安全地拿來字串比對——
這正是 runewright 那個 bug 的反面教材：`t.name`（天賦名）是翻譯過的，不能比對。

## 4. 讀天賦

```bash
tools/playtest.sh lua 'local p=game.player local s="" local n=0 for tid,lev in pairs(p.talents) do n=n+1 if n<=12 then s=s..tid.."="..lev.." " end end print("[TAL] n="..n.." unused_tal="..tostring(p.unused_talents).." unused_gen="..tostring(p.unused_generics).." :: "..s)'
```

```
[TAL] n=10 unused_tal=2 unused_gen=2 :: T_WEAPON_COMBAT=1 T_ATTACK=1 T_INFUSION:_HEALING_3=1 T_WARSHOUT_BERSERKER=1 T_STAMINA_POOL=1 ...
```

驗自訂職業的起手天賦、驗 `unlockTalents`、驗天賦等級縮放，都從這裡開始。

## 5. 配點（不用點圖示）

升級畫面用滑鼠點圖示很脆（座標隨語系/解析度浮動）。直接學：

```bash
tools/playtest.sh lua 'local p=game.player local before=p:getTalentLevelRaw(p.T_WEAPONS_MASTERY) p:learnTalent(p.T_WEAPONS_MASTERY,true) p.unused_talents=p.unused_talents-1 print("[LEARN] weapons_mastery "..before.." -> "..p:getTalentLevelRaw(p.T_WEAPONS_MASTERY).." unused_tal="..p.unused_talents)'
```

```
[LEARN] weapons_mastery 1 -> 2 unused_tal=1
```

- `learnTalent(tid, force)` 的 `force=true` 會跳過前置需求檢查——**要驗前置條件本身時別給 force**。
- `learnTalent` **不會**自動扣 `unused_talents`，要自己扣，否則後面的點數斷言會對不上。
- 天賦 id 用 `p.T_XXX`（actor 上有這些常數），不必寫字串。

## 6. 操控角色移動

```bash
tools/playtest.sh lua 'local p=game.player for _,a in pairs(game.level.entities) do if a.name=="large white snake" then p:move(a.x-1,a.y,true) print("[MOVE] player now "..p.x..","..p.y.." / target "..a.name.." @"..a.x..","..a.y.." hp"..math.floor(a.life)) break end end'
```

```
[MOVE] player now 8,19 / target large white snake @9,19 hp8
```

`move(x, y, force)` 的 `force=true` 是**瞬移**（跳過地形與耗時檢查），拿來快速擺位很方便；
要驗「移動本身」的規則（阻擋、陷阱觸發、耗時）就**不要**給 force。

## 7. 觀察「這一回合發生了什麼」（最重要的一則）

把 `game.log` 攔截、鏡射到 stdout。裝上之後，**遊戲內每一條訊息都自動變成純文字進 `run.log`**：

```bash
tools/playtest.sh lua 'if not game._ol then game._ol=game.log game.log=function(...) local t={} for i=1,select("#",...) do t[#t+1]=tostring((select(i,...))) end print("[LOG] "..table.concat(t," ")) return game._ol(...) end print("[HOOK] game.log patched") end'
```

`if not game._ol` 的 guard 是必要的——重複套用會疊成遞迴。

裝好後做動作，然後一次撈：

```bash
tools/playtest.sh lua 'local p=game.player local tg for _,a in pairs(game.level.entities) do if a.name=="large white snake" then tg=a break end end print("[ATK] pre hp="..math.floor(tg.life).." turn="..game.turn) p:attackTarget(tg) print("[ATK] post hp="..math.floor(tg.life).." dead="..tostring(tg.dead).." turn="..game.turn)'
tools/playtest.sh log '\[ATK\]|\[LOG\]'
```

```
[ATK] pre hp=8 turn=0
[ATK] post hp=-34 dead=true turn=0
[LOG]	#UID:3231:0##fbd578#player#LAST#擊中巨型白蛇造成#WHITE#42 物理#LAST#傷害。
[LOG]	#{bold}##UID:3231:0##fbd578#player#LAST#擊殺了巨型白蛇!#{normal}#
[LOG] Game Turn %d 9
[LOG]	遊戲回合 9
```

讀得到：命中、**傷害數字與傷害類型**、擊殺、回合推進。這就是「AI 自己觀察該回合結果」的完整能力。

幾個要知道的：

- 訊息含 `#COLOR#` / `#{bold}#` / `#UID:...#` 標記，做斷言時記得先剝掉或用 `string.find` 抓片段。
- 每條訊息常出現兩次：一次是原始 format 字串（`Game Turn %d 9`），一次是翻譯後的成品（`遊戲回合 9`）。
- `attackTarget` 是同步的，所以 pre/post 可以寫在同一行。**但 `p:move()` 之後的 AI 反應不是**
  ——怪物的回合要等遊戲主迴圈跑，得隔一次呼叫再撈 log。
- `game.turn` 在同一行內不會變（回合結算在主迴圈），要看回合推進得看 `[LOG] 遊戲回合 N`。

同樣的 patch 手法可以套在任何函式上，用來抓 addon 自己的呼叫時序：

```bash
tools/playtest.sh lua 'local f=SomeClass.someMethod SomeClass.someMethod=function(s,...) print("[SPY] someMethod called") return f(s,...) end'
```

## 8. 其他有用的一行

```bash
# 直接殺光 unique，驗 on_die 掛的任務推進（跟玩家砍死走同一條路徑，E/interface/ActorLife.lua:91）
tools/playtest.sh lua 'for _,e in pairs(game.level.entities) do if e.unique then e:die(game.player) end end'

# 換關
tools/playtest.sh lua 'game:changeLevel(2, "myaddon+myzone")'

# 給任務
tools/playtest.sh lua 'game.player:grantQuest("myaddon+myquest")'

# 施放新學的天賦（快捷鍵只綁 1-5，slot 6+ 鍵盤按不到，只能走這條）
tools/playtest.sh lua 'game.player:useTalent(game.player.T_你的天賦短名)'
```

## 0. 建角也不用滑鼠：`--birth`

```bash
tools/playtest.sh start tome-xxx --cheat --birth default
tools/playtest.sh start tome-xxx --cheat --birth Elf/Shalore/Mage/Archmage
```

直接停在**遊戲內**（不是建角畫面），`playtest.sh lua` 立刻可用。實測輸出：

```
[OK] autobirth 已設定：Shalore Archmage
[OK] 已自動建角（Shalore Archmage）並進入遊戲。
[V2] Shalore/Archmage hp=90 mana=130 talents=13 :: T_LIGHTNING T_COMMAND_STAFF T_MANATHRUST T_SHALOREN_SPEED ...
```

格式是 `<race>/<subrace>/<class>/<subclass>`，**一律用 birth descriptor 的英文原名**
（`_t()` 翻譯前；descriptor 定義在 `M/data/birth/`）。打錯字不會靜默失敗——
夾具會印 `missing=<欄位>` 並停在建角畫面讓你看。

### 它是怎麼做到的

`mods/tome-autobirth/` 是**開發用測試夾具 addon**（superload `mod/dialogs/Birther.lua`），
由 `--birth` 自動加掛，並把規格寫進 `<scratch home>/4.0/autobirth.lua`。
沒有那個規格檔就完全 no-op，所以誤裝到真實遊戲也不會有事。**它永遠不進 `dist/`。**

為什麼非得用 addon 而不是 Lua console：

- **建角對話框會吃掉所有鍵盤事件**，`ctrl+L` 在那個畫面進不去（實測 `playtest.sh lua`
  在建角畫面直接 FAIL：「Lua console 沒拿到焦點」）。建角完成前沒有任何程式化入口，
  這是整條無頭鏈唯一的斷點，只能從模組內部解。
- 引擎的 `__module_extra_info.auto_birth`（`E/Birther.lua:335`）**對 ToME 無效**——
  ToME 用自訂 GUI birther，把引擎的 `selectType`/`updateList` 覆寫成空函式
  （`M/mod/dialogs/Birther.lua:1140-1141`），那條清單流程根本不會跑。
- 而且 `__module_extra_info` 只能透過 `core.game.reboot()` 的第 6 個參數灌進去
  （`game/loader/init.lua:32-38` 用 `loadstring` + `setfenv`），命令列沒有對應開關——
  C 層只吃 `--home --no-steam --no-web --flush-stdout --no-debug --safe-mode --xpos/--ypos --logtofile`。

夾具的做法抄原版自己的 `makeDefault()`（`M/mod/dialogs/Birther.lua:392`，
註解就寫著 *"Make a default character when using cheat mode, for easier testing"*）：
設好全部 descriptor 再 `atEnd("created")`。但原版那支**有 bug 不能直接用**：

| 原版 `makeDefault` 的問題 | 夾具怎麼處理 |
|---|---|
| 漏設 `order` 裡的 `"base"`，於是 `setDescriptor` 算出的 `ok=false`，`c_ok` 保持 hidden，`atEnd` 第一行 `not self.ui_by_ui[self.c_ok].hidden`（`:306`）直接擋掉 | 照 `self.order` 逐項設，含 `base`（`M/data/birth/descriptors.lua:32-33`，name 就叫 `"base"`） |
| 寫死 Cornac Berserker | 從規格檔讀，才能測自訂職業 |
| 綁在名字輸入框的 Enter（`:104`），要先讓那個框拿到焦點 | 掛在 `on_register`，不需要任何按鍵 |
| `atEnd` 會 `unregisterDialog(self)`，在 `on_register` 執行中做很危險 | 用 `game:onTickEnd()` 延到本 tick 結束 |

實測踩到的：按 Enter 觸發 `makeDefault` 後**紙娃娃會變成女性人類拿雙手劍、但 birth 不會完成**
（`run.log` 沒有 `[PLAYER BIRTH] resolved`）——就是上表第一列那個 `base` 漏設。

`no_birth_popup = true` 同時跳過升級對話框與開場劇情（`M/mod/class/Game.lua:341,345`），
所以 `--birth` 之後不需要再按任何 Return。

⚠️ `tools/verify.sh tome-autobirth` **不適用**——夾具沒有 hook、不會印 `hook complete`。
它的驗證方式就是拿它跑一次 `--birth`。

## 建議的測試骨架

```bash
tools/playtest.sh start tome-xxx --cheat --birth <race>/<subrace>/<class>/<subclass>
tools/playtest.sh probe logmirror             # 先裝，之後每條遊戲訊息都變純文字
tools/playtest.sh probe actors                # 看有什麼目標
tools/playtest.sh probe attack "<生物名>"      # 動手，自動撈回結果
tools/playtest.sh shot result                 # ← 截圖交給使用者判讀
tools/playtest.sh stop
```

臨時查東西才用 `playtest.sh lua '<一行>'`；**會重複用的手法一律寫成 probe**——
probe 可以正常排版、寫中文註解，而且壓平器會先幫你擋掉非 ASCII 與語法錯誤，
不會像手打那樣「送進去卻靜默沒有輸出」。

整條鏈現在**完全不需要滑鼠座標**，也就不再受語系/解析度影響。
（`01-why-and-usage.md` 的建角座標表只在不加 `--birth`、要手動走 UI 時才需要。）
