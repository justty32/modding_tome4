local CAMP_ZONE = "camp+base"   -- 與 data/zones/base/ 對應（engine/Zone.lua:155-165 的 + 慣例）

newTalent{
    name = "建造營火",
    short_name = "CAMP_BUILD_FIRE",
    type = { "spell/camp", 1 },
    points = 1, mode = "activated", no_energy = true, cooldown = 5, no_npc_use = true,
    image = "talents/arcane_power.png",
    getCost = function(self, t) return 50 end,
    on_pre_use = function(self, t) return game.zone and game.zone.short_name == CAMP_ZONE end,
    action = function(self, t)
        local cost = t.getCost(self, t)
        if (self.money or 0) < cost then game.logPlayer(self, "#LIGHT_RED#金幣不足（需要 %d）。", cost) return end
        local g = game.zone:makeEntityByName(game.level, "grid", "CAMP_FIRE")
        if g then game.zone:addEntity(game.level, g, "grid", self.x, self.y) end
        self:incMoney(-cost)
        for _, a in ipairs(game.party.m_list or {}) do
            if a and not a.dead then
                if a.resetToFull then a:resetToFull() else a.life = a.max_life end
            end
        end
        game.logPlayer(self, "#LIGHT_GREEN#你生起一堆營火，在旁歇息，全隊體力盡復。（花費 %d 金幣）", cost)
        return true
    end,
    info = function(self, t)
        return ([[在營地搭建一堆營火（花費 %d 金幣），並在旁休息、全隊完全恢復。可重複搭建。
	只能在營地建造。]]):format(t.getCost(self, t))
    end,
}
