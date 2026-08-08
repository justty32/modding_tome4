local _M = {}

local function context()
    local c = game and (game.ffh_current_encounter or game.ffh_world_encounter_target)
    return c or {}
end

function _M.liveEnemies(level)
    local n = 0
    for _, e in pairs(level and level.entities or {}) do
        if e and not e.dead and e.ffh_skirmish_enemy then n = n + 1 end
    end
    return n
end

function _M.enemyDie(self, who)
    local level = game and game.level
    if not (level and level.data and level.data.ffh_skirmish) then return end
    local remaining = _M.liveEnemies(level)
    if remaining <= 0 and not level.data.ffh_skirmish.resolved then
        _M.resolve(level, "player_won")
    end
end

function _M.resolve(level, result)
    local data = level.data.ffh_skirmish or {}
    if data.resolved then return data end
    data.resolved = true
    data.result = result
    level.data.ffh_skirmish = data

    if game then
        game.ffh_last_skirmish_result = data
        if result == "player_won" and data.unit_id and game.ffh_ai then
            local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
            data.removed_unit = ai.removeUnit(game.ffh_ai, data.unit_id) and true or false
        elseif result == "player_retreat" and data.unit_id and game.ffh_ai then
            local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
            ai.log(game.ffh_ai, ("skirmish retreat from %s at %s,%s"):format(tostring(data.unit_id), tostring(data.world_x), tostring(data.world_y)))
            data.removed_unit = false
        end
        if game.player then
            game.logPlayer(game.player, "#LIGHT_BLUE#The Fall from Heaven skirmish is resolved: %s.", tostring(result))
        end
    end
    return data
end

function _M.retreat()
    if game and game.level and game.level.data and game.level.data.ffh_skirmish and not game.level.data.ffh_skirmish.resolved then
        _M.resolve(game.level, "player_retreat")
    end
    return false
end

function _M.postProcess(level)
    local c = context()
    level.data.ffh_skirmish = {
        unit_id = c.unit_id,
        kind = c.kind,
        owner = c.owner,
        sprite = c.sprite,
        world_x = c.x,
        world_y = c.y,
        resolved = false,
    }

    for _, e in pairs(level.entities or {}) do
        if e and e.type == "humanoid" and e.subtype == "ffh" then
            e.ffh_skirmish_enemy = true
            e.ffh_encounter_unit_id = c.unit_id
            e.ffh_encounter_owner = c.owner
            e.on_die = _M.enemyDie
        end
    end
    return level.data.ffh_skirmish
end

return _M
