-- 芙蕾雅眷族據點的焊死 NPC。
-- 貼圖沿用原版 npc/*.png。焊在靜態地圖上：fam-freya.lua 的 defineTile 第 4 參。

-- 眷族長・夜語。芙蕾雅眷族的當家，行事神秘。對話 = "orario+fam-freya-head"。
newEntity{
	define_as = "FAM_FREYA_HEAD",
	type = "humanoid", subtype = "elf",
	name = "眷族長・夜語",
	display = 'p', color = colors.VIOLET,
	image = "npc/humanoid_shalore_elven_mage.png",
	desc = "芙蕾雅眷族的眷族長。她打量你的眼神，像在估量一件物件的價值。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-freya-head",

	body = { INVEN = 10 },
	life_rating = 100, max_life = 5000,
	rank = 3, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 10, dex = 14, mag = 16, con = 10 },
}

-- 情報屋・嵐。芙蕾雅眷族的眼睛，專賣歐拉麗的傳聞。對話 = "orario+fam-freya-rogue"。
newEntity{
	define_as = "FAM_FREYA_ROGUE",
	type = "humanoid", subtype = "human",
	name = "情報屋・嵐",
	display = 'p', color = colors.GREY,
	image = "npc/humanoid_human_rogue.png",
	desc = "芙蕾雅眷族的情報屋。帽子壓得很低，聲音低到只有你聽得見。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-freya-rogue",

	body = { INVEN = 10 },
	life_rating = 80, max_life = 3000,
	rank = 2, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 10, dex = 16, mag = 10, con = 10 },
}
