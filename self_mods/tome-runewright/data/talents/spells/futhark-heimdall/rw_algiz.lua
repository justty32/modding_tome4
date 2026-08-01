local Particles = require "engine.Particles"

newTalent {
    name = "阿爾吉茲・庇護",
    short_name = "RW_ALGIZ",
    image = "talents/arcane_shield.png",
    type = { "spell/futhark-heimdall", 3 },
    mode = "sustained",
    points = 5,
    sustain_mana = 35,
    cooldown = 20,
    is_spell = true,
    tactical = { DEFEND = 2 },
    getResist = function(self, t) return 4 + self:getTalentLevel(t) * 3 end,
    getArmour = function(self, t) return 3 + self:getTalentLevel(t) * 2 end,
    activate = function(self, t)
        return {
            res = self:addTemporaryValue("resists", { all = t.getResist(self, t) }),
            arm = self:addTemporaryValue("combat_armor", t.getArmour(self, t)),
            particle = self:addParticles(Particles.new("arcane_power", 1)),
        }
    end,
    deactivate = function(self, t, p)
        self:removeTemporaryValue("resists", p.res)
        self:removeTemporaryValue("combat_armor", p.arm)
        if p.particle then self:removeParticles(p.particle) end
        return true
    end,
    info = function(self, t)
        return ("麋鹿之角向天豎起，這是最古老的守護之符。\n\n持續期間所有抗性 +%d%%，護甲 +%d。"):
            format(t.getResist(self, t), t.getArmour(self, t))
    end,
}
