熟練度影響技能的效果上限。`getTalentMastery()` 在技能公式中常見：

```lua
-- 技能內部用 getTalentMastery 來縮放效果：
local mastery = self:getTalentTypeMastery("blood/sanguination")
-- 返回值：0.3（初始值）到 1.0+（用點解鎖後）

-- 實際應用範例：
local dam = base_dam * mastery
```

**設定初始熟練度的方式**：

```lua
-- 方式 1：在 talents_types 中設定（推薦）
talents_types = {
    ["blood/sanguination"] = {true, 0.3},  -- 0.3 = 基礎熟練度加成
    -- 實際熟練度 = 1.0 + 0.3 = 1.3（因為引擎以 1.0 為基礎）
},

-- 方式 2：在 copy 中用 resolvers 設定（用於更精細控制）
copy = {
    resolvers.talents_types_mastery{
        ["blood/sanguination"] = 0.4,  -- 覆蓋 talents_types 中的值
    },
},
```

**讓玩家提升熟練度**：在技能 UI 中按 `+` 鍵投入「熟練度點數」（mastery point），需要在 Birther 中設定玩家有多少點可以分配。ToME 標準是每 10 級一個熟練度點。

---
