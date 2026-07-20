### 效果目標

冰錐飛行時留下一條**藍白色冰晶拖尾**，粒子從飛行方向往兩側散開，快速消失。

### 檔案：`mod/data/gfx/particles/ice_bolt.lua`

```lua
-- mod/data/gfx/particles/ice_bolt.lua
-- 冰錐飛行拖尾粒子

-- ── 頂層設定（在 return 之前設定） ───────────────────────────
base_size = 32   -- 粒子大小隨格子尺寸縮放（32 = 標準格大小）

-- ── 生成器定義 ────────────────────────────────────────────────
return {
    -- BLEND_SHINY = 加法混色（疊加更亮），適合火、冰、電等光效
    blend_mode = core.particles.BLEND_SHINY,

    generator = function()
        -- 從飛行方向（往 tx, ty 的方向）散開
        -- tx, ty 是 Particles.new 的 args 傳入的目標偏移（格數）
        local base_angle = math.atan2(
            ty * engine.Map.tile_h,
            tx * engine.Map.tile_w
        )

        -- 粒子從飛行路徑兩側隨機偏移噴出
        local side_angle = base_angle + math.rad(rng.range(-60, 60))
        local speed = rng.float(0.5, 2.0)

        return {
            -- 生命週期：8~16 幀（短暫的拖尾）
            life = rng.range(8, 16),
            trail = 0,

            -- 大小：4~8px，逐漸縮小至消失
            size  = rng.range(4, 8), sizev = -0.3, sizea = 0,

            -- 初始位置：在飛行路徑附近小範圍隨機
            x  = rng.range(-4, 4), xv = 0, xa = 0,
            y  = rng.range(-4, 4), yv = 0, ya = 0,

            -- 運動方向：往兩側散開
            dir  = side_angle,
            dirv = math.rad(rng.range(-2, 2)),  -- 微小的方向漂移
            dira = 0,
            vel  = speed, velv = -0.05, vela = 0,

            -- 顏色：藍白混合（冰晶感）
            -- 白色高光核心：r,g,b 都接近 1
            -- 外圍轉為冰藍色：g 逐漸降低，b 保持高
            r = rng.float(0.6, 1.0),  rv = -0.02, ra = 0,
            g = rng.float(0.8, 1.0),  gv = -0.03, ga = 0,
            b = 1.0,                  bv =  0.00, ba = 0,
            a = rng.float(0.5, 0.9),  av = -0.05, aa = 0,
        }
    end,
},
-- ── 更新函式：每幀呼叫，控制噴出速率 ─────────────────────────
function(self)
    -- 飛行中持續噴出：每幀噴 3 顆粒子
    self.ps:emit(3)
end,
-- ── 最大粒子數量 ──────────────────────────────────────────────
-- 飛行最長 range=20 格，每格約 10 幀，共約 200 幀 × 3 顆 = 600
600,
-- ── 貼圖路徑（自訂冰晶形狀） ─────────────────────────────────
"particles_images/ice_shard"
```

---
