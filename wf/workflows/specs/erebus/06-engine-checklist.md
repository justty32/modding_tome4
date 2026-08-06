# 06 — 新大陸 addon：引擎層必抄清單

> 給實作 agent 照抄，不是給人讀的百科。只列「漏了會壞、而且是靜默壞掉」的事。
> 唯一資料來源：`docs/knowledge/worldmap-and-zones.md`＋`worldmap-parts/01,02,03`、
> `docs/knowledge/addon-loading.md`、`docs/knowledge/npc-and-chats.md`、
> `docs/knowledge/quests-and-lore.md`、`docs/knowledge/README.md` 的靜默失敗總表，
> 與實例 `self_mods/tome-runeisles/`（新大地圖＋城鎮＋兩個地城＋主線）。
> 本檔只搬運上述文件已寫好的 `檔案:行號`，不新增、不推測、不複驗。

## 1. 必要檔案清單（照 `self_mods/tome-runeisles/` 的實際檔案樹）

| 檔案 | 職責 |
|---|---|
| `init.lua` | addon 宣告：`short_name`／`version`／`weight`／`data = true`／`hooks = true`（不要 `overload` 整張大地圖，理由見 §3） |
| `hooks/load.lua` | 兩個大地圖接點 hook＋lore 的 `loadDefinition`＋selfcheck（§3、§7、§8） |
| `data/maps/worldmap.lua` | 新大地圖本體，純 Lua ASCII，尺寸須精確等於 zone 的 `width`/`height` |
| `data/maps/eyal-portal.lua` | 貼到原版 Eyal 上的那張小 overlay 子地圖（傳送門那一格） |
| `data/maps/towns/stonemark.lua` | 城鎮地圖 |
| `data/zones/worldmap/{zone,grids,npcs,objects,traps}.lua` | 新大地圖本身的 zone（`wilderness=true`） |
| `data/zones/wilderness-add/grids.lua` | 追加到「原版 Eyal」grid_list 的地磚定義（傳送門格），靠 `Entity:loadList` hook 生效 |
| `data/zones/town-stonemark/{zone,grids,npcs,objects,traps}.lua` | 城鎮 zone |
| `data/zones/<dungeon>/{zone,grids,npcs,objects,traps}.lua` | 每座地城各一份（範例有 `stone-circle/`、`unnamed-tomb/`） |
| `data/quests/rune-isles.lua` | 主線 quest 定義，惰性載入，不需 hook |
| `data/lore/lore.lua`、`data/lore/runeisles.lua` | 文獻定義，**必須**在 hook 裡自己 `loadDefinition`（§7） |
| `data/chats/lorekeeper.lua` | NPC 對話檔，`can_talk = "<addon>+<file>"` 即可找到，不需 `overload` |

## 2. `init.lua` 的三個必填地雷欄位

| 欄位 | 缺了會怎樣 | 出處 |
|---|---|---|
| `version` | 與模組 `{1,7,6}` 不相容 → `natural_compatible=false` → addon 被 `table.remove`，**全程沒有任何錯誤訊息** | `addon-loading.md` §3，`E/version.lua:90-97`、`E/Module.lua:390, 595` |
| `weight` | `nil` 會讓 `E/Module.lua:437` 的 `table.sort` 對 nil 比較拋錯，**拖垮使用者所有 addon** | `addon-loading.md` §1、坑清單第 2 條 |
| 資料夾名 `<for_module>-<short_name>` | 前綴不符 → `E/Module.lua:409` 篩選時**靜默忽略**，無錯誤訊息 | `addon-loading.md` §2 |

## 3. 兩個 hook：把新大陸接上 Eyal 的唯一乾淨接點

**不要 `overload` 整份 `data/maps/wilderness/eyal.lua`**——`overload` 是整檔取代，載入順序由 `weight`
決定，兩個都這樣做的 addon 會互相靜默吃掉對方的改動（`worldmap-parts/02-adding-to-eyal.md` §4）。
官方 DLC（orcs）走的是下面這兩個 hook，是加法不是取代。

### 3.1 `Entity:loadList`（`E/Entity.lua:1267`）

