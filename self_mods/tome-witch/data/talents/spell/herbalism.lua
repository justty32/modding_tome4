-- 草藥 —— 女巫的招牌技能樹。
--
-- newTalent 的 short_name 若不指定，會由 name 大寫底線化生成
-- （engine/interface/ActorTalents.lua:88 附近），中文名會產生非 ASCII 的天賦 id。
-- 因此每個天賦都**明確指定 short_name**，並加 WITCH_ 前綴避免與其他 addon 撞名
-- （撞名是 assert 崩潰）。

local DamageType = require "engine.DamageType"

newTalentType {
    type = "spell/herbalism",
    name = "草藥",
    description = "調配魔藥、萃取藥露，以藥草的力量在戰鬥中求生。",
    generic = false,
    allow_random = true,
}

-- 藥草知識：被動。毒/疾病免疫 + 治療加成。
--
-- 免疫是靜態被動，寫 passives 即可（只在 learnTalent 時計算一次）；
-- 若日後要「隨狀態浮動」的效果，改用 callbackOnActBase 每回合重算
-- （見 docs/knowledge/class-parts/01-birth-and-talents.md §2）。
newTalent {
    name = "藥草知識",
    short_name = "WITCH_HERB_LORE",
    image = "talents/infusion__wild.png",
    type = { "spell/herbalism", 1 },
    mode = "passive",
    points = 5,
    getImmunity = function(self, t) return math.floor(self:combatTalentScale(t, 12, 36, 0.75)) / 100 end,
    getHealBonus = function(self, t) return math.floor(self:combatTalentScale(t, 5, 20, 0.75)) / 100 end,
    passives = function(self, t, p)
        self:talentTemporaryValue(p, "disease_immune", t.getImmunity(self, t))
        self:talentTemporaryValue(p, "poison_immune", t.getImmunity(self, t))
        self:talentTemporaryValue(p, "healing_factor", t.getHealBonus(self, t))
    end,
    info = function(self, t)
        return ("你對藥草的深刻理解使你免疫 %d%% 的毒與疾病，並提升 %d%% 的治療效果。"):
            format(t.getImmunity(self, t) * 100, t.getHealBonus(self, t) * 100)
    end,
}

-- 女巫魔藥：主動。遠程毒彈。
--
-- DamageType.POISON 的 projector 會自動對目標上 EFF_POISONED 的持續毒傷
-- （M/data/damage_types.lua:1801-1816），不需要手動 setEffect。
newTalent {
    name = "女巫魔藥",
    short_name = "WITCH_BREW",
    image = "talents/slime_spit.png",
    type = { "spell/herbalism", 2 },
    mode = "activated",
    points = 5,
    mana = 12,
    cooldown = 6,
    range = 6,
    is_spell = true,
    requires_target = true,
    tactical = { ATTACK = { NATURE = 2 } },
    -- 彈道的「長相」來自 target 的 display（飛行中的粒子 + 拖尾），
    -- bolt_slime / slimetrail 是原版毒彈的標準形制（M/data/talents/cunning/poisons.lua:154）。
    target = function(self, t)
        return { type = "bolt", range = self:getTalentRange(t), talent = t,
                 display = { particle = "bolt_slime", trail = "slimetrail" } }
    end,
    getDamage = function(self, t)
        local dam = 20 + self:combatTalentSpellDamage(t, 15, 150)
        -- 草藥大師被動強化
        if self:knowTalent(self.T_WITCH_MASTER_HERBALIST) then
            local mt = self:getTalentFromId(self.T_WITCH_MASTER_HERBALIST)
            dam = dam * (1 + mt.getStrength(self, mt))
        end
        return dam
    end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        -- projectile()＝會飛的彈道（engine/interface/ActorProject.lua:406），
        -- 第 6 參數是彈體自身的粒子。
        self:projectile(tg, x, y, DamageType.POISON, self:spellCrit(t.getDamage(self, t)),
            { type = "bolt_slime" })
        game:playSoundNear(self, "talents/slime")
        game.logSeen(self, "%s 擲出一瓶劇毒魔藥！", self:getName():capitalize())
        return true
    end,
    info = function(self, t)
        return ("擲出一瓶劇毒魔藥，造成 %0.1f 點自然傷害，並使目標持續中毒 5 回合。"):
            format(self:damDesc("NATURE", t.getDamage(self, t)))
    end,
}

-- 生命藥露：主動。立即回血 + 5 回合生命回復。
--
-- heal() 會把生命 cap 在 max_life（engine/interface/ActorLife.lua:56-61）。
-- EFF_REGENERATION 的 power 就是每回合加的 life_regen（M/data/timed_effects/physical.lua:183-213）。
newTalent {
    name = "生命藥露",
    short_name = "WITCH_LIFE_DRAUGHT",
    image = "talents/infusion__regeneration.png",
    type = { "spell/herbalism", 3 },
    mode = "activated",
    points = 5,
    mana = 15,
    cooldown = 10,
    is_spell = true,
    tactical = { HEAL = 2 },
    getHeal = function(self, t)
        local heal = 40 + self:combatTalentSpellDamage(t, 30, 200)
        -- 草藥大師被動強化
        if self:knowTalent(self.T_WITCH_MASTER_HERBALIST) then
            local mt = self:getTalentFromId(self.T_WITCH_MASTER_HERBALIST)
            heal = heal * (1 + mt.getStrength(self, mt))
        end
        return heal
    end,
    getRegen = function(self, t) return 8 + self:getTalentLevel(t) * 4 end,
    action = function(self, t)
        local healed = self:heal(t.getHeal(self, t), self)
        self:setEffect(self.EFF_REGENERATION, 5, { power = t.getRegen(self, t) })
        game:playSoundNear(self, "talents/heal")
        game.logSeen(self, "%s 飲下一瓶生命藥露，回復 %d 點生命。", self:getName():capitalize(), healed)
        return true
    end,
    info = function(self, t)
        return ("飲下一瓶生命藥露，立即回復 %d 點生命，並在 5 回合內每回合回復 %d 點生命。"):
            format(t.getHeal(self, t), t.getRegen(self, t))
    end,
}

-- 草藥大師：被動。強化女巫魔藥與生命藥露。
newTalent {
    name = "草藥大師",
    short_name = "WITCH_MASTER_HERBALIST",
    image = "talents/vulnerability_poison.png",
    type = { "spell/herbalism", 4 },
    mode = "passive",
    points = 5,
    getStrength = function(self, t) return math.floor(self:combatTalentScale(t, 5, 25, 0.75)) / 100 end,
    info = function(self, t)
        return ("你是草藥的大師。女巫魔藥的傷害與生命藥露的回復量提升 %d%%。"):
            format(t.getStrength(self, t) * 100)
    end,
}
