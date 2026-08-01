-- 洛基眷族據點的物件。
-- 載入原版物品基底清單，並定義壁架上的 lore 書（撿起即自動 learnLore）。
load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "FAM_LOKI_BOOK",
	name = "中層巡邏守則",
	lore = "orario-fam-loki",
	desc = "洛基眷族的巡邏守則手抄本，邊角有磨損與舊血跡。",
	rarity = false,
	encumberance = 0,
}
