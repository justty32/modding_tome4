local DamageType = require "engine.DamageType"
local Particles = require "engine.Particles"

newTalent {
    name = "索維洛・勝利之光",
    short_name = "RW_SOWILO",
    image = "talents/searing_light.png",
    type = { "spell/futhark-heimdall", 4 },
    mode = "activated",
    points = 5,
    mana = 26,
    cooldown = 10,
    range = 8,
    is_spell = true,
    requires_target = true,
    tactical = { ATTACK = { LIGHT = 2 }, DISABLE = { blind = 1 } },
    -- beam：整條路徑上的目標都吃到（形制見 data/talents/spells/fire.lua:37）
    target = function(self, t) return { type = "beam", range = self:getTalentRange(t), talent = t } end,
    getDamage = function(self, t) return 28 + self:combatTalentSpellDamage(t, 20, 280) end,
    getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) / 2) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        local dur = t.getDuration(self, t)
        local pow = self:combatSpellpower()
        self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)))
        -- 光束粒子吃 tx/ty（相對位移），半徑傳射程距離。形制見 air.lua:48-50 的 lightning_beam
        game.level.map:particleEmitter(self.x, self.y,
            math.max(math.abs(x - self.x), math.abs(y - self.y)),
            "light_beam", { tx = x - self.x, ty = y - self.y })
        game:playSoundNear(self, "talents/spell_generic")
        -- 致盲要逐個目標處理；project 的 DamageType 不會幫你上異常狀態
        self:project(tg, x, y, function(px, py)
            local target = game.level.map(px, py, game.level.map.ACTOR)
            if not target then return end
            if target:canBe("blind") then
                target:setEffect(target.EFF_BLINDED, dur, { apply_power = pow, apply_save = "combatSpellResist" })
            else
                game.logSeen(target, "%s 抵抗了致盲！", target:getName():capitalize())
            end
        end)
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("太陽不與黑暗爭辯，它只是升起。\n\n射出一道光束，貫穿路徑上所有敵人，造成 %0.1f 點光明傷害並致盲 %d 回合。\n獲得 1 點符文充能。"):
            format(self:damDesc("LIGHT", t.getDamage(self, t)), t.getDuration(self, t))
    end,
}
