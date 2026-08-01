# T-Engine 4 — engine/ 原始碼詳細分析

> 原始碼位於 `game/engines/te4-1.7.6/engine/`（解壓自 `te4-1.7.6.teae`）。

---

## 1. OOP 基礎系統 (class.lua)

T-Engine 4 在 Lua 5.1 上自行實作物件導向系統，為引擎地基。

### 類別建立

```lua
module(..., package.seeall, class.make)               -- 無繼承
module(..., package.seeall, class.inherit(A, B, C))   -- 多重繼承 mixin
```

| 方法 | 說明 |
|------|------|
| `class.make(c)` | 將 module table 升格為類別，注入 `new()`、`castAs()` |
| `class.inherit(...bases)` | 多重繼承：將所有 base 欄位**快取複製**到子類別（非 `__index` 鏈），左到右、後者覆蓋 |
| `getClassName()`, `getClass()`, `isClassName(name)` | 類別自省 |

### 物件實例化

```lua
local obj = MyClass.new(...)
-- 等同：obj.__CLASSNAME = "module.name"; setmetatable(obj, {__index=MyClass}); obj:init(...)
```

- `__CLASSNAME`：字串，存檔/讀檔時重建 metatable 用
- `__ATOMIC = true`：標記此 table 為物件，不做深拷貝

### Clone 機制

| 方法 | 說明 |
|------|------|
| `obj:clone(t)` | 淺拷貝，選擇性合併 `t` |
| `obj:cloneFull(post_copy)` | 遞迴深拷貝，cyclic safe，呼叫子物件 `:cloned()` |
| `obj:cloneCustom(alt_nodes, type_checker)` | 可自訂跳過/替換特定節點的深拷貝 |
| `obj:cloneForSave()` | 同 cloneFull 但不呼叫 `:cloned()`，用於序列化前 |
| `obj:cloneReloaded()` | 讀檔後重建 metatable 並呼叫所有 `:loaded()` |
| `obj:replaceWith(t)` | 就地替換物件內容（in-place），不改變引用 |

### Hook & Event 系統

```lua
class:bindHook("ActorAI:act", function(self, data) ... end)
self:triggerHook{"ActorAI:act", key=val, ...}
```

- `bindHook`：每次 bind 後動態重新生成一個 closure，把所有 handler 串成一個函數（避免 table 查找）
- `triggerHook`：任一 handler 回傳 `true` 則整體回傳 `true`
- `__persistent_hooks`：存入存檔的 hook，讀檔時自動重新 bind

### 存檔整合

- 存檔：序列化為 Lua 字串寫入 zip（每個物件一個檔案），由 `engine.Savefile` 管理
- 讀檔：反序列化字串，根據 `__CLASSNAME` 重設 metatable，呼叫 `:loaded()`
- `_no_save_fields`：排除在序列化之外的欄位列表

---

## 2. 實體系統

### Entity.lua — 所有遊戲物件的基底

**核心屬性**
- `uid`：唯一識別碼；加入全域弱值表 `__uids[uid] = self`（GC 安全）
- `__position_aware`：子類別設 `true` 表示此實體在地圖上有位置

**初始化流程**（`Entity.new{...}`）
1. 分配 uid、加入 `__uids`
2. 複製傳入 table 所有欄位（table 類型做 `table.clone`）
3. 展開顏色 shorthand（`color` → `color_r/g/b`）
4. 若有 `embed_particles`，立即附加粒子系統
5. Debug 模式下檢查 upvalue（禁止 closure 在 definition 內）

**Define / Resolve 兩階段生命週期**

| 階段 | 說明 |
|------|------|
| Prototype（定義期） | 屬性可為 resolver 佔位符；在 zone/npc.lua 中建立 |
| Instance（實例期） | clone 後呼叫 `:resolve()`，resolver 替換為實際值 |

**臨時值系統**

```lua
local id = self:addTemporaryValue("combat_def", 10)  -- 加成
self:removeTemporaryValue("combat_def", id)           -- 撤銷（ID 追蹤）
```

支援多種應用模式：`add`、`mult`、`mult0`、`perc_inv`、`inv1`、`highest`、`lowest`、`last`。

