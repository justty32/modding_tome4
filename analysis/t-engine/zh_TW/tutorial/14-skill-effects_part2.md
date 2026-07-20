# 教學 14：技能視覺特效（續）

## 步驟三：爆炸粒子 ice_explosion.lua

目標：冰錐命中時向外飛散的冰晶碎片 + 短暫冰白閃光。

```lua
-- mod/data/gfx/particles/ice_explosion.lua
-- 冰爆炸（命中爆散）

local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
local nb_emitted = 0

return {
    blend_mode = core.particles.BLEND_SHINY,
    generator = function()
        local angle  = math.rad(rng.float(0, 360))
        local radius_pct = rng.float(0.3, 1.0)
        local r_dist = sradius * radius_pct
        return {
            life = rng.range(10, 25), trail = 1,
            size=rng.range(3,10), sizev=-0.3, sizea=0,
            x=rng.range(-4,4), xv=0, xa=0,
            y=rng.range(-4,4), yv=0, ya=0,
            dir=angle, dirv=0, dira=0,
            vel=r_dist/15, velv=-r_dist/15/15, vela=0,
            r=rng.float(0.7,1.0), rv=-0.03, ra=0,
            g=rng.float(0.8,1.0), gv=-0.02, ga=0,
            b=1.0, bv=0, ba=0,
            a=rng.float(0.7,1.0), av=-0.04, aa=0,
        }
    end,
},
function(self)
    if nb_emitted == 0 then
        self.ps:emit(math.max(50, radius * 80))
        nb_emitted = 1
    end
end,
math.max(50, radius * 80 + 10),
"particles_images/ice_shard"
```

---

## 步驟四：持續光環 ice_aura.lua

目標：冰護盾施法時身上旋轉的冰晶碎片。

```lua
-- mod/data/gfx/particles/ice_aura.lua
-- 冰護盾持續光環

can_shift = true   -- 隨實體移動
base_size = 32

return {
    blend_mode = core.particles.BLEND_SHINY,
    generator = function()
        local angle = math.rad(rng.float(0, 360))
        local orbit_r = rng.range(14, 20)
        local dir = angle + math.rad(90)
        return {
            life = rng.range(20, 40), trail = 0,
            x=orbit_r*math.cos(angle), xv=0, xa=0,
            y=orbit_r*math.sin(angle), yv=0, ya=0,
            dir=dir, dirv=-math.rad(rng.float(1.5,2.5)), dira=0,
            vel=rng.float(0.8,1.5), velv=0, vela=0,
            size=rng.range(3,7), sizev=-0.05, sizea=0,
            r=rng.float(0.3,0.7), rv=0, ra=0,
            g=rng.float(0.7,1.0), gv=0, ga=0,
            b=1.0, bv=0, ba=0,
            a=rng.float(0.5,0.9), av=-0.02, aa=0,
        }
    end,
},
function(self) self.ps:emit(2) end,
200,
"particles_images/ice_shard"
```

---

## 步驟五：技能定義（整合特效）

三種附加粒子方式：

| 方式 | 時機 | API |
|------|------|-----|
| 投射物拖尾 | `project` 飛行過程 | `tg.display = {particle="name", trail="name"}` |
| 落點爆炸 | 命中後 callback 或 `action` | `map:particleEmitter(x,y,radius,"name",{args})` |
| 持續光環 | SUSTAINED activate/deactivate | `addParticles(Particles.new(...))` / `removeParticles()` |

### `mod/data/talents/ice.lua`

```lua
local Particles = require "engine.Particles"

newTalentType{type="spell/ice", name="冰系魔法", description="操控寒氣的冰系魔法。"}

-- 技能一：冰錐術（拖尾 + 落點爆炸）
newTalent{
    name="冰錐術", type={"spell/ice",1}, points=5,
    cooldown=4, range=10, proj_speed=8,
    requires_target=true, reflectable=true,
    action = function(self, t)
        local tg = {
            type="bolt", range=self:getTalentRange(t), talent=t,
            display = {  -- 方式 A：投射物拖尾
                particle = "ice_bolt",
                trail    = "ice_bolt",
            },
        }
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        local dam = 15 + self:getTalentLevel(t) * 10
        -- 方式 B：project 完成後落點爆炸
        self:project(tg, x, y, DamageType.COLD, dam, function(px, py)
            game.level.map:particleEmitter(px, py, 0,
                "ice_explosion", {radius=0, tx=px, ty=py})
        end)
        return true
    end,
    info = function(self, t)
        return ("向目標發射冰錐，造成 %d 點寒冷傷害。"):format(15+self:getTalentLevel(t)*10)
    end,
}
```

---（續 part3）---