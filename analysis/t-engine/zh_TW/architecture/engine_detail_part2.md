## 3. 世界結構

```
World
 └─ Zone（地區，如「迷宮 A」）
     └─ Level（樓層，如「B1F」）
         ├─ Map（地圖格資料 + 渲染）
         └─ [Actor, ...]（本層角色列表）
```

### World.lua

純基底類別；一個存檔一個實例，跨角色死亡持久存在。僅提供 `init()` 與 `run()` 生命週期掛點。

---

### Zone.lua — 地區生成協調器

**主要職責**
- 載入 zone.lua 定義（`short_name`, `max_level`, `level_range`, `generator`, `levels`）
- 協調地圖/Actor/Object/Trap 生成器
- 管理多層 Level（含持久化：`persistent = "zone" | "level" | false`）
- Ego 系統：`ego_rules` 定義前綴/後綴如何合併到實體

**關鍵方法**

| 方法 | 說明 |
|------|------|
| `getLevel(game, lev, old_lev)` | 取得/生成指定層，處理持久化策略 |
| `newLevel(level_data, lev, old_lev, game)` | 建立新層（含生成 + 連通性驗證） |
| `makeEntity(level, type, filter, force_level)` | 隨機生成並解析單一實體 |
| `makeEntityByName(level, type, name)` | 依 `define_as` 生成指定實體 |
| `addEntity(level, e, typ, x, y)` | 將實體放置到關卡地圖 |
| `computeRarities(type, list, level, filter)` | 建立基於稀有度/等級的機率表 |
| `checkFilter(e, filter, typ)` | 驗證實體是否符合過濾條件 |
| `finishEntity(level, type, e, ego_filter)` | 最終解析（含 ego 套用） |
| `applyEgo(e, ego, type)` | 合併 ego 屬性到實體 |
| `setup(t)` | 靜態方法：註冊 Actor/Grid/Object/Trap 類別 |

**設計細節**
- 稀有度計算：`10000 / ood_factor^distance`（越超出深度越少見）
- 連通性驗證：用 A* 確認關卡可達性，失敗最多重試 50 次
- LRU cache：`enableLastPersistZones(max)` 快取最近造訪的 zone

---

### Level.lua — 單一樓層容器

| 欄位 | 說明 |
|------|------|
| `level` | 深度層數 |
| `map` | Map 物件 |
| `e_array` | 回合順序的實體列表 |
| `entities` | `{uid→entity}` O(1) 查找 |
| `spots` | 生成器提供的生成點（出口、寶藏…） |
| `sublevels` | 子層列表 `{name→Level}` |
| `last_iteration` | `{i=index}` 迭代安全移除追蹤 |

**關鍵設計**
- 迭代安全：`removeEntity()` 在迭代中間時調整 `last_iteration.i`，避免跳過實體
- 子層堆疊：`selectSublevel(name)` 原子交換主層與子層

---

### Map.lua — 空間格子 + 渲染後端

**Z 層常數**

| 常數 | 值 | 說明 |
|------|----|------|
| `Map.TERRAIN` | 1 | 地形/牆壁 |
| `Map.TRAP` | 50 | 陷阱 |
| `Map.ACTOR` | 100 | 角色/怪物 |
| `Map.PROJECTILE` | 500 | 投射物 |
| `Map.OBJECT` | 1000 | 物品 |
| `Map.TRIGGER` | 10000 | 觸發器 |

**主要欄位**

| 欄位 | 說明 |
|------|------|
| `map` | 稀疏陣列 `[x+y*w]={pos→entity}` |
| `seens`, `remembers`, `has_seens` | FOV 可見性狀態 |
| `lites` | 光源/火炬狀態 |
| `effects` | 暫時效果（傷害/視覺範圍） |
| `_fovcache` | `{block_sight, block_esp, block_sense, path_caches}` |
| `_map` | C 引擎地圖物件（`core.map`） |
| `mx`, `my` | 視口捲動偏移 |

**主要方法**

| 方法 | 說明 |
|------|------|
| `setViewPort(x, y, w, h, tile_w, tile_h, ...)` | 設定顯示區域與圖磚大小 |
| `display(x, y, nb_keyframe, ...)` | 渲染地圖與特效 |
| `call(x, y, pos, e)` | metamethod：get/set 實體（帶自動更新） |
| `updateMap(x, y)` | 重建 MapObject、FOV 快取、實體檢查函數 |
| `checkAllEntities(x, y, what, ...)` | 遍歷 (x,y) 所有實體查詢方法 |
| `addEffect(src, x, y, duration, damtype, ...)` | 生成暫時視覺/傷害範圍 |
| `moveViewSurround(x, y, marginx, marginy)` | 追蹤玩家視口 |

