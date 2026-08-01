NPC 繼承 `Actor`，加上 AI 決策：

```lua
-- game/modules/hellodungeon/class/NPC.lua

require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t, no_default)
    mod.class.Actor.init(self, t, no_default)
    ActorAI.init(self, t)
end

-- NPC 每回合行動
function _M:act()
    if not mod.class.Actor.act(self) then return end

    -- 計算 FOV（NPC 需要知道能看到什麼）
    self:computeFOV(self.sight or 20)

    -- 讓 AI 做決策
    self:doAI()

    -- 若 AI 沒有消耗能量，自動消耗（避免卡住）
    if not self.energy.used then self:useEnergy() end
end

-- 受傷時自動鎖定攻擊者
function _M:onTakeHit(value, src)
    if not self.ai_target.actor and src.targetable then
        self.ai_target.actor = src
    end
    return mod.class.Actor.onTakeHit(self, value, src)
end

-- NPC Tooltip（顯示 AI 目標）
function _M:tooltip()
    return mod.class.Actor.tooltip(self) ..
        ("\n目標: %s\nUID: %d"):format(
            self.ai_target.actor and self.ai_target.actor.name or "無",
            self.uid)
end
```

---
