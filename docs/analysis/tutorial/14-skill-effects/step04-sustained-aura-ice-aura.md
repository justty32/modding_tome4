### 效果目標

施法者持續施展冰護盾時，身上環繞著**旋轉的冰晶碎片**，慢慢繞圈移動，提示這是一個 SUSTAINED 技能。

### 檔案：`mod/data/gfx/particles/ice_aura.lua`

```lua
-- mod/data/gfx/particles/ice_aura.lua
-- 冰護盾持續光環

can_shift = true   -- 允許隨實體移動（走路時粒子跟著移動）
base_size = 32     -- 大小隨格子縮放

return {
    blend_mode = core.particles.BLEND_SHINY,

    generator = function()
        -- 在圓環上隨機選一個起始角度
        local angle = math.rad(rng.float(0, 360))
        local orbit_r = rng.range(14, 20)  -- 軌道半徑（像素）
        -- 每顆粒子繞圈方向：逆時針 dirv = -math.rad(2)
        local dir = angle + math.rad(90)   -- 切線方向（垂直於半徑）

        return {
            life = rng.range(20, 40),
            trail = 0,

            -- 初始位置：在軌道圓上
            x  = orbit_r * math.cos(angle),  xv = 0, xa = 0,
            y  = orbit_r * math.sin(angle),  yv = 0, ya = 0,

            -- 繞圈運動：向切線方向前進，方向持續轉動（產生圓形路徑）
            dir  = dir,
            dirv = -math.rad(rng.float(1.5, 2.5)),  -- 旋轉速度（負 = 逆時針）
            dira = 0,
            vel  = rng.float(0.8, 1.5), velv = 0, vela = 0,

            -- 大小：中等，逐漸縮小至消失
            size  = rng.range(3, 7), sizev = -0.05, sizea = 0,

            -- 顏色：冰藍色，逐漸淡出
            r = rng.float(0.3, 0.7),  rv = 0,     ra = 0,
            g = rng.float(0.7, 1.0),  gv = 0,     ga = 0,
            b = 1.0,                  bv = 0,     ba = 0,
            a = rng.float(0.5, 0.9),  av = -0.02, aa = 0,
        }
    end,
},
function(self)
    -- 持續光環：每幀穩定噴出（讓圓環看起來是連續的）
    self.ps:emit(2)
end,
-- 最大粒子數：持續光環需要足夠多（200 顆讓圓環看起來飽滿）
200,
"particles_images/ice_shard"
```

---
