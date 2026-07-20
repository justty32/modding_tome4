-- 載入工匠天賦、教給每個新角色、自報 selfcheck。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"

local GRANT = { "T_CR_IMBUE", "T_CR_TRANSMUTE" }

class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition("/data-crafting/talents/spells/crafting.lua")
    local ok = true
    for _, tn in ipairs(GRANT) do
        local defd = ActorTalents.talents_def[ActorTalents[tn]] ~= nil
        if not defd then ok = false end
        print(("[CRAFTING] selfcheck %s = %s"):format(tn, defd and "OK" or "FAIL"))
    end
    print("[CRAFTING] hook complete")
end)

-- 每個新角色建好後自動學會兩個工匠天賦（不花技能點、不可遺忘）。
class:bindHook("ToME:birthDone", function(self, data)
    local p = game and game.player
    if not (p and p.learnTalent) then return end
    for _, tn in ipairs(GRANT) do
        local tid = ActorTalents[tn]
        if tid and not p:knowTalent(tid) then
            p:learnTalent(tid, true, nil, { no_unlearn = true })
        end
    end
end)
