-- 盧恩銘刻 —— 盧恩術士的主動技能樹。
--
-- newTalent 的 short_name 若不指定，會由 name 大寫底線化生成
-- （engine/interface/ActorTalents.lua:88 附近），中文名會產生非 ASCII 的天賦 id。
-- 因此每個天賦都**明確指定 short_name**。

local DamageType = require "engine.DamageType"

newTalentType {
    type = "spell/runecraft",
    name = "盧恩銘刻",
    description = "書寫並引動盧恩符文，將奧術之力凝定於形。",
    generic = false,
    allow_random = true,
}

newTalent {
    name = "銘刻符文",
    short_name = "RW_ENGRAVE_RUNE",
    image = "talents/arcane_power.png",
    type = { "spell/runecraft", 1 },
    mode = "activated",
    points = 5,
    mana = 12,
    cooldown = 6,
    is_spell = true,
    tactical = { BUFF = 2 },
    getCharge = function(self, t) return 1 + math.floor(self:getTalentLevel(t) / 2) end,
    getPower = function(self, t) return 5 + self:getTalentLevel(t) * 4 end,
    action = function(self, t)
        self:incRunecharge(t.getCharge(self, t))
        self:setEffect(self.EFF_RW_ENGRAVED, 5, { power = t.getPower(self, t) })
        -- ⚠️ 不可用 "arcane_power"。它的更新函式是無條件 `self.ps:emit(8)`，永遠 isAlive()，
        -- 而 map 的粒子只在 isAlive() 為 false 時才會被回收（engine/Map.lua:1488-1496）——
        -- 丟給 particleEmitter 就會**永久留在地圖上**。它只能配 addParticles（deactivate 時手動移除）。
        -- ball_* 系列的更新函式都有 nb 計數會停，適合當一次性施法特效。
        game.level.map:particleEmitter(self.x, self.y, 1, "ball_arcane", { radius = 1 })
        game:playSoundNear(self, "talents/spell_generic")
        game.logSeen(self, "%s 在自身刻下一道盧恩符文。", self:getName():capitalize())
        return true
    end,
    info = function(self, t)
        return ("在自身銘刻一道符文，獲得 %d 點符文充能，並在 5 回合內提升 %d 點法術強度。"):
            format(t.getCharge(self, t), t.getPower(self, t))
    end,
}

newTalent {
    name = "符文箭",
    short_name = "RW_RUNIC_BOLT",
    image = "talents/manathrust.png",
    type = { "spell/runecraft", 2 },
    mode = "activated",
    points = 5,
    mana = 15,
    cooldown = 4,
    range = 7,
    is_spell = true,
    requires_target = true,
    tactical = { ATTACK = { ARCANE = 2 } },
    -- 彈道的「長相」來自 target 的 display（飛行中的粒子 + 拖尾），不是 projectile 的參數。
    -- type="hit" 是瞬發、沒有飛行過程。形制照抄原版 Manathrust（arcane.lua:39）。
    target = function(self, t)
        return { type = "bolt", range = self:getTalentRange(t), talent = t,
                 display = { particle = "bolt_arcane", trail = "arcanetrail" } }
    end,
    getDamage = function(self, t) return 20 + self:combatTalentSpellDamage(t, 15, 180) end,
    action = function(self, t)
        local tg = self:getTalentTarget(t)
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        -- projectile()＝會飛的彈道（engine/interface/ActorProject.lua:406），
        -- 第 6 參數是粒子。project() 則是瞬發、粒子出現在命中格。
        -- "manathrust" 是彈道粒子，拿去 particleEmitter 只會在目標格閃一下、沒有飛行過程。
        -- projectile() 的第 6 參數是彈體自身的粒子（arcane.lua:58 同款）
        self:projectile(tg, x, y, DamageType.ARCANE, self:spellCrit(t.getDamage(self, t)),
            { type = "manathrust" })
        game:playSoundNear(self, "talents/arcane")
        self:incRunecharge(1)
        return true
    end,
    info = function(self, t)
        return ("射出一道符文箭，造成 %0.1f 點奧術傷害，並獲得 1 點符文充能。"):
            format(self:damDesc("ARCANE", t.getDamage(self, t)))
    end,
}

newTalent {
    name = "充能爆發",
    short_name = "RW_RUNE_DISCHARGE",
    image = "talents/arcane_vortex.png",
    type = { "spell/runecraft", 3 },
    mode = "activated",
    points = 5,
    mana = 20,
    cooldown = 12,
    range = 0,
    radius = 3,
    is_spell = true,
    tactical = { ATTACKAREA = { ARCANE = 3 } },
    target = function(self, t)
        return { type = "ball", range = 0, radius = self:getTalentRadius(t), selffire = false, talent = t }
    end,
    getDamagePerCharge = function(self, t) return 6 + self:combatTalentSpellDamage(t, 4, 40) end,
    -- 消耗全部充能；沒有充能就不該讓玩家白白花掉冷卻
    on_pre_use = function(self, t) return self:getRunecharge() > 0 end,
    action = function(self, t)
        local charges = self:getRunecharge()
        if charges <= 0 then return nil end
        local tg = self:getTalentTarget(t)
        local dam = t.getDamagePerCharge(self, t) * charges
        self:project(tg, self.x, self.y, DamageType.ARCANE, self:spellCrit(dam))
        game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_arcane", { radius = tg.radius })
        game:playSoundNear(self, "talents/arcane")
        self:incRunecharge(-charges)
        game.logSeen(self, "%s 引爆了 %d 點符文充能！", self:getName():capitalize(), charges)
        return true
    end,
    info = function(self, t)
        return ("引爆你所有的符文充能，對半徑 %d 內的敵人每點充能造成 %0.1f 點奧術傷害。\n沒有充能時無法施放。"):
            format(self:getTalentRadius(t), self:damDesc("ARCANE", t.getDamagePerCharge(self, t)))
    end,
}

-- 這棵樹刻意只有 3 個技能。原本第 4 位是「護印」（全抗性持續技），
-- 與海姆達爾之族的 ᛉ Algiz 庇護機制重疊，已移除：
-- runecraft 專心當資源引擎（產生與消耗符文充能），防護交給 Algiz。
