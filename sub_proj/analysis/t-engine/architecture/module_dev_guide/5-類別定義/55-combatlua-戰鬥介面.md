### 5.5 Combat.lua — 戰鬥介面

```lua
-- game/modules/mymod/class/interface/Combat.lua
require "engine.class"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.make)

-- 碰撞邏輯：撞到敵人 = 攻擊
function _M:bumpInto(target)
    if target:reactionToward(self) < 0 then
        return self:attackTarget(target)
    end
end

-- 實際攻擊計算
function _M:attackTarget(target, mult)
    mult = mult or 1
    local dam = self.combat.dam * mult
    -- 傷害 = 攻擊力 + 力量加成 - 護甲
    dam = dam + self:getStr()
    dam = dam - (target.combat_armor or 0)
    if dam < 0 then dam = 0 end

    DamageType:get(DamageType.PHYSICAL).projector(
        self, target.x, target.y, DamageType.PHYSICAL, dam)
    self:useEnergy()
    return true
end
```

