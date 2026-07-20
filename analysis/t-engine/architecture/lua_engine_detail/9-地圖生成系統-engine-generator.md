### 9.1 Generator 基底

所有 generator 繼承 `engine.Generator`，實作 `:generate(lev, old_lev)` 方法。

```lua
-- Zone 定義中指定 generator
generator = {
    map = {class="engine.generator.map.Roomer", -- 地圖 generator
           floor = "FLOOR", wall = "WALL", ...},
    actor = {class="engine.generator.actor.Random",
             nb_npc = {10, 15}, ...},
    object = {class="engine.generator.object.Random",
              nb_object = {3, 5}, ...},
}
```

### 9.2 主要地圖生成器

**Rooms（`engine/generator/map/Rooms.lua`）**：
- 遞迴 BSP 切割（預設 10 次）產生房間。
- 每個最終房間記錄一個 spot，用於放置出口、NPC。
- 最簡單、效能最高的地牢生成器。

**RoomsLoader（`engine/generator/map/RoomsLoader.lua`）**：
- 從預定義的 room template 檔案（`.lua`）讀取房間形狀。
- 用 MST（最小生成樹）連接所有房間，確保連通性。
- 支援 special rooms（boss 房、寶庫等）。

**Cavern**：
- 隨機洞窟，使用細胞自動機（多次 smooth 迭代）。

**Maze**：
- 標準迷宮演算法（recursive backtracking）。

**Forest**：
- Perlin noise 決定樹木/草地分佈。

**Heightmap**：
- 高度圖轉換為地形（山脈、平原、水域）。

**WaveFunctionCollapse**：
- 呼叫 C++ WFC 核心（`src/wfc/`），從樣本圖案學習並生成一致的地圖。

**Static**：
- 從 `.lua` 腳本直接讀取手工設計的地圖（多用於 boss 房、城鎮）。

**GOL（Game of Life）**：
- 多代細胞自動機生成有機感的洞穴。

### 9.3 Tilemap 中間表示（`engine/tilemaps/`）

部分生成器先產生抽象 tilemap（字元代號），再映射到實際 Entity。`Tilemap.lua` 提供此轉換。

---
