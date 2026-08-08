local class = require "engine.class"

local WILD_GRIDS = "/data/zones/wilderness/grids.lua"
local ADD_GRIDS = "/data-fall-from-heaven/zones/wilderness-add/grids.lua"

local PORTAL_X, PORTAL_Y = 22, 17
local FFH_AI
local FFH_PROJECTION

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
        data = { map = "fall-from-heaven+eyal-portal" },
    }
end)

class:bindHook("ToME:load", function(self, data)
    FFH_AI = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
    FFH_PROJECTION = dofile("/data-fall-from-heaven/ffh/worldmap-projection.lua")
    rawset(_G, "__ffh_world_ai", FFH_AI)
    rawset(_G, "__ffh_worldmap_projection", FFH_PROJECTION)

    local checks = {
        { "worldmap_zone", fs.exists("/data-fall-from-heaven/zones/worldmap/zone.lua") },
        { "worldmap_grids", fs.exists("/data-fall-from-heaven/zones/worldmap/grids.lua") },
        { "worldmap_map", fs.exists("/data-fall-from-heaven/maps/worldmap.lua") },
        { "eyal_portal_map", fs.exists("/data-fall-from-heaven/maps/eyal-portal.lua") },
        { "wilderness_add", fs.exists(ADD_GRIDS) },
        { "black_tower_sites", fs.exists("/data-fall-from-heaven/ffh/black-tower-sites.lua") },
        { "asset_catalog", fs.exists("/data-fall-from-heaven/ffh/assets.lua") },
        { "unit_art_catalog", fs.exists("/data-fall-from-heaven/ffh/unit-art.lua") },
        { "worldmap_projection", FFH_PROJECTION and type(FFH_PROJECTION.apply) == "function" },
        { "worldmap_projection_actor_api", FFH_PROJECTION and type(FFH_PROJECTION.actorCount) == "function" },
        { "worldmap_actor_helpers", fs.exists("/data-fall-from-heaven/ffh/worldmap-actors.lua") },
        { "world_ai_state", fs.exists("/data-fall-from-heaven/ffh/world-state.lua") },
        { "world_ai_rules", fs.exists("/data-fall-from-heaven/ffh/world-rules.lua") },
        { "world_ai_report", fs.exists("/data-fall-from-heaven/ffh/world-report.lua") },
        { "skirmish_controller", fs.exists("/data-fall-from-heaven/ffh/skirmish.lua") },
        { "probe_helpers", fs.exists("/data-fall-from-heaven/ffh/probes.lua") },
        { "asset_city_icon", fs.exists("/data-fall-from-heaven/gfx/ffh/icons/proxy/city-sheaim.png") },
        { "asset_inferno_icon", fs.exists("/data-fall-from-heaven/gfx/ffh/icons/units/son-of-the-inferno.png") },
        { "nif_proxy_abaddon", fs.exists("/data-fall-from-heaven/gfx/ffh/sprites/nif-proxy/abaddon.png") },
        { "nif_proxy_archer", fs.exists("/data-fall-from-heaven/gfx/ffh/sprites/nif-proxy/archer.png") },
        { "city_zone", fs.exists("/data-fall-from-heaven/zones/city/zone.lua") },
        { "city_map", fs.exists("/data-fall-from-heaven/maps/sites/city.lua") },
        { "landing_camp_zone", fs.exists("/data-fall-from-heaven/zones/landing-camp/zone.lua") },
        { "landing_camp_map", fs.exists("/data-fall-from-heaven/maps/sites/landing-camp.lua") },
        { "skirmish_zone", fs.exists("/data-fall-from-heaven/zones/skirmish/zone.lua") },
        { "skirmish_map", fs.exists("/data-fall-from-heaven/maps/sites/skirmish.lua") },
        { "skirmish_npcs", fs.exists("/data-fall-from-heaven/zones/skirmish/npcs.lua") },
        { "world_ai", FFH_AI and type(FFH_AI.step) == "function" and type(FFH_AI.report) == "function" },
    }
    for _, c in ipairs(checks) do
        print(("[FALL-FROM-HEAVEN] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
    end
    print("[FALL-FROM-HEAVEN] hook complete")
end)

class:bindHook("ToME:birthDone", function(self, data)
    if FFH_AI and game then FFH_AI.ensure(game) end
end)
