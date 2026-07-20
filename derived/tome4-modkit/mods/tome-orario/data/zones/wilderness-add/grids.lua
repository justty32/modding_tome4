-- 追加到 Eyal 大地圖 grid_list 的地磚（歐拉麗之門）。由 hooks 的 Entity:loadList 併入。
-- 目的地 "orario+orario" 是普通城鎮 zone（非 wilderness），所以不需 change_level_check。
newEntity{
	base = "PLAINS",
	define_as = "ORARIO_PORTAL",
	name = "歐拉麗之門",
	desc = "一道憑空立起的巨大石門，門後是另一個世界的天空與一座高聳入雲的高塔。",
	display = 'O', color = colors.GOLD, back_color = colors.DARK_GREEN,
	image = "terrain/grass.png",
	add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
	special_minimap = colors.GOLD,
	notice = true, show_tooltip = true, glow = true,
	nice_tiler = false,
	can_encounter = false,

	change_level = 1,
	change_zone = "orario+orario",
}
