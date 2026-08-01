## 14. Grid 類別

Grid 通常不需大幅修改，繼承引擎 Grid 即可：

```lua
-- game/modules/hellodungeon/class/Grid.lua

require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

-- 可在這裡覆寫 block_move 等行為
-- 引擎 Grid 已內建門的開關邏輯
```

---

## 15. 戰鬥介面（Combat.lua）

戰鬥邏輯作為「混入」(mixin)：

```lua
-- game/modules/hellodungeon/class/interface/Combat.lua

require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"

-- class.make 建立純混入（不繼承任何基底）
module(..., package.seeall, class.make)

-- 碰撞處理：根據陣營關係決定攻擊或交換位置
function _M:bumpInto(target)
    local reaction = self:reactionToward(target)
    if reaction < 0 then
        -- 敵人：攻擊
        return self:attackTarget(target)
    elseif reaction >= 0 then
        -- 友善：交換位置
        if self.move_others then
            game.level.map:remove(self.x, self.y, Map.ACTOR)
            game.level.map:remove(target.x, target.y, Map.ACTOR)
            game.level.map(self.x, self.y, Map.ACTOR, target)
            game.level.map(target.x, target.y, Map.ACTOR, self)
            self.x, self.y, target.x, target.y =
                target.x, target.y, self.x, self.y
        end
    end
end

-- 簡易攻擊：力量 + 武器傷害 - 護甲
function _M:attackTarget(target, mult)
    if self.combat then
        local dam = (self.combat.dam or 0) + self:getStr()
            - target.combat_armor
        DamageType:get(DamageType.PHYSICAL).projector(
            self, target.x, target.y,
            DamageType.PHYSICAL,
            math.max(0, dam)
        )
    end
    self:useEnergy(game.energy_to_act)
end
```
