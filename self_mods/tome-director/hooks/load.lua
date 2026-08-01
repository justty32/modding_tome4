-- 載入 Director 函式庫、註冊場景、教除錯天賦、自報 selfcheck。
--
-- ⚠️ ActorTalents 等在 M/mod/load.lua:60-70 是 local，hook 的閉包看不到，
--    必須在檔頭自己 require（見 docs/knowledge/addon-loading.md §0）。
local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"

class:bindHook("ToME:load", function(self, data)
	-- 1) 函式庫。dofile 絕對 VFS 路徑——addon 的 data/ 不在 package.path 上，
	--    require("data.lib.director") 一定失敗（addon-loading.md §0）。
	local D = dofile("/data-director/lib/director.lua")

	-- 2) 場景。
	dofile("/data-director/scenes/scenes.lua")

	-- 3) 除錯天賦。
	ActorTalents:loadDefinition("/data-director/talents/director.lua")

	-- 4) selfcheck：讓 verify.sh 靠 grep 判定，而不是判讀畫面。
	local Player = require "mod.class.Player"
	local checks = {
		{ "lib",       D ~= nil and type(D.play) == "function" },
		{ "singleton", rawget(_G, "__tome_director") == D },
		{ "scene",     D and D.scenes and D.scenes.demo ~= nil },
		{ "handlers",  D and D.handlers and D.handlers.walk ~= nil and D.handlers.chat ~= nil
		                 and D.handlers.spawn ~= nil and D.handlers.camera ~= nil
		                 and D.handlers.say ~= nil and D.handlers.log ~= nil },
		-- 台詞框用的動態 chat 檔。少了它每一句 say 都會炸，但 verify 不會自己發現。
		{ "sayfile",   fs.exists("/data-director/chats/_line.lua") },
		-- 幀驅動器。演出不吃回合全靠它（見 data/lib/director.lua 檔頭的 v2 說明），
		-- 所以 registerTimer 若哪天在引擎裡改名，要在這裡就被抓到，不是等演出卡住才發現。
		{ "pump",      type(D.pump) == "function"
		                 and type(require("engine.Game").registerTimer) == "function" },
		{ "superload", Player.__director_superload == true },
		{ "talent",    ActorTalents.talents_def[ActorTalents.T_DIRECTOR_DEMO] ~= nil },
	}
	for _, c in ipairs(checks) do
		print(("[DIRECTOR] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
	end
	print("[DIRECTOR] hook complete")
end)

-- 每個新角色都學會除錯天賦（同 tome-companions 的做法）。
class:bindHook("ToME:birthDone", function(self, data)
	local p = game and game.player
	if not p or not p.learnTalent then return end
	if not p:knowTalent(p.T_DIRECTOR_DEMO) then
		p:learnTalent(p.T_DIRECTOR_DEMO, true, 1)
	end
end)

-- 讀檔／換層後的保險：把中斷演出留下的木偶還原。
--
-- 為什麼需要：演出期間 NPC 的 ai 被清掉（E/interface/ActorAI.lua:136 靠 ai 判定），
-- 原值存在 actor.__director_ai_saved 上、會跟著存檔走。若玩家在演出中途存檔離開，
-- 導演本身不會被序列化（它刻意只活在 _G 裡），沒有這一段的話那些 NPC 會永遠變木頭。
class:bindHook("Game:changeLevel", function(self, data)
	local D = rawget(_G, "__tome_director")
	if D and D.restoreAll then D.restoreAll() end
end)
