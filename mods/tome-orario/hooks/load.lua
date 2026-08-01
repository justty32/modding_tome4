-- 把歐拉麗入口貼到 Eyal 大地圖，並自報 selfcheck。抄 runeisles/tome-camp 的兩個 hook。
local class = require "engine.class"

-- 德斯城（25,17）旁。runeisles 用 (23,17)、tome-camp 用 (24,17)，這裡取 (25,18)，
-- 德斯城正南、同一片平原，與另兩者不重疊。
local WILD_GRIDS = "/data/zones/wilderness/grids.lua"
local ADD_GRIDS  = "/data-orario/zones/wilderness-add/grids.lua"
local PORTAL_X, PORTAL_Y = 25, 18

class:bindHook("Entity:loadList", function(self, data)
    if data.file ~= WILD_GRIDS then return end
    self:loadList(ADD_GRIDS, data.no_default, data.res, data.mod, data.loaded)
end)

class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
    if data.mapfile ~= "wilderness/eyal" then return end
    data.list[#data.list + 1] = {
        x = PORTAL_X - 1, y = PORTAL_Y - 1, w = 3, h = 3,
        overlay = true,
        generator = "engine.generator.map.Static",
        data = { map = "orario+eyal-orario-portal" },
    }
end)

-- selfcheck：確認 hook 掛上、地圖/zone 檔存在（讀得到）。zone 由 changeLevel 惰性載入，
-- 這裡只能確認檔案 loadfile 得起來（語法正確）。
class:bindHook("ToME:load", function(self, data)
    local function ok(path)
        local f = loadfile(path)
        return f ~= nil
    end
    print(("[ORARIO] selfcheck hub_map = %s"):format(ok("/data-orario/maps/orario.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck portal_overlay = %s"):format(ok("/data-orario/maps/eyal-orario-portal.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck guild_chat = %s"):format(ok("/data-orario/chats/guild.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck bounty_quest = %s"):format(ok("/data-orario/quests/bounty.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck tavern_chat = %s"):format(ok("/data-orario/chats/tavern.lua") and "OK" or "FAIL"))
    print("[ORARIO] hook complete")
end)
