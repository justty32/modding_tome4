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
	--       M/data/zones/slime-tunnels/zone.lua:72-78（post_process 裡用 Astar 驗連通）
	--
	-- ⚠️ 修過的坑 1：post_process 是 zone 等級的欄位，E/Zone.lua:1163-1164 每生成一層
	-- 都會呼叫一次——max_level=3 的這個 zone 會在 3 層樓各放一個葛薇，
	-- 變成同一個「守根人」同時出現在 3 個地方（playtest 實測抓到）。
	-- 她的設定是「守著唯一一條老樹根、走不開」，只該出現在玩家踏進來的那一層。
	--
	-- ⚠️ 修過的坑 2（2026-08-01 實機回報「守根人卡在入口」）：舊版用
	--   util.findFreeGrid(up.x, up.y, 6, true, {ACTOR=true})
	-- 找位置，有兩個致命問題：
	--   a) findFreeGrid（E/utils.lua:2966-2978）依距離**升序**排序後回傳最近的一格，
	--      而 up 那格自己也是「可走、沒有 actor」→ 距離 0 → 她被放在**入口樓梯格上**。
	--      玩家進場時 M/mod/class/Game.lua:1301-1306 偵測到樓梯上有人，force move 她
	--      到最近的空格；`edge_entrances = {4,6}` 讓入口是**地圖邊緣**的樓梯，
	--      往內只有一條**一格寬**的隧道（E/generator/map/Roomer.lua:117-145），
	--      所以她被推到那條隧道唯一的一格上，整個入口被她堵死。
	--      她是 never_move + cant_be_moved + can_talk：
	--        - M/mod/class/interface/Combat.lua:41-45 撞到 can_talk 的目標會**開對話**，
	--          走不到 :50 那條 swap 分支，玩家永遠換不掉她的位置；
	--        - M/mod/class/interface/ActorAI.lua:332 never_move/cant_be_moved 直接
	--          讓 canBumpDisplace 回 false，NPC 也推不動她。
	--      實測證據：玩家 (0,33)，她 (0,34)，八方只有 (0,34) 可走，canMove(0,34)=false；
	--      A* 只看地形時 entrance→(9,36) 有 11 步，把 actor 也算進去就是 NIL。
	--   b) findFreeGrid 內部查的是 `game.level.map`，但 post_process 跑在
	--      E/Zone.lua:1163（`game.level` 還是**上一張**地圖，見 Game:changeLevel 的
	--      賦值順序）——它其實在對錯的地圖做 isBound / ACTOR / block_move 判斷。
	--
	-- 現在的做法：自己掃 `level.map`（唯一保證正確的那張），只挑滿足下列條件的格子，
	-- 依離入口的距離升序取第一個能過驗證的：
	--   * 可走、沒有 actor、不是樓梯也沒有 change_zone / change_level
	--   * 離入口至少 2 格（不站在入口旁邊跟玩家搶格子）
	--   * 八方至少 5 格可走 → 是房間內的開闊地，不是一格寬的通道
	--   * 硬保證：把她那格當牆，A* 仍能從入口走到下樓梯；且入口走得到她
	post_process = function(level)
		if level.level ~= 1 then return end
		local Map = require "engine.Map"
		local Astar = require "engine.Astar"
		local map = level.map
		local up, down = level.default_up, level.default_down
		if not map or not up then return end

		local function walkable(x, y)
			return map:isBound(x, y) and not map:checkEntity(x, y, Map.TERRAIN, "block_move")
		end

		-- 便宜的篩選：地形／占用／不是出入口／不是一格寬通道
		local function plausible(x, y)
			if not walkable(x, y) then return false end
			if map(x, y, Map.ACTOR) then return false end
			if x == up.x and y == up.y then return false end
			if down and x == down.x and y == down.y then return false end
			local t = map(x, y, Map.TERRAIN)
			if not t or t.change_zone or t.change_level then return false end
			local open = 0
			for i = -1, 1 do for j = -1, 1 do
				if (i ~= 0 or j ~= 0) and walkable(x + i, y + j) then open = open + 1 end
			end end
			return open >= 5
		end

		-- 昂貴的驗證：她既走得到，又不會把入口到下樓梯的路切斷
		local a = Astar.new(map, game:getPlayer())
		local function connectivity_ok(x, y)
			if not a:calc(up.x, up.y, x, y) then return false end
			if down and (down.x ~= up.x or down.y ~= up.y) then
				local not_her = function(cx, cy) return not (cx == x and cy == y) end
				if not a:calc(up.x, up.y, down.x, down.y, nil, nil, not_her) then return false end
			end
			return true
		end

		local cands = {}
		for x = 0, map.w - 1 do for y = 0, map.h - 1 do
			local d = core.fov.distance(up.x, up.y, x, y)
			if d >= 2 and plausible(x, y) then cands[#cands + 1] = { x = x, y = y, d = d } end
		end end
		table.sort(cands, function(p, q) return p.d < q.d end)

		local m = game.zone:makeEntityByName(level, "actor", "WITCHWOOD_CRONE")
		if not m then return end
		for _, c in ipairs(cands) do
			if connectivity_ok(c.x, c.y) then
				game.zone:addEntity(level, m, "actor", c.x, c.y)
				print(("[WITCHWOOD] crone placed at %d,%d up=%d,%d dist=%d"):format(c.x, c.y, up.x, up.y, c.d))
				return
			end
		end
		print(("[WITCHWOOD] crone placement FAILED: %d candidates, none connectivity-safe"):format(#cands))
	end,
}
