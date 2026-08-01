部分生成器先產生抽象 tilemap（字元代號），再映射到實際 Entity。

### Tilemap.lua — 基底

- `setSize(w, h, fill_with)` / `makeData(w, h, fill_with)` — 建立 2D 陣列
- `point(x, y)` — 帶運算子重載的位置物件（+, -, *, /, distance, direction）
- `pointIterator(sx, sy, tx, ty)` — 矩形區域迭代器
- `clone()` — 深拷貝

### WaveFunctionCollapse.lua

- 整合 C++ WFC 核心（樣本學習模式）
- `run(t)` — 同步或非同步啟動 WFC
- `waitAll(...)` — 平行等待多個 WFC 實例（效能優化）
- `parseResult(data)` — 解析字元輸出為 2D 格子

### BSP.lua / Maze.lua / Heightmap.lua / Noise.lua / Rooms.lua / Static.lua / Proxy.lua

各種對應演算法的 Tilemap 變體。

---
