# crafting-and-imbue — 附魔（鑲嵌）與配方煉製

路徑代號見 [README.md](README.md)。前例：`tome-crafting` addon。

> **2026-08-01 更正**：舊版本檔頭寫「Steamtech 是 DLC、源碼不在 checkout」——已不成立。
> 三包官方 DLC 已解壓到 `D`（`vendor/dlc/`）。Steamtech 製作系統的完整源碼可讀，見 §蒸汽科技。

## 附魔（把寶石鑲入裝備）＝ 造一個 fake ego + `applyEgo`

基礎遊戲的玩家附魔介面就一個：煉金師的 **Imbue Item** 天賦（`M/data/talents/spells/stone-alchemy.lua:109-148`）。
核心三步（可原樣抄，`tome-crafting` 就是放寬版）：

```lua
-- 1) 兩段 showInventory：先挑寶石（filter gem.type=="gem" and gem.imbue_powers），再挑裝備
-- 2) 用寶石的 imbue_powers 造一個 fake ego
local ego = require("engine.Entity").new{
    name = "附魔 "..gem:getName{no_count=true},
    been_imbued = true,                       -- 防重複附魔的旗標
    wielder = table.clone(gem.imbue_powers),  -- 寶石的效果表 → 穿戴加成
    talent_on_spell = gem.talent_on_spell,
    fake_ego = true, unvault_ego = true,
}
-- 3) 套到裝備上
game.zone:applyEgo(o, ego, "object")          -- 引擎 Zone.lua:533
```
- `gem.imbue_powers` 定義在 `M/data/general/objects/gem.lua:77-78`（`newGem` 的 imbue 參數）。
- `been_imbued`／`fake_ego` 影響顯示：`M/mod/class/Object.lua:577-578`。
- 商業版（珠寶商 NPC 對話付費附魔）：`M/data/chats/jewelry-store.lua:20-83`。
- 實測（applyEgo 直接路徑）：gem 的 imbue_powers 併進 armor.wielder、been_imbued=true 成立。
- **UI 是 `talentDialog` 協程 + 巢狀 `showInventory`**（`E/interface/ActorInventory.lua:383-388`，
  等待邏輯 `E/interface/ActorTalents.lua:1248-1281`）——這套是所有「天賦開對話選材料」的共同底層，別自造。

## 配方煉製（材料→產物）通用骨架

基礎遊戲**沒有**通用玩家配方系統（只有任務腳本化的 brotherhood-of-alchemists）。要做鍛造/藥水/煉製，
自己寫這套骨架（`tome-crafting` 的 T_CR_TRANSMUTE 就是最小範例，消耗 3 寶石→產 1 寶石）：

```lua
-- 掃背包湊材料
local inv = self:getInven("INVEN")
local mats = {}
for i, o in ipairs(inv) do if 符合材料條件(o) then mats[#mats+1] = {o=o, i=i} end end
if #mats < 需要數 then 提示不足 return end
-- 產出成品（makeEntity 依關卡等級隨機，或 makeEntityByName 指定）
local out = game.zone:makeEntity(game.level, "object", {type="gem"}, nil, true)
-- 扣材料：★ 從高 index 往低 index 移除，避免 index 位移
for k = 需要數, 1, -1 do self:removeObject(inv, mats[k].i, true) end
out:identify(true); self:addObject(inv, out)
```
- `removeObject(inven, index, no_unstack)`——第 2 參是**背包 index**（不是物件）；
  多次移除務必**降序 index**，否則移掉低位後高位 index 全錯。
- 產出用 `makeEntity`（隨機、依等級）或 `makeEntityByName`（指定 define_as）。
- 鍛造／藥水製作＝同一骨架，只換「材料條件」與「產出物」。參考現成教學
  `docs/analysis/tutorial/10-base-camp-basic.md:483-515` 的 `craft()`。
- transmo 箱（物品→金幣/寶石）是另一個「物品進→產出」範本：`M/mod/class/Actor.lua:8113-8146`。

## 蒸汽科技（Steamtech）製作：最重要的一件事是**它有一半在基礎遊戲裡**