原版 grid 清單載完後廣播，把同一個 `res` 表交出來；用同一個 `res` 再載一次自己的檔案就等於 append，
讓 `newEntity{ base="PLAINS" }` 找得到已定義的 `PLAINS`（`E/Entity.lua:1228` 查 `res[t.base]`）。

```lua
class:bindHook("Entity:loadList", function(self, data)
    if data.file ~= "/data/zones/wilderness/grids.lua" then return end
    self:loadList("/data-<short>/zones/wilderness-add/grids.lua",
                  data.no_default, data.res, data.mod, data.loaded)
end)
```
（`worldmap-parts/02-adding-to-eyal.md` §4-1；完整實作見 `self_mods/tome-runeisles/hooks/load.lua:28-31`。）

### 3.2 `MapGeneratorStatic:subgenRegister`（`E/generator/map/Static.lua:696`）

Static 生成器畫完主地圖後廣播，往 `data.list` 塞一筆就會生成一張子地圖並貼上去（`:698-720`）。

```lua
class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
    if data.mapfile ~= "wilderness/eyal" then return end
    data.list[#data.list+1] = { x=22, y=16, w=3, h=3, overlay=true,
        generator = "engine.generator.map.Static",
        data = { map = "<short>+eyal-portal" } }
end)
```
（`worldmap-parts/02-adding-to-eyal.md` §4-2；完整實作見 `self_mods/tome-runeisles/hooks/load.lua:43-51`。）

**留白的關鍵**：子地圖裡沒有 `defineTile` 過的字元，`Static:resolve` 回 nil（`:557`），
`:578` 的 `if g then` 整格跳過；`E/Map.lua:1063` 的 `overlay()` 也只複製有東西的格子。
只要各 addon 的矩形視窗不重疊，就能無限共存（`overlay=true` 走 `Map:overlay`；不加則是
`Map:import`，會整片蓋掉）。（`worldmap-parts/02-adding-to-eyal.md` §4）

**這兩個 hook 檔頂端必須自己 `require`**：`class`、`ActorTalents`、`Birther` 等在
`M/mod/load.lua:60-70` 是 `local` 不是全域，hook 閉包看不到，當全域用會
`attempt to index global 'X' (a nil value)`（`addon-loading.md` §0）。

## 4. 大地圖入口格必要欄位

| 欄位 | 缺了會怎樣 | 出處 |
|---|---|---|
| `change_level` + `change_zone` | 沒有就不是入口，消費點在 `M/mod/class/Game.lua:2277-2292`（CHANGE_LEVEL 鍵） | `worldmap-parts/03-decoration-and-campaign.md` §9 |
| `add_displays`（或 `add_mos`） | **沒有的話那一格在畫面上就只是一片草地／雪地，玩家找不到入口** | 同上；`docs/knowledge/README.md` 靜默失敗表：「大地圖入口格沒給 `add_displays`」 |
| `glow = true` | 沒設就不會替「還沒進去過的入口」加發光標記（`M/mod/class/Grid.lua:38-44` 的 `initGlow`，需要 `change_zone` 且開了 nicer_tiles） | `worldmap-parts/03` §9 |

原版慣例貼圖：傳送門 `terrain/maze_teleport.png`（`wilderness/grids.lua:527`）、
城鎮 `terrain/village_01.png`（`:510`）、地城入口 `terrain/dungeon_entrance02.png`（`:585`）。

⚠️ **走上去不會自動換關**——`mod/class/Player.lua:288-292` 只印一行提示，真正換關要玩家按
`<`／`>`／右鍵。自動化測試要送 `>` 鍵才會觸發（`worldmap-parts/03` 文末「change_level/change_zone
地磚」一節，2026-07-11 實測）。

## 5. zone 必填欄位與 `grids.lua` 缺席的後果

| 欄位 | 缺了會怎樣 |
|---|---|
| `max_level` | **assert 崩潰**（`E/Zone.lua:124`）|
| `width` / `height` | **崩潰**（`E/Map.lua:224` 對 nil 做算術）|
| `generator.map` + `.class` | **崩潰**（`E/Zone.lua:1015-1016` assert）|
| `generator.map.map` 指向不存在的檔 | **崩潰**（`Static.lua:465-473` error）|
| `level_range` | 預設 `{1,1}`，不崩 |
| `generator.actor` / `.object` / `.trap` | 完全可選，沒有 `.class` 就跳過（`E/Zone.lua:1141,1147,1153`）|
| `grids.lua` | 不崩，但 grid_list 是空表 → **整張圖靜默變成空白** |
| `npcs.lua` / `objects.lua` / `traps.lua` | 不崩，清單為空（`E/Entity.lua:1197-1206` 只印警告）|

