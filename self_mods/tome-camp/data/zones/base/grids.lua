-- 營地地形。
load("/data/general/grids/basic.lua")   -- HARDWALL / DOOR / FLOOR / WALL

-- 營火：純裝飾（療癒由「返回營地」天賦在抵達時處理，不塞進 grid callback——
-- 匿名 callback 不可序列化，是 tutorial 10 的核心教訓）。繼承 FLOOR 以正常渲染地磚。
newEntity{
	base = "FLOOR", define_as = "CAMP_FIRE",
	name = "營火",
	desc = "劈啪作響的營火。在它旁邊歇腳，疲憊一掃而空。",
	display = '*', color = colors.LIGHT_RED, back_color = colors.DARK_GREY,
	special_minimap = colors.LIGHT_RED,
}

-- 可建造的儲物箱（由 T_CAMP_BUILD_STASH 用 makeEntityByName+addEntity 放到玩家腳下）。
-- 繼承 FLOOR 以正常渲染且可站立。
newEntity{
	base = "FLOOR", define_as = "CAMP_STASH",
	name = "儲物箱",
	desc = "一個結實的木箱，存放你的家當。",
	display = '=', color = colors.UMBER, back_color = colors.DARK_UMBER,
	special_minimap = colors.UMBER,
}

-- 出口：走回 Eyal 大地圖（從大地圖入口進來的玩家由此離開）。
-- change_zone "wilderness" ＝原版 Eyal 大地圖 zone（/data/zones/wilderness/）。
-- 基底照抄原版離開大地圖的地磚語意。
newEntity{
	base = "FLOOR", define_as = "CAMP_EXIT",
	name = "離開營地，回到大地圖",
	display = '<', color_r = 255, color_g = 0, color_b = 255,
	image = "terrain/worldmap.png",
	always_remember = true, notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
