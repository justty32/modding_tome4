# items-and-egos — 物品、神器、ego 詞綴、套裝、掉落

路徑代號見 [README.md](README.md)（`E`=引擎、`M`=ToME 模組、`R`=第三方 addon 前例）。

## 載入管線：addon 怎麼把新物品／新 ego 塞進遊戲

**一切物品清單都走 `loadList`，而 `loadList` 檔尾必廣播 `Entity:loadList` hook（`E/Entity.lua:1267`）。**
這跟 runeisles 往 wilderness 加地磚是同一組接點，物品領域一樣適用：

- zone 載物品：`Zone:loadBaseLists()` → `self.object_class:loadList(getBaseName().."objects.lua")`（`E/Zone.lua:176`）。
  一般 zone 的 `zone.lua` **沒有** `object_list` 欄位；靠 zone 自己的 `objects.lua` 用 `load()` 鏈通用檔。
- 通用物品匯總檔：zone objects.lua → `objects-maj-eyal.lua:25` → `objects.lua`（40 個子檔，`M/data/general/objects/objects.lua:26-88`）。
  `world-artifacts.lua` 在 `objects.lua:85` 被鏈入；`world-artifacts-maj-eyal.lua` 在 `objects-maj-eyal.lua:34`。
- **ego 檔也走同一個 loadList**：基底物品宣告 `egos="/data/general/objects/egos/weapon.lua", egos_chance={...}`
  （例 BASE_LONGSWORD `M/data/general/objects/swords.lua:33`），Zone 在 `getEgosList` 真正載入
  （`E/Zone.lua:360`，`no_default=true`）。所以 hook 一樣會響。

**追加寫法（nullpack 原樣，`R/nullpack/hooks/load.lua:41-57`）：**

```lua
class:bindHook("Entity:loadList", function(self, data)
    if data.file == "/data/general/objects/world-artifacts.lua" then
        self:loadList("/data-<addon>/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
    end
    if data.file == "/data/general/objects/egos/weapon.lua" then
        self:loadList("/data-<addon>/egos-weapon.lua", data.no_default, data.res, data.mod, data.loaded)
    end
end)
```

- `data.file` 是絕對式模組路徑（`"/data/general/objects/egos/weapon.lua"` 這種格式）。
- 一定要原封轉傳 `data.no_default / data.res / data.mod / data.loaded`——同一個 `res` 才是 append 語意
  （`newEntity` 是 `res[#res+1]=e`，`E/Entity.lua:1238`）。ego 載入時 `no_default=true`，轉傳就對。
- 其他前例：necromancy+ 追加 boss-artifacts（`R/necromancy+/hooks/load.lua:24-31`）、
  verdant 追加 world-artifacts（`R/verdant/hooks/load.lua:58-63`）、arcanum 一個 hook 管多檔（`R/arcanum/hooks/load.lua:161-217`）。

**注意**：ego 清單有 per-level 快取（`E/Zone.lua:356-361` `getEntitiesList`/`setEntitiesList`），改完 ego 檔要重開 zone 才會重載。

## artifact 定義欄位速查

武器教學範例 Unstoppable Mauler（`M/data/general/objects/world-artifacts.lua:994-1019`）、
防具範例 Helm of the Dwarven Emperors（同檔 :801-833）：

| 欄位 | 意義 |
|---|---|
| `base` | 繼承基底模板（slot、外觀、攻速由基底來） |
| `define_as` | 具名 ID，供 `makeEntityByName` / set / drops 引用 |
| `unique = true` | 全局只生成一次（見下方掉落節） |
| `unided_name` | 未鑑定顯示名 |
| `rarity` | **沒有 rarity 就永不隨機生成**；數值越小越常見 |
| `material_level` | 材質分層（1-5），影響掉落深度 |
| `power_source` | `{technique=true}` / `{arcane=true}`…，影響 antimagic |
| `combat` | 武器數值；內可放 `talent_on_hit` |
| `wielder` | 穿戴時 `addTemporaryValue` 的屬性表（`M/mod/class/Actor.lua:4633-4638`） |
| `max_power`+`power_regen` | 主動技充能池 |
| `use_talent` | 綁既有天賦當主動技 `{id, level, power}` |
| `use_power` | 自訂函式版主動技 `{name, power, use=fn(self,who)}`，例 Summertide Phial 同檔 :376-386 |

### 觸發欄位（合法鍵集中在 `M/mod/class/Object.lua:45`）

