-- 赫斯緹雅眷族據點的物件。
-- 載入原版物品基底清單（object_list 非空，任何 resolvers 才不會靜默失敗），
-- 並定義爐灶旁的 lore 書（base = BASE_LORE 由 objects-maj-eyal.lua → objects.lua → scrolls.lua
-- 帶進來；撿起即自動 learnLore，見 mod/class/Object.lua:2489-2491）。
load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "FAM_HEARTH_BOOK",
	name = "爐灶之家的規矩",
	lore = "orario-fam-hearth",
	desc = "一本手抄的小冊子，記著赫斯緹雅眷族的會規與爐灶女神的訓誨。",
	rarity = false,
	encumberance = 0,
}
