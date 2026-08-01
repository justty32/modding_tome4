local CAMP_ZONE = "camp+base"   -- 與 data/zones/base/ 對應（engine/Zone.lua:155-165 的 + 慣例）

-- 營地儲物箱：存進去的物品存在 player.camp_stash（隨存檔保存，跟 camp_return 一樣）。
-- 只能在營地使用。存入用 showInventory、取出用 listPopup（都是引擎既有 UI）。

newTalent{
    name = "存入儲物箱",
    short_name = "CAMP_STASH_PUT",
    type = { "spell/camp", 1 },
    points = 1, mode = "activated", no_energy = true, cooldown = 2, no_npc_use = true,
    image = "talents/arcane_power.png",
    on_pre_use = function(self, t) return game.zone and game.zone.short_name == CAMP_ZONE and self.camp_has_stash end,
    doDeposit = function(self, o, item)
        self.camp_stash = self.camp_stash or {}
        self:removeObject(self:getInven(self.INVEN_INVEN), item, true)
        self.camp_stash[#self.camp_stash + 1] = o
        game.logPlayer(self, "#LIGHT_GREEN#你把 %s 收進了儲物箱。", o:getName{ do_colour = true })
    end,
    action = function(self, t)
        self:showInventory("存入哪件物品？", self:getInven(self.INVEN_INVEN),
            function(o) return true end,
            function(o, item) t.doDeposit(self, o, item) end)
        return true
    end,
    info = function(self, t) return "把背包裡的物品存進營地儲物箱（持久保存）。只能在營地使用。" end,
}
