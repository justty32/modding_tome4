local Particles = require "engine.Particles"

newTalent {
    name = "溫優・圓滿",
    short_name = "RW_WUNJO",
    image = "talents/arcane_might.png",
    type = { "spell/futhark-freyr", 4 },
    mode = "sustained",
    points = 5,
    sustain_mana = 40,
    cooldown = 20,
    is_spell = true,
    tactical = { BUFF = 2 },
    getCrit = function(self, t) return 3 + self:getTalentLevel(t) * 2 end,
    getPower = function(self, t) return 4 + self:getTalentLevel(t) * 3 end,
    activate = function(self, t)
        return {
            crit = self:addTemporaryValue("combat_spellcrit", t.getCrit(self, t)),
            pow  = self:addTemporaryValue("combat_spellpower", t.getPower(self, t)),
            -- 持續技要有可見的光環，否則玩家不知道自己開著沒
            particle = self:addParticles(Particles.new("arcane_power", 1)),
        }
    end,
    deactivate = function(self, t, p)
        self:removeTemporaryValue("combat_spellcrit", p.crit)
        self:removeTemporaryValue("combat_spellpower", p.pow)
        if p.particle then self:removeParticles(p.particle) end
        return true
    end,
    info = function(self, t)
        return ("圓滿並非終點，而是諸符和諧的狀態。\n\n持續期間法術爆擊率 +%d%%，法術強度 +%d。"):
            format(t.getCrit(self, t), t.getPower(self, t))
    end,
}
