戰鬥邏輯作為「混入」（mixin）：

```lua
-- game/modules/hellodungeon/class/interface/Combat.lua

require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"

-- 使用 class.make 建立一個純混入（不繼承任何基底）
module(..., package.seeall, class.make)

-- 碰撞處理：根據陣營關係決定攻擊還是交換位置
function _M:bumpInto(target)
    local reaction = self:reactionToward(target)
    if reaction < 0 then
        -- 敵人：攻擊
        return self:attackTarget(target)
    elseif reaction >= 0 then
        -- 友善：嘗試交換位置
        if self.move_others then
            game.level.map:remove(self.x, self.y, Map.ACTOR)
            game.level.map:remove(target.x, target.y, Map.ACTOR)
            game.level.map(self.x, self.y, Map.ACTOR, target)
            game.level.map(target.x, target.y, Map.ACTOR, self)
            self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
        end
    end
end

-- 簡單的攻擊邏輯：力量 + 武器傷害 - 護甲
function _M:attackTarget(target, mult)
    if self.combat then
        local dam = (self.combat.dam or 0) + self:getStr() - target.combat_armor
        DamageType:get(DamageType.PHYSICAL).projector(
            self, target.x, target.y,
            DamageType.PHYSICAL,
            math.max(0, dam)
        )
    end
    self:useEnergy(game.energy_to_act)
end
```

---