（表格出處：`worldmap-parts/02-adding-to-eyal.md` §6）

`levels[n]` 是**深合併**進 zone 資料的（`E/Zone.lua:867` 的 `table.merge(res, ..., true)`），
所以 `levels[1] = { generator = { map = { up = "X" } } }` 不會把 `generator.map.class` 洗掉（同 §6）。

### ⚠️ `objects.lua` 空著不等於「用隨機掉落就好」

`E/Zone.lua:176` 只從 zone 自己的 `objects.lua` 建 `self.object_list`，而地板隨機掉落
（`generator.object.Random`）與 NPC 的 `resolvers.equip`/`resolvers.drops`（經
`M/mod/resolvers.lua:105` 的 `game.zone:makeEntity(level, "object", filter)`）**兩條路徑都吃
同一個 `object_list`**。清單空的話兩者都靜默失敗，只在 run.log 印 `[resolveObject] **FAILED**`，
症狀是 NPC 光著手、地上什麼都沒有。除非真的要「這個 zone 一件物品都不該有」，否則一律補：

```lua
load("/data/general/objects/objects-maj-eyal.lua")   -- 抄 town-derth/objects.lua
```
（`worldmap-parts/02-adding-to-eyal.md` §6「⚠️ `objects.lua` 空著 ≠『用隨機掉落就好』」；
同一坑的 NPC 面向見 `npc-and-chats.md` §6，該文件記錄 2026-07-11 在 tome-orario 的實測：
補這行前三個 NPC 全空手，補後長劍／長弓／法杖都正確裝上。）

### ⚠️ `guardian` 預設只在最深那層生成

```lua
-- E/generator/actor/Random.lua:51-56
local glevel = self.zone.max_level
if self.guardian_level then glevel = self.guardian_level end
if self.guardian and self.level.level == glevel then self:generateGuardian(self.guardian) end
```
沒設 `guardian_level`，`guardian` 只會出現在 `zone.max_level` 那一層。想讓 boss 守在第 1 層，
必須明寫 `guardian_level = 1`（`worldmap-parts/02-adding-to-eyal.md` §6）。

## 6. 地城第 1 層上樓梯接回大地圖

`levels[1].generator.map.up = "<你的 grid>"`，那個 grid 帶
`change_level=1, change_zone="<你的大地圖短名>"`。原版同款：
`M/data/zones/norgos-lair/zone.lua:74-78` 的 `ROCKY_UP_WILDERNESS`
（`worldmap-parts/03-decoration-and-campaign.md` §9）。

`self_mods/tome-runeisles/data/zones/unnamed-tomb/zone.lua` 的實作範例：
```lua
levels = {
    [1] = {
        generator = { map = { up = "RI_UP_WORLDMAP" } },
    },
}
```
（因為 `levels[n]` 深合併，這裡只寫 `up` 不會洗掉 `generator.map.class`，見 §5。）

## 7. lore 必須自己 `loadDefinition`

addon 的 `data/` 是私有掛載點（`fs.mount(base.."/data", "/data-"..add.short_name, true)`，
`E/Module.lua:498-503`），**不會**被自動掃描合併進 `/data/`。

quest 與 lore 的載入方式完全不同（`quests-and-lore.md` §1）：

| | quest | lore |
|---|---|---|
| 何時載入 | `grantQuest()` 被呼叫的當下才 `loadfile` | 開機時一次載完（`M/mod/load.lua:111`） |
| addon 要做什麼 | 什麼都不用做，檔案放對路徑就好 | **必須自己再 `loadDefinition` 一次** |

lore 漏了那一步的症狀：NPC 一死觸發 `on_death_lore` 就 nil index。寫法（`quests-and-lore.md` §1）：

