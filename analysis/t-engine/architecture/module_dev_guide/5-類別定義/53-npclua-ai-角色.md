### 5.3 NPC.lua — AI 角色

```lua
require "engine.class"
require "mod.class.Actor"
require "engine.interface.ActorAI"

module(..., package.seeall, class.inherit(
    mod.class.Actor,
    engine.interface.ActorAI
))

function _M:init(t, no_default)
    mod.class.Actor.init(self, t, no_default)
    engine.interface.ActorAI.init(self, t, no_default)
end

function _M:act()
    if not mod.class.Actor.act(self) then return false end

    -- 計算視野
    self:computeFOV(self.sight or 20)
    -- 執行 AI 決策
    self:doAI()
end

-- 受傷時鎖定攻擊者為目標
function _M:onTakeHit(value, src)
    if src and src.player then
        self.ai_target.actor = src
    end
    return value
end
```

