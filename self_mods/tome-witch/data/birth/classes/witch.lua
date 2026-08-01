-- 女巫（Witch）—— 全新 class，非既有 class 的子職業。
--
-- 完整的「新 class」比「子職業」多兩個白名單關卡，缺一不可：
--
-- 1) class 自己的 descriptor_choices.subclass：__ALL__="disallow" 白名單制，
--    Birther:generateClasses 只把 subclass 清單裡 allow 的子職業掛到這個 class 底下
--    （M/mod/dialogs/Birther.lua:950-956）。
--
-- 2) 世界 descriptor_choices.class：Maj'Eyal / Infinite / Arena 三個世界共用
--    default_eyal_descriptors{ class = { __ALL__ = "disallow", ... } }
--    （M/data/birth/worlds.lua:20-62），不 allow 的話建角畫面根本看不到這個 class
--    （Birther.lua:943-946 的 isDescriptorAllowed 直接放行不了）。
--    實證範本：vendor/orig/neka_therianthropy_summoner/data/birth/classes/summon.lua:986-988。
--
-- 檔案被 loadDefinition 載入時，ActorTalents / Birther 都是全域可用的 API 物件
-- （本檔是在 ToME:load hook 的閉包內被執行，與 hooks/load.lua 頂端的 require 無關）。

newBirthDescriptor {
    type = "class",
    name = "Witch", -- 保持 ASCII：short_name 由此生成（WITCH）。顯示名走 locale。
    desc = {
        "女巫與草藥共鳴，調配魔藥、萃取藥露，以藥草知識在戰鬥中求生。",
        "她們的力量來自對植物的深刻理解，而非蠻橫的法力傾瀉。",
    },
    descriptor_choices = {
        subclass = {
            __ALL__ = "disallow",
            Witch = "allow",
        },
    },
    copy = {
        mana_regen = 0.5,
        mana_rating = 7,
        -- 起始銘文欄位只有 3 個（M/mod/class/interface/ActorInscriptions.lua:30），
        -- 法師系預設的「法力風暴符文」＋基礎「回覆／狂暴紋身」已佔滿，
        -- 多加的會被 setInscription 靜默丟棄。女巫的回血走 spell/herbalism 的生命藥露。
    },
}

newBirthDescriptor {
    type = "subclass",
    name = "Witch",
    desc = {
        "女巫是草藥與魔藥的調配者。",
        "她的招牌技能樹「草藥」涵蓋毒藥、藥露與藥草知識——",
        "先以藥草知識強化體魄，再以女巫魔藥削弱敵人，最後用生命藥露維繫自己。",
        "最重要的屬性是：魔法與靈巧。",
        "#GOLD#屬性修正：",
        "#LIGHT_BLUE# * +0 力量、+0 敏捷、+0 體質",
        "#LIGHT_BLUE# * +5 魔法、+2 意志、+3 靈巧",
        "#GOLD#每級生命：#LIGHT_BLUE# -1",
    },
    power_source = { arcane = true, nature = true },
    stats = { mag = 5, wil = 2, cun = 3 },
    -- {已知?, 熟練度}。false = 該樹存在但未解鎖，需花類別點數才能開
    -- （engine/Birther.lua:408-421 → learnTalentType）。
    talents_types = {
        -- 招牌樹：草藥。起手就開、高熟練度。
        ["spell/herbalism"] = { true, 1.3 },
    },
    talents = {
        [ActorTalents.T_MANA_POOL]       = 1, -- 法力池；沒有它法力恆為 0
        [ActorTalents.T_WITCH_HERB_LORE] = 1, -- 藥草知識：起手就有的被動
        [ActorTalents.T_WITCH_BREW]      = 1, -- 女巫魔藥：起手就能放的主動技
    },
    copy = {
        max_life = 90,
        life_rating = 9,
        mana_regen = 0.5,
        resolvers.equipbirth {
            { type = "weapon", subtype = "staff", name = "elm staff", autoreq = true, ego_chance = -1000 },
            { type = "armor",  subtype = "cloth", name = "linen robe", autoreq = true, ego_chance = -1000 },
        },
        -- power_source 在 Birther:apply() 並沒有被讀取（engine/Birther.lua:370-446），
        -- 只有多重職業流程會複製它。單一主職業必須自己塞進 copy。
        power_source = { arcane = true, nature = true },
    },
    experience = 1.0,
}

-- 世界白名單：不 allow 的話建角畫面根本不會出現 Witch 這個 class
-- （worlds.lua:36-50 的 class = { __ALL__ = "disallow", ... }）。
for _, world in ipairs { "Maj'Eyal", "Infinite", "Arena" } do
    getBirthDescriptor("world", world).descriptor_choices.class.Witch = "allow"
end
