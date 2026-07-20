`load.lua` 負責在遊戲開始前載入所有定義（傷害、技能、效果等），最後回傳 Game 類別。

```lua
-- game/modules/mymod/load.lua

-- 引入引擎元件
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local Birther = require "engine.Birther"

-- 1. 載入鍵位綁定（引擎內建組合）
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- 2. 載入遊戲資料定義
DamageType:loadDefinition("/data/damage_types.lua")
ActorTalents:loadDefinition("/data/talents.lua")
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- 3. 定義角色資源（自訂的 MP、怒氣、能量…）
ActorResource:defineResource("Power", "power", nil, "power_regen",
    "Power is used to fuel special talents.")

-- 4. 定義角色屬性
ActorStats:defineStat("Strength",     "str", 10, 1, 100, "Physical power")
ActorStats:defineStat("Dexterity",    "dex", 10, 1, 100, "Agility")
ActorStats:defineStat("Constitution",  "con", 10, 1, 100, "Health")

-- 5. 載入 AI 行為定義（使用引擎內建 AI）
ActorAI:loadDefinition("/engine/ai/")

-- 6. 載入角色創建描述
Birther:loadDefinition("/data/birth/descriptors.lua")

-- 7. 若為即時制，啟用即時模式
-- core.game.setRealtime(20)  -- 每秒 20 tick

-- 8. 回傳 Game 類別（引擎會呼叫 Game.new()）
return { require "mod.class.Game" }
```

---
