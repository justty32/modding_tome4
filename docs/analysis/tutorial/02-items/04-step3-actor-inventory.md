`ActorInventory` 是一個**混入（mixin）**，需要加入 Actor 的 `class.inherit()` 列表，並在 `body` 欄位宣告每個揹包欄的最大格數：

```lua
-- game/modules/hellodungeon/class/Actor.lua

require "engine.class"
local Actor = require "engine.Actor"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorFOV = require "engine.interface.ActorFOV"
local ActorInventory = require "engine.interface.ActorInventory"   -- ← 新增

module(..., package.seeall, class.inherit(
    Actor,
    ActorTalents,
    ActorStats,
    ActorResource,
    ActorTemporaryEffects,
    ActorAI,
    ActorFOV,
    ActorInventory      -- ← 新增
))

function _M:init(t, no_default)
    -- 宣告揹包欄位格數
    -- body 在 ActorInventory:init() 中被消耗（轉換為 self.inven 表格），之後設為 nil
    -- 格數決定最多能放幾個「格」的物品（堆疊算一格）
    t.body = t.body or {
        INVEN  = 20,    -- 主揹包：20格
        WEAPON = 1,     -- 武器欄：只有 1 個武器
    }

    Actor.init(self, t, no_default)
    ActorTalents.init(self, t)
    ActorStats.init(self, t)
    ActorResource.init(self, t)
    ActorTemporaryEffects.init(self, t)
    ActorInventory.init(self, t)   -- ← 新增，放在所有 init 的最後
end

--- 每回合的行動（能量驅動）
function _M:act()
    if not Actor.act(self) then return end
    self:timedEffects()
    self:useEnergy()
end

--- 用於戰鬥傷害計算：回傳基礎傷害（後面會擴充為讀取武器）
function _M:combatDamage()
    local dam = self.combat_dam or 5
    -- 若主武器欄有武器，加上武器的 combat_dam 加成
    -- （wielder 系統會自動把 combat_dam 加到 Actor 身上，
    --   所以這裡 self.combat_dam 已包含武器加成）
    return dam
end
```

**為什麼 `body` 在 init 之後就消失？**

`ActorInventory:init()` 會讀取 `self.body`，為每個宣告的槽位建立 `self.inven[id]` 表格，然後把 `self.body` 設為 `nil`（釋放記憶體，也避免存檔時重複初始化）。這是引擎的設計：`body` 是「建構參數」，不是持久狀態。

---
