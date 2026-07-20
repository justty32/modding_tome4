-- 把「盧恩術士」掛進既有的 Mage class。
--
-- 這個檔案不會被自動掃描——addon 的 data/ 掛在私有的 /data-runewright/
-- （engine/Module.lua:498-503），必須由 hooks/load.lua 呼叫
-- Birther:loadDefinition("/data-runewright/birth/classes/mage.lua")。
-- 實證範例：~/repo/moddings/tome4/external/orig/arcanum/hooks/load.lua:47-54

local ActorTalents = require "engine.interface.ActorTalents"

newBirthDescriptor {
    type = "subclass",
    name = "Runewright", -- 保持 ASCII：short_name 由此生成（RUNEWRIGHT）。中文名走 locale。
    desc = {
        "盧恩術士不是符文的使用者，而是符文的書寫者。",
        "他們把奧術之力銘刻於自身，每一次引動銘文都在體內累積符文充能；",
        "而當身上的銘文構成特定組合時，會產生共鳴，帶來意想不到的力量。",
        "他們的力量來自對銘文本質的理解，而非蠻橫的法力傾瀉。",
    },
    power_source = { arcane = true },
    stats = { mag = 5, wil = 3, cun = 2 },
    -- {已知?, 熟練度}。false = 該樹存在但未解鎖，需花類別點數才能開
    -- （engine/Birther.lua:408-421 → learnTalentType）。
    -- 三族（ættir）刻意只開第一族：第二、三族留給玩家用類別點解鎖，
    -- 呼應「符文是循序習得的」這個設定。
    talents_types = {
        -- 核心：資源引擎
        ["spell/runecraft"]        = { true, 0.3 },
        ["spell/runic-mastery"]    = { true, 0.3 },
        ["spell/inscription-lore"] = { true, 0.2 },
        -- 古弗薩克文三族
        ["spell/futhark-freyr"]    = { true, 0.2 },
        ["spell/futhark-heimdall"] = { false, 0.2 },
        ["spell/futhark-tyr"]      = { false, 0.2 },
        -- 雜項
        ["spell/staff-combat"]     = { true, 0.0 },
        ["cunning/survival"]       = { false, 0.0 },
    },
    talents = {
        [ActorTalents.T_MANA_POOL]         = 1,
        [ActorTalents.T_RUNE_CHARGE_POOL]  = 1, -- 沒有它，getRunecharge() 恆回 0
        [ActorTalents.T_RW_ENGRAVE_RUNE]   = 1,
        [ActorTalents.T_RW_RUNIC_MASTERY]  = 1,
        -- 起手就給「共鳴之心」：起始銘文是護盾符文 + 治療輸能，正好觸發壁壘共鳴。
        -- 共鳴是這個職業的招牌機制，不該讓玩家等到升級才第一次看到它運作。
        [ActorTalents.T_RW_RESONANT_MIND]  = 1,
        -- 符文盤是純 UI，不花技能點，直接給。玩家看不到共鳴在做什麼的話，這個職業就沒了。
        [ActorTalents.T_RW_RUNEBOARD]      = 1,
    },
    copy = {
        max_life = 90,
        life_rating = 9,
        mana_regen = 0.5,
        resolvers.equipbirth {
            { type = "weapon", subtype = "staff", name = "elm staff", autoreq = true, ego_chance = -1000 },
            { type = "armor",  subtype = "cloth", name = "linen robe", autoreq = true, ego_chance = -1000 },
        },
        -- 不加 resolvers.inscription：銘文欄位預設只有 3 個，法師系的
        -- 「法力風暴符文」＋ 基礎的「回覆／狂暴紋身」已經佔滿。
        -- 多加的會被 setInscription 靜默丟棄（ActorInscriptions.lua:72，建角時 vocal=false）。
        -- 「泉湧共鳴」就是為了這組原版預設而設計的：不動起始配裝，也就沒有平衡問題，
        -- 玩家第一回合就看得到共鳴運作。額外欄位由 spell/inscription-lore 提供。
        -- power_source 在 Birther:apply() 並沒有被讀取（engine/Birther.lua:370-446），
        -- 只有多重職業流程會複製它。單一主職業必須自己塞進 copy。
        power_source = { arcane = true },
    },
    experience = 1.0,
}

-- 加進 Mage 的子職業白名單。Mage 的 descriptor_choices.subclass 是 __ALL__ = "disallow"
--（modules/tome/data/birth/classes/mage.lua:40-49），不明確 allow 就選不到。
-- getBirthDescriptor 只是讀寫全域表（engine/Birther.lua:86-89），沒有重掃機制。
getBirthDescriptor("class", "Mage").descriptor_choices.subclass.Runewright = "allow"
