-- Step Fall from Heaven world AI by N deterministic civ turns.

local ai = dofile("/data-fall-from-heaven/ffh/world-ai.lua")
ai.ensure(game)

local n = tonumber(ARG1) or 1
for i = 1, n do ai.step(game.ffh_ai) end

print((ai.report(game.ffh_ai):gsub("^%[FFH%-AI%]", "[PROBE.FFH_AI_STEP]")))
