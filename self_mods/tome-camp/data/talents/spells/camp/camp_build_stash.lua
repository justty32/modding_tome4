local CAMP_ZONE = "camp+base"   -- 與 data/zones/base/ 對應（engine/Zone.lua:155-165 的 + 慣例）

-- 建造系統：花金幣在營地搭建結構。用 makeEntityByName+addEntity 把 grid 放到玩家腳下
-- （tutorial 11 的 Grid 替換手法）；persistent zone 會把地形變更存起來，所以蓋好的結構下次還在。

newTalent{
    name = "建造儲物箱",
    short_name = "CAMP_BUILD_STASH",
    type = { "spell/camp", 1 },
    points = 1, mode = "activated", no_energy = true, cooldown = 5, no_npc_use = true,
    image = "talents/arcane_power.png",
    getCost = function(self, t) return 100 end,
    on_pre_use = function(self, t) return game.zone and game.zone.short_name == CAMP_ZONE end,
    action = function(self, t)
        if self.camp_has_stash then game.logPlayer(self, "#LIGHT_RED#你已經有一個儲物箱了。") return end
        local cost = t.getCost(self, t)
        if (self.money or 0) < cost then game.logPlayer(self, "#LIGHT_RED#金幣不足（需要 %d）。", cost) return end
        local g = game.zone:makeEntityByName(game.level, "grid", "CAMP_STASH")
        if g then game.zone:addEntity(game.level, g, "grid", self.x, self.y) end
        self:incMoney(-cost)
        self.camp_has_stash = true
        game.logPlayer(self, "#LIGHT_GREEN#你在營地搭起了一個儲物箱。（花費 %d 金幣）", cost)
        return true
    end,
    info = function(self, t)
        return ([[在營地搭建一個儲物箱（花費 %d 金幣）。搭好後才能使用「存入／取出儲物箱」。
	只能在營地建造，且只能蓋一個。]]):format(t.getCost(self, t))
    end,
}
