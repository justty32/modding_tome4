-- 巴別塔的地形。
load("/data/general/grids/basic.lua")   -- HARDWALL / DOOR / FLOOR / WALL / UP / DOWN

-- 第 1 層的上樓梯：通回中央廣場。繼承 UP（上樓梯外觀），只換目的地。
newEntity{
	base = "UP", define_as = "BABEL_UP_HUB",
	name = "離開巴別塔，回到中央廣場",
	change_level = 1,
	change_zone = "orario+orario",
}
