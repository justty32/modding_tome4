## 5. Birther subclass 深度解析

`newBirthDescriptor` 的 `subclass` 類型定義職業在角色創建時的所有屬性：

```lua
-- game/addons/sanguinist/data/birth/classes/sanguinist.lua

-- 大類別（class）：讓血術師在職業選單中有自己的分類
-- 這個定義控制「選職業大類時看到什麼」
newBirthDescriptor{
    type = "class",
    name = "血術師",   -- 大類別名稱
    desc = {
        "血術師以血液為媒介施展古老的禁忌魔法，",
        "能汲取敵人的生命力，以鮮血鑄造護盾。",
    },
    -- descriptor_choices：限制這個大類別下可選的小類別
    descriptor_choices = {
        subclass = {
            __ALL__ = "disallow",
            ["Sanguinist"] = "allow",
        },
    },
    copy = {
        -- 大類別共用屬性（所有血術師子職業都繼承）
        max_life = 90,
    },
}

-- ════════════════════════════════════════════════════
-- 子職業（subclass）：核心定義
-- ════════════════════════════════════════════════════
newBirthDescriptor{
    type = "subclass",
    name = "Sanguinist",    -- 職業名稱（英文，也是 ActorTalents.T_XXX 的查找鍵）
    desc = {
        "血術師是掌握禁忌血液魔法的法師，",
        "他們以血液為燃料，汲取敵人的生命以延續自身。",
        "血術師的防禦能力極強，但需要謹慎管理生命值。",
        "",
        "#GOLD#重要屬性：",
        "#LIGHT_BLUE# * 魔力（Magic）：影響血術技能的傷害和效果",
        "#LIGHT_BLUE# * 體質（Constitution）：影響最大生命值",
        "#GOLD#每級生命：#LIGHT_BLUE# +2",
    },

    -- 加點的力量來源（用於與物品的相容性判斷）
    -- technique = 肉體技能, arcane = 奧術, nature = 自然, psionic = 靈能
    power_source = {arcane=true},

    -- 起始屬性加點
    stats = {
        mag = 5,    -- 魔力 +5
        con = 2,    -- 體質 +2
        str = -1,   -- 力量 -1（血術師不擅長近戰）
    },

    -- 技能樹訪問權（talents_types）
    -- 格式：["type/subtype"] = {已解鎖, 初始熟練度}
    -- true = 角色創建時就能見到此技能樹
    -- false = 未解鎖（需要特殊條件才能訪問）
    -- 熟練度：0.3 = 起始技能消耗效率 1.3 倍（基礎是 1.0）
    talents_types = {
        -- 血術師專屬技能樹
        ["blood/sanguination"]   = {true,  0.3},  -- 主技能樹，已解鎖

        -- 通用技能樹（大多數職業都有）
        ["spell/arcane"]         = {false, 0.2},  -- 奧術（未解鎖，可花點解鎖）
        ["cunning/survival"]     = {true,  0.2},  -- 求生技巧
        ["technique/combat-training"] = {false, 0.0},  -- 戰鬥訓練（弱）
    },

    -- 起始技能（從技能定義中直接習得）
    -- 使用 ActorTalents 上的常數（在 data/talents/blood.lua 載入後自動定義）
    talents = {
        [ActorTalents.T_BLOOD_MASTERY] = 1,  -- 血術精通第 1 點
        [ActorTalents.T_BLOOD_DRAIN]   = 1,  -- 血液汲取第 1 點
    },

    -- 技能樹熟練度（額外加成，在 talents_types 的基礎熟練度之上）
    -- 通常在 copy 中用 resolvers 設定
    -- （見第 8 節）

    -- copy：會被「複製貼上」到角色上的屬性
    -- 這裡放的是複雜的 resolver 和特殊屬性
    copy = {
        -- 每級生命加成
        life_rating = 12,    -- 比 warrior（14）少，比 mage（8）多

        -- 每級魔力回復
        mana_regen = 0.5,

        -- 起始魔力
        max_mana = 100,

        -- 不受鎧甲施法懲罰（血術師用布甲）
        -- combat_spellpower 的計算（由 ToME 的 Armor 系統管理）

        -- 起始裝備（見第 7 節詳細說明）
        equipment = resolvers.equipbirth{ id=true,
            -- 一件布甲（輕型防護）
            {type="armor", subtype="cloth", name="linen robe",
             autoreq=true, ego_chance=-1000},
            -- 一根木杖
            {type="weapon", subtype="staff", name="elm staff",
             autoreq=true, ego_chance=-1000},
        },

        -- 起始揹包物品（不裝備，直接放入揹包）
        inventory = resolvers.inventorybirth{ id=true,
            -- 3 瓶治癒藥水（使用 define_as 精確指定）
            {type="potion", subtype="potion", defined="POTION_REGENERATION",
             ego_chance=-1000},
            {type="potion", subtype="potion", defined="POTION_REGENERATION",
             ego_chance=-1000},
        },

        -- 角色外觀（裝備模型貼圖）
        moddable_attachement_spots = "mage",
    },
}
```

