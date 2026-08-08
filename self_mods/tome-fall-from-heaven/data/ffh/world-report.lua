local _M = {}

function _M.report(state)
    state = state or (game and game.ffh_ai)
    if not state then return "[FFH-AI] inactive" end

    local owners = {}
    for _, city in ipairs(state.cities) do
        owners[city.owner] = (owners[city.owner] or 0) + 1
    end
    local owner_bits = {}
    for owner, count in pairs(owners) do
        owner_bits[#owner_bits + 1] = ("%s:%d"):format(tostring(owner), count)
    end
    table.sort(owner_bits)

    local last = {}
    local from = math.max(1, #state.log - 5)
    for i = from, #state.log do last[#last + 1] = state.log[i] end

    local sample = state.units[1]
    local sample_unit = sample and ("%s@%d,%d:%s"):format(sample.id, sample.x, sample.y, tostring(sample.sprite)) or "none"
    return ("[FFH-AI] scenario=%s civ_turn=%d units=%d cities=%d owners=%s sample=%s last=%s"):format(
        tostring(state.scenario), state.civ_turn, #state.units, #state.cities,
        table.concat(owner_bits, ","), sample_unit, table.concat(last, " | "))
end

return _M
