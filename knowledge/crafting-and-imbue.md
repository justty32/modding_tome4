# crafting-and-imbue — 附魔（鑲嵌）與配方煉製

路徑代號見 [README.md](README.md)。前例：`tome-crafting` addon。
註：蒸氣工匠(Steamtech)機械製作是 DLC，本機未安裝、源碼不在 checkout；以下全為**基礎遊戲**機制。

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
  `sub_proj/analysis/t-engine/tutorial/10-base-camp-basic.md:483-515` 的 `craft()`。
- transmo 箱（物品→金幣/寶石）是另一個「物品進→產出」範本：`M/mod/class/Actor.lua:8113-8146`。

## 全職業可用

同 [companions-and-party.md](companions-and-party.md)：`ToME:birthDone` hook 教一個 `no_energy`、
不設 mana 的天賦給每個新角色，任何職業都能用、且好測。