---

## 6. descriptor_choices：種族與職業相容性

`descriptor_choices` 控制「選擇 A 後，B 的選項如何被過濾」。最常見的是種族-職業相容性：

```lua
-- 在 subclass 定義中設定哪些種族可以選擇此職業：
descriptor_choices = {
    -- 過濾 "race" 類型的描述符
    race = {
        -- 允許所有種族（不設限制）
        __ALL__ = "allow",
    },
    -- 或者只允許特定種族：
    -- race = {
    --     __ALL__  = "disallow",
    --     ["Human"] = "allow",
    --     ["Elf"]   = "allow",
    -- },
}

-- 在 race 定義中也可以設定哪些職業兼容：
-- （位於 data/birth/races/xxx.lua）
newBirthDescriptor{
    type = "race",
    name = "Human",
    descriptor_choices = {
        subclass = {
            -- 允許玩家選擇血術師
            ["Sanguinist"] = "allow",
            -- 其他職業的 allow/disallow 由各職業的 subclass 定義控制
        },
    },
    -- ...
}
```

**相容性邏輯**：種族和職業的 `descriptor_choices` 取**交集**。只有兩邊都 `"allow"` 的組合才能被玩家選擇。

---

## 7. resolvers.equipbirth 與 resolvers.inventorybirth

這兩個 resolver 是 ToME 特有的，**專門用於角色創建時**的裝備初始化：

```lua
-- equipbirth：嘗試自動裝備到適當槽位
equipment = resolvers.equipbirth{ id=true,   -- id=true：物品自動鑑定
    -- 每個表格是一個物品篩選條件
    {
        type = "weapon", subtype="staff",
        name = "elm staff",      -- 精確名稱匹配
        autoreq = true,          -- 自動提升屬性/等級以滿足需求（角色創建常用）
        ego_chance = -1000,      -- 不生成附魔（確保是基礎版）
        ignore_material_restriction = true,  -- 忽略材料等級限制（equipbirth 默認啟用）
    },
    -- 也可以用更寬鬆的條件（讓系統隨機選）
    {
        type = "armor",
        subtype = "cloth",
        autoreq = true,
        ego_chance = -1000,
    },
},

-- inventorybirth：放入揹包（不裝備）
inventory = resolvers.inventorybirth{ id=true,
    {type="potion", subtype="potion"},  -- 任意藥水
    {type="potion", defined="POTION_REGENERATION"},  -- 精確指定物品 define_as
},
```

**`resolvers.equip` vs `resolvers.equipbirth` 的差異**：

| 欄位 | equip（NPC 用） | equipbirth（出生用） |
|------|----------------|---------------------|
| 材料限制 | 遵守 zone 的 material_level | 忽略（可以在任何材料等級） |
| 使用場景 | NPC 的 resolvers.equip{} | 角色創建的 copy.equipment |
| autoreq | 不常用 | 推薦使用，確保能穿上 |

---

