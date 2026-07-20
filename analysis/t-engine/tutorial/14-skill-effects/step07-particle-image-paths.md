粒子定義的第 4 個返回值是相對於**虛擬檔案系統根目錄 `/data/gfx/`** 的路徑（不含 `.png`）：

```lua
-- 寫這個：
"particles_images/ice_shard"

-- 引擎會找：
"/data/gfx/particles_images/ice_shard.png"

-- 物理路徑（你的模組）：
"mod/data/gfx/particles_images/ice_shard.png"
```

內建可用貼圖：

| 路徑（省略 `/data/gfx/`） | 外觀描述 |
|--------------------------|---------|
| `particle`（預設）| 圓形高斯模糊光點 |
| `particle_cloud` | 較大的雲狀光點 |
| `particle_torus` | 環形（donut）形狀 |
| `particles_images/beam` | 細長光束片段（用於直線效果） |

---
