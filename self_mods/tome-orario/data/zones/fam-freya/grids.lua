-- 芙蕾雅眷族據點的地形。
load("/data/general/grids/basic.lua")   -- HARDWALL / DOOR / FLOOR / WALL

-- 回中央廣場的傳送門（抄巴別塔 BABEL_UP_HUB 的寫法，只換目的地）。
newEntity{
	base = "FLOOR", define_as = "FAM_FREYA_EXIT",
	name = "回到中央廣場",
	desc = "一道安靜的傳送門，通往歐拉麗中央廣場。",
	display = '<', color = colors.LIGHT_RED,
	image = "terrain/marble_floor.png", add_mos = { { image = "terrain/maze_teleport.png" } },
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "orario+orario",
}
