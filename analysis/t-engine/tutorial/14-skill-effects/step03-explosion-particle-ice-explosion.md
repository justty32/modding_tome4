### 效果目標

冰錐命中目標時，在目標格爆發一圈**向外飛散的冰晶碎片**，並有一個**短暫的冰白色閃光**。

### 檔案：`mod/data/gfx/particles/ice_explosion.lua`

```lua
-- mod/data/gfx/particles/ice_explosion.lua
-- 冰爆炸（命中時的爆散效果）

-- radius 由 particleEmitter 呼叫時傳入
local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
local nb_emitted = 0   -- 記錄已噴出的批次數（用於一次性爆炸）

return {
    blend_mode = core.particles.BLEND_SHINY,

    generator = function()
        -- 隨機方向向外爆炸
        local angle  = math.rad(rng.float(0, 360))
        local radius_pct = rng.float(0.3, 1.0)  -- 0.3~1.0 倍半徑
        local r_dist = sradius * radius_pct

        return {
            life = rng.range(10, 25),
            trail = 1,   -- 帶拖尾

            -- 從中心向外爆炸：初始位置在中心附近
            size  = rng.range(3, 10), sizev = -0.3, sizea = 0,
            x  = rng.range(-4, 4),  xv = 0, xa = 0,
            y  = rng.range(-4, 4),  yv = 0, ya = 0,

            -- 方向：向外四散，速度隨距離遞減
            dir  = angle, dirv = 0, dira = 0,
            vel  = r_dist / 15,        -- 在 15 幀內飛到邊緣
            velv = -r_dist / 15 / 15,  -- 逐漸減速
            vela = 0,

            -- 顏色：白色核心 → 冰藍色邊緣 → 透明消失
            r = rng.float(0.7, 1.0),  rv = -0.03, ra = 0,
            g = rng.float(0.8, 1.0),  gv = -0.02, ga = 0,
            b = 1.0,                  bv =  0.00, ba = 0,
            a = rng.float(0.7, 1.0),  av = -0.04, aa = 0,
        }
    end,
},
function(self)
    -- 一次性爆炸：只在第一幀噴出大量粒子，之後不再噴
    if nb_emitted == 0 then
        -- 爆炸粒子數量與半徑成正比（半徑越大越壯觀）
        self.ps:emit(math.max(50, radius * 80))
        nb_emitted = 1
    end
end,
-- 最大粒子數：一次爆出，設定足夠大
math.max(50, radius * 80 + 10),
"particles_images/ice_shard"
```

---
