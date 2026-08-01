-- 洛基眷族據點的焊死 NPC。
-- 貼圖沿用原版 npc/*.png。焊在靜態地圖上：fam-loki.lua 的 defineTile 第 4 參。

-- 眷族長・弗羅斯特。負責巴別塔中層巡邏的雙劍士。對話 = "orario+fam-loki-head"。
newEntity{
	define_as = "FAM_LOKI_HEAD",
	type = "humanoid", subtype = "human",
	name = "眷族長・弗羅斯特",
	display = 'p', color = colors.LIGHT_BLUE,
	image = "npc/humanoid_human_gladiator.png",
	desc = "洛基眷族的眷族長。兩道劍疤交叉過眉骨，站姿像隨時準備迎戰一整個階層的怪物。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-loki-head",

	body = { INVEN = 10 },
	life_rating = 100, max_life = 5000,
	rank = 3, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 16, dex = 14, mag = 8, con = 14 },
}

-- 事務長・莉朵。眷族的文書官，對歐拉麗的大小委託瞭若指掌。對話 = "orario+fam-loki-clerk"。
newEntity{
	define_as = "FAM_LOKI_CLERK",
	type = "humanoid", subtype = "human",
	name = "事務長・莉朵",
	display = 'p', color = colors.ORANGE,
	image = "npc/humanoid_human_townsfolk_aimless_looking_merchant01_64.png",
	desc = "洛基眷族的事務長。桌上永遠堆著委託單，嘴角帶著精明的笑。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-loki-clerk",

	body = { INVEN = 10 },
	life_rating = 80, max_life = 3000,
	rank = 2, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 10, dex = 12, mag = 12, con = 10 },
}
