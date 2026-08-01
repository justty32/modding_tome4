-- 潮沒石陣的地形。
load("/data/general/grids/basic.lua")  -- FLOOR / WALL / DOOR / UP / DOWN

-- 第一層的上樓梯直接通回符文諸島大地圖。
newEntity{
	define_as = "RI_UP_WORLDMAP",
	type = "floor", subtype = "floor",
	name = "離開，回到符文諸島",
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/worldmap.png" } },
	display = '<', color_r = 255, color_g = 0, color_b = 255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "runeisles+worldmap",
}
