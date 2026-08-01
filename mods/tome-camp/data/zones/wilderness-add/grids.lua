-- 追加到原版 Eyal 大地圖 grid_list 的地磚。由 hooks/load.lua 的 Entity:loadList hook
-- 在原版 /data/zones/wilderness/grids.lua 載完後，用同一個 res 表再載一次（所以 base="PLAINS"
-- 找得到）。照抄官方 orcs DLC 與本專案 runeisles 的 wilderness-add 手法。

-- 營地入口：德斯城旁的小徑，通往你的私人營地。
--
-- 相對 runeisles 的符文石環：**不需要 change_level_check**。runeisles 的目的地是「第二張
-- wilderness 大地圖」，兩張大地圖共用一組 wild_x/wild_y 會互相蓋掉，才要手動換存座標。
-- 這裡的目的地 "camp+base" 是一個普通房間 zone（不是 wilderness），跟進 Trollmire 一樣，
-- 引擎自動記住你在大地圖的位置、離開時放回原處，沒有那個 bug。
newEntity{
	base = "PLAINS",
	define_as = "CAMP_PORTAL",
	name = "營地入口",
	desc = "一條踏出來的小徑，通往你在此紮下的營地。",
	-- 沒有 add_displays 這一格在畫面上就只是草地，玩家找不到入口（runeisles 踩過）。
	display = '&', color = colors.LIGHT_GREEN, back_color = colors.DARK_GREEN,
	image = "terrain/grass.png",
	add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
	special_minimap = colors.LIGHT_GREEN,
	notice = true, show_tooltip = true, glow = true,
	nice_tiler = false,
	can_encounter = false,

	change_level = 1,
	change_zone = "camp+base",
}
