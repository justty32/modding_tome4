local State = dofile("/data-fall-from-heaven/ffh/world-state.lua")

local _M = {}

local function manhattan(a, b)
    return math.abs((a.x or 0) - (b.x or 0)) + math.abs((a.y or 0) - (b.y or 0))
end

local function stepToward(unit, target)
    local dx = target.x - unit.x
    local dy = target.y - unit.y
    if math.abs(dx) >= math.abs(dy) and dx ~= 0 then
        unit.x = unit.x + (dx > 0 and 1 or -1)
    elseif dy ~= 0 then
        unit.y = unit.y + (dy > 0 and 1 or -1)
    elseif dx ~= 0 then
        unit.x = unit.x + (dx > 0 and 1 or -1)
    end
end

local function cityById(state, id)
    for _, city in ipairs(state.cities) do
        if city.id == id then return city end
    end
end

local function nearestEnemyCity(state, unit)
    local best, best_dist
    for _, city in ipairs(state.cities) do
        if city.owner ~= unit.owner then
            local d = manhattan(unit, city)
            if not best_dist or d < best_dist then
                best, best_dist = city, d
            end
        end
    end
    return best, best_dist
end

function _M.resolveAttack(state, unit, city, unit_index)
    State.log(state, ("%s attacks %s"):format(unit.id, city.name))
    if unit.strength >= city.garrison then
        local old_owner = city.owner
        city.owner = unit.owner
        city.garrison = 1
        unit.x, unit.y = city.x, city.y
        State.log(state, ("%s captures %s owner %s->%s"):format(unit.id, city.name, tostring(old_owner), tostring(city.owner)))
    else
        city.garrison = city.garrison - unit.strength
        table.remove(state.units, unit_index)
        State.log(state, ("%s is destroyed at %s"):format(unit.id, city.name))
    end
end

function _M.step(state)
    state.civ_turn = state.civ_turn + 1

    for _, city in ipairs(state.cities) do
        city.production = (city.production or 0) + (city.population or 1)
        if city.production >= 2 then
            city.production = city.production - 2
            State.spawnWarband(state, city)
        end
    end

    local i = 1
    while i <= #state.units do
        local unit = state.units[i]
        local target = nearestEnemyCity(state, unit)
        if target then
            stepToward(unit, target)
            State.log(state, ("%s moves toward %s to %d,%d"):format(unit.id, target.name, unit.x, unit.y))
            local occupied = cityById(state, target.id)
            if occupied and unit.x == occupied.x and unit.y == occupied.y and unit.owner ~= occupied.owner then
                _M.resolveAttack(state, unit, occupied, i)
            end
        end
        i = i + 1
    end

    return state
end

return _M
