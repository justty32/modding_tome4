-- 討伐委託。惰性載入：who:grantQuest("orario+bounty") 被呼叫的當下才 loadfile
-- （ActorPartyQuest.lua:33-52，見 docs/knowledge/quests-and-lore.md §1-2）。不需在 hooks 註冊。
--
-- 明寫 id → 遊戲裡的 quest id 是 "orario-bounty"（不帶 addon 前綴）。
-- name / desc 是 assert 必填（ActorPartyQuest.lua:52-53）。
id = "orario-bounty"
name = "討伐委託：巴別塔階層主"

desc = function(self, who)
	local d = {}
	d[#d + 1] = "冒險者公會受付孃委託你討伐盤踞在巴別塔第一階層的巨獸『格鲁勒』。"
	d[#d + 1] = ""
	if self:isStatus(engine.Quest.DONE) then
		d[#d + 1] = "#LIGHT_GREEN#* 你討伐了格鲁勒，並回公會領取了報酬。#WHITE#"
	elseif self:isStatus(engine.Quest.COMPLETED) then
		d[#d + 1] = "#LIGHT_GREEN#* 你討伐了格鲁勒。#WHITE#"
		d[#d + 1] = "* 回中央廣場的冒險者公會回報，領取報酬。"
	else
		d[#d + 1] = "* 從中央廣場的白塔進入巴別塔，在第一階層找到並討伐格鲁勒。"
	end
	return table.concat(d, "\n")
end
