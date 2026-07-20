### 粒子系統架構

TE4 的粒子系統由三個層次組成：

```
Lua 定義檔（data/gfx/particles/xxx.lua）
  └─ 描述「每顆粒子長什麼樣」和「多快噴出粒子」
      ↓  loadfile 後傳到 C 層
C 粒子引擎（src/particles.c）
  └─ 在獨立執行緒中每幀更新所有粒子的物理狀態
      ↓
OpenGL 渲染（display_sdl.c）
  └─ 用 GPU 批次繪製所有粒子點 / 線
```

粒子計算在**獨立 C 執行緒**中進行，不影響遊戲邏輯幀率。

### 粒子定義檔的返回格式

```lua
-- 返回 4 個值（第 4 個可省略）：
return 
    { generator = function() ... end, ... },  -- ① 粒子生成器定義表
    function(self) ... end,                    -- ② 更新函式（每幀呼叫）
    max_particles,                             -- ③ 總粒子上限
    "texture/path"                             -- ④ 貼圖路徑（可省略，預設 particle.png）
```

### 粒子參數完整列表

| 參數 | 說明 | 單位 |
|------|------|------|
| `x, xv, xa` | X 位置、速度、加速度 | 像素 |
| `y, yv, ya` | Y 位置、速度、加速度 | 像素 |
| `dir, dirv, dira` | 運動方向（弧度）、角速度、角加速度 | rad |
| `vel, velv, vela` | 速度大小、速度加速度、加加速 | px/幀 |
| `size, sizev, sizea` | 粒子大小、大小變化速率 | 像素 |
| `r, rv, ra` | 紅色通道（0~1）、變化速率 | 歸一化 |
| `g, gv, ga` | 綠色通道 | 歸一化 |
| `b, bv, ba` | 藍色通道 | 歸一化 |
| `a, av, aa` | 透明度（0~1）、變化速率 | 歸一化 |
| `life` | 生命週期（幀數） | 幀 |
| `trail` | `1` = 有拖尾；`0` = 無；負數 = 連接到第 N 號粒子（ENGINE_LINES 用） | - |

> **規律**：每幀更新：`x += xv; xv += xa`（Position → Velocity → Acceleration）。顏色同理：`r += rv; rv += ra`。這讓你只需指定初始值和加速度，物理自動計算。

---
