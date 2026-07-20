-- 冒險者公會・受付孃的對話。討伐委託流程：
--   受託（grantQuest）→ 到巴別塔第 1 層打倒階層主（boss on_die 設 COMPLETED）→ 回此處回報領賞（設 DONE）。
--
-- ⚠️ 對話檔的回傳值就是起始 chat 的 id（E/Chat.lua:70，見 knowledge/npc-and-chats.md §2），
--    漏掉結尾的 return 一開口就崩。
-- ⚠️ 「離開」放 answers 最前面：選項一多對話框會被擠出畫面底部（同 §3）。
-- 對話檔每次開啟都重新執行，cond(npc, player) 回 false 的選項不顯示（E/dialogs/Chat.lua:160）。
local Quest = engine.Quest
local QID = "orario-bounty"

newChat{ id = "welcome",
	text = [[「歡迎來到冒險者公會。」
受付孃抬起頭。「巴別塔裡總有清不完的怪物——需要委託的話，隨時開口。」]],
	answers = {
		{ "（離開）" },

		-- 尚未接過委託 → 授予任務。
		{ "我想接一件討伐委託。",
			cond = function(npc, player) return not player:hasQuest(QID) end,
			action = function(npc, player) player:grantQuest("orario+bounty") end,
			jump = "accepted",
		},

		-- 委託進行中（已受託、尚未討伐）。
		{ "（關於進行中的討伐委託）",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.PENDING) end,
			jump = "inprogress",
		},

		-- 已討伐、尚未領賞 → 結算報酬並標為 DONE。
		{ "#LIGHT_GREEN#我已經討伐了階層主，前來回報。#WHITE#",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.COMPLETED) end,
			action = function(npc, player)
				player:incMoney(50)
				player:setQuestStatus(QID, Quest.DONE)
				game.logPlayer(player, "#GOLD#公會發給你 50 枚金幣作為討伐報酬。#WHITE#")
			end,
			jump = "rewarded",
		},

		-- 委託已結案。
		{ "（打聲招呼）",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.DONE) end,
			jump = "thanks",
		},
	},
}

newChat{ id = "accepted",
	text = [[「委託內容：巴別塔第一階層盤踞著一頭名為『格鲁勒』的巨獸。討伐它，回來領賞。」
受付孃把委託書推給你。「入口就在廣場中央的白塔，往下走。」]],
	answers = { { "（收下委託）" } },
}

newChat{ id = "inprogress",
	text = [[「討伐目標『格鲁勒』還在巴別塔第一階層。」
受付孃指了指廣場中央的白塔。「別空手回來。」]],
	answers = { { "（離開）" } },
}

newChat{ id = "rewarded",
	text = [[「幹得漂亮。這是你應得的報酬。」
受付孃在委託書上蓋了個章。「巴別塔還深得很——歡迎再來接委託。」]],
	answers = { { "（離開）" } },
}

newChat{ id = "thanks",
	text = [[「上次的委託辛苦了。巴別塔隨時歡迎你。」]],
	answers = { { "（離開）" } },
}

return "welcome"
