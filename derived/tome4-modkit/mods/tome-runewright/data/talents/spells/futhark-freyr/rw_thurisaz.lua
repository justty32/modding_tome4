local DamageType = require "engine.DamageType"

newTalent {
    name = "圖里薩茲・巨人之刺",
    short_name = "RW_THURISAZ",
    image = "talents/thorn_grab.png",
    type = { "spell/futhark-freyr", 2 },
    mode = "activated",
    points = 5,
    mana = 18,
    cooldown = 8,
    range = 6,
    is_spell = true,
    requires_target = true,
    tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1 } },
    target = function(self, t)
        return { type = "bolt", range = self:getTalentRange(t), talent = t,
                 display = { particle = "bolt_earth", trail = "earthtrail" } }
    end,
    getDamage = function(self, t) return 25 + self:combatTalentSpellDamage(t, 20, 260) end,
    getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t) / 2) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        -- stone_spikes 是**命中特效**，原版一律配 project()（eldritch-stone.lua:72）。
        -- 飛行過程交給 target 的 display（bolt_earth + earthtrail）。
        self:projectile(tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)),
            { type = "stone_spikes" })
        game:playSoundNear(self, "talents/earth")
        local target = game.level.map(x, y, game.level.map.ACTOR)
        if target then
            if target:canBe("stun") then
                target:setEffect(target.EFF_STUNNED, t.getDuration(self, t),
                    { apply_power = self:combatSpellpower(), apply_save = "combatSpellResist" })
            else
                game.logSeen(target, "%s 抵抗了暈眩！", target:getName():capitalize())
            end
        end
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("荊棘刺穿一切傲慢。\n\n召出一根符文荊棘，造成 %0.1f 點物理傷害，並試圖暈眩目標 %d 回合。\n獲得 1 點符文充能。"):
            format(self:damDesc("PHYSICAL", t.getDamage(self, t)), t.getDuration(self, t))
    end,
}
