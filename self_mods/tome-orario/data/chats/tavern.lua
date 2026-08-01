-- 酒館「豐饒女主人」的招募對話。三個可招募冒險者（劍士/弓手/法師）共用這支對話。
--
-- 招募＝抄 tome-companions 的 doRecruit（docs/knowledge/companions-and-party.md）：
--   轉玩家陣營 → addMember(control="full") → co_owner/max_level=nil → forceLevelup 到玩家等級。
-- 「入隊後隨主人成長」與「免疫主人傷害」由 tome-companions 提供（其天賦的 callbackOnLevelup
--   與 superload onTakeHit 對任何 co_owner 生效）；未裝 tome-companions 時，招募與即時同級仍有效。
--
-- ⚠️ 對話檔必須 return 起始 chat id（E/Chat.lua:70）。「離開」放最前面（選項會被擠出畫面）。

local function do_recruit(npc, player)
	npc:setTarget(nil)
	npc.faction = player.faction
	npc.never_anger = true
	npc.never_move = nil          -- 解除「招牌不動」，入隊後才能被操控／跟隨
	npc.can_talk = nil            -- 入隊後不再開招募對話
	if not (game.party and game.party:hasMember(npc)) then
		game.party:addMember(npc, {
			control = "full", type = "companion", title = "酒館夥伴",
			orders = { target = true, leash = true, anchor = true, talents = true, behavior = true },
		})
	end
	-- addMember 之後才設自訂標記（addMember 會合併欄位、保留 table identity）。
	npc.co_owner = player
	npc.summoner = player
	npc.summoner_gain_exp = false
	npc.max_level = nil           -- 清野生上限，才能隨主人一路成長
	npc:forceLevelup(math.max(npc.level or 1, player.level))
	local nm = (npc.getName and npc:getName() or npc.name or "夥伴")
	game.logSeen(npc, "#LIGHT_GREEN#%s 加入了你的隊伍！", tostring(nm):capitalize())
end

newChat{ id = "welcome",
	text = [[「這裡是『豐饒女主人』——巴別塔冒險者歇腳的地方。」
你面前的冒險者打量著你。「要下迷宮的話……或許我能同行？」]],
	answers = {
		{ "（離開）" },
		{ "#LIGHT_GREEN#加入我的隊伍，一起下巴別塔吧。#WHITE#",
			cond = function(npc, player) return not (game.party and game.party:hasMember(npc)) end,
			action = function(npc, player) do_recruit(npc, player) end,
			jump = "joined",
		},
	},
}

newChat{ id = "joined",
	text = [[「成交。我的劍（弓／法術）聽你調度。」
對方站起身，跟到了你身後。（可在隊伍介面切換操控，或按下令鍵指揮。）]],
	answers = { { "（出發）" } },
}

return "welcome"
