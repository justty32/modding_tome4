local CAMP_ZONE = "camp+base"   -- 與 data/zones/base/ 對應（engine/Zone.lua:155-165 的 + 慣例）

newTalent{
    name = "返回營地",
    short_name = "CAMP_RECALL",
    type = { "spell/camp", 1 },
    points = 1,
    mode = "activated",
    no_energy = true,       -- 不耗行動、不設 mana，任何職業都能用
    cooldown = 10,
    no_npc_use = true,
    image = "talents/arcane_power.png",
    action = function(self, t)
        local in_camp = game.zone and game.zone.short_name == CAMP_ZONE
        if in_camp then
            local ret = self.camp_return
            if not ret then
                game.logPlayer(self, "#LIGHT_RED#沒有可返回的地點。")
                return
            end
            -- changeLevel 一律延到 tick 結束再做（從 action 內直接換關會打斷正在跑的流程）。
            game:onTickEnd(function()
                game:changeLevel(ret.lev or 1, ret.zone, {})
            end)
            game.logPlayer(self, "#LIGHT_GREEN#你收拾營地，回到旅途上……")
        else
            -- 記下目前位置（存在 player 上會隨存檔保存），再前往營地並在營火旁歇息。
            self.camp_return = { zone = game.zone.short_name, lev = (game.level and game.level.level) or 1 }
            game:onTickEnd(function()
                game:changeLevel(1, CAMP_ZONE, {})
                for _, a in ipairs(game.party.m_list or {}) do
                    if a and not a.dead then
                        if a.resetToFull then a:resetToFull() else a.life = a.max_life end
                    end
                end
                game.logPlayer(game.player, "#LIGHT_GREEN#你在營火旁歇下，體力盡復。")
            end)
            game.logPlayer(self, "#LIGHT_GREEN#你踏上返回營地的路……")
        end
        return true
    end,
    info = function(self, t)
        return [[在野外使用：傳送到你的私人營地，並在營火旁完全恢復（休息）。
	在營地使用：收拾行囊，回到你先前所在之處。
	營地狀態持久——你留下的東西下次還在。]]
    end,
}
