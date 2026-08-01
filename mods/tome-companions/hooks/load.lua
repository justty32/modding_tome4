-- 載入契約天賦、把它教給每個新角色、並自報 selfcheck。
--
-- 這些必須在這裡 require：它們在 mod/load.lua 是 local，hook 閉包看不到（見其他 addon）。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"

class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition("/data-companions/talents/spells/companionship.lua")

    -- selfcheck 給 tools/verify.sh grep 用。
    local talent_ok = ActorTalents.talents_def[ActorTalents.T_CO_RECRUIT] ~= nil
    -- superload 的免傷 onTakeHit 是否掛上（superload 尾端設了 __companions_immunity 旗標）。
    local ok_super, Actor = pcall(require, "mod.class.Actor")
    local super_ok = ok_super and Actor.__companions_immunity == true

    print(("[COMPANIONS] selfcheck talent = %s"):format(talent_ok and "OK" or "FAIL"))
    print(("[COMPANIONS] selfcheck immunity_superload = %s"):format(super_ok and "OK" or "FAIL"))
    print("[COMPANIONS] hook complete")
end)

-- 每個新角色建好後，自動學會契約召募（不花技能點、不可遺忘），讓系統即開即用、可測。
-- ToME:birthDone 在建角完成後廣播（mod/class/Game.lua:336,386），此時 game.player 已存在。
class:bindHook("ToME:birthDone", function(self, data)
    local p = game and game.player
    if p and p.learnTalent and not p:knowTalent(ActorTalents.T_CO_RECRUIT) then
        p:learnTalent(ActorTalents.T_CO_RECRUIT, true, nil, { no_unlearn = true })
    end
end)
