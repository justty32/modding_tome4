# 教學 07：為 ToME 新增職業與技能樹（進階 Addon）

> **目標**：深入 ToME 的職業系統，製作一個完整的新職業「血術師（Sanguinist）」：自訂技能類型（TalentType）、五個技能（含被動、施放、持續）、依賴鏈、熟練度系統、Birther 整合、起始裝備，以及種族相容性設定。
>
> **前置條件**：閱讀並理解教學 06（Addon 基礎）。本教學是教學 06「暗影刺客」的直接延伸，聚焦在教學 06 沒有詳細說明的進階細節。

---

## 目錄

1. [TalentType 深度解析](#1-talenttype-深度解析)
2. [newTalent 所有選項](#2-newtalent-所有選項)
3. [require：前置條件完整規格](#3-require前置條件完整規格)
4. [技能依賴鏈範例（五個技能）](#4-技能依賴鏈範例)
5. [Birther subclass 深度解析](#5-birther-subclass-深度解析)
6. [descriptor_choices：種族與職業相容性](#6-descriptor_choices-種族與職業相容性)
7. [resolvers.equipbirth 與 resolvers.inventorybirth](#7-resolversequipbirth-與-resolversinventorybirth)
8. [熟練度系統（Mastery）](#8-熟練度系統mastery)
9. [完整 Addon 實作](#9-完整-addon-實作)
10. [測試與除錯技巧](#10-測試與除錯技巧)
11. [常見錯誤排查](#11-常見錯誤排查)

---

## 1. TalentType 深度解析

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

