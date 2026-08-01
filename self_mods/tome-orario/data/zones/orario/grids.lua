-- 歐拉麗中央廣場的地形。
load("/data/general/grids/basic.lua")   -- HARDWALL / DOOR / FLOOR / WALL

-- 巴別塔——中央大迷宮的入口。走上去按 '>' 進入。
newEntity{
	base = "FLOOR", define_as = "ORARIO_TOWER",
	name = "巴別塔——迷宮入口",
	desc = "高聳入雲的白色巨塔，向下延伸成無盡的地下迷宮。冒險者的一切在此開始。",
	display = '>', color = colors.GOLD, back_color = colors.DARK_GREY,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/stair_down.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "orario+babel",
}

-- 回到 Eyal 大地圖（歐拉麗之門）。
newEntity{
	base = "FLOOR", define_as = "ORARIO_EXIT",
	name = "歐拉麗之門，回到 Eyal 大地圖",
	display = '<', color_r = 255, color_g = 0, color_b = 255,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/worldmap.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

-- ── 眷族據點傳送門（廣場底部三棟建築的門內，data/maps/orario.lua 的 p/q/r）──────────
-- 走上去按 '>' 進入各眷族據點。外觀抄原版 Angolwen 傳送門的 maze_teleport 疊圖
-- （wilderness/grids.lua:527）。

newEntity{
	base = "FLOOR", define_as = "ORARIO_FAM_HEARTH",
	name = "赫斯緹雅眷族 據點",
	desc = "一扇泛著暖光的傳送門，通往赫斯緹雅眷族的據點——歐拉麗最樸素也最有人情味的家。",
	display = '&', color = colors.LIGHT_RED,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/maze_teleport.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "orario+fam-hearth",
}

newEntity{
	base = "FLOOR", define_as = "ORARIO_FAM_LOKI",
	name = "洛基眷族 據點",
	desc = "一座氣派的傳送門，通往洛基眷族的據點——掌控巴別塔中層秩序的頂尖眷族。",
	display = '&', color = colors.LIGHT_RED,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/maze_teleport.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "orario+fam-loki",
}

newEntity{
	base = "FLOOR", define_as = "ORARIO_FAM_FREYA",
	name = "芙蕾雅眷族 據點",
	desc = "一道半掩在陰影裡的傳送門，通往芙蕾雅眷族的據點——歐拉麗最深不可測的地方。",
	display = '&', color = colors.LIGHT_RED,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/maze_teleport.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "orario+fam-freya",
}
