local _M = {}

function _M.worldProjectionReport()
    local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
    local proj = dofile("/data-fall-from-heaven/ffh/worldmap-projection.lua")
    ai.ensure(game)

    local unit = game.ffh_ai.units[1]
    local sample = {
        id = unit and unit.id or "u-probe",
        kind = unit and unit.kind or "warband",
        owner = unit and unit.owner or 1,
        x = 4,
        y = 4,
        strength = unit and unit.strength or 1,
        sprite = unit and unit.sprite or nil,
    }

    local Map = require "engine.Map"
    local Level = require "engine.Level"
    local Grid = require "mod.class.Grid"
    local lev = Level.new(1, Map.new(10, 10))
    for x = 0, 9 do
        for y = 0, 9 do
            lev.map(x, y, Map.TERRAIN, Grid.new{
                name = "probe ground",
                type = "floor", subtype = "probe",
                display = '.', color = colors.WHITE,
            })
        end
    end

    local placed = proj.apply(lev, {units = {sample}})
    local grid = lev.map(sample.x, sample.y, Map.TERRAIN)
    local actor = lev.map(sample.x, sample.y, Map.ACTOR)
    return ("[PROBE.FFH_AI_MAP] placed=%d counted=%d actors=%d unit=%s pos=%s,%s marker=%s sprite=%s actor=%s actor_sprite=%s"):format(
        placed, proj.count(lev), proj.actorCount(lev),
        sample.id, sample.x, sample.y,
        grid and tostring(grid.ffh_unit_marker) or "nil",
        grid and tostring(grid.ffh_unit_sprite) or "nil",
        actor and tostring(actor.ffh_world_unit_marker) or "nil",
        actor and tostring(actor.image) or "nil")
end

return _M
