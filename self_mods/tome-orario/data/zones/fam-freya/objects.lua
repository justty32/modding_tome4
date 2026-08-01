-- 芙蕾雅眷族據點的物件。
-- 載入原版物品基底清單，並定義陰影裡的 lore 書（撿起即自動 learnLore）。
load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "FAM_FREYA_BOOK",
	name = "夜之帳",
	lore = "orario-fam-freya",
	desc = "一張邊緣燒焦的紙頁，墨跡淡得幾乎看不見。",
	rarity = false,
	encumberance = 0,
}