想做「鍛造／鑲嵌／附魔／釀造」這類 WoW 式生產職業，這是最完整的現成範本。
但先搞清楚哪些拿得到、哪些要自己寫：

| 層 | 在哪 | 沒有 DLC 也能用？ |
|---|---|---|
| **裝配槽**（把裝置裝到裝備上） | `M/mod/class/Object.lua:2565-2577`、`M/mod/class/Actor.lua:8168-8300` | ✅ **基礎遊戲** |
| **材料倉庫**（reagent bank） | `M/mod/class/interface/PartyIngredients.lua:25-120` | ✅ **基礎遊戲** |
| **配方系統**（`newRecipe`、學圖紙、做出東西） | `D/tome-orcs/overload/mod/class/interface/PartyTinker.lua`（**只有 175 行**） | ❌ DLC，但短到可以自己重寫 |
| **製作 UI** | `D/tome-orcs/overload/mod/dialogs/CreateTinker.lua`（284 行） | ❌ 同上 |
| 配方／裝置內容 | `D/tome-orcs/data/tinkers/*.lua`、`data/general/objects/tinkers/*.lua`（六類） | ❌ DLC 內容 |

> **結論**：不能依賴玩家裝了 DLC，但**槽位與材料兩套底層是白拿的**，
> 只要自己補一層 175 行的配方層即可。DLC 那份是 GPL，可照抄結構。

### 1. 裝配槽（＝WoW 的鑲嵌／附魔），基礎遊戲原生

裝置物件（`D/tome-orcs/data/general/objects/tinker.lua:23-35` 的 `BASE_TINKER`）靠這些欄位描述「我能裝在什麼上面」：

| 欄位 | 檢查處 | 語意 |
|---|---|---|
| `is_tinker = "<種類>"` | `Object.lua:2570`、`Actor.lua:8170` | **裝置種類字串，可以自訂** |
| `on_type` / `on_subtype` | `Object.lua:2571-2572` | 限定物品 type/subtype（如 `weapon`/`longsword`）|
| `on_slot` | `Object.lua:2573` | 限定裝備欄位 |
| `on_special(self, base_o, who)` | `Actor.lua:8233` | 任意自訂條件 |
| `object_tinker = {...}` | `Actor.lua:8257-8260` | **實際加成**，逐鍵 `addTemporaryValue` 到底材上 |
| `on_tinker` / `on_untinker` | `Actor.lua:8255, 8190` | 回傳真值＝**拒絕**裝配（`forbid`） |

底材端：`self.tinker` 存已裝的裝置（一件只能一個，`Object.lua:2574`）；`forbid_tinkers` 可整個禁止（`:2575`）。

**角色端的閘門是 `can_tinker`**：

```lua
-- M/mod/class/Actor.lua:8169-8170
if not self.can_tinker then return nil, "can not use attachments" end
if not self.can_tinker[tinker.is_tinker] then return nil, "can not use attachments of this type" end
```

它是一張**任意 key 的表**，由天賦的 `on_learn` 掛上去（`D/tome-orcs/data/talents/steam/other.lua:128-135`）。
→ **每個生產職業可以是自己一種 `is_tinker`**：`can_tinker = {runeforge=1}` 配 `is_tinker = "runeforge"`，
互不干擾，也不會誤裝到蒸汽零件上。這就是做多套生產職業的天然分界。

順帶：`can_tinker` 一設，背包會自動多一個「裝置」分頁（`M/mod/load.lua:256`），
角色卡與裝備畫面也會自動顯示子物件（`M/mod/dialogs/CharacterSheet.lua:157`、`ShowEquipInven.lua:63`）。**UI 白拿。**

回呼：`callbackOnWearTinker` / `callbackOnTakeoffTinker`（`M/mod/class/Actor.lua:6086-6087`）。

### 2. 材料倉庫（＝WoW 的材料銀行），基礎遊戲原生

`M/mod/class/interface/PartyIngredients.lua`。掛在 **party 上，不是 actor**。

```lua
newIngredient{ id=..., name=..., desc=..., icon=..., min=..., max=... }  -- :43-56，六個都 assert
game.party:collectIngredient(id, nb, silent)   -- :72   取得（自動夾在 min/max）
game.party:hasIngredient(id, nb)               -- :94   檢查
game.party:useIngredient(id, nb)               -- :106  扣除
```

