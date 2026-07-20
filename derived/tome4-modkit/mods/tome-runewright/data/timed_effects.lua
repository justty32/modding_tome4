-- 盧恩術士的持續效果。
-- 由 hooks/load.lua 的 ActorTemporaryEffects:loadDefinition 載入。
--
-- 每個 buff 都掛一個 addParticles 光環：持續效果沒有視覺，玩家就不知道自己還有沒有。
-- 粒子名必須是 tome-gfx.team 的 data/gfx/particles/*.lua 真實存在的檔（共 315 個）。

local Particles = require "engine.Particles"

newEffect {
    name = "RW_ENGRAVED",
    desc = "銘刻",
    long_desc = function(self, eff) return ("身上的盧恩符文正在發光，法術強度 +%d。"):format(eff.power) end,
    type = "magical",
    subtype = { arcane = true },
    status = "beneficial",
    parameters = { power = 5 },
    on_gain = function(self, err) return "#Target# 身上的符文亮起。", "+銘刻" end,
    on_lose = function(self, err) return "#Target# 身上的符文黯淡下去。", "-銘刻" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("combat_spellpower", eff.power)
        eff.particle = self:addParticles(Particles.new("arcane_power", 1))
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("combat_spellpower", eff.tmpid)
        if eff.particle then self:removeParticles(eff.particle) end
    end,
}

-- ᚲ Kenaz：火炬照亮視野
newEffect {
    name = "RW_TORCH",
    desc = "火炬",
    long_desc = function(self, eff) return ("肯納茲之火在身側燃燒，視野 +%d。"):format(eff.lite) end,
    type = "magical",
    subtype = { fire = true, light = true },
    status = "beneficial",
    parameters = { lite = 1 },
    on_gain = function(self, err) return "#Target# 點燃了符文火炬。", "+火炬" end,
    on_lose = function(self, err) return "#Target# 的火炬熄滅了。", "-火炬" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("lite", eff.lite)
        eff.particle = self:addParticles(Particles.new("ball_fire", 1))
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("lite", eff.tmpid)
        if eff.particle then self:removeParticles(eff.particle) end
    end,
}

-- ᛖ Ehwaz：駿馬疾行
newEffect {
    name = "RW_STEED",
    desc = "駿馬",
    long_desc = function(self, eff) return ("埃瓦茲之符加持雙足，移動速度 +%d%%。"):format(eff.speed * 100) end,
    type = "magical",
    subtype = { arcane = true, speed = true },
    status = "beneficial",
    parameters = { speed = 0.3 },
    on_gain = function(self, err) return "#Target# 的步伐輕快起來。", "+駿馬" end,
    on_lose = function(self, err) return "#Target# 的步伐慢了下來。", "-駿馬" end,
    activate = function(self, eff)
        eff.tmpid = self:addTemporaryValue("movement_speed", eff.speed)
        -- radius 不可省略。ball_teleport.lua:22 寫的是 `local radius = radius`，
        -- **沒有預設值**，少傳就在 :63 的 `5*radius*266` 對 nil 做算術而拋 Lua Error。
        -- 同一批的 ball_fire.lua:29 與 ball_arcane.lua:22 寫的是 `radius or 6`，所以少傳不會炸——
        -- 「別的粒子這樣寫沒事」不能拿來當根據，每個粒子檔的預設值都要自己確認。
        eff.particle = self:addParticles(Particles.new("ball_teleport", 1, { radius = 1 }))
    end,
    deactivate = function(self, eff)
        self:removeTemporaryValue("movement_speed", eff.tmpid)
        if eff.particle then self:removeParticles(eff.particle) end
    end,
}

-- ᛟ Othala：先祖傳承（終極技）
newEffect {
    name = "RW_INHERITANCE",
    desc = "祖產",
    long_desc = function(self, eff)
        return ("先祖銘刻的符文正在生效：法術強度 +%d，所有抗性 +%d%%。"):format(eff.power, eff.resist)
    end,
    type = "magical",
    subtype = { arcane = true },
    status = "beneficial",
    parameters = { power = 0, resist = 0 },
    on_gain = function(self, err) return "#Target# 周身浮現古老的符文。", "+祖產" end,
    on_lose = function(self, err) return "#Target# 身上的古老符文散去。", "-祖產" end,
    activate = function(self, eff)
        if eff.power > 0 then eff.powid = self:addTemporaryValue("combat_spellpower", eff.power) end
        if eff.resist > 0 then eff.resid = self:addTemporaryValue("resists", { all = eff.resist }) end
        eff.particle = self:addParticles(Particles.new("ball_arcane", 1))
    end,
    deactivate = function(self, eff)
        if eff.powid then self:removeTemporaryValue("combat_spellpower", eff.powid) end
        if eff.resid then self:removeTemporaryValue("resists", eff.resid) end
        if eff.particle then self:removeParticles(eff.particle) end
    end,
}
