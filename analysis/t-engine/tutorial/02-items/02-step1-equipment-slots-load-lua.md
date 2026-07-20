在 `load.lua` 中，使用 `ActorInventory:defineInventory()` 宣告我們的裝備欄位。這個呼叫必須在任何 Actor 被創建**之前**完成（所以放在 `load.lua` 最前面）。

**為什麼需要 defineInventory？**

`ActorInventory` 只有一個預設槽位：`INVEN`（主揹包，`INVEN_INVEN`）。所有「可穿戴」的槽位（武器欄、防具欄…）都必須手動定義。定義後，引擎會自動產生常數 `INVEN_WEAPON`，所有 Actor 類別都能透過這個常數存取欄位。

```lua
-- game/modules/hellodungeon/load.lua

local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"  -- ← 新增
local Birther = require "engine.Birther"

-- 載入預設按鍵綁定（inventory 包含 g/d/e/i 等背包鍵）
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- 定義裝備欄位
-- 參數：short_name, 顯示名稱, is_worn（true=穿戴時觸發 onWear）, 說明, show_equip
ActorInventory:defineInventory("WEAPON", "主武器", true,
    "主武器欄位，裝備武器以增加攻擊力。", true)

-- 傷害類型、技能、效果、屬性（與教學 01 相同）
DamageType:loadDefinition("/data/damage_types.lua")
ActorTalents:loadDefinition("/data/talents.lua")
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

ActorResource:defineResource(
    "Power", "power",
    nil, "power_regen",
    "能量代表你使用特殊技能的能力。"
)

ActorStats:defineStat("Strength",    "str", 10, 1, 100, "力量：影響近戰傷害。")
ActorStats:defineStat("Dexterity",   "dex", 10, 1, 100, "敏捷：影響命中率。")
ActorStats:defineStat("Constitution","con", 10, 1, 100, "體質：影響最大生命值。")

ActorAI:loadDefinition("/engine/ai/")
Birther:loadDefinition("/data/birth/descriptors.lua")

return { require "mod.class.Game" }
```

**defineInventory 參數說明**：

| 參數 | 說明 |
|------|------|
| `"WEAPON"` | short_name，產生常數 `INVEN_WEAPON`，物品的 `slot` 欄位也要填這個 |
| `"主武器"` | 顯示給玩家看的名稱 |
| `true` | `is_worn = true`：物品加入此槽位時自動呼叫 `onWear()`，應用 `wielder` 加成 |
| `true`（最後一個） | `show_equip = true`：裝備視窗中顯示此欄位 |

---
