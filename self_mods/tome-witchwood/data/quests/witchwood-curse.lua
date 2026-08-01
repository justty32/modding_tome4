-- 支線任務：竊語老槐（quest id: witchwood-curse）——Agent C（劇情）負責。
--
-- 惰性載入：who:grantQuest("witchwood+witchwood-curse") 被呼叫的當下才 loadfile
-- （M/mod/class/interface/ActorPartyQuest.lua:28,45）。不需在 hooks 註冊。
-- 明寫 id → 遊戲裡的 quest id 是 "witchwood-curse"（不帶 addon 前綴，:50）。
-- name / desc 是 assert 必填（ActorPartyQuest.lua:52-53）。
--
-- 討伐計數的依據：game.player.all_kills（M/mod/class/Actor.lua:3450-3452，
-- 玩家每殺一隻怪就 +1，key 是怪物的顯示名）。它是玩家的存檔欄位，跨 session
-- 存活，所以進度不用靠 hook / 怪物 on_die 也能在重開遊戲後正確計算。
-- on_grant 時快照基準數，之後只算「接任務之後殺的」。
--
-- 流程：接任務（PENDING）→ 討伐 3 隻林中老嫗（WITCHWOOD_HAG）→ 回去找葛薇
-- 覆命：她在對話動作裡檢查 all_kills，夠了就把任務一口氣推到 DONE 並發獎勵
-- （對話檔 data/chats/witchwood-crone.lua，reward 的發放也在那裡）。

id = "witchwood-curse"
name = "竊語老槐"

local HAG_NAME = "林中老嫗"  -- 契約固定：Agent A 的 WITCHWOOD_HAG 顯示名（CONTRACT.md 中文名欄）
local NEEDED = 3

-- 玩家累計殺掉的林中老嫗數（含接任務前的；扣除用 kills_base）
hag_kills = function(self, who)
	local p = who or game.player
	local ak = p and p.all_kills
	if not ak then return 0 end  -- 新角色 all_kills 預設是 false（Actor.lua:101）
	local n = ak[HAG_NAME] or 0
	if n == 0 then
		-- 防禦：A 若在顯示名上加了前綴／後綴，key 包含「林中老嫗」也算
		for k, v in pairs(ak) do
			if type(k) == "string" and k:find(HAG_NAME, 1, true) then n = n + v end
		end
	end
	return n
end

-- 接任務後殺掉的數量（desc 與對話都用這個）
progress = function(self)
	return self:hag_kills(game.player) - (self.kills_base or 0)
end

kills_base = 0

on_grant = function(self, who)
	self.kills_base = self:hag_kills(who)
	-- 一定要回 false：on_grant 回 truthy 會讓 quest 不被授予（E/Quest.lua:44 do_not_gain）
	return false
end

desc = function(self, who)
	local d = {}
	d[#d + 1] = "瑞文谷西北方的女巫森林，是女巫力量的源頭——第一個走進這片林子的女人，"
	d[#d + 1] = "從竊語老槐的根鬚底下學會了草木的低語。"
	d[#d + 1] = "如今黑汁沿著根鬚從瑞文谷方向滲進樹心，纏住了三名林中老嫗，使她們發狂，襲擊商旅。"
	d[#d + 1] = "守根人葛薇守在樹根旁不能離開，委託你討伐被腐化的林中老嫗，斬斷老槐纏在她們身上的根鬚。"
	d[#d + 1] = ""
	if self:isStatus(engine.Quest.DONE) then
		d[#d + 1] = "#LIGHT_GREEN#* 你討伐了三名被腐化的林中老嫗，黑汁退了回去。#WHITE#"
		d[#d + 1] = "#LIGHT_GREEN#* 你從葛薇手中接過了謝禮。#WHITE#"
	else
		local cur = math.min(self:progress(), NEEDED)
		if cur >= NEEDED then
			d[#d + 1] = ("#LIGHT_GREEN#* 你討伐了三名被腐化的林中老嫗（%d/%d）。#WHITE#"):format(cur, NEEDED)
			d[#d + 1] = "* 回去找守根人葛薇覆命。"
		else
			d[#d + 1] = ("* 討伐林中老嫗（%d/%d）。"):format(cur, NEEDED)
			d[#d + 1] = "* 老嫗在森林深處出沒——越深的地方，黑汁的味道越濃。"
		end
	end
	return table.concat(d, "\n")
end
