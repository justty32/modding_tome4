-- 主線：無銘之物。
--
-- quest 是「惰性載入」的：沒有任何預載清單，也不需要在 hooks 裡註冊。
-- who:grantQuest("runeisles+rune-isles") 被呼叫的當下，
-- mod/class/interface/ActorPartyQuest.lua:33-52 才 loadfile 這個檔案。
-- 檔名裡的 "runeisles+" 前綴會被解析成 /data-runeisles/quests/rune-isles.lua。
--
-- 這裡明寫 id，於是遊戲裡的 quest id 是 "rune-isles"（不帶 addon 前綴）；
-- ActorPartyQuest.lua:50 只在沒寫 id 時才拿整個 "runeisles+rune-isles" 當 id。
id = "rune-isles"
name = "無銘之物"

desc = function(self, who)
	local d = {}
	d[#d + 1] = "碑港的守碑人蘇爾德告訴你：鎮住「無銘之物」的三座符文石陣正在崩解。"
	d[#d + 1] = "古代的刻名師沒有殺死它——他們讓它失去名字，因為無法被指涉的東西也無法被召喚。"
	d[#d + 1] = "現在符文正在磨蝕。它快要重新變得可以被說出口了。"
	d[#d + 1] = ""
	if self:isCompleted("circle") then
		d[#d + 1] = "#LIGHT_GREEN#* 你找到了潮沒石陣。#WHITE#"
	else
		d[#d + 1] = "* 前往中島的潮沒石陣，看看石陣崩壞到什麼地步。"
	end
	if self:isCompleted("warden") then
		d[#d + 1] = "#LIGHT_GREEN#* 你從潮汐守衛的骸骨裡取出了斷裂的符文石片。#WHITE#"
	else
		d[#d + 1] = "* 石陣深處有東西在看守它。取回它守著的符文石片。"
	end
	if self:isCompleted("unnamed") then
		d[#d + 1] = "#LIGHT_GREEN#* 你把名字刻完，然後殺死了它。#WHITE#"
	elseif self:isCompleted("warden") then
		d[#d + 1] = "* 帶著石片前往北島的無銘之墓。把那個名字刻完——然後殺了它。"
	else
		d[#d + 1] = "* 北島的墓穴入口拒絕你。你還沒有它的名字。"
	end
	return table.concat(d, "\n")
end

on_status_change = function(self, who, status, sub)
	-- 三個子目標都完成才算通關。
	-- 這裡再呼叫一次 setQuestStatus 不會無限遞迴：engine/Quest.lua:110 有
	-- `if self.status == status then return false end` 擋住。
	if self.status == engine.Quest.DONE then return end
	if self:isCompleted("circle") and self:isCompleted("warden") and self:isCompleted("unnamed") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game.logPlayer(who, "#LIGHT_BLUE#那個輪廓終於散開了。你想不起它剛才長什麼樣子——這一次是因為它真的不在了。")
	end
end
