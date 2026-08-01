-- 赫斯緹雅眷族據點的焊死 NPC。
-- 與公會受付孃同款：faction 非敵對 + can_talk 即「攻擊＝開對話」（Combat.lua:42-49），
-- 不需自己掛 hook。貼圖沿用原版 npc/*.png（美術成本 0，見 npc-and-chats.md §4.5）。
-- 焊在靜態地圖上：fam-hearth.lua 的 defineTile 第 4 參 = actor 的 define_as。

-- 眷族長・希爾妲。爐灶女神的祭司，赫斯緹雅眷族的代理團長。對話 = "orario+fam-hearth-head"。
newEntity{
	define_as = "FAM_HEARTH_HEAD",
	type = "humanoid", subtype = "human",
	name = "眷族長・希爾妲",
	display = 'p', color = colors.LIGHT_RED,
	image = "npc/humanoid_human_human_citizen.png",
	desc = "赫斯緹雅眷族的代理團長。圍裙上沾著麵粉與香灰，笑起來像鄰家的祖母。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-hearth-head",

	body = { INVEN = 10 },
	life_rating = 100, max_life = 5000,
	rank = 3, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 10, dex = 10, mag = 10, con = 10 },
}

-- 見習冒險者・堤姆。夢想跟同伴一起下巴別塔的少年。對話 = "orario+fam-hearth-apprentice"。
newEntity{
	define_as = "FAM_HEARTH_APPRENTICE",
	type = "humanoid", subtype = "human",
	name = "見習冒險者・堤姆",
	display = 'p', color = colors.LIGHT_UMBER,
	image = "npc/humanoid_human_apprentice_mage.png",
	desc = "赫斯緹雅眷族最年輕的成員。木劍繫在腰間，眼睛亮得像第一次看見巴別塔的人。",
	faction = "allied-kingdoms",
	can_talk = "orario+fam-hearth-apprentice",

	body = { INVEN = 10 },
	life_rating = 80, max_life = 3000,
	rank = 2, size_category = 3,
	exp_worth = 0,
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 12, dex = 12, mag = 8, con = 10 },
}
