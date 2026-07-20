### BSP.lua — 二元空間分割

- `init(w, h, min_w, min_h, max_depth)` — 初始化樹
- `partition(store)` — 遞迴切割（50% 隨機選軸）
- `leafs`：僅葉節點；`splits`：切割座標（用於走廊生成）

### MST.lua — 最小生成樹（Kruskal 演算法）

- `edge(r1, r2, cost, data)` — 加入帶權邊
- `run()` — Union-Find 計算 MST，回傳最小邊集合
- `fattenRandom(nb_adds)` — 加入隨機非 MST 邊（增加環路）
- `fattenShorter(nb_adds)` — 加入最短非 MST 邊

---
