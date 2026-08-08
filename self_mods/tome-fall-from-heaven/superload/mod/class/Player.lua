local _M = loadPrevious(...)

local base_onEnterLevelEnd = _M.onEnterLevelEnd
function _M:onEnterLevelEnd(zone, level)
    local ret = base_onEnterLevelEnd(self, zone, level)
    if zone and zone.short_name == "fall-from-heaven+skirmish" and level and not level.data.ffh_skirmish then
        dofile("/data-fall-from-heaven/ffh/skirmish.lua").postProcess(level)
    end
    return ret
end

local base_onWorldEncounter = _M.onWorldEncounter
function _M:onWorldEncounter(target, x, y)
    if target and target.ffh_world_unit_marker and game then
        game.ffh_world_encounter_target = {
            unit_id = target.ffh_unit_id,
            kind = target.ffh_unit_kind,
            owner = target.ffh_unit_owner,
            sprite = target.ffh_unit_sprite,
            x = x or target.x,
            y = y or target.y,
        }
    end
    return base_onWorldEncounter(self, target, x, y)
end

local base_actBase = _M.actBase
function _M:actBase(...)
    local ret = base_actBase(self, ...)
    local ai = rawget(_G, "__ffh_world_ai")
    local projection = rawget(_G, "__ffh_worldmap_projection")
    if ai and game and game.ffh_ai then
        local ticked = ai.maybeTick(game.turn)
        if projection and game.zone and game.zone.short_name == "fall-from-heaven+worldmap" and game.level then
            if ticked or game.ffh_ai.projected_units == nil then projection.apply(game.level, game.ffh_ai) end
        end
    end
    return ret
end

return _M
