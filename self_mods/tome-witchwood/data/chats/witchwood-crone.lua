-- 守根人 葛薇（WITCHWOOD_CRONE）的對話——支線任務「竊語老槐」。
--
-- ⚠️ 檔尾必須 return 起始節點的 id，否則 E/dialogs/Chat.lua:134 nil index 崩潰
--    （E/Chat.lua:70：檔案的回傳值就是 default_id）。
-- ⚠️ 「離開」放 answers 最前面：選項一多對話框會被擠出畫面底部。
-- 對話檔每次開啟都重新執行（E/Chat.lua:69 loadchat），所以檔頂可以直接讀
-- game.player 的任務狀態，用動態文字生成 notyet 節點。
--
-- 任務進度（討伐數）的算法與 quest 檔一致：game.player.all_kills[名字] 減去
-- 接任務時的基準（q.kills_base），見 data/quests/witchwood-curse.lua 檔頭。

local Quest = engine.Quest
local QID = "witchwood-curse"
local NEEDED = 3
local REWARD = 45
local HAG_NAME = "林中老嫗"

local function hagKills(p)
	local ak = p and p.all_kills
	if not ak then return 0 end
	local n = ak[HAG_NAME] or 0
	if n == 0 then
		for k, v in pairs(ak) do
			if type(k) == "string" and k:find(HAG_NAME, 1, true) then n = n + v end
		end
	end
	return n
end

local function progress(p)
	local q = p and p:hasQuest(QID)
	if not q then return 0 end
	return hagKills(p) - (q.kills_base or 0)
end

-- 覆命動作：討伐數夠了 → 結案＋領賞，跳 rewarded；不夠 → 跳 notyet。
-- action 的回傳值會覆蓋 jump（E/dialogs/Chat.lua:103-110），所以兩邊都能跳。
local function report(npc, player)
	local cur = progress(player)
	if cur < NEEDED then return "notyet" end
	player:setQuestStatus(QID, Quest.COMPLETED)
	player:setQuestStatus(QID, Quest.DONE)
	player:incMoney(REWARD)
	game.logPlayer(player, ("#GOLD#葛薇把一袋乾枯的藥草和 %d 枚金幣塞進你手裡。#WHITE#"):format(REWARD))
	return "rewarded"
end

-- 討伐中的動態進度文字（每次開對話重新執行，所以數字是當下的）
local q = game.player and game.player:hasQuest(QID)
local cur = (q and math.min(progress(game.player), NEEDED)) or 0
local notyet_text
if cur <= 0 then
	notyet_text = [[葛薇嗅了嗅空氣，搖了搖頭。
「黑汁還在樹心裡滾。一個姊妹都還沒有離開——你聞不到嗎？那股腐葉、鐵鏽跟舊血的氣味。」
她按住樹根。「去林子深處。根鬚連著三個姊妹，把她們送走。」]]
else
	notyet_text = ("葛薇嗅了嗅空氣，閉上眼睛。\n「走了 %d 個姊妹……還差 %d 個。黑汁縮回去一點了，但根鬚還連著。」\n她按住樹根，像在聽它喘息。「別拖太久。拖久了，腐化會順著根往瑞文谷爬。」"):format(cur, NEEDED - cur)
end

newChat{ id = "welcome",
	text = [[老嫗盤坐在一條沒入地下的老樹根旁，沒有回頭。
「又有人從瑞文谷那邊過來。」她的聲音像乾樹皮在摩擦。「你聞到了嗎——這片林子底下，有東西在改道。」]],
	answers = {
		{ "（離開）" },

		-- 尚未接任務 → 授予。
		{ "我聽說了這片森林的詛咒。",
			cond = function(npc, player) return not player:hasQuest(QID) end,
			action = function(npc, player) player:grantQuest("witchwood+witchwood-curse") end,
			jump = "granted",
		},

		-- 討伐中 → 覆命（夠了結案，不夠帶去 notyet）。
		{ "我來覆命——林中老嫗的事。",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.PENDING) end,
			action = report,
			jump = "notyet",
		},

		-- 已討伐、還沒結案的防禦分支（正常流程會在同一段對話直接結案）。
		{ "我討伐完畢，前來覆命。",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.COMPLETED) end,
			action = function(npc, player)
				player:setQuestStatus(QID, Quest.DONE)
				player:incMoney(REWARD)
				game.logPlayer(player, ("#GOLD#葛薇把一袋乾枯的藥草和 %d 枚金幣塞進你手裡。#WHITE#"):format(REWARD))
				return "rewarded"
			end,
		},

		-- 已結案。
		{ "（向婆婆道別）",
			cond = function(npc, player) return player:isQuestStatus(QID, Quest.DONE) end,
			jump = "thanks",
		},
	},
}

newChat{ id = "granted",
	text = [[葛薇終於轉過頭。她的眼睛像兩潭褐色的死水，裡面有東西在游。
「這片林子底下埋著一棵老槐——女巫的源頭。第一個走進這片林的女人，從它的根鬚底下聽懂了草木的低語。女巫的學問，全都是從這兒漏出去的。」
「這幾年，黑汁從瑞文谷方向滲進樹心，纏住了三個姊妹。她們不再守樹根，開始獵殺旅人——腐化喜歡血，越殺，根就爛得越快。」
「我走不開。你替我把那三個姊妹送走。根鬚斷了，黑汁就爬不回來。」]],
	answers = { { "我明白了。" } },
}

newChat{ id = "notyet",
	text = notyet_text,
	answers = { { "（離開）" } },
}

newChat{ id = "rewarded",
	text = [[「根鬚斷了。」葛薇閉上眼睛，很久很久。
「謝謝你，旅人。老槐欠你一條命，我也欠你一條。」
她遞過來一袋乾枯的藥草與金幣。「回瑞文谷去吧。告訴他們，林子暫時還撐得住。」]],
	answers = { { "（收下謝禮）" } },
}

newChat{ id = "thanks",
	text = [[「根鬚安靜下來了。」葛薇按著樹根，像在聽它的心跳。
「林子裡的東西不會忘記你。有事，就再來。」]],
	answers = { { "（離開）" } },
}

return "welcome"
