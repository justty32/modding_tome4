-- 把歐拉麗入口貼到 Eyal 大地圖，並自報 selfcheck。抄 runeisles/tome-camp 的兩個 hook。
local class = require "engine.class"
local Map = require "engine.Map"
local Store = require "mod.class.Store"
local PartyLore = require "mod.class.interface.PartyLore"

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

-- ── 舊存檔遷移：眷族據點的門口 ────────────────────────────────────────────────
-- 中央廣場的 zone.lua 是 `persistent = "zone"`，整個 zone（含已產生的 level）會被
-- 存進存檔的 .teaz（engine/Zone.lua:190 push、:945 讀回）。所以 v0.4 那份「三棟密閉
-- 3x3 建築把 p/q/r 封死」的地圖，在既有角色的存檔裡是**凍結**的——光改
-- data/maps/orario.lua 只對新角色有效。
--
-- 這個 hook 在每次換層後跑（mod/class/Game.lua:1442 triggerHook{"Game:changeLevel"}），
-- 只要發現廣場南牆那三格門口還是牆，就換成 FLOOR。冪等：新地圖進來時三格本來就是
-- FLOOR，fixed = 0，什麼都不印。
-- 換地形的寫法抄引擎自己開門的那行（mod/class/Grid.lua:81 map(x,y,TERRAIN,door_g)）。
local HUB_ZONE = "orario+orario"
local DOORWAYS = { { 4, 12 }, { 13, 12 }, { 22, 12 } }

class:bindHook("Game:changeLevel", function(self, data)
    local zone, level = game.zone, game.level
    if not zone or not level or zone.short_name ~= HUB_ZONE then return end
    local map = level.map
    local floor = zone.grid_list and zone.grid_list.FLOOR
    if not map or not floor then return end

    local fixed = 0
    for _, c in ipairs(DOORWAYS) do
        local x, y = c[1], c[2]
        local g = map(x, y, Map.TERRAIN)
        if g and g.does_block_move then
            map(x, y, Map.TERRAIN, floor)
            if game.nicer_tiles then game.nicer_tiles:updateAround(level, x, y) end
            fixed = fixed + 1
        end
    end
    if fixed > 0 then
        map:cleanFOV()
        map.changed = true
        print(("[ORARIO] migrate famhearth_doorways = %d"):format(fixed))
    end
end)

-- selfcheck：確認 hook 掛上、地圖/zone/商店/對話/lore 檔存在（讀得到）。zone 由
-- changeLevel 惰性載入，這裡只能確認檔案 loadfile 得起來（語法正確）。
class:bindHook("ToME:load", function(self, data)
    -- 市集商店定義：登錄進 Store.stores_def（原版在 mod/load.lua:242 做，addon 的
    -- data/ 是私有掛載點不會被自動掃到，必須自己補一次）。lore 同理（mod/load.lua:111）。
    Store:loadStores("/data-orario/stores/market.lua")
    PartyLore:loadDefinition("/data-orario/lore/lore.lua")

    local function ok(path)
        local f = loadfile(path)
        return f ~= nil
    end
    local function lore_ok(id)
        return (PartyLore.lore_defs or {})[id] ~= nil
    end
    local function store_ok(def)
        return (Store.stores_def or {})[def] ~= nil
    end

    print(("[ORARIO] selfcheck hub_map = %s"):format(ok("/data-orario/maps/orario.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck portal_overlay = %s"):format(ok("/data-orario/maps/eyal-orario-portal.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck guild_chat = %s"):format(ok("/data-orario/chats/guild.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck bounty_quest = %s"):format(ok("/data-orario/quests/bounty.lua") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck tavern_chat = %s"):format(ok("/data-orario/chats/tavern.lua") and "OK" or "FAIL"))
    -- v0.4：市集商店（定義 + 陷阱層入口）。
    print(("[ORARIO] selfcheck store_weapon = %s"):format(store_ok("ORARIO_WEAPON") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck store_supplies = %s"):format(store_ok("ORARIO_SUPPLIES") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck store_material = %s"):format(store_ok("ORARIO_MATERIAL") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck market_traps = %s"):format(ok("/data-orario/zones/orario/traps.lua") and "OK" or "FAIL"))
    -- v0.4：三眷族據點 zone（zone.lua + map + npcs + grids + objects + traps）。
    local fam = { "fam-hearth", "fam-loki", "fam-freya" }
    for _, z in ipairs(fam) do
        local zbase = ("/data-orario/zones/%s"):format(z)
        print(("[ORARIO] selfcheck zone_%s = %s"):format(z,
            ok(zbase .. "/zone.lua") and ok("/data-orario/maps/" .. z .. ".lua") and
            ok(zbase .. "/npcs.lua") and ok(zbase .. "/grids.lua") and
            ok(zbase .. "/objects.lua") and ok(zbase .. "/traps.lua") and "OK" or "FAIL"))
    end
    -- v0.4：眷族 NPC 對話（六支）。
    local chats = {
        "fam-hearth-head", "fam-hearth-apprentice",
        "fam-loki-head", "fam-loki-clerk",
        "fam-freya-head", "fam-freya-rogue",
    }
    for _, c in ipairs(chats) do
        print(("[ORARIO] selfcheck chat_%s = %s"):format(c, ok("/data-orario/chats/" .. c .. ".lua") and "OK" or "FAIL"))
    end
    -- v0.4：lore（三篇，撿書時 learnLore 需要它們已載入）。
    print(("[ORARIO] selfcheck lore_hearth = %s"):format(lore_ok("orario-fam-hearth") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck lore_loki = %s"):format(lore_ok("orario-fam-loki") and "OK" or "FAIL"))
    print(("[ORARIO] selfcheck lore_freya = %s"):format(lore_ok("orario-fam-freya") and "OK" or "FAIL"))
    -- 眷族據點門口：直接讀 data/maps/orario.lua 的字串，斷言南牆那三格不是 '#'。
    -- 「玩家走不進去」這種 bug 靜態就抓得到一半，剩下一半靠 playtest 的 A*。
    local doors_ok = false
    local f = loadfile("/data-orario/maps/orario.lua")
    if f then
        local rows = {}
        setfenv(f, setmetatable({ defineTile = function() end }, { __index = _G }))
        local got = f()
        if type(got) == "table" then rows = got end
        local row = rows[13]   -- Lua 1-based，對應地圖第 12 列（y = 12）
        if type(row) == "string" then
            doors_ok = row:sub(5, 5) ~= "#" and row:sub(14, 14) ~= "#" and row:sub(23, 23) ~= "#"
        end
    end
    print(("[ORARIO] selfcheck famhearth_doorways = %s"):format(doors_ok and "OK" or "FAIL"))
    print("[ORARIO] hook complete")
end)
