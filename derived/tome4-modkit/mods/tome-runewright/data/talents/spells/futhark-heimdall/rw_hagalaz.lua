local DamageType = require "engine.DamageType"
local Particles = require "engine.Particles"

newTalent {
    name = "哈格拉茲・冰雹",
    short_name = "RW_HAGALAZ",
    image = "talents/ice_storm.png",
    type = { "spell/futhark-heimdall", 1 },
    mode = "activated",
    points = 5,
    mana = 20,
    cooldown = 8,
    range = 7,
    radius = 2,
    is_spell = true,
    tactical = { ATTACKAREA = { COLD = 2 } },
    target = function(self, t)
        return { type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), talent = t }
    end,
    getDamage = function(self, t) return 22 + self:combatTalentSpellDamage(t, 18, 240) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        self:project(tg, x, y, DamageType.COLD, self:spellCrit(t.getDamage(self, t)))
        game.level.map:particleEmitter(x, y, tg.radius, "ball_ice", { radius = tg.radius })
        game:playSoundNear(self, "talents/ice")
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("冰雹落下時，不問你是誰。\n\n召來符文冰雹，對半徑 %d 內造成 %0.1f 點寒冷傷害。\n獲得 1 點符文充能。"):
            format(self:getTalentRadius(t), self:damDesc("COLD", t.getDamage(self, t)))
    end,
}
