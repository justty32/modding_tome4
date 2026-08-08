local _M = {}

local UnitArt

local function unitArt()
    if UnitArt then return UnitArt end
    UnitArt = dofile("/data-fall-from-heaven/ffh/unit-art.lua")
    return UnitArt
end

local function copyCity(city)
    return {
        id = city.id,
        name = city.name,
        owner = city.owner,
        x = city.map_x,
        y = city.map_y,
        population = city.population or 1,
        production = 0,
        garrison = 1,
    }
end

function _M.ensureUnitArt(state)
    for _, unit in ipairs(state.units or {}) do
        unit.sprite = unit.sprite or unitArt().unitSprite(unit.kind)
    end
end

function _M.newState(sites, interval)
    local state = {
        scenario = sites.scenario,
        width = sites.width,
        height = sites.height,
        interval = interval,
        game_turn_last = nil,
        civ_turn = 0,
        cities = {},
        units = {},
        log = {},
        next_unit_id = 1,
    }

    for _, city in ipairs(sites.cities or {}) do
        state.cities[#state.cities + 1] = copyCity(city)
    end

    for _, start in ipairs(sites.starts or {}) do
        state.units[#state.units + 1] = {
            id = "u" .. state.next_unit_id,
            kind = "expedition",
            owner = start.owner,
            x = start.map_x,
            y = start.map_y,
            strength = 2,
            origin = start.id,
            sprite = unitArt().unitSprite("expedition"),
        }
        state.next_unit_id = state.next_unit_id + 1
    end

    state.log[#state.log + 1] = ("init cities=%d units=%d"):format(#state.cities, #state.units)
    return state
end

function _M.log(state, msg)
    state.log[#state.log + 1] = ("T%03d %s"):format(state.civ_turn, msg)
    while #state.log > 20 do table.remove(state.log, 1) end
end

function _M.spawnWarband(state, city)
    local unit = {
        id = "u" .. state.next_unit_id,
        kind = "warband",
        owner = city.owner,
        x = city.x,
        y = city.y,
        strength = 1,
        origin = city.id,
        sprite = unitArt().unitSprite("warband"),
    }
    state.next_unit_id = state.next_unit_id + 1
    state.units[#state.units + 1] = unit
    _M.log(state, ("%s raises %s at %d,%d"):format(city.name, unit.id, unit.x, unit.y))
    return unit
end

function _M.removeUnit(state, unit_id)
    if not (state and unit_id) then return nil end
    for i, unit in ipairs(state.units or {}) do
        if unit.id == unit_id then
            table.remove(state.units, i)
            _M.log(state, ("skirmish removes %s at %d,%d"):format(unit.id, unit.x or -1, unit.y or -1))
            return unit
        end
    end
end

return _M
