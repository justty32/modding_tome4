`require` 控制玩家何時能加點到這個技能。支援靜態值和動態函數：

```lua
require = {
    -- 屬性要求：每個等級都可以有不同要求
    stat = {
        mag = function(level) return 12 + level * 5 end,
        -- level 1：需要 mag 17
        -- level 2：需要 mag 22，以此類推
        -- 也可以是靜態數字：mag = 20
    },

    -- 等級要求
    level = function(level) return -5 + level * 4 end,
    -- level 1：-5 + 4 = 角色 -1 級才能加（實際上無限制）
    -- level 3：-5 + 12 = 角色 7 級以上

    -- 前置技能要求（最常用的依賴鏈機制）
    talent = {
        -- 格式1：{技能ID, 需要的等級}
        {self.T_BLOOD_DRAIN, 2},   -- 需要「血液汲取」學到第 2 級

        -- 格式2：只要學過（任意等級）
        self.T_BLOOD_MASTERY,

        -- 格式3：{技能ID, false} 表示「不能學過這個技能」（互斥）
        -- {self.T_HOLY_LIGHT, false},
    },

    -- 出身需求（此職業才能學）
    birth_descriptors = {
        {"subclass", "Sanguinist"},  -- 只有血術師才能學此技能
    },

    -- 特殊條件（自訂邏輯）
    special = {
        desc = "必須吸收過至少一個敵人的生命",
        fct  = function(self, t, offset)
            return (self.blood_absorbed or 0) >= 1
        end,
    },
}
```

**技能依賴鏈示意圖**：

```
血術精通（被動）  ← 位置 1，無前置
    ↓ 需要 1 點
血液汲取（主動）  ← 位置 2，require.talent = {T_BLOOD_MASTERY}
    ↓ 需要 2 點
血盾屏護（持續）  ← 位置 3，require.talent = {T_BLOOD_DRAIN, 2}
    ↓ 需要 2 點
血液爆發（主動）  ← 位置 4（最強技能），require.talent = {T_BLOOD_SHIELD, 2}
```

---