- `combat.talent_on_hit = { [Talents.T_X]={level=N,chance=P} }`——近戰命中觸發（`M/mod/class/interface/Combat.lua:795-802`；crit 版 :804-811）。
- `talent_on_spell`（物件**頂層**，格式是**陣列** `{{chance,talent,level}}`，跟 talent_on_hit 不同）——施法觸發
  （註冊 `M/mod/class/Actor.lua:4649-4655`，觸發 `M/data/damage_types.lua:641-650`；`talent_on_wild_gift`/`talent_on_mind` 對稱）。
- `special_on_hit / special_on_crit / special_on_kill = {desc=_t"...", fct=function(combat, who, target, dam, special)}`
  ——命中／爆擊／擊殺回呼（`M/mod/class/interface/Combat.lua:981-1008`）。

### callback 簽名

`on_wear(self, who, inven_id)`（`M/mod/class/Actor.lua:4630`）、`on_takeoff` 同形（`E/interface/ActorInventory.lua:611`）、
`on_pickup(self, who, num)`（`E/interface/ActorInventory.lua:244`）、`on_drop(self, who)` 回傳 true 可擋丟棄（:352）。

## 物品的美術成本：低到幾乎不用考慮

物品有**兩套互相獨立**的外觀，可以只做其中一套：

| | 欄位 | 是什麼 | 成本 |
|---|---|---|---|
| **圖示** | `image = "object/artifact/xxx.png"` | 背包／地上看到的樣子 | **1 張 64×64** |
| **身上疊圖** | `moddable_tile` | 裝備穿在角色身上畫出來的樣子 | 見下 |

實測 `M/data/gfx/shockbolt/object/artifact/` 共 348 張，**除 1 張外全是 64×64**。
自製 PNG 放 `overload/data/gfx/shockbolt/object/...`，引用寫 `image = "object/..."`
（不含 `shockbolt/`）——規則見 [visuals-and-sounds-parts/02](visuals-and-sounds-parts/02-asset-paths-and-overload.md)。

**身上疊圖多數情況成本是 0**：用 `resolvers.moddable_tile("<27 種 slot 之一>")`
就能重用既有的 per-race 貼圖，還自動依 `material_level` 給五階外觀。
只有要獨一無二外觀的神器才需要 `special/%s_...`，那才是每族一張 × 16 族。
完整清單與判斷方式見 [races-and-tiles.md §3](races-and-tiles.md)。

沒給 `moddable_tile` 的裝備會**靜默不畫疊圖**，功能完全正常（`M/mod/class/Actor.lua:4383-4388`）。

### ego 詞綴**完全不碰貼圖**

`M/data/general/objects/egos/weapon.lua` 全檔沒有 `image` / `add_mos` / `moddable_tile`。
ego 只改：名字前後綴（`name` + `prefix=true` / `suffix=true`）、`wielder` 數值、
`keywords`、`rarity`、`cost`。

→ **新增詞綴的美術成本是 0**，這是內容量產性價比最高的一塊。

## 套裝（set）機制

**偵測邏輯全在 `Actor:onWear`（`M/mod/class/Actor.lua:4549-4626`）／`onTakeoff`（:4754-4788），Object.lua 只負責顯示（`M/mod/class/Object.lua:1280-1288`）。**

- 每件寫 `set_list = { {"define_as","對方ID"}, ... }`＋`set_desc`；集齊時對每件呼叫
  `on_set_complete(self, who, inven_id, set_objects)` 並標 `self.set_complete`（:4605-4622）；破套呼叫 `on_set_broken`（:4758-4760）。
- **只搜已穿戴槽位**（`inven.worn`，:4583-4591）——放背包不算，必須穿上。
- 加成用 `self:specialSetAdd({"wielder","xxx"}, val)`（暫時值，破套自動移除 :4761-4777）。
- 物件自身邏輯可讀 `self.set_complete` 旗標改行為（月/日雙劍 special_on_hit 就是這樣，`world-artifacts.lua:887-895`）。
- 前例：Moon/Star 雙劍互指（:866-971）、Telos 杖上下半一次列兩件（`world-artifacts-maj-eyal.lua:784-793`）、Garkul 護符+頭盔（:320-359）。
- `set_list/on_set_complete/on_set_broken` 已在 `protect_props` 裡（`M/mod/class/GameState.lua:757-758`），clone 不會丟。

## 可成長物品：沒有通用框架，前例是自己改欄位

**標準手法＝`onTakeoff` → 永久改 `o.combat`/`o.wielder` → `onWear`**（wielder 是穿戴時一次性套用，不重穿不生效）：

