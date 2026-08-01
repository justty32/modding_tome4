# T-Engine 4 — Lua 引擎層詳細分析

> 所有原始碼位於 `game/engines/te4-1.7.6.teae`（zip 格式），解壓後為 `engine/` 目錄。

---

## 1. OOP 基礎系統 (`engine/class.lua`)

TE4 在 Lua 5.1 上自行實作了一套物件導向系統，是整個引擎的地基。

### 1.1 類別建立

```lua
module(..., package.seeall, class.make)        -- 單一繼承/無繼承
module(..., package.seeall, class.inherit(A, B, C))  -- 多重繼承 mixin
```

- **`class.make(c)`**：將 module table 升格為類別，注入 `new()`、`castAs()` 方法。
- **`class.inherit(...bases)`**：多重繼承，將所有 base 的欄位**快取複製**到子類別（而非 `__index` 鏈），避免查找開銷。繼承順序為左到右、後者覆蓋前者。

### 1.2 物件實例化

```lua
local obj = MyClass.new(...)
-- 等同於：
local obj = {}
obj.__CLASSNAME = "module.name"
obj.__ATOMIC = true
setmetatable(obj, {__index = MyClass})
obj:init(...)
```

- `__CLASSNAME`：字串，用於存檔/讀檔時重建 metatable。
- `__ATOMIC = true`：標記此 table 為物件，不做深拷貝。

### 1.3 Clone 機制

| 方法 | 說明 |
|------|------|
| `obj:clone(t)` | 淺拷貝，選擇性合併 `t` |
| `obj:cloneFull()` | 遞迴深拷貝，相同子物件只拷貝一次（cyclic safe），呼叫各子物件的 `:cloned()` |
| `obj:cloneCustom(alt_nodes, type_checker)` | 可自訂跳過/替換特定節點的深拷貝 |
| `obj:cloneForSave()` | 同 cloneFull 但不呼叫 `:cloned()`，僅用於序列化前準備 |
| `obj:cloneReloaded()` | 讀檔後重建 metatable 並呼叫所有 `:loaded()` |
| `obj:replaceWith(t)` | 就地替換物件內容（in-place），不改變引用 |

### 1.4 Hook & Event 系統

```lua
class:bindHook("ActorAI:act", function(self, data) ... end)
self:triggerHook{"ActorAI:act", key=val, ...}
```

- **`bindHook(hook, fct)`**：將 handler 加入指定 hook。每次 bind 後會動態重新生成一個 closure，把所有 handler 串成一個函數（避免 table 查找）。
- **`triggerHook(hook_table)`**：呼叫該 hook 的所有 handler，任一 handler 回傳 `true` 則整體回傳 `true`。
- `__persistent_hooks`：存入存檔的 hook，讀檔時自動重新 bind。

### 1.5 存檔整合

```lua
obj:save(filter, allow)
class.load(str, delayloading)
```

- 存檔：將物件序列化為 Lua 字串並寫入 zip（每個物件一個檔案），由 `engine.Savefile` 管理。
- 讀檔：反序列化字串，根據 `__CLASSNAME` 重設 metatable，呼叫 `:loaded()`。
- `loadNoDelay = true`：強制同步呼叫 `:loaded()`（不延遲），用於 Shader 等需立即初始化的物件。

---

## 2. 實體系統 (`engine/Entity.lua`)

### 2.1 核心屬性

```lua
-- 每個 Entity 都有唯一的 uid
self.uid = next_uid
__uids[self.uid] = self   -- 全域弱引用表，可用 uid 快速查找
```

- `__uids`：弱值 table（`{__mode="v"}`），實體無任何其他引用時自動 GC。
- `__position_aware`：子類別設為 `true` 表示此實體在地圖上有位置（Actor、Trap 等）。

### 2.2 初始化流程

```lua
Entity.new{display='@', color_r=255, name="Player", ...}
```

1. 分配 uid，加入 `__uids`。
2. 將傳入 table 的所有欄位複製到 self（table 類型做 `table.clone`）。
3. 展開顏色 shorthand（`color` → `color_r/g/b`，`tint` → `tint_r/g/b`）。
4. 若有 `embed_particles`，立即附加粒子系統。
5. Debug 模式下檢查 upvalue（禁止實體 definition 裡使用 closure）。

### 2.3 Define / Resolve 兩階段生命週期

實體有兩個階段：
- **Prototype（定義期）**：在 zone/npc.lua 等定義檔中建立，屬性可以是 resolver 佔位符。
- **Instance（實例期）**：從 prototype clone 出來並呼叫 `:resolve()`，resolver 替換為實際值。

```lua
-- 定義期（prototype）
local npc_proto = Actor.define{
    name = "Goblin",
    level = resolvers.rngrange(1, 5),      -- 等 resolve 再算
    talents = resolvers.talents{[T_ATTACK]=1},
}

-- 實例期
local npc = npc_proto:clone()
npc:resolve()  -- 此時 level 變成真實數字，talents 被學習
```

---

## 3. Resolver 系統 (`engine/resolvers.lua`)

Resolver 是一個「延遲計算」框架，讓實體定義可以包含亂數、條件邏輯，直到 resolve 時才實際執行。

### 3.1 Resolver 結構

```lua
resolvers.foo(...)    -- 回傳 {__resolver="foo", ...data...}
resolvers.calc.foo(t, e)  -- 實際計算，t=resolver table，e=entity
```

- `__resolve_instant = true`：在其他 resolver 之前優先執行。

### 3.2 內建 Resolvers

| Resolver | 說明 |
|----------|------|
| `resolvers.rngrange(x, y)` | 隨機整數 [x, y] |
| `resolvers.rngfloat(x, y)` | 隨機浮點數 |
| `resolvers.rngavg(x, y)` | 平均隨機（更集中於中間值） |
| `resolvers.dice(x, y)` | xdy 擲骰 |
| `resolvers.rngtable(t)` | 從 table 隨機取一個值 |
| `resolvers.mbonus(max, add)` | 依當前層數縮放的加成（越深越強） |
| `resolvers.talents(list)` | 學習技能列表 |
| `resolvers.rngtalent(list)` | 從列表隨機學一個技能 |
| `resolvers.rngtalentsets(list)` | 從集合隨機選一組技能 |
| `resolvers.tmasteries(list)` | 設定技能類型熟練度 |
| `resolvers.inventory(list)` | 生成物品放入揹包 |
| `resolvers.drops(list)` | 定義死亡掉落物 |
| `resolvers.equip(list)` | 生成物品並裝備 |
| `resolvers.racial()` | 種族特性 |
| `resolvers.sustains_at_birth()` | 出生時啟動持續技能 |

`resolvers.current_level` 是全域變數，生成前由 Zone 設定，讓 mbonus 等 resolver 感知當前深度。
