-- 碑港的地形。
load("/data/general/grids/basic.lua")     -- HARDWALL / DOOR / FLOOR / WALL
load("/data/general/grids/water.lua")     -- DEEP_WATER
load("/data/general/grids/mountain.lua")  -- ROCKY_SNOWY_TREE*

-- ⚠️ 不要用 base="GRASS"。
-- data/general/grids/forest.lua:29 給 GRASS 掛了
-- nice_tiler = { method="replace", base={"GRASS_PATCH", 100, 1, 14} }，
-- 100% 機率把貼圖換成草地變體——你設的 image 永遠不會出現在畫面上。
-- 實機第一次進碑港，整座雪港是綠草地就是這麼來的。
-- 所以下面三個地形都不繼承任何 base，自己從頭定義。
newEntity{
	define_as = "RI_TOWN_GROUND",
	type = "floor", subtype = "snow",
	name = "積雪的地面", image = "terrain/frozen_ground.png",
	display = '.', color = colors.WHITE, back_color = colors.LIGHT_BLUE,
}
newEntity{
	define_as = "RI_TOWN_FLAGSTONE",
	type = "floor", subtype = "floor",
	name = "石板地", image = "terrain/stone_road1.png",
	display = '_', color = colors.GREY, back_color = colors.DARK_GREY,
	special_minimap = colors.DARK_GREY,
}
newEntity{
	define_as = "RI_TOWN_PIER",
	type = "floor", subtype = "floor",
	name = "棧橋", image = "terrain/stone_road1.png",
	display = '=', color = colors.UMBER, back_color = colors.DARK_UMBER,
	special_minimap = colors.UMBER,
}

newEntity{ base = "HARDWALL", define_as = "RI_RUNESTONE",
	name = "符文石碑",
	desc = "刻滿古弗薩克文的立石。字跡被風雪磨得很淺，但仍讀得出來。",
	display = 'O', color = colors.LIGHT_BLUE,
}

-- 雪松，取代原版的綠樹（這裡是北方冰封群島）
newEntity{ base = "ROCKY_SNOWY_TREE1", define_as = "RI_TOWN_TREE", name = "霜杉" }

-- 回大地圖。基底照抄原版 GRASS_UP_WILDERNESS（data/general/grids/forest.lua:151-162），
-- 只把 change_zone 換成我們自己的大地圖短名。
newEntity{
	define_as = "RI_UP_WORLDMAP",
	type = "floor", subtype = "snow",
	name = "離開，回到符文諸島",
	image = "terrain/frozen_ground.png", add_mos = { { image = "terrain/worldmap.png" } },
	display = '<', color_r = 255, color_g = 0, color_b = 255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "runeisles+worldmap",
}
