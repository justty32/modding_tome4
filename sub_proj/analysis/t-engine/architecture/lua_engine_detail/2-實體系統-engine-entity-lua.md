### 2.1 核心屬性

```lua
-- 每個 Entity 都有唯一的 uid
self.uid = next_uid
__uids[self.uid] = self   -- 全局弱引用表，可用 uid 快速查找
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
