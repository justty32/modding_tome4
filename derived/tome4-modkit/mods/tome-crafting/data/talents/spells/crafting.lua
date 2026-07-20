-- 工匠之藝：附魔（imbue）＋煉製（recipe）。由 hooks/load.lua loadDefinition 並在 birth 教給玩家。

newTalentType{
    type = "spell/crafting",
    name = "工匠之藝",
    description = "附魔與煉製之術。",
    generic = true,
    allow_random = false,
}

-- 附魔：把一顆寶石鑲入一件裝備。
-- 沿用基礎遊戲 Imbue Item（M/data/talents/spells/stone-alchemy.lua:109-148）的作法：
-- 兩段 showInventory（挑寶石→挑裝備）→ 造一個 fake ego（wielder=寶石的 imbue_powers）→ applyEgo。
-- 相對原版放寬：任何職業可用、可鑲武器或防具（非僅身甲）、不限寶石等級。
newTalent{
    name = "附魔",
    short_name = "CR_IMBUE",
    type = { "spell/crafting", 1 },
    points = 1,
    mode = "activated",
    no_energy = true,       -- 不耗行動、不設 mana，任何職業都能用
    cooldown = 20,
    no_npc_use = true,
    image = "talents/arcane_power.png",
    action = function(self, t)
        local inv = self:getInven("INVEN")
        local ret = self:talentDialog(self:showInventory("附魔用哪顆寶石？", inv,
            function(gem) return gem.type == "gem" and gem.imbue_powers end,
            function(gem, gem_item)
                local nd = self:showInventory("附魔到哪件裝備？", inv,
                    function(o) return (o.type == "armor" or o.type == "weapon") and o.slot and not o.been_imbued end,
                    function(o, item)
                        self:removeObject(inv, gem_item)
                        local Entity = require("engine.Entity")
                        local ego = Entity.new{
                            name = "附魔 "..gem:getName{no_count = true},
                            display_string = " <"..gem:getName{no_count = true}..">",
                            been_imbued = true,
                            wielder = table.clone(gem.imbue_powers),
                            talent_on_spell = gem.talent_on_spell,
                            fake_ego = true, unvault_ego = true,
                        }
                        local nm = o:getName{do_colour = true, no_count = true}
                        game.zone:applyEgo(o, ego, "object")
                        game.logPlayer(self, "#LIGHT_GREEN#你為 %s 附上了 %s。", nm, gem:getName{do_colour = true, no_count = true})
                        self:talentDialogReturn(true)
                        game:unregisterDialog(self:talentDialogGet())
                    end)
                nd.unload = function(_) game:unregisterDialog(self:talentDialogGet()) end
                return true
            end))
        if not ret then return nil end
        return true
    end,
    info = function(self, t)
        return [[把背包裡任一顆寶石鑲入一件武器或防具，永久獲得該寶石的效果。
每件裝備只能附魔一次，且無法還原。]]
    end,
}

-- 煉製：材料→產物的配方範例。消耗 3 顆寶石，煉出 1 顆隨機寶石。
-- 這示範「掃背包湊材料 → makeEntity 產出成品 → 扣材料」的通用配方骨架，
-- 鍛造/藥水製作都是同一套（換材料條件與產出物即可）。
newTalent{
    name = "煉製",
    short_name = "CR_TRANSMUTE",
    type = { "spell/crafting", 1 },
    points = 1,
    mode = "activated",
    no_energy = true,
    cooldown = 30,
    no_npc_use = true,
    image = "talents/arcane_power.png",
    getCost = function(self, t) return 3 end,   -- 需要幾顆寶石
    -- 抽成函式，方便 console 直接測。回傳成品或 nil。
    doCraft = function(self, t)
        local inv = self:getInven("INVEN")
        -- 收集背包裡的寶石（連同其 inventory index）
        local gems = {}
        for i, o in ipairs(inv) do
            if o.type == "gem" then gems[#gems + 1] = { o = o, i = i } end
        end
        if #gems < t.getCost(self, t) then
            game.logPlayer(self, "#LIGHT_RED#煉製需要至少 %d 顆寶石（背包只有 %d）。", t.getCost(self, t), #gems)
            return nil
        end
        -- 產出一顆隨機寶石（依當前關卡等級）
        local out = game.zone:makeEntity(game.level, "object", { type = "gem" }, nil, true)
        if not out then
            game.logPlayer(self, "#LIGHT_RED#煉製失敗：找不到可產出的寶石。")
            return nil
        end
        -- 從後往前扣，避免 index 位移
        for k = t.getCost(self, t), 1, -1 do
            self:removeObject(inv, gems[k].i, true)
        end
        out:identify(true)
        self:addObject(inv, out)
        game.logPlayer(self, "#LIGHT_GREEN#你消耗 %d 顆寶石，煉出了 %s。", t.getCost(self, t), out:getName{do_colour = true, no_count = true})
        return out
    end,
    action = function(self, t)
        return t.doCraft(self, t) ~= nil
    end,
    info = function(self, t)
        return ([[消耗背包裡 %d 顆寶石，煉出 1 顆隨機寶石。
（材料→產物配方的通用骨架；鍛造與藥水製作同理。）]]):format(t.getCost(self, t))
    end,
}
