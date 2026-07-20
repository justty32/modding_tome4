-- 守碑人 蘇爾德 的對話。
--
-- 檔尾必須 return 起始節點的 id，否則 engine/dialogs/Chat.lua:134 會 nil index 崩潰。
-- 選項太多時對話框會被擠出畫面底部，所以「結束對話」放最後、劇情選項放前面。

newChat{ id = "welcome",
	text = [[老人抬起頭。他的指節腫大，握著一把磨得極短的刻刀。
「又一個從南邊石環過來的。」他沒有問你是誰。「那你大概還不知道自己站在什麼東西頭上。」]],
	answers = {
		{ "我站在什麼東西頭上？", jump = "unnamed" },
		{ "這些石碑是什麼？", jump = "stones" },
		{ "我先走了。" },
	},
}

newChat{ id = "stones",
	text = [[「刻名師的活兒。」他用刻刀敲了敲最近的一塊。
「符文不是拿來燒東西的。符文是拿來『稱呼』東西的。你能叫出一個東西的名字，你就能綁住它。」
他停了一下。「反過來也成立。」]],
	answers = {
		{ "反過來是什麼意思？", jump = "unnamed" },
		{ "我先走了。" },
	},
}

newChat{ id = "unnamed",
	text = [[「他們殺不掉它。所以他們把它的名字從世界上刻掉了。」
「三座石陣，一座刻一段名字，反著刻——只要那個名字不完整，它就不能被說出口，也就不能真正存在。」
老人終於看著你。「石頭會磨損。海水在磨它。你聽得見嗎？」]],
	answers = {
		{ "我去看看那座石陣。",
			cond = function(npc, player) return not player:hasQuest("rune-isles") end,
			action = function(npc, player) player:grantQuest("runeisles+rune-isles") end,
			jump = "accepted" },
		{ "石陣在哪裡？",
			cond = function(npc, player) return player:hasQuest("rune-isles") end,
			jump = "accepted" },
		{ "這不關我的事。" },
	},
}

newChat{ id = "accepted",
	text = [[「中島。往北走，過浮冰道。」
「你會需要一塊石片——守著石陣的東西身上有一塊。沒有它，北島的墓門不會讓你進去。」
他低下頭繼續刻。「那不是門在攔你。是你會忘記自己要去哪裡。」]],
	answers = {
		{ "我明白了。" },
	},
}

return "welcome"
