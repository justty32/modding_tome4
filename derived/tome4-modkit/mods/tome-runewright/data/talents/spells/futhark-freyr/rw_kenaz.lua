local DamageType = require "engine.DamageType"

newTalent {
    name = "肯納茲・火炬",
    short_name = "RW_KENAZ",
    image = "talents/flame.png",
    type = { "spell/futhark-freyr", 3 },
    mode = "activated",
    points = 5,
    mana = 22,
    cooldown = 9,
    range = 6,
    radius = 2,
    is_spell = true,
    tactical = { ATTACKAREA = { FIRE = 2 } },
    target = function(self, t)
        return { type = "ball", range = self:getTalentRange(t), radius = self:getTalentRadius(t), talent = t }
    end,
    getDamage = function(self, t) return 20 + self:combatTalentSpellDamage(t, 15, 220) end,
    getLite = function(self, t) return math.floor(self:getTalentLevel(t) / 2) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
        game.level.map:particleEmitter(x, y, tg.radius, "ball_fire", { radius = tg.radius })
        game:playSoundNear(self, "talents/fire")
        self:setEffect(self.EFF_RW_TORCH, 6, { lite = t.getLite(self, t) })
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("火炬既是武器，也是知識。\n\n引燃半徑 %d 內的一切，造成 %0.1f 點火焰傷害；接下來 6 回合視野 +%d。\n獲得 1 點符文充能。"):
            format(self:getTalentRadius(t), self:damDesc("FIRE", t.getDamage(self, t)), t.getLite(self, t))
    end,
}
