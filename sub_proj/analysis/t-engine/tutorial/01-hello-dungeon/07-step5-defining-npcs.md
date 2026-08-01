先建立全域 NPC 庫（`data/general/npcs/kobold.lua`），再在地區中引用它。

**全域庫（`data/general/npcs/kobold.lua`）**：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua

local Talents = require("engine.interface.ActorTalents")

-- 科博德基礎定義（所有科博德的共同屬性）
newEntity{
    define_as = "BASE_NPC_KOBOLD",
    type = "humanoid", subtype = "kobold",
    display = "k", color = colors.WHITE,
    desc = _t[[醜陋的綠色小傢伙！]],

    -- AI：使用內建的 "dumb_talented_simple"
    -- talent_in=3 表示平均每 3 回合使用一次技能
    ai = "dumb_talented_simple", ai_state = { talent_in = 3 },

    stats = { str=5, dex=5, con=5 },
    combat_armor = 0,
}

-- 具體的科博德戰士（繼承自 BASE_NPC_KOBOLD）
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "kobold warrior", color = colors.GREEN,
    level_range = {1, 4},
    exp_worth = 1,      -- 擊殺獲得的經驗值倍率
    rarity = 4,         -- 稀有度（越高越少見）
    max_life = resolvers.rngavg(5, 9),  -- 生命值（隨機平均）
    combat = { dam = 2 },               -- 近戰基礎傷害
}

-- 重甲科博德（較強版本，出現在更高層）
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "armoured kobold", color = colors.AQUAMARINE,
    level_range = {5, 10},
    exp_worth = 1,
    rarity = 4,
    max_life = resolvers.rngavg(10, 12),
    combat_armor = 3,   -- 護甲值（減少受到的傷害）
    combat = { dam = 5 },
}
```

**地區 NPC 引用（`data/zones/dungeon/npcs.lua`）**：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/npcs.lua

-- 載入全域 NPC 定義到此地區
load("/data/general/npcs/kobold.lua")

-- 你也可以在這裡加入只有這個地區才有的 NPC
-- newEntity{ base = "BASE_NPC_KOBOLD",
--     name = "dungeon kobold champion", ...
-- }
```

**NPC 屬性速查**：

| 屬性 | 說明 |
|------|------|
| `define_as` | 唯一識別符（大寫），用於 `base` 繼承和 `guardian` 指定 |
| `base` | 繼承的基底定義（複製全部屬性後覆蓋）|
| `display` | 顯示字元（ASCII 模式）|
| `level_range` | 出現的樓層等級範圍 |
| `rarity` | 稀有度（越高越少出現）|
| `exp_worth` | 擊殺給予的經驗值係數 |
| `ai` | AI 類型（`"dumb_talented_simple"` 是最常用的基礎 AI）|
| `combat.dam` | 裸手近戰傷害 |
| `combat_armor` | 護甲值 |
| `max_life` | 最大生命值（可用 `resolvers.rngavg(min, max)` 隨機）|

---