**關鍵設計**
- **動態實體檢查函數**：每個 (x,y) 位置編譯一個專屬 Lua 函數，僅檢查該位置存在的實體，避免 `pairs()` 開銷
- **FOV 快取分離**：sight/ESP/sense 三套獨立快取
- **懶更新**：只有呼叫 `call()`/`remove()` 時才呼叫 `updateMap(x,y)`，不持續更新

---

### MapEffect.lua — 暫時地圖效果

繼承自 Entity，增加：
- `alpha`（0-100，預設 100）— 透明度
- `display_on_seen`（預設 true）— 僅在可見格子顯示
- 可掛載 `overlay_particle` 做複雜視覺效果

---

## 4. 遊戲迴圈

### Game.lua — 基底遊戲類別

**主要職責**：遊戲狀態、UI 對話框堆疊、渲染、輸入、設定、協程管理

| 方法 | 說明 |
|------|------|
| `tick()` | 核心 tick：處理錯誤、協程、shader、計時器 |
| `display(nb_keyframes)` | 渲染幀：對話框、飄字、tween、計時器 |
| `registerDialog(d)` / `unregisterDialog(d)` | 對話框堆疊管理 |
| `onTickEnd(f, name)` | 回合結束 callback（可回傳 `TICK_RESCHEDULE` 重排） |
| `registerCoroutine(id, co)` / `cancelCoroutine(id)` | 協程池管理 |
| `setResolution(res, force)` | 解析度切換 |
| `saveGame()` | 遊戲持久化 |

**重要資料結構**
- `dialogs`：堆疊式 UI 對話框（頂部接收輸入）
- `entities`：弱值 table，實體在無引用時自動 GC
- `on_tick_end`：`{fcts, names}` — 回合末 callback 佇列
- `__coroutines`：背景任務協程 pool

---

### GameEnergyBased.lua — Energy-based 行動系統

```lua
-- 每 tick 給所有實體加 energy
e.energy.value += energy_per_tick * e.energy.mod * e.global_speed
-- energy 足夠時行動
if e.energy.value >= energy_to_act then e:act() end
```

| 參數 | 預設值 |
|------|--------|
| `energy_to_act` | 1000 |
| `energy_per_tick` | 100 |

- `entities`：弱值 table 的行動實體登錄表
- `level.last_iteration`：暫停後恢復迭代位置（安全中途暫停）
- 支援主層 + sublevel 同時 tick

---

### GameTurnBased.lua — 回合制變體（54 行）

繼承 GameEnergyBased，加上暫停機制：

```lua
-- 玩家 act() → game.paused = true（等待輸入）
-- 玩家行動後消耗 energy → game.paused = false（NPC 輪流行動）
```

- `paused`：布林暫停旗標
- `can_pause = true`：啟用 GameEnergyBased 的暫停邏輯
- 若玩家 energy 不足時自動取消暫停（防止死鎖）

---

## 5. Resolver 延遲計算系統 (resolvers.lua)

Resolver 是「延遲計算」框架，讓實體定義包含亂數/條件邏輯，直到 `resolve()` 時才執行。

**結構**：`resolvers.foo(...)` 建立 `{__resolver="foo", ...data}`；`resolvers.calc.foo(t, e)` 執行計算。

| Resolver | 說明 |
|----------|------|
| `rngrange(x, y)` | 隨機整數 [x, y]（`__resolve_instant`）|
| `rngfloat(x, y)` | 隨機浮點數 |
| `rngavg(x, y)` | 平均隨機（集中於中間值）|
| `dice(x, y)` | xdy 擲骰 |
| `rngtable(t)` | 從 table 隨機取一值 |
| `rngcolor(t)` | 隨機顏色並設 color_r/g/b |
| `mbonus(max, add)` | 依當前層數縮放的加成 |
| `talents(list)` | 學習技能列表 |
| `rngtalent(list)` | 從列表隨機學一個技能 |
| `rngtalentsets(list)` | 從集合隨機選一組技能 |
| `tmasteries(list)` | 設定技能類型熟練度 |
| `levelup(base, every, inc, max)` | 升級屬性進程設定 |
| `generic(fct)` | 自訂函數 resolver |

- `__resolve_instant`：在其他 resolver 之前優先執行（適合即時亂數）
- `__resolve_last`：在其他 resolver 之後執行
- `resolvers.current_level`：全域變數，Zone 生成前設定，讓 `mbonus` 感知當前深度
