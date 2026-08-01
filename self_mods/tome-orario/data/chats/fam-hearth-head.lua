-- 赫斯緹雅眷族・眷族長希爾妲的對話。
-- ⚠️ 對話檔必須 return 起始 chat id（E/Chat.lua:70）。「離開」放最前面（選項會被擠出畫面）。

newChat{ id = "welcome",
	text = [[「哎呀，有客人上門了——歡迎歡迎，這裡是赫斯緹雅眷族的據點。」
圍裙上沾著麵粉的老婦人擦了擦手，朝你笑。「外頭風大吧？坐下喝杯茶再走。」]],
	answers = {
		{ "（離開）" },

		{ "打聽赫斯緹雅眷族的事。",
			jump = "lore",
		},

		{ "（初次拜訪，討一份見面禮。）",
			cond = function(npc, player) return not player.__orario_hestia_gift end,
			action = function(npc, player)
				player.__orario_hestia_gift = true
				player:incMoney(30)
				game.logPlayer(player, "#GOLD#希爾妲把 30 枚金幣塞進你手裡：「眷族窮，但待客的禮數不能少。」#WHITE#")
			end,
			jump = "gift",
		},

		{ "問問歐拉麗該怎麼走。",
			jump = "city",
		},
	},
}

newChat{ id = "lore",
	text = [[「我們啊，是全歐拉麗最小的眷族——沒有自己的塔，也沒有半支像樣的冒險者隊伍，
據點還是這間舊神祠改建的。」她替你倒了杯熱茶。「但爐灶女神只獎賞守約的人，
所以我們的會規只有三條：對同伴守信、對客人奉茶、對巴別塔保持敬畏。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "gift",
	text = [[「眷族雖然窮，但該有的禮數一樣不少。這點錢拿去，買點像樣的東西，
別學堤姆那小子光著腳就想闖巴別塔。」她瞇著眼笑了。「有空常回來坐坐。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "city",
	text = [[「從據點出去就是中央廣場。白塔『巴別塔』的入口在廣場中央——要下迷宮就往那走；
要接討伐委託就去找冒險者公會的受付孃；想補充行囊，頂排那排『巴別塔市集』的
武具行、雜貨行和材料行都能逛逛。」她朝門外努了努嘴。「歐拉麗不大，但該有的都有。」]],
	answers = { { "（告辭）" } },
}

return "welcome"
