結合以上所有系統，實作一套「技能命中時：飄字 + 攻擊搖晃 + 粒子 + 螢幕震動」的效果：

```lua
-- mod/class/interface/Combat.lua（或在技能 action 中呼叫）

local FlyingText = require "engine.FlyingText"
local tween = require "tween"

-- 通用的命中特效函式
function _M:hitEffect(target, damage, dtype)
    local map = game.level.map
    local sx = map.display_x + (target.x - map.mx) * map.tile_w
    local sy = map.display_y + (target.y - map.my) * map.tile_h

    -- 1. 傷害飄字
    local color
    if dtype == DamageType.FIRE   then color = {255, 120,  30}
    elseif dtype == DamageType.ICE then color = { 80, 200, 255}
    else                               color = {255, 255,  80} end

    game.flyers:add(sx, sy - map.tile_h/2,
        35,
        (rng.range(0,2)-1) * 0.3, -2.5,
        tostring(math.ceil(damage)), color, false)

    -- 2. 攻擊搖晃（攻擊者往目標方向衝刺）
    self:setMoveAnim(self.x, self.y, 4, nil,
        util.getDir(target.x, target.y, self.x, self.y), 0.25)

    -- 3. 粒子效果
    map:particleEmitter(target.x, target.y, 1, "melee_attack",
        {color = target.blood_color or {255, 0, 0}})

    -- 4. 大傷害時震動螢幕
    if damage > 50 then
        game.uiset:screenShake(damage / 20, 15)  -- 假設 UISet 有 screenShake 方法
    end
end
```

---
