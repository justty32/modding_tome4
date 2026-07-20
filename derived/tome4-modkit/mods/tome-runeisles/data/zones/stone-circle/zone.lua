-- 潮沒石陣（The Drowned Circle）——中島，主線第一站。
--
-- 古代刻名師鎮壓「無銘之物」的三座符文石陣之一，半沉在浮冰底下。
return {
	name = "潮沒石陣",
	level_range = { 1, 10 },
	level_scheme = "player",
	max_level = 2,   -- 沒有 max_level 會 assert 崩潰（engine/Zone.lua:124）
	width = 50, height = 50,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Woods of Eremae.ogg",

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
			nb_npc = { 8, 12 },
			guardian = "RI_TIDE_WARDEN",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = { 3, 5 },
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = { 0, 0 },
		},
	},

	-- 第一層的「上樓梯」要通回符文諸島的大地圖，而不是上一層。
	-- 原版同款寫法：data/zones/norgos-lair/zone.lua:74-78 的 ROCKY_UP_WILDERNESS。
	levels = {
		[1] = {
			generator = { map = { up = "RI_UP_WORLDMAP" } },
		},
	},

	-- 進入 zone 就推進主線第一階段。on_enter 每次進來都會跑，
	-- 但 engine/Quest.lua:105 對同狀態的子目標會 return false，重複設定無害。
	on_enter = function(lev, old_lev, newzone)
		local p = game.party:findMember{ main = true }
		if p and p:hasQuest("rune-isles") then
			p:setQuestStatus("rune-isles", engine.Quest.COMPLETED, "circle")
		end
	end,
}
