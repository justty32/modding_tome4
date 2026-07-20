-- 無銘之墓（The Unnamed Tomb）——北島，主線終點。
return {
	name = "無銘之墓",
	level_range = { 6, 20 },
	level_scheme = "player",
	max_level = 3,
	width = 50, height = 50,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Dungeon.ogg",

	generator = {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = { 4, 6 },
			rooms = { "simple", "pilar", "circular" },
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = { 10, 14 },
			-- guardian 預設只在 zone.max_level 那一層生成
			-- （engine/generator/actor/Random.lua:50-56 的 glevel = self.zone.max_level），
			-- 所以無銘之物出現在第 3 層，不必自己指定 guardian_level。
			guardian = "RI_THE_UNNAMED",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = { 4, 6 },
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = { 0, 0 },
		},
	},

	-- 第一層的「上樓梯」要通回符文諸島的大地圖，而不是上一層。
	-- levels[n] 是深合併進 zone 資料的（engine/Zone.lua:867 的 table.merge(..., true)），
	-- 所以這裡只寫 up，不會把 generator.map 的 class 洗掉。
	levels = {
		[1] = {
			generator = { map = { up = "RI_UP_WORLDMAP" } },
		},
	},
}
