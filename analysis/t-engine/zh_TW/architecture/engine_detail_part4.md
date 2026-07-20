## 7. 玩家介面混入

### PlayerRest — 休息系統

```lua
player:restInit(turns, "resting", "rested", on_end_callback)
```

- 每回合呼叫 `restCheck()` 判斷是否停止（子類別覆寫）
- 停止條件：受傷、敵人出現、HP/MP 滿等

### PlayerRun — 自動奔跑

```lua
player:runInit(dir)    -- 方向奔跑
player:runFollow(path) -- 沿預計算路徑奔跑
```

- `runCheck()`：感知地形變化（岔路口、敵人、物品）
- `running` 狀態：`{dir, block_left/right, ignore_left/right, path, cnt}`
- 支援自動探索整合（`running.explore` 旗標）

### PlayerExplore — 自動探索

- Flood-fill BFS 找最近未探索格或物品
- 自動規避非對稱 LoS（防埋伏）
- 優先「孤立」未探索格（只有一個相鄰未見格的格子）

### PlayerHotkeys — 快捷鍵系統

- 7 頁 × 12 槽 = 84 個快捷鍵
- 支援技能與物品兩種類型
- `hotkey_page`：當前頁；`quickhotkeys`：全局模板

### PlayerMouse — 滑鼠控制

- `mouseMove(tmx, tmy, ...)` — A* 尋路 + 直線路徑 fallback
- `mouseScrollMap(map, xrel, yrel)` — Shift + 拖曳捲動地圖
- 偵測敵人限制移動路徑

### GameTargeting — 目標選擇系統

- 三種目標模式：`"lock"`（掃描）、`"free"`（滑鼠）、`"immediate"`（方向性）
- 使用協程暫停執行等待玩家選擇
- 戰術格子 overlay：紅=阻擋、藍=可用、綠=盟友、黃=敵人
- `tooltipDisplayAtMap(x, y, text)` — 地圖上方顯示提示

### WorldAchievements — 成就系統

- 三個作用域：世界（world）/ 遊戲（game）/ 玩家（player）
- `gainAchievement(id, src)` — 檢查 `can_gain` 條件後授予
- 廣播到聊天頻道；支援「巨型」成就特殊顯示

### BloodyDeath — 死亡視覺效果

- `bloodyDeath(tint)` — 對 3 個相鄰格套用血色染色
- `has_blood`：`true` 或 `{nb, color=[r,g,b]}`

---

## 8. 傷害類型系統 (DamageType.lua)

```lua
DamageType:newDamageType{
    name = "FIRE", type = "fire", text_color = "#r#",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then target:takeHit(dam, src) end
    end,
}
-- 自動生成 DamageType.FIRE 常數
```

- 每種傷害類型有獨立 projector 函數，由 `ActorProject:project()` 呼叫
- `setDefaultProjector(fct)` — 未自訂 projector 的傷害類型使用預設
- `projectingFor(src, v)` / `getProjectingFor(src)` — 委派投射（一個角色代另一個投射）

---

## 9. 目標系統 (Target.lua)

**目標形狀描述**：

```lua
{type="bolt", range=10}              -- 直線單目標
{type="beam", range=10}              -- 直線貫穿
{type="ball", range=5, radius=3}     -- 球形 AOE
{type="cone", range=8, cone_angle=45} -- 扇形
{type="hit"}                          -- 直接命中
```

**目標樣式**
- `lock`（掃描模式）：鍵盤掃描目標
- `free`（自由模式）：滑鼠指定位置
- `immediate`（即時模式）：方向鍵選擇

**渲染**
- 彩色 overlay 即時顯示射程/形狀（紅/藍/綠/黃 tile 顏色）
- 可選 FBO 渲染做半透明 overlay 效果
- 箭頭指示器顯示來源→目標方向

---

## 10. 程序地圖生成系統 (generator/)

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
