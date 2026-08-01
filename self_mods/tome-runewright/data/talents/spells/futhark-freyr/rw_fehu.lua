newTalent {
    name = "菲胡・流轉",
    short_name = "RW_FEHU",
    image = "talents/arcane_feed.png",
    type = { "spell/futhark-freyr", 1 },
    mode = "activated",
    points = 5,
    cooldown = 10,
    is_spell = true,
    tactical = { MANA = 2 },
    getRatio = function(self, t) return 8 + self:getTalentLevel(t) * 4 end,
    -- 沒有充能就沒東西可轉換，別讓玩家白花冷卻
    on_pre_use = function(self, t) return self:getRunecharge() > 0 end,
    action = function(self, t)
        local charges = self:getRunecharge()
        if charges <= 0 then return nil end
        local mana = charges * t.getRatio(self, t)
        self:incRunecharge(-charges)
        self:incMana(mana)
        -- 不可用 "arcane_power"：它永不停止發射，丟給 particleEmitter 會永久留在地圖上。
        -- 原因見 runecraft.lua 同一處的長註解。
        game.level.map:particleEmitter(self.x, self.y, 1, "ball_arcane", { radius = 1 })
        game:playSoundNear(self, "talents/spell_generic")
        game.logSeen(self, "%s 將 %d 點符文充能流轉為法力。", self:getName():capitalize(), charges)
        return true
    end,
    info = function(self, t)
        return ("財富即流動之物。\n\n消耗你所有的符文充能，每點轉化為 %d 點法力。\n沒有充能時無法施放。"):
            format(t.getRatio(self, t))
    end,
}
