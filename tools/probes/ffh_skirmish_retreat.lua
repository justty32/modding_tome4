-- Verify that retreating from a FFH skirmish keeps the world unit and records a retreat.

local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
local ctrl = dofile("/data-fall-from-heaven/ffh/skirmish.lua")
ai.ensure(game)

local before = #game.ffh_ai.units
local unit = game.ffh_ai.units[1]
local Level = require "engine.Level"
local Map = require "engine.Map"
local lev = Level.new(1, Map.new(4, 4))
lev.data.ffh_skirmish = {
    unit_id = unit and unit.id or "none",
    kind = unit and unit.kind or "none",
    owner = unit and unit.owner or 0,
    world_x = unit and unit.x or -1,
    world_y = unit and unit.y or -1,
    resolved = false,
}
ctrl.resolve(lev, "player_retreat")
local after = #game.ffh_ai.units
local data = lev.data.ffh_skirmish
print(("[PROBE.FFH_SKIRMISH_RETREAT] before=%d after=%d unit=%s result=%s removed=%s"):format(before, after, tostring(data.unit_id), tostring(data.result), tostring(data.removed_unit)))