- `max = INFINITY`（`-1`，`:27`）＝無上限；`min = INFINITY` ＝**一旦取得就永久擁有**（適合「已學會的知識」）。
- 有 hook：`PartyIngredients:collectIngredient`（`:89`），可以掛「採集到材料時…」。

比 §配方煉製 那套「掃背包湊材料」乾淨得多——**材料不佔背包格**，這正是 WoW 生產職業的手感。

### 3. 配方層（要自己重寫的那 175 行）

`D/tome-orcs/overload/mod/class/interface/PartyTinker.lua`。同樣掛 party。

```lua
newRecipe{                                     -- :43-57，四個 assert：id/name/desc/icon
  id = "STEAMSAW", name = ..., icon = ..., desc = ...,
  base_ml = 1, max_ml = 5,                     -- 材料等級（tier）上下限，:74-75
  talents = { T_SMITH = 2, T_MECHANICAL = 1 }, -- 天賦等級門檻，:77-79
  ingredients = { LUMP_ORE = 7 },              -- 吃材料倉庫，:81-83
  items = { ... },                             -- 吃背包裡的實體物品（比對 define_as），:86-90
  special = {{desc=..., cond=function(tdef, party, actor) ... end}},  -- 任意條件，:92-94
  create = function(tdef, party, actor, ml, silent, onend) ... end,   -- 自訂產出，:132-133
}
```

沒給 `create` 就走預設路徑：按 `"TINKER_"..id..ml` 從物品清單 `makeEntityByName` 產出（`:108-110, 136`）。
`ml` 會**接在 id 後面**當後綴查找，材料也是先找 `ING..ml` 再退回 `ING`（`:82, 89, 115-116`）——
這是 tier 分級的實作方式，一個配方自然長出五個等級的產物。

學配方＝`game.party:learnTinker(id)`（`:168-175`），存在 `party.known_tinkers`。
圖紙物品範本在 `D/tome-orcs/data/general/objects/schematics.lua:21-61`：
`use_simple` 讀了就學會並銷毀，`on_prepickup` 讓已知圖紙不重複撿。
`random_schematic = {level, rarity, cost}` 讓配方自動進隨機掉落池（`:65-84`）。

### 4. 對照 WoW 生產職業

| WoW | 對應到什麼 | 現成度 |
|---|---|---|
| 附魔 / 鑲嵌 | 裝配槽（`object_tinker` 加成） | 底層全有，只要寫裝置內容 |
| 鍛造（打造裝備） | `create` 自訂函式，看 `STEAMSAW`（`D/tome-orcs/data/tinkers/smith.lua:3-45`）——它**吃掉一把武器改造成另一把、還保留原 ego** | 有完整範本 |
| 煉金 / 釀造（消耗品） | 預設產出路徑即可，不必寫 `create` | 最簡單 |
| 採集（礦、草藥） | `collectIngredient` + zone 物件 | 底層有，採集點要自己做 |
| 學配方 | 圖紙物品 + `learnTinker` | 有範本 |
| 專精分支 | `talents` 門檻 + `can_tinker` 種類 | 有 |

### 5. 坑

1. **一件裝備只能裝一個裝置**（`Object.lua:2574`）。要多槽位得自己改 superload。
2. `object_tinker` 是 `addTemporaryValue`，卸下時靠 `oldo.tinkered` 記錄的 id 還原（`Actor.lua:8191-8197`）。
   **自己寫類似機制務必成對**，否則加成會永久疊加。
3. 裝配預設**消耗一個回合**（`Actor.lua:8275-8278`），除非 actor 有 `free_tinker_attach`。
4. `PartyTinker.lua:152, 156` 留著 DarkGod 的 debug `print`（`"!!aazdazdazd!!!"`）——照抄時記得刪。
5. 材料倉庫在 **party**，不是 actor。單人也一樣走 `game.party:`。

## 全職業可用

同 [companions-and-party.md](companions-and-party.md)：`ToME:birthDone` hook 教一個 `no_energy`、
不設 mana 的天賦給每個新角色，任何職業都能用、且好測。
