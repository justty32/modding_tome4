# 教學 14：技能視覺特效（粒子系統 + 自訂貼圖）

## 目標

為技能加入完整視覺特效：
1. **飛彈拖尾**：飛行投射物帶火焰或冰晶效果
2. **落點爆炸**：命中後目標格爆發粒子
3. **持續光環**：SUSTAINED 技能施法者身上旋繞光環
4. **自訂粒子貼圖**：自製 PNG 取代內建圓形粒子

以**冰刺術（Ice Spike）** 示範。

---

## 粒子系統架構

```
Lua 定義檔（data/gfx/particles/xxx.lua）
  └─ 描述粒子長相與噴出速率 → C 層 loadfile
C 粒子引擎（particles.c）— 獨立執行緒每幀更新物理狀態
OpenGL 渲染（display_sdl.c）— GPU 批次繪製
```

粒子計算在**獨立 C 執行緒**進行，不影響遊戲邏輯幀率。

---

## 粒子定義檔返回格式

```lua
return 
    { generator = function() ... end, ... },  -- ① 生成器定義表
    function(self) ... end,                    -- ② 更新函式（每幀呼叫）
    max_particles,                             -- ③ 總粒子上限
    "texture/path"                             -- ④ 貼圖路徑（可省略，預設 particle.png）
```

## 粒子參數

| 參數 | 說明 |
|------|------|
| `x, xv, xa` / `y, yv, ya` | 位置、速度、加速度（像素） |
| `dir, dirv, dira` | 方向（弧度）、角速度、角加速度 |
| `vel, velv, vela` | 速度大小、速度加速度、加加速 |
| `size, sizev, sizea` | 粒子大小、大小變化 |
| `r/g/b, rv/gv/bv, ra/ga/ba` | 顏色通道（0~1）、變化速率 |
| `a, av, aa` | 透明度（0~1）、變化速率 |
| `life` | 生命週期（幀數） |
| `trail` | 1=有拖尾 / 0=無 / 負數=連接到第 N 號粒子 |

> 每幀更新：`x += xv; xv += xa`，顏色同理 `r += rv; rv += ra`。

---

## 檔案結構

```
mod/data/
  talents/ice.lua           ← 冰系技能定義
  gfx/particles/
    ice_bolt.lua            ← 冰錐飛行粒子
    ice_explosion.lua       ← 冰錐爆炸粒子
    ice_aura.lua            ← 冰護盾光環
  gfx/particles_images/
    ice_shard.png           ← 自訂冰晶貼圖（32×32 PNG）
```

---

## 步驟一：粒子貼圖規格

| 屬性 | 要求 |
|------|------|
| 格式 | PNG RGBA 四通道 |
| 尺寸 | 正方形，建議 32×32 或 64×64 |
| 背景 | 完全透明（Alpha=0） |
| 中心 | 粒子原點在圖片中心 |
| 顏色 | 全白（1,1,1,1），讓 Lua 的 r/g/b 完整控制 |

**為什麼全白？** 著色公式：`最終顏色 = 貼圖像素 × 粒子 r/g/b/a 參數`。貼圖非白時顏色無法純由參數控制。

### `ice_shard.png` 製作

1. 建立 32×32 透明畫布（GIMP/Krita/Aseprite）
2. 中心畫細長菱形（冰晶形狀），純白 #FFFFFF
3. 高斯模糊半徑 1px 柔和邊緣
4. 存至 `mod/data/gfx/particles_images/ice_shard.png`

> 路徑映射：粒子定義第 4 回傳值 `"particles_images/ice_shard"` → `/data/gfx/particles_images/ice_shard.png`（無須副檔名）。

---

## 步驟二：飛行粒子 ice_bolt.lua

目標：冰錐飛行時藍白色冰晶拖尾，粒子從飛行方向往兩側散開快速消失。

```lua
-- mod/data/gfx/particles/ice_bolt.lua
-- 冰錐飛行拖尾粒子

base_size = 32   -- 粒子大小隨格子尺寸縮放

return {
    blend_mode = core.particles.BLEND_SHINY,  -- 加法混色
    generator = function()
        local base_angle = math.atan2(ty * engine.Map.tile_h, tx * engine.Map.tile_w)
        local side_angle = base_angle + math.rad(rng.range(-60, 60))
        local speed = rng.float(0.5, 2.0)
        return {
            life = rng.range(8, 16), trail = 0,
            size = rng.range(4,8), sizev=-0.3, sizea=0,
            x=rng.range(-4,4), xv=0, xa=0,
            y=rng.range(-4,4), yv=0, ya=0,
            dir=side_angle, dirv=math.rad(rng.range(-2,2)), dira=0,
            vel=speed, velv=-0.05, vela=0,
            r=rng.float(0.6,1.0), rv=-0.02, ra=0,
            g=rng.float(0.8,1.0), gv=-0.03, ga=0,
            b=1.0, bv=0, ba=0,
            a=rng.float(0.5,0.9), av=-0.05, aa=0,
        }
    end,
},
function(self)
    self.ps:emit(3)  -- 每幀噴 3 顆
end,
600,  -- 最大粒子數（range=20 × ~10幀/格 × 3 = ~600）
"particles_images/ice_shard"
```

---（續 part2）---