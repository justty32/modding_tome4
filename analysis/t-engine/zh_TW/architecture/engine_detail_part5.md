## 11. AI 系統 (ai/)

AI 是命名行為的組合，以字串 key 組合：

```lua
npc.ai = "dumb_talented"     -- 主 AI
npc.ai_state = {talent_in=3} -- AI 狀態參數
```

### simple.lua — 基礎 AI 行為

| AI 名稱 | 說明 |
|---------|------|
| `move_simple` | 直線朝目標移動 |
| `move_dmap` | 目標可見用距離地圖；否則往最後目擊點 |
| `move_astar` / `move_astar_advanced` | A* 尋路（含 Actor 阻擋可選）|
| `move_blocked_astar` | 被阻擋多回合後切換 A* |
| `move_wander` | 隨機相鄰移動 |
| `move_complex` | 整合多策略（A*/距離地圖/漫遊） |
| `flee_simple` / `flee_dmap` | 反向移動 + 障礙迴避 |
| `target_simple` / `target_player` | 目標選取（最近敵人或玩家）|
| `simple` / `dmap` | 合成 AI（目標選取 + 移動）|
| `none` | 空 AI 佔位符 |

### talented.lua — 技能使用 AI

| AI 名稱 | 說明 |
|---------|------|
| `dumb_talented` | 隨機挑可用技能；無戰術評估 |
| `improved_talented` | 嘗試最多 5 個技能 + fallback |
| `dumb_talented_simple` | 目標選取 + N 分之一機率用技能 + 移動 |

`ai_state.talent_in`：使用技能的頻率；`ai_state.no_talents`：技能抑制旗標

### special_movements.lua — 特殊移動

| AI 名稱 | 說明 |
|---------|------|
| `move_ghoul` | 交替移動/暫停（`pause_chance`）|
| `move_snake` | 側滑接近；只在近距離時直線衝鋒 |

---

## 12. 演算法 (algorithms/)

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

## 13. Tilemap 中間表示 (tilemaps/)

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

## 14. 存檔系統 (Savefile.lua)

### 格式

每次存檔 = 一個 zip 檔，內含多個 Lua 序列化字串：

```
/save/<player_name>/
    save.lua          -- 頂層 game 物件
    description.lua   -- 元資料（模組、版本、Addon、可讀取旗標）
    <hash1>.lua       -- 某個子物件（Level、Actor…）
    <hash2>.lua
```

### 存檔流程

1. `game:save()` → `Savefile:init(name)` → 建立 zip
2. `core.serial.new()` 序列化根物件
3. 遞迴遇到子物件 → `addToProcess(t)` 排隊
4. 相同物件引用 → `loadObject(hash)` 取代（避免重複）
5. 完成後關閉 zip，可選 Steam Cloud 上傳

### 讀檔流程

1. `Savefile:load()` → 解壓到 `/tmp/loadsave/`
2. `class.load(str)` 反序列化，遇 `loadObject` 遞迴讀取
3. 根據 `__CLASSNAME` 重設 metatable
4. 延遲呼叫 `:loaded()`（確保相互引用建立後才初始化）

### 其他特性

- `SavefilePipe`：背景存檔（協程分批，避免卡頓）
- `setSaveMD5Type(type)`：啟用 MD5 校驗（偵測存檔修改）
- `saveQuickBirth(descriptor)` / `loadQuickBirth()` — 快速角色創建模板

---

## 15. 渲染支援系統

### Tiles.lua — 圖磚快取

- 三層巢狀 table 快取（char → fgidx → bgidx）
- `loadTileset(file)` — 載入大圖切片定義
- `loadImage(image)` — 含 addon 路徑支援
- `get(char, fr, fg, fb, br, bg, bb, image, ...)` — 取得快取/生成圖磚
- `clean()` — 清除快取並 GC

### Shader.lua — GLSL Shader 管理

- 懶載入：第一次存取 `shader.shad` 才實際編譯
- 參數化快取：相同名稱+參數的 shader 共用
- `setUniform(k, v)` — 設定數字/向量/材質 uniform
- `cleanup()` — 刪除超時的臨時 shader
- `core.shader.allow(kind)` — 依使用者設定決定 shader 功能等級

### Particles.lua — 粒子系統

```lua
local p = Particles.new("flame", radius=1, {size=2, density=50})
actor:addParticles(p)
```

- 粒子定義在 `/data/gfx/particles/*.lua`（行為、壽命、顏色曲線）
- C 層維護物理計算（`src/particles.c`）
- `__particles_gl` 弱引用 table 防止 GC 前仍被渲染
- 支援子粒子（sub-emitters）複合效果

### FlyingText.lua — 飄字效果

- `add(x, y, duration, xvel, yvel, str, color, bigfont)` — 建立飄字
- 弱引用 table 追蹤活躍飄字；到期自動清除
- 生命末尾放大縮放效果（pop-out）
