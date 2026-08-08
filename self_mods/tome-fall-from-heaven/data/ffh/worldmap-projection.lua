local Map = require "engine.Map"
local UnitArt = dofile("/data-fall-from-heaven/ffh/unit-art.lua")
local WorldActors = dofile("/data-fall-from-heaven/ffh/worldmap-actors.lua")

local _M = {}

local function inBounds(map, x, y)
    return x and y and x >= 0 and y >= 0 and x < map.w and y < map.h
end

local function restoreMarked(level)
    local map = level and level.map
    if not map then return 0 end
    local restored = 0
    for x = 0, map.w - 1 do
        for y = 0, map.h - 1 do
            local g = map(x, y, Map.TERRAIN)
            if g and g.ffh_unit_marker and g.ffh_base_grid then
                map(x, y, Map.TERRAIN, g.ffh_base_grid)
                restored = restored + 1
            end
        end
    end
    return restored
end

local function markerName(unit)
    return WorldActors.markerName(unit)
end

function _M.apply(level, state)
    local map = level and level.map
    if not (map and state and state.units) then return 0 end
    restoreMarked(level)
    WorldActors.restore(level)

    local placed = 0
    local occupied = {}
    for _, unit in ipairs(state.units) do
        local x, y = unit.x, unit.y
        local key = tostring(x) .. "," .. tostring(y)
        if inBounds(map, x, y) and not occupied[key] then
            local base = map(x, y, Map.TERRAIN)
            if base then
                local g = base:cloneFull()
                g.ffh_unit_marker = true
                g.ffh_unit_id = unit.id
                g.ffh_unit_sprite = unit.sprite or UnitArt.unitSprite(unit.kind)
                g.ffh_base_grid = base
                g.name = markerName(unit)
                g.display = unit.owner == 0 and 'E' or 'w'
                g.color = unit.owner == 0 and colors.LIGHT_BLUE or colors.LIGHT_RED
                g.notice = true
                g.show_tooltip = true
                g.special_minimap = unit.owner == 0 and colors.LIGHT_BLUE or colors.LIGHT_RED
                g.add_displays = g.add_displays or {}
                g.add_displays[#g.add_displays + 1] = mod.class.Grid.new{
                    image = g.ffh_unit_sprite,
                    z = 18,
                }
                g:altered()
                if g.initGlow then g:initGlow() end
                map(x, y, Map.TERRAIN, g)
                if not map(x, y, Map.ACTOR) then
                    WorldActors.add(level, WorldActors.make(unit), x, y)
                end
                occupied[key] = true
                placed = placed + 1
            end
        end
    end
    if map.redisplay then map:redisplay() end
    state.projected_units = placed
    return placed
end

function _M.count(level)
    local map = level and level.map
    if not map then return 0 end
    local n = 0
    for x = 0, map.w - 1 do
        for y = 0, map.h - 1 do
            local g = map(x, y, Map.TERRAIN)
            if g and g.ffh_unit_marker then n = n + 1 end
        end
    end
    return n
end

function _M.actorCount(level)
    return WorldActors.count(level)
end

return _M