```lua
-- hooks/load.lua
local PartyLore = require "mod.class.interface.PartyLore"  -- mod/load.lua 裡是 local，不是全域
class:bindHook("ToME:load", function(self, data)
    PartyLore:loadDefinition("/data-<short>/lore/lore.lua")
end)
```

`on_death_lore` 的 id 對不上也是 nil index，所以 selfcheck 值得直接檢查
`PartyLore.lore_defs["<你的 id>"] ~= nil`（`quests-and-lore.md` §4）。

## 8. selfcheck 怎麼寫才會被 `tools/verify.sh` 判讀

判讀邏輯在 `tools/lua/verdict.lua`：先找 Lua Error（一票否決），再找 addon 自報的
`[<SHORT大寫>] hook complete`（最可信的成功訊號），接著檢查同前綴的
`selfcheck ... = FAIL`（有 FAIL 就算失敗）。完全照抄
`self_mods/tome-runeisles/hooks/load.lua:63-79` 的格式：

```lua
local checks = {
    { "worldmap_zone", fs.exists("/data-runeisles/zones/worldmap/zone.lua") },
    { "worldmap_map", fs.exists("/data-runeisles/maps/worldmap.lua") },
    { "eyal_portal_map", fs.exists("/data-runeisles/maps/eyal-portal.lua") },
    { "wilderness_add", fs.exists(ADD_GRIDS) },
    { "town_zone", fs.exists("/data-runeisles/zones/town-stonemark/zone.lua") },
    { "dungeon_zones", fs.exists("/data-runeisles/zones/stone-circle/zone.lua")
        and fs.exists("/data-runeisles/zones/unnamed-tomb/zone.lua") },
    { "quest", fs.exists("/data-runeisles/quests/rune-isles.lua") },
    { "chat", fs.exists("/data-runeisles/chats/lorekeeper.lua") },
    { "lore", (PartyLore.lore_defs or {})["runeisles-warden"] ~= nil
        and (PartyLore.lore_defs or {})["runeisles-unnamed"] ~= nil },
}
for _, c in ipairs(checks) do
    print(("[RUNEISLES] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
end
print("[RUNEISLES] hook complete")
```

要點（`self_mods/tome-runeisles/hooks/load.lua:53-55` 的註解）：

- 前綴要用 addon 短名的**大寫**（`verdict.lua` 用 `short:upper()` 組 tag）。
- selfcheck 只能查「檔案在不在」「定義有沒有註冊進表」——grid_list 要玩家真的走進大地圖才會建，
  那部分只能靠 `tools/playtest.sh` 走過去看，不是 selfcheck 的職責。
- 最後一定要印 `[<SHORT>] hook complete`，否則 verdict 會退化成「通用判定」，只證明 addon 被引擎
  掃到掛載，不證明內容正確。

## 9. 本主題相關的靜默失敗小表

（原表在 `docs/knowledge/README.md` 的「這個引擎很愛靜默失敗」總表，這裡只挑與
zone／大地圖／NPC 相關的列，一字不改照搬。）

| 你做錯的事 | 症狀 |
|---|---|
| `data/` 底下的定義沒手動 `loadDefinition` | 檔案在，東西不存在 |
| NPC 放在城鎮入口格 | 玩家進不了城，無訊息 |
| 大地圖入口格沒給 `add_displays` | 那格看起來只是普通草地，玩家找不到入口 |
| 把樹/建築這類特徵直接寫在地磚的 `image` | 透明處露出黑底，沒有地面。一格只畫一個 TERRAIN 實體，特徵要疊在 `add_mos` |
| zone 的 `grids.lua` 缺席 | 整張地圖靜默變空白 |
| 靜態地圖某一列長度不對 | **崩潰**（這個不靜默，但錯因離現場很遠）|
| 設了 `wda.script` 但腳本檔不存在 | **崩潰**，且是玩家走第一步的時候才炸 |
| 只在 scratch home 測過，忘了 `deploy.sh` 到真 home | 三層驗證全綠，使用者的遊戲裡什麼都沒有 |
| 用 `require("data.…")` 取自己 addon 的檔 | 私有掛載點不在 `package.path`，一定失敗；包 `pcall` 只印 FAIL 沒有 Lua Error，不包則整個職業靜默消失。`lint.sh` 抓不到 |
