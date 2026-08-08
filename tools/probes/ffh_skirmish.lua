-- Generate the FFH tactical skirmish in memory and report its placed actors.

local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
ai.ensure(game)

local unit = game.ffh_ai.units[1]
game.ffh_current_encounter = {
    unit_id = unit and unit.id or "u-probe",
    kind = unit and unit.kind or "warband",
    owner = unit and unit.owner or 1,
    sprite = unit and unit.sprite or nil,
    x = unit and unit.x or 4,
    y = unit and unit.y or 4,
}

local Zone = require("engine.Zone")
Zone:setup{map_class="engine.Map", level_class="engine.Level", npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap"}

local z = Zone.new("fall-from-heaven+skirmish")
local ld = {
    level=1,
    width=z.width,
    height=z.height,
    all_lited=z.all_lited,
    all_remembered=z.all_remembered,
    generator=z.generator,
}
local lev = z:newLevel(ld, 1, nil, game)
lev.zone = z
dofile("/data-fall-from-heaven/ffh/skirmish.lua").postProcess(lev)

local actors = {}
for _, e in pairs(lev.entities or {}) do
    if e and e.type == "humanoid" and e.subtype == "ffh" then
        actors[#actors + 1] = ("%s@%d,%d:%s:%s"):format(e.define_as or e.name, e.x or -1, e.y or -1, tostring(e.image), tostring(e.ffh_encounter_unit_id))
    end
end
table.sort(actors)

local up = lev.default_up
local data = lev.data.ffh_skirmish or {}
print(("[PROBE.FFH_SKIRMISH] actors=%d unit=%s resolved=%s up=%s,%s sample=%s"):format(#actors, tostring(data.unit_id), tostring(data.resolved), up and up.x or "nil", up and up.y or "nil", table.concat(actors, " | ")))
