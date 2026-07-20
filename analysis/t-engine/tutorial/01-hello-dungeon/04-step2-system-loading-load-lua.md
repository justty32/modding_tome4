`load.lua` 負責初始化所有遊戲系統（屬性、技能、AI 等），並回傳 Game 類別：

```lua
-- game/modules/hellodungeon/load.lua

local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"

-- 載入預設按鍵綁定（移動、快捷鍵、背包、動作、介面、除錯）
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- 載入傷害類型定義
DamageType:loadDefinition("/data/damage_types.lua")

-- 載入技能定義
ActorTalents:loadDefinition("/data/talents.lua")

-- 載入持續效果（Buff/Debuff）定義
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- 定義資源池：Power（能量），用來施展技能
-- 參數：顯示名稱, 內部名稱, 最大值欄位名, 回復速度欄位名, 說明
ActorResource:defineResource(
    "Power", "power",
    nil, "power_regen",
    "能量代表你使用特殊技能的能力。"
)

-- 定義基本屬性
-- 參數：名稱, 縮寫, 預設值, 最小值, 最大值, 說明
ActorStats:defineStat("Strength",    "str", 10, 1, 100,
    "力量：影響近戰傷害與攜帶重量。")
ActorStats:defineStat("Dexterity",   "dex", 10, 1, 100,
    "敏捷：影響命中率、閃避與輕武器傷害。")
ActorStats:defineStat("Constitution","con", 10, 1, 100,
    "體質：影響最大生命值。")

-- 載入引擎內建 AI 腳本
ActorAI:loadDefinition("/engine/ai/")

-- 載入角色創建描述符（職業/種族選擇）
Birther:loadDefinition("/data/birth/descriptors.lua")

-- 最後一行：回傳 Game 類別，這是模組的遊戲入口
return { require "mod.class.Game" }
```

**注意**：
- 路徑 `/data/...` 是**虛擬路徑**，對應模組的 `data/` 目錄
- `return { require "mod.class.Game" }` 是必須的，告訴引擎要用哪個 Game 類別

---
