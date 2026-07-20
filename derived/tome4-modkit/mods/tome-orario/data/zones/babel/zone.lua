-- 巴別塔——歐拉麗中央的大迷宮。程序生成的多層地城（抄 runeisles/unnamed-tomb 的 Roomer 手法）。
-- 短名 "orario+babel"。第 1 層的上樓梯通回中央廣場（而非上一層）。
return {
	name = "巴別塔",
	level_range = { 1, 12 },
	level_scheme = "player",
	max_level = 5,
	width = 40, height = 40,
	all_lited = false,       -- 地城：迷霧探索
	persistent = "zone",
	ambient_music = "Dungeon.ogg",

	generator = {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 8,
			edge_entrances = { 4, 6 },
			rooms = { "simple", "pilar" },
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = { 6, 10 },
			-- 討伐委託的目標，保證在第 1 層生成（見 npcs.lua 的 ORARIO_BOUNTY_BOSS）。
			guardian = "ORARIO_BOUNTY_BOSS",
			guardian_level = 1,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = { 2, 4 },
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = { 0, 2 },
		},
	},

	-- 第 1 層的上樓梯通回中央廣場（levels[n] 深合併進 zone 資料，engine/Zone.lua:867，
	-- 只覆寫 up、不會洗掉 generator.map.class）。
	levels = {
		[1] = {
			generator = { map = { up = "BABEL_UP_HUB" } },
		},
	},
}
