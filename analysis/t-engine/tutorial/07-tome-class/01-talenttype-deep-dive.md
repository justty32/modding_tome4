`newTalentType{}` 宣告一個技能分類（技能樹）。ToME 的技能以 `"category/subcategory"` 格式組織。

### 1.1 完整欄位說明

```lua
newTalentType{
    -- ── 必填 ──────────────────────────────────────────────────
    type        = "blood/sanguination",   -- 識別符：category/sub
    name        = "血術精通",             -- 顯示名稱（技能樹標題）

    -- ── 常用選項 ───────────────────────────────────────────────
    description = "操控血液的古老力量。", -- 描述（滑鼠懸停時顯示）

    -- generic = true：「通用」技能樹
    --   → 在 Birther 的 talents_types 表格中，false/true 第一個元素用 false 表示未解鎖
    --   → 通用技能點數（unused_generics）消費，而非職業點數（unused_talents）
    --   → 不同的成長曲線（通常較通用技能較弱）
    -- generic = false 或不設（預設）：職業技能樹，消費 unused_talents
    generic     = false,

    -- allow_random = true：允許此技能樹的技能被隨機 Boss 隨機習得
    -- allow_random = false（預設）：此技能樹不會隨機出現在 Boss 身上
    allow_random = true,

    -- not_on_random_boss = true：即使 allow_random=true，也不讓技能樹本身
    --   出現在隨機 Boss 的技能類型列表中（個別技能仍可能被選中）
    not_on_random_boss = true,

    -- min_require：此技能樹的技能要求最少的屬性值才能加點
    -- 實際上這個欄位控制的是 Birther 展示時是否顯示屬性需求
    -- 技能的實際需求在 newTalent 的 require 中定義
    min_require = { stat = { mag=20 } },

    -- on_mastery_change：當玩家改變此技能樹熟練度時呼叫
    on_mastery_change = function(self, mastery, tt)
        -- self = Actor, mastery = 新熟練度值, tt = 技能樹 type 字串
        -- 可以在這裡更新相依屬性
    end,
}
```

### 1.2 category 與 subcategory 的關係

```
type = "blood/sanguination"
         ↑         ↑
    category    subcategory

category = "blood"          ← 大類別（如 technique, cunning, spell, gift）
subcategory = "sanguination" ← 小類別（技能樹名稱）
```

引擎自動從 type 提取 `category`（第一個 `/` 前）。同一個 category 下的技能樹，在技能 UI 中會分組顯示。

---
