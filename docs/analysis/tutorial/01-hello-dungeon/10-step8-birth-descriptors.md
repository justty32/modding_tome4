`Birther` 是 TE4 的角色創建流程。你需要定義描述符（職業/種族）讓玩家選擇：

```lua
-- game/modules/hellodungeon/data/birth/descriptors.lua

-- 基礎描述符：所有角色共有的基本屬性
newBirthDescriptor{
    type = "base",
    name = "base",
    desc = {},              -- 說明文字（顯示在角色創建畫面）
    experience = 1.0,       -- 經驗值倍率

    -- 直接複製這些屬性到玩家身上
    copy = {
        max_level = 10,
        lite = 4,           -- 照明範圍（格）
        max_life = 25,
    },
}

-- 職業選項 1：破壞者（近戰）
newBirthDescriptor{
    type = "role",
    name = "Destroyer",
    desc = {
        "以蠻力席捲一切！",
        "起始技能：踢擊",
    },
    -- 出生時學習的技能
    talents = {
        [ActorTalents.T_KICK] = 1,
    },
    -- 直接複製到角色的屬性
    copy = {
        stats = {str=14, dex=8, con=12},
    },
}

-- 職業選項 2：酸液狂（法術）
newBirthDescriptor{
    type = "role",
    name = "Acid-maniac",
    desc = {
        "以酸液溶解一切！",
        "起始技能：酸液噴射",
    },
    talents = {
        [ActorTalents.T_ACID_SPRAY] = 1,
    },
    copy = {
        stats = {str=8, dex=14, con=10},
    },
}
```

**角色創建流程**：引擎自動生成選擇畫面，玩家依序從各 `type` 中選一個描述符，最後合併所有 `copy` 和 `talents`。

在 `Game.lua` 中啟動 Birther 時，指定需要選擇哪些 `type`：

```lua
-- 讓玩家依序選擇 "base" 和 "role" 兩個描述符
Birther.new(nil, self.player, {"base", "role"}, function()
    -- 角色創建完成後的回呼
    self:changeLevel(1, "dungeon")
end)
```

---
