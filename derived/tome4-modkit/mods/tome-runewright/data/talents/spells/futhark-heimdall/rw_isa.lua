local DamageType = require "engine.DamageType"

newTalent {
    name = "伊薩・冰封",
    short_name = "RW_ISA",
    image = "talents/freeze.png",
    type = { "spell/futhark-heimdall", 2 },
    mode = "activated",
    points = 5,
    mana = 24,
    cooldown = 12,
    range = 6,
    is_spell = true,
    requires_target = true,
    tactical = { DISABLE = { stun = 2 } },
    target = function(self, t)
        return { type = "bolt", range = self:getTalentRange(t), talent = t,
                 display = { particle = "bolt_ice", trail = "icetrail" } }
    end,
    getDuration = function(self, t) return 3 + math.floor(self:getTalentLevel(t) / 2) end,
    getHP = function(self, t) return 50 + self:combatTalentSpellDamage(t, 20, 200) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        -- DamageType.FREEZE 的 param 形制照抄 data/talents/spells/ice.lua:46
        -- 飛過去再冰封：飛行外觀來自 target 的 display，命中粒子是 {type="freeze"}（ice.lua:45 同款）
        self:projectile(tg, x, y, DamageType.FREEZE,
            { dur = t.getDuration(self, t), hp = t.getHP(self, t) }, { type = "freeze" })
        game:playSoundNear(self, "talents/ice")
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("冰不摧毀，只是讓一切停下。\n\n將目標冰封 %d 回合（冰塊有 %d 點生命）。\n獲得 1 點符文充能。"):
            format(t.getDuration(self, t), t.getHP(self, t))
    end,
}
