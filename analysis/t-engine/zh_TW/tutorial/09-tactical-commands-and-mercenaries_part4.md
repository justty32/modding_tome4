## 步驟五：傭兵模板

### 站位系統：faction

TE4 用 `faction` 字串決定友敵關係。`Faction:factionReaction(f1, f2)` 回傳 ≥ 0（友好/中立）或 < 0（敵對）。`target_simple` AI 會找 `reactionToward(act) < 0` 的目標攻擊。

將傭兵的 `faction` 設為 `"players"` 即可讓他們自動將所有敵人視為攻擊目標：

```lua
faction = "players"   -- 與玩家同陣營，視 monsters faction 為敵
```

### 檔案：`mod/data/npcs/mercenaries.lua`

```lua
-- mod/data/npcs/mercenaries.lua
-- 可招募的傭兵模板
-- 使用 define_as 讓 zone:makeEntityByName 可以精確找到這個模板

local NPC = require "mod.class.NPC"   -- 使用你模組的 NPC 類別

-- ── 鐵衛士（近戰型） ─────────────────────────────────────────
newEntity{
    define_as = "MERC_WARRIOR",
    type = "humanoid", subtype = "human",
    name = "鐵衛士", -- 招募後可被重命名
    display = "@", color = {r=150, g=200, b=255},

    -- 陣營設為 players，自動敵視 monsters
    faction = "players",

    -- 使用我們的指令 AI
    ai = "commanded_ally",
    ai_state = {
        ai_move = "move_simple",
    },

    -- 屬性與等級
    level_range = {1, 10},
    exp_worth   = 0,    -- 殺死不給玩家經驗（傭兵是隊友不是獎勵）
    rank        = 2,

    max_life    = resolvers.rngrange(80, 120),
    life_rating = 12,
    stats = {str=16, dex=12, con=14, mag=5, wil=8, cun=10},

    -- 自動依等級成長
    autolevel = "warrior",

    -- 出生時裝備（resolvers.equip 在 resolve 時執行）
    resolvers.equip{
        {type="weapon", subtype="longsword", defined="IRON_LONGSWORD", random_art_replace={base_list="mod:data/general/objects/weapons.lua"}},
        {type="armor",  subtype="heavy",     defined="IRON_MAIL_ARMOUR"},
    },
}

-- ── 森林弓手（遠程型） ───────────────────────────────────────
newEntity{
    define_as = "MERC_ARCHER",
    type = "humanoid", subtype = "elf",
    name = "森林弓手",
    display = "@", color = {r=100, g=220, b=100},

    faction    = "players",
    ai         = "commanded_ally",
    ai_state   = {ai_move = "move_simple"},

    level_range = {1, 10},
    exp_worth   = 0,
    rank        = 2,

    max_life    = resolvers.rngrange(55, 80),
    life_rating = 9,
    stats = {str=10, dex=18, con=10, mag=5, wil=10, cun=14},

    autolevel   = "archer",

    resolvers.equip{
        {type="weapon", subtype="longbow", defined="ELM_LONGBOW"},
        {type="ammo",   subtype="arrow",   defined="ARROW", nb_object=resolvers.rngrange(20, 40)},
    },
}

-- ── 流浪法師（魔法型） ───────────────────────────────────────
newEntity{
    define_as = "MERC_MAGE",
    type = "humanoid", subtype = "human",
    name = "流浪法師",
    display = "@", color = {r=200, g=100, b=255},

    faction    = "players",
    ai         = "commanded_ally",
    ai_state   = {ai_move = "move_simple", talent_in = 2}, -- 更常使用技能

    level_range = {1, 10},
    exp_worth   = 0,
    rank        = 2,

    max_life    = resolvers.rngrange(40, 60),
    life_rating = 7,
    stats = {str=8, dex=10, con=8, mag=20, wil=14, cun=12},

    autolevel   = "mage",

    talents = {
        [T_FIREBALL] = 3,
        [T_LIGHTNING] = 2,
    },
}
```

> **`exp_worth = 0`**：傭兵死亡不給玩家額外經驗，避免玩家刻意讓傭兵送死刷 XP。
>
> **`ai_state.talent_in = 2`**：`dumb_talented_simple` AI 每 `talent_in` 回合才用一次技能（預設 6）。設為 2 讓法師更積極施法。

---

