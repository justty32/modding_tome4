-- 女巫森林（Witchwood）——瑞文谷（Derth）西北方一片被詛咒的老林。
--
-- 本檔是 Agent B（地圖）的 zone 定義。做法照 self_mods/tome-runeisles/
-- data/zones/stone-circle/zone.lua（本 repo 已驗證過的 dungeon 範本）：
--   * generator.map 用 Roomer（石陣同款，最穩）
--   * generator.actor 用 Random + guardian，怪一律引用 Agent A 的三個 id
--   * levels[1] 把 up 換成回大地圖的出口（照石陣 :74-78 的寫法）
--
-- zone short_name 必須是 witchwood，路徑走 addon 私有掛載點：
-- engine/Zone.lua:160-166 看到 "addon+name" 才把查找路徑換成 /data-witchwood/zones/，
-- 所以入口地磚的 change_zone 是 "witchwood+witchwood"（詳見 wilderness-add.lua 註解）。
return {
	name = "女巫森林",
	level_range = { 1, 30 },
	level_scheme = "player",
	-- 沒有 max_level 會 assert 崩潰（engine/Zone.lua:124）
	max_level = 3,
	width = 50, height = 50,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	color_shown = { 0.62, 0.8, 0.58, 1 },
	color_obscure = { 0.35, 0.5, 0.32, 0.6 },
	ambient_music = "Woods of Eremae.ogg",

	generator = {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = { 4, 6 },
			rooms = { "simple", "pilar" },
			['.'] = "WITCHWOOD_FLOOR",
			['#'] = "WITCHWOOD_TREE",
			up = "WITCHWOOD_UP2",
			down = "WITCHWOOD_DOWN",
			door = "WITCHWOOD_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = { 12, 18 },
			filters = { { max_ood = 2 } },
			-- guardian 由 engine/generator/actor/Random.lua:98-99 用名字撈
			-- npc_list（engine/Zone.lua:486-493），跟 rarity 無關，保證每場必有。
			guardian = "WITCHWOOD_HAG",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = { 4, 7 },
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = { 0, 0 },
		},
	},

	-- 第一層的「上樓梯」通回原版 Eyal 大地圖（change_zone = "wilderness"）。
	-- 進 zone 時 mod/class/Game.lua:1258-1271 會找 change_zone == 來處 short_name
	-- 的地磚當落腳點——所以玩家從入口踏進來會直接站在這格出口上。
	levels = {
		[1] = {
			generator = { map = { up = "WITCHWOOD_UP_WILDERNESS" } },
		},
	},

	-- -----------------------------------------------------------------------
	-- 把守根人葛薇放到地圖上（本 session 代為接線，補三個 agent 之間的接縫）。
	-- -----------------------------------------------------------------------
	-- 本 zone 是 Roomer 隨機生成，沒有靜態地圖可以 defineTile
	-- （runeisles 的守碑人是靠 town 靜態圖放的，這裡走不通），
	-- 所以照原版隨機 zone 的作法在 post_process 指名生成 + 找空格放。
	-- 前例：M/data/zones/arena-unlock/zone.lua:40-45（makeEntityByName + addEntity）
	--       M/data/zones/noxious-caldera/zone.lua:108（util.findFreeGrid 找空格）
	post_process = function(level)
		local m = game.zone:makeEntityByName(level, "actor", "WITCHWOOD_CRONE")
		if not m then return end
		-- 從上樓梯往外找空格：玩家一進圖就看得到她，又不會壓在 change_zone 格上
		-- （壓在出口格的坑見 docs/knowledge/npc-and-chats.md）。
		local up = level.default_up
		if not up then return end
		local x, y = util.findFreeGrid(up.x, up.y, 6, true, { [engine.Map.ACTOR] = true })
		if x and y then
			game.zone:addEntity(level, m, "actor", x, y)
		end
	end,
}