- Corpathus（`world-artifacts.lua:3392-3497`）：`special_on_kill` 裡
  `findInAllInventoriesBy("define_as","CORPUS")` → onTakeoff → `physcrit+=2`、`combat_critical_power+=4` → onWear（:3411-3420）。
- Morrigor（:3589-3656）：擊殺後把死者的天賦寫進 `o.use_talent` 動態獲得主動技（:3618-3649，只吸一次）。

## 掉落與生成

- **rarity → 機率**：`Zone:computeRarities`（`E/Zone.lua:214`）；必須同時有 `rarity` 與 `level_range` 才進池（:223）；
  機率 = `floor(max / rarity)`（:230）。
- **unique 去重**：`game.uniques[classname.."/"..unique]`，`checkFilter` 擋（`E/Zone.lua:295`）；
  登記在 `Entity:added()`（`E/Entity.lua:806-811`）、移除還原（:817-833）。`makeEntityByName` 對已存在 unique 回 nil，除非帶 `force_unique`（`E/Zone.lua:496-499`）。
- **tome 掉落表 → filter**：`GameState:entityFilterAlter`（`M/mod/class/GameState.lua:1357`；uniques 權重表 :1122-1320）。
- **NPC 掉落**：`resolvers.drops{chance, nb, {defined="X"}}`（`M/mod/resolvers.lua:420`；`defined` 走 makeEntityByName :87-89）。
  boss 前例 `M/data/zones/dreadfell/npcs.lua:60-61`。randart 版 `resolvers.drop_randart`（:488）。
- **商店**：`Store:loadup`（`E/Store.lua:62`）——`filters` 走 makeEntity 隨機進貨（:83）、`fixed`/`defined` 保證上架（:84,:103-104）。
  新物品只要 type/subtype/rarity 對，會被既有商店 filter 自動選中，不必改商店。`not_in_stores` 可擋（:85）。

### 自製商店：hook 載入，機制與原版同一條

商店定義就是一個帶 `store = {...}` 的 `newEntity`。addon 用
`M/mod/class/Store.lua:28` 的 `loadStores` 掛進 `Store.stores_def`——
與原版 `M/mod/load.lua:242` 的 `Store:loadStores("/data/general/stores/basic.lua")` 同機制：

```lua
-- hooks/load.lua，ToME:load 裡
require("mod.class.Store"):loadStores("/data-<addon>/stores/market.lua")
```

擺到地圖上照原版寫法：zone 的 `traps.lua` 放 `BASE_STORE` +
`resolvers.store("DEF_NAME", faction, door, sign)`（抄 `M/data/zones/town-derth/traps.lua`）。

⚠️ **商店是 trap 層的實體，不在 `game.level.entities` 裡。**
要取實體用 `game.level.map(x, y, Map.TRAP)`；
`map:checkEntity(x, y, Map.TRAP, "is_store")` 回傳的是**那個欄位的值**（`true`），不是實體。
（2026-08-01 實測：用 `level.entities` 掃 `is_store` 會得到 0 家店，害你以為商店沒生成。）

### 無頭驗證買賣（繞過模態彈窗）

商店 UI 的購買確認是 `yesnoPopup`，自動化按不到。用底層 API 直接走完整流程：

```lua
local price = store:getObjectPrice(o, "buy")        -- M/mod/class/Store.lua:249
store:onBuy(who, o, idx, 1, true)                   -- :154，before=true
store:transfer(store, who, idx, 1)                  -- E/Store.lua:149
who:incMoney(-price)
store:onBuy(who, o, idx, 1, false)                  -- after
```

賣出反向。實測價格關係：買價約物品 cost 的 1.23–1.35 倍，賣價約 5%（寶石約 40%）。
- **地圖保底**：`game.zone:makeEntityByName(level,"object","X")` + `game.zone:addEntity(level,o,"object",x,y)`
  （前例 `M/data/zones/slazish-fen/zone.lua:108-109`）。

## console 測試（配 playtest.sh --cheat）

```lua
o = game.zone:makeEntityByName(game.level, "object", "MY_DEFINE_AS", true)
game.player:addObject(game.player.INVEN_INVEN, o)
game.zone:addEntity(game.level, o, "object")
```

這正是 debug 對話框 `M/mod/dialogs/debug/CreateItem.lua:259-265` 的內部寫法。
未鑑定會顯示 unided_name——console 補 `o:identify(true)`。
