-- 洛基眷族・眷族長弗羅斯特的對話。
-- ⚠️ 對話檔必須 return 起始 chat id（E/Chat.lua:70）。「離開」放最前面。

newChat{ id = "welcome",
	text = [[「洛基眷族的據點，閒人免進——」劍士的目光掃過你，語氣緩了半分。
「……不過你既然能從中央廣場走進來，想必也不是純粹的閒人。說吧，什麼事？」]],
	answers = {
		{ "（離開）" },

		{ "打聽洛基眷族的事。",
			jump = "lore",
		},

		{ "（初次拜訪，討一份見面禮。）",
			cond = function(npc, player) return not player.__orario_loki_gift end,
			action = function(npc, player)
				player.__orario_loki_gift = true
				player:incMoney(50)
				game.logPlayer(player, "#GOLD#弗羅斯特扔給你一袋金幣：「洛基眷族不欠人情——這是見面禮，收下就兩清。」#WHITE#")
			end,
			jump = "gift",
		},

		{ "打聽巴別塔深層的傳言。",
			jump = "deep",
		},
	},
}

newChat{ id = "lore",
	text = [[「我們管著巴別塔中層的巡邏——不是因為最有耐心，而是因為最有把握。
每一層誰在、誰該走、誰該留下，洛基眷族都記錄在案。」他頓了頓。
「巡邏守則就三句：出手可以，記仇不行；見死不救，當天除名；巴別塔吃人，洛基不吃自己人。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "gift",
	text = [[「歐拉麗的規矩：新面孔上門，東道主不能空手。」他把錢袋拋給你。
「不過記住——這不是施捨，是投資。等你哪天在巴別塔裡闖出名號，洛基眷族會記得你。」]],
	answers = { { "（告辭）" } },
}

newChat{ id = "deep",
	text = [[「深層的傳言……」他沉默了一會。「有人說，巴別塔往下不是越挖越深，
而是越走越像某個『本就不該存在』的地方。階層主的血統越來越古老，也越來越不像活物。」
他看了你一眼。「這不是勸退，是提醒。裝備、藥水、同伴——一樣都別省。」]],
	answers = { { "（告辭）" } },
}

return "welcome"
