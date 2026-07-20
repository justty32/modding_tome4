所有生成器繼承 `engine.Generator`，實作 `:generate(lev, old_lev)` 方法。

**Zone 中指定生成器**：
```lua
generator = {
    map   = {class="engine.generator.map.Roomer", floor="FLOOR", wall="WALL"},
    actor = {class="engine.generator.actor.Random", nb_npc={10,15}},
}
```

### 地圖生成器 (generator/map/)

| 生成器 | 演算法 | 特色 |
|--------|--------|------|
| `Rooms` | 遞迴 BSP 切割 | 最簡單；根據長寬比選切割軸 |
| `RoomsLoader` | 預設計房間 + MST 連通 | 支援 .tmx / .lua 房間；房間旋轉/翻轉 |
| `Cavern` | Perlin noise + flood-fill | 含連通性驗證；支援插入房間 |
| `CavernousTunnel` | 洞窟變體 | — |
| `Maze` | 深度優先遞迴回溯 | 可調整格子寬高（`widen_w/h`）|
| `Forest` | Perlin noise + A* 道路 | 多層植被；邊緣入口；路點連通 |
| `Heightmap` | 分形高度圖 | 依高度閾值分配地形類型 |
| `Building` | 兩層 BSP（街區→建築）| 牆壁門洞系統 |
| `Town` | 單層 BSP | L 形內部隔間；可選院落 |
| `Static` | 手工 .tmx / .lua 地圖 | 完整自訂環境 API |
| `GOL` | Game of Life 細胞自動機 | 3 代演化；自訂生死規則 |
| `MapScript` | Script 驅動 | — |
| `WaveFunctionCollapse` | 呼叫 C++ WFC 核心 | 樣本學習 + 非同步生成 |
| `Empty`, `Filled`, `Hexacle`, `Octopus`, `TileSet` | 特殊變體 | — |

### Actor 生成器 (generator/actor/)

**Random.lua**：
- `nb_npc`：每層生成數量範圍
- `filters`：Actor 類型過濾器
- `guardian`：Boss 定義（含生成地點偏好）
- 連通性檢查；Boss 失敗則重建關卡

### Object/Trap 生成器

- `generator/object/Random.lua`、`generator/object/OnSpots.lua`
- `generator/trap/Random.lua`

---
