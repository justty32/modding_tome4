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
