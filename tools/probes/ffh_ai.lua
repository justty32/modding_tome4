-- Fall from Heaven world AI state.

local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
ai.ensure(game)

print((ai.report(game.ffh_ai):gsub("^%[FFH%-AI%]", "[PROBE.FFH_AI]")))
