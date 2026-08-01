-- 芙蕾雅眷族・眷族長夜語的對話。
-- ⚠️ 對話檔必須 return 起始 chat id（E/Chat.lua:70）。「離開」放最前面。

newChat{ id = "welcome",
	text = [[「……進來吧。門沒關，芙蕾雅眷族不設防。」
昏暗大廳裡的女人沒有起身，只是轉過頭看你，像在端詳一件剛入手的器皿。
「迷路的冒險者？還是……專程來找我們的？」]],
	answers = {
		{ "（離開）" },

		{ "打聽芙蕾雅眷族的事。",
			jump = "lore",
		},

		{ "（初次拜訪，討一份見面禮。）",
			cond = function(npc, player) return not player.__orario_freya_gift end,
			action = function(npc, player)
				player.__orario_freya_gift = true
				player:incMoney(40)
				game.logPlayer(player, "#GOLD#夜語沒有多問，只讓一枚錢袋滑到你腳邊：「這是你的見面禮。我已經記住你了。」#WHITE#")
			end,
			jump = "gift",
		},

		{ "問歐拉麗的傳聞。",
			jump = "rumor",
		},
	},
}

newChat{ id = "lore",
	text = [[「芙蕾雅眷族不追名聲，只追『潛力』。我見過在巴別塔第一層就敢往深處走的新人，
也見過名滿歐拉麗的強者，在第一層就永遠留在了那裡。」她微微一笑。
「他們都說我們的眼睛看得太遠。也許吧——但看得遠的人，從不後悔自己看到的一切。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "gift",
	text = [[「見面禮……不，這只是『留意』的代價。」她低聲說。
「好好活著，從巴別塔回來，再來找我——到那時候，我們再談真正重要的事。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "rumor",
	text = [[「歐拉麗的傳聞啊……巴別塔最近比往常『吵』，深處的怪物活動得頻繁了些，
公會因此掛出了討伐委託；市集頂排開了家新武具行，據說師傅的手藝不錯；
還有——」她頓了頓。「豐饒女主人酒館來了幾個生面孔的冒險者，身手都不俗。
去認識認識，對你沒壞處。」]],
	answers = { { "（告辭）" } },
}

return "welcome"