**主要方法**

| 方法 | 說明 |
|------|------|
| `resolve(t, last, on_entity, key_chain)` | 執行所有 resolver，將 prototype 轉為 instance |
| `makeMapObject(tiles, idx)` | 建立地圖視覺物件 (MapObject) |
| `addParticles(ps)` / `removeParticles(ps)` | 粒子系統管理 |
| `toScreen(tiles, x, y, w, h, a, ...)` | 渲染到螢幕 |
| `addTemporaryValue(prop, v)` / `removeTemporaryValue(prop, id)` | 可撤銷屬性加成 |
| `check(prop, ...)` | 屬性 getter（若值為函數則呼叫之） |
| `attr(prop, v, fix)` | 屬性 getter/setter，含 fallback |
| `loadList(file, no_default, res, mod)` | 從 Lua 檔載入實體定義列表 |

---

### Actor.lua — 角色/怪物基底

繼承自 Entity，增加角色行為：

| 欄位/方法 | 說明 |
|-----------|------|
| `x`, `y` | 位置（**勿直接設定**，使用 `move()`） |
| `energy` | `{value, mod}` 行動點累積池 |
| `faction` | 陣營識別符 |
| `sight` | 視野範圍 |
| `dead` | 死亡旗標 |
| `act()` | 每回合被呼叫，允許行動 |
| `move(x, y, force)` | 移動（含碰撞/攻擊判斷） |
| `moveDir(dir, force)` | 八方向移動 |
| `setupMinimapInfo(mo, map)` | 根據陣營關係設小地圖顏色 |
| `setEmote(e)` | 附加表情粒子 |
| `defineDisplayCallback()` | 設定粒子與戰術顯示 callback |

---

### Grid.lua — 地形格

- 極簡介面，主要用於地圖裝飾與移動阻擋
- `block_move(x, y, e, act, couldpass)` — 移動阻擋邏輯
- `setupMinimapInfo(mo, map)` — 依可通行性設小地圖顏色
- `_noalpha` — 停用 alpha 通道渲染

---

### Object.lua — 物品/裝備

| 功能 | 方法 |
|------|------|
| 堆疊管理 | `stackable()`, `canStack(o)`, `stack(o)`, `unstack(num)`, `forAllStack(fct)` |
| 裝備 | `wornInven()`, `slot`, `require` |
| 命名 | `getName(t)`, `getDesc()` |
| 需求描述 | `getRequirementDesc(who)` — 帶顏色標記（已滿足/未滿足） |
| 排序 | `getTypeOrder()`, `getSubtypeOrder()` |

`stacking`（預設為名稱）決定堆疊識別符；`stacked` table 追蹤堆疊內容。

---

### Trap.lua — 陷阱

| 欄位/方法 | 說明 |
|-----------|------|
| `triggered` | 觸發 callback（必填），回傳 `(known, delete)` |
| `disarmable` | 可否解除 |
| `detect_power`, `disarm_power` | 難度評等 |
| `known_by` | 弱引用 table，追蹤知道此陷阱的角色 |
| `setKnown(actor, v)` / `knownBy(actor)` | 知曉狀態管理 |
| `canDisarm(x, y, who)` / `disarm(x, y, who)` | 解除邏輯 |
| `trigger(x, y, who)` | 觸發陷阱 |
| `on_move(x, y, who, forced)` | 踩到時自動觸發 |

---

### Projectile.lua — 投射物

| 欄位/方法 | 說明 |
|-----------|------|
| `project` | `{def: {typ, x, y, tg, damtype, dam, particles}}` 投射定義 |
| `homing` | `{target, count, on_hit, on_move}` 追蹤飛彈資料 |
| `travel_particle`, `trail_particle` | 飛行/軌跡粒子 |
| `src` | 發射來源 Actor |
| `move(x, y, force)` | 移動（帶粒子/軌跡處理） |
| `makeProject(src, display, def, ...)` | 工廠方法 |
| `act()` | 每回合執行移動/行動 |

支援兩種模式：預計算路徑（projectile-type）與追蹤飛彈（homing）。
