local Map = require "engine.Map"
local UnitArt = dofile("/data-fall-from-heaven/ffh/unit-art.lua")
local WorldNPC = require "mod.class.WorldNPC"

local _M = {}

function _M.markerName(unit)
    return ("FFH %s %s"):format(unit.kind or "unit", unit.id or "?")
end

function _M.onEncounter()
    if game and game.player then
        game.ffh_current_encounter = game.ffh_world_encounter_target or {}
        game.player.energy.value = game.energy_to_act
        game.paused = true
        game.player:runStop()
        game:changeLevel(1, "fall-from-heaven+skirmish")
        game.logPlayer(game.player, "#LIGHT_RED#A Fall from Heaven warband forces a skirmish.")
    end
    return true
end

function _M.make(unit)
    local sprite = unit.sprite or UnitArt.unitSprite(unit.kind)
    local owner = unit.owner or 0
    local actor = WorldNPC.new{
        name = _M.markerName(unit),
        type = "humanoid",
        subtype = "ffh",
        faction = owner == 0 and "allied-kingdoms" or "enemies",
        display = owner == 0 and 'E' or 'w',
        color = owner == 0 and colors.LIGHT_BLUE or colors.LIGHT_RED,
        image = sprite,
        unit_power = math.max(100, (unit.strength or 1) * 100),
        max_unit_power = math.max(100, (unit.strength or 1) * 100),
        ffh_world_unit_marker = true,
        ffh_unit_id = unit.id,
        ffh_unit_kind = unit.kind,
        ffh_unit_owner = owner,
        ffh_unit_sprite = sprite,
        on_encounter = _M.onEncounter,
    }
    actor:resolve()
    actor:resolve(nil, true)
    return actor
end

function _M.add(level, actor, x, y)
    if level.zone and level.zone.addEntity then
        level.zone:addEntity(level, actor, "actor", x, y)
    elseif game and game.level == level and game.zone and game.zone.addEntity then
        game.zone:addEntity(level, actor, "actor", x, y)
    else
        actor.x, actor.y = x, y
        level:addEntity(actor, nil, true)
        level.map(x, y, Map.ACTOR, actor)
        actor:added()
    end
end

function _M.restore(level)
    if not (level and level.entities) then return 0 end
    local removed = 0
    local old = {}
    for _, e in pairs(level.entities) do
        if e and e.ffh_world_unit_marker then old[#old + 1] = e end
    end
    for _, e in ipairs(old) do
        level:removeEntity(e, true)
        e.dead = true
        removed = removed + 1
    end
    return removed
end

function _M.count(level)
    if not (level and level.entities) then return 0 end
    local n = 0
    for _, e in pairs(level.entities) do
        if e and e.ffh_world_unit_marker then n = n + 1 end
    end
    return n
end

return _M
