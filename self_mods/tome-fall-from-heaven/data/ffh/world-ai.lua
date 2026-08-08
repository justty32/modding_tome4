-- Facade for the Fall from Heaven Civ-style world simulation.
-- Keep this API stable; hooks and probes load this file directly.

local State = dofile("/data-fall-from-heaven/ffh/world-state.lua")
local Rules = dofile("/data-fall-from-heaven/ffh/world-rules.lua")
local Report = dofile("/data-fall-from-heaven/ffh/world-report.lua")

local _M = {}

_M.TURN_INTERVAL = 1000

function _M.newState(sites)
    return State.newState(sites, _M.TURN_INTERVAL)
end

function _M.ensure(game)
    if game.ffh_ai then
        State.ensureUnitArt(game.ffh_ai)
        return game.ffh_ai
    end
    local sites = dofile("/data-fall-from-heaven/ffh/black-tower-sites.lua")
    game.ffh_ai = _M.newState(sites)
    print(("[FALL-FROM-HEAVEN] ai init scenario=%s cities=%d units=%d"):format(
        tostring(game.ffh_ai.scenario), #game.ffh_ai.cities, #game.ffh_ai.units))
    return game.ffh_ai
end

function _M.log(state, msg)
    return State.log(state, msg)
end

function _M.spawnWarband(state, city)
    return State.spawnWarband(state, city)
end

function _M.removeUnit(state, unit_id)
    return State.removeUnit(state, unit_id)
end

function _M.resolveAttack(state, unit, city, unit_index)
    return Rules.resolveAttack(state, unit, city, unit_index)
end

function _M.step(state)
    return Rules.step(state)
end

function _M.maybeTick(game_turn)
    local state = _M.ensure(game)
    game_turn = game_turn or game.turn or 0
    if not state.game_turn_last then
        state.game_turn_last = game_turn
        return false
    end
    if game_turn - state.game_turn_last < (state.interval or _M.TURN_INTERVAL) then
        return false
    end
    state.game_turn_last = game_turn
    _M.step(state)
    print(("[FALL-FROM-HEAVEN] ai turn=%d units=%d"):format(state.civ_turn, #state.units))
    return true
end

function _M.report(state)
    return Report.report(state)
end

return _M
