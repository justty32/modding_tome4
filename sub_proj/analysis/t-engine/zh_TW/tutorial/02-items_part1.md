# 教學 02：物品系統

> **目標**：為 hellodungeon 模組加入完整物品系統——撿拾武器/藥水、裝備增傷、飲藥回血、怪物掉落。
>
> **前置**：教學 01 之 hellodungeon 可正常執行。

---

## 1. 系統架構

TE4 物品系統四大核心：

```
ActorInventory（背包界面）
  ├── INVEN（主背包，無限格）
  └── WEAPON 等裝備槽（穿上生效）

engine.Object（物品實體）
  ├── slot        → 對應 defineInventory 之 short_name
  ├── wielder     → 裝備後臨時屬性加成
  ├── use_simple  → 使用效果（消耗品）
  └── stacking    → 是否可堆疊

Zone.object_list（物品資料庫）
  └── 自 data/zones/<zone>/objects.lua 載入

generator.object（地圖生成器）
  └── engine.generator.object.Random → 隨機散落
```

資料流向：

```
load.lua
  → defineInventory               （定義槽位）
  → Object:loadDefinition         （載入原型）

zone.lua
  → object_class = "mod.class.Object"
  → generator.object.class = "engine.generator.object.Random"

Actor:init → body = { INVEN=20, WEAPON=1 }

按鍵 g → Actor:pickupFloor()
按鍵 e/w → Actor:wearObject()     （自動 onWear → 套用 wielder）
按鍵 d → Actor:dropFloor()
```

---

## 2. 定義裝備欄位（load.lua）

`ActorInventory` 僅有預設 `INVEN`。所有可穿戴槽位須以 `defineInventory()` 宣告，產生常數 `INVEN_WEAPON`。

```lua
-- game/modules/hellodungeon/load.lua

local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"  -- 新增
local Birther = require "engine.Birther"

KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- defineInventory(short_name, 顯示名, is_worn, 說明, show_equip)
ActorInventory:defineInventory("WEAPON", "主武器", true,
    "主武器欄位，裝備武器以增加攻擊力。", true)

DamageType:loadDefinition("/data/damage_types.lua")
ActorTalents:loadDefinition("/data/talents.lua")
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

ActorResource:defineResource("Power", "power", nil, "power_regen",
    "能量代表你使用特殊技能的能力。")

ActorStats:defineStat("Strength",    "str", 10, 1, 100, "力量：影響近戰傷害。")
ActorStats:defineStat("Dexterity",   "dex", 10, 1, 100, "敏捷：影響命中率。")
ActorStats:defineStat("Constitution","con", 10, 1, 100, "體質：影響最大生命值。")

ActorAI:loadDefinition("/engine/ai/")
Birther:loadDefinition("/data/birth/descriptors.lua")

return { require "mod.class.Game" }
```

### `defineInventory` 參數

| 參數 | 意義 |
|------|------|
| `"WEAPON"` | short_name，產生 `INVEN_WEAPON`；物品 `slot` 須與此一致 |
| `true` (is_worn) | 物品加入槽位時自動呼叫 `onWear()`，套用 `wielder` 加成 |
| `true` (show_equip) | 裝備視窗中顯示此欄位 |
