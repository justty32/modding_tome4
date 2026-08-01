-- 提爾之族（Tyr's Ætt）—— 古弗薩克文的第三族，主題是勝利、人倫與傳承。
--
-- 第三族以 Tiwaz（戰神提爾）起首，以 Othala（祖產）收尾——
-- 從個人的勝利走到世代的傳承，是整套符文的終章。這裡取其四：
--   ᛏ Tiwaz  戰神之矛、公正的勝利  → 高傷單體，消耗充能
--   ᛖ Ehwaz  駿馬、伙伴、疾行      → 機動
--   ᛗ Mannaz 人、自我、群體        → 共鳴的力量
--   ᛟ Othala 祖產、繼承、家土      → 終極技，把充能與共鳴一次兌現

local DamageType = require "engine.DamageType"

newTalentType {
    type = "spell/futhark-tyr",
    name = "提爾之族",
    description = "古弗薩克文的第三族。傳承之符，把累積的充能與共鳴化為決定性的一擊。",
    generic = false,
    allow_random = true,
}

newTalent {
    name = "提瓦茲・勝利之矛",
    short_name = "RW_TIWAZ",
    image = "talents/arcane_bolts.png",
    type = { "spell/futhark-tyr", 1 },
    mode = "activated",
    points = 5,
    mana = 20,
    cooldown = 7,
    range = 7,
    is_spell = true,
    requires_target = true,
    tactical = { ATTACK = { ARCANE = 3 } },
    target = function(self, t)
        return { type = "bolt", range = self:getTalentRange(t), talent = t,
                 display = { particle = "bolt_arcane", trail = "arcanetrail" } }
    end,
    getDamage = function(self, t) return 30 + self:combatTalentSpellDamage(t, 25, 300) end,
    -- 每點充能額外加成，但不強制消耗——沒充能也能用，只是弱
    getBonusPerCharge = function(self, t) return 0.06 + self:getTalentLevel(t) * 0.02 end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        local charges = self:getRunecharge()
        local dam = t.getDamage(self, t) * (1 + charges * t.getBonusPerCharge(self, t))
        self:projectile(tg, x, y, DamageType.ARCANE, self:spellCrit(dam), { type = "manathrust" })
        game:playSoundNear(self, "talents/arcane")
        if charges > 0 then self:incRunecharge(-charges) end
        return true
    end,
    info = function(self, t)
        return ("提爾以右手餵養巨狼，換取諸神的勝利。\n\n擲出符文之矛，造成 %0.1f 點奧術傷害。\n每點符文充能使傷害提升 %d%%，施放後消耗全部充能。"):
            format(self:damDesc("ARCANE", t.getDamage(self, t)), t.getBonusPerCharge(self, t) * 100)
    end,
}

newTalent {
    name = "埃瓦茲・駿馬",
    short_name = "RW_EHWAZ",
    image = "talents/rune__controlled_phase_door.png",
    type = { "spell/futhark-tyr", 2 },
    mode = "activated",
    points = 5,
    mana = 14,
    cooldown = 14,
    is_spell = true,
    no_energy = true, -- 施放不耗行動：逃命技才有意義（mod/class/Actor.lua:5800 用 util.getval 取值）
    tactical = { ESCAPE = 2 },
    getSpeed = function(self, t) return 0.2 + self:getTalentLevel(t) * 0.1 end,
    getDuration = function(self, t) return 3 + math.floor(self:getTalentLevel(t) / 2) end,
    action = function(self, t)
        self:setEffect(self.EFF_RW_STEED, t.getDuration(self, t), { speed = t.getSpeed(self, t) })
        game.level.map:particleEmitter(self.x, self.y, 1, "ball_teleport", { radius = 1 })
        game:playSoundNear(self, "talents/teleport")
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("馬與騎者是一體的。\n\n%d 回合內移動速度 +%d%%。施放不消耗行動。\n獲得 1 點符文充能。"):
            format(t.getDuration(self, t), t.getSpeed(self, t) * 100)
    end,
}

newTalent {
    name = "曼納茲・人之符",
    short_name = "RW_MANNAZ",
    image = "talents/arcane_eye.png",
    type = { "spell/futhark-tyr", 3 },
    mode = "passive",
    points = 5,
    -- 這個天賦的效果是「動態」的：隨啟動中的共鳴數量而變。
    -- 因此不寫在 passives（那只在學習時算一次），
    -- 而由 superload/mod/class/Actor.lua 的 runewrightSyncResonances() 在共鳴變動時重算。
    getPowerPerResonance = function(self, t) return 3 + self:getTalentLevel(t) * 2 end,
    info = function(self, t)
        local active = self:runewrightResonances()
        return ("一個人是諸多關係的總和。\n\n每個啟動中的共鳴，賦予你 +%d 點法術強度。\n\n#LIGHT_GREEN#目前啟動中的共鳴：%d 個（法術強度 +%d）#LAST#\n\n#GREY#需要學會「共鳴之心」才會有共鳴。#LAST#"):
            format(t.getPowerPerResonance(self, t), #active, #active * t.getPowerPerResonance(self, t))
    end,
}

newTalent {
    name = "奧薩拉・祖產",
    short_name = "RW_OTHALA",
    image = "talents/arcane_destruction.png",
    type = { "spell/futhark-tyr", 4 },
    mode = "activated",
    points = 5,
    mana = 40,
    cooldown = 30,
    is_spell = true,
    tactical = { BUFF = 3 },
    getPowerPerCharge = function(self, t) return 2 + self:getTalentLevel(t) end,
    getResistPerResonance = function(self, t) return 3 + self:getTalentLevel(t) end,
    getDuration = function(self, t) return 5 + self:getTalentLevelRaw(t) end,
    on_pre_use = function(self, t) return self:getRunecharge() > 0 end,
    action = function(self, t)
        local charges = self:getRunecharge()
        if charges <= 0 then return nil end
        local resonances = #self:runewrightResonances()
        self:incRunecharge(-charges)
        self:setEffect(self.EFF_RW_INHERITANCE, t.getDuration(self, t), {
            power = charges * t.getPowerPerCharge(self, t),
            resist = resonances * t.getResistPerResonance(self, t),
        })
        game.level.map:particleEmitter(self.x, self.y, 2, "ball_arcane", { radius = 2 })
        game:playSoundNear(self, "talents/arcane")
        game.logSeen(self, "%s 喚醒了先祖銘刻的符文。", self:getName():capitalize())
        return true
    end,
    info = function(self, t)
        return ("你所繼承的，不只是土地，還有寫在土地上的字。\n\n消耗你所有的符文充能，持續 %d 回合：\n每點消耗的充能 +%d 法術強度；\n每個啟動中的共鳴 +%d%% 全抗性。\n\n沒有充能時無法施放。"):
            format(t.getDuration(self, t), t.getPowerPerCharge(self, t), t.getResistPerResonance(self, t))
    end,
}
