-- 載入營地天賦、教給每個新角色、把營地入口貼到 Eyal 大地圖、自報 selfcheck。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"

-- 大地圖入口：德斯城（25,17）旁的平原。runeisles 的符文石環在 (23,17)，這裡取 (24,17)，
-- 同一列（確認是平原），與 runeisles 相鄰但不重疊，兩者共存。
local WILD_GRIDS = "/data/zones/wilderness/grids.lua"
local ADD_GRIDS  = "/data-camp/zones/wilderness-add/grids.lua"
local PORTAL_X, PORTAL_Y = 24, 17

local GRANT = { "T_CAMP_RECALL", "T_CAMP_STASH_PUT", "T_CAMP_STASH_TAKE", "T_CAMP_BUILD_STASH", "T_CAMP_BUILD_FIRE" }

class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition("/data-camp/talents/spells/camp.lua")
    for _, tn in ipairs(GRANT) do
        local ok = ActorTalents.talents_def[ActorTalents[tn]] ~= nil
        print(("[CAMP] selfcheck %s = %s"):format(tn, ok and "OK" or "FAIL"))
    end
    print("[CAMP] hook complete")
end)

class:bindHook("ToME:birthDone", function(self, data)
    local p = game and game.player
    if not (p and p.learnTalent) then return end
    for _, tn in ipairs(GRANT) do
        local tid = ActorTalents[tn]
        if tid and not p:knowTalent(tid) then
            p:learnTalent(tid, true, nil, { no_unlearn = true })
        end
    end
end)

-- 讓原版 wilderness 的 grid_list 多認得一個地磚（CAMP_PORTAL）。
-- 用同一個 res 表再 loadList，等於 append（engine/Entity.lua:1238）。抄 runeisles/orcs DLC。
class:bindHook("Entity:loadList", function(self, data)
    if data.file ~= WILD_GRIDS then return end
    self:loadList(ADD_GRIDS, data.no_default, data.res, data.mod, data.loaded)
end)

-- 把營地入口那一格 overlay 到 Eyal 大地圖上。
-- engine/generator/map/Static.lua:696 畫完主圖、跑子生成器前廣播；overlay 只複製有東西的格
-- （周圍 '?' 未 defineTile 會被跳過），所以只佔中心一格、對其他 addon 是加法。
class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
    if data.mapfile ~= "wilderness/eyal" then return end
    data.list[#data.list + 1] = {
        x = PORTAL_X - 1, y = PORTAL_Y - 1, w = 3, h = 3,
        overlay = true,
        generator = "engine.generator.map.Static",
        data = { map = "camp+eyal-camp-portal" },
    }
end)
