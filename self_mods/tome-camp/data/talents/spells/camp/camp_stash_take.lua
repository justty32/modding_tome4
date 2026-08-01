local CAMP_ZONE = "camp+base"   -- 與 data/zones/base/ 對應（engine/Zone.lua:155-165 的 + 慣例）

newTalent{
    name = "取出儲物箱",
    short_name = "CAMP_STASH_TAKE",
    type = { "spell/camp", 1 },
    points = 1, mode = "activated", no_energy = true, cooldown = 2, no_npc_use = true,
    image = "talents/arcane_power.png",
    on_pre_use = function(self, t) return game.zone and game.zone.short_name == CAMP_ZONE and self.camp_has_stash end,
    doWithdraw = function(self, idx)
        local o = table.remove(self.camp_stash or {}, idx)
        if not o then return nil end
        self:addObject(self:getInven(self.INVEN_INVEN), o)
        game.logPlayer(self, "#LIGHT_GREEN#你從儲物箱取回了 %s。", o:getName{ do_colour = true })
        return o
    end,
    action = function(self, t)
        self.camp_stash = self.camp_stash or {}
        if #self.camp_stash == 0 then game.logPlayer(self, "#LIGHT_RED#儲物箱是空的。") return end
        local list = {}
        for i, o in ipairs(self.camp_stash) do
            list[#list + 1] = { name = o:getName{ do_colour = true, no_count = true }, idx = i }
        end
        require("engine.Dialog"):listPopup("取出物品", "選擇要取回的物品", list, 500, 300, function(item)
            if item and item.idx then t.doWithdraw(self, item.idx) end
        end)
        return true
    end,
    info = function(self, t) return "從營地儲物箱取回物品。只能在營地使用。" end,
}
