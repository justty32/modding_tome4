-- 演出導演（Director）——讓 NPC 照腳本表演。
--
-- ── 為什麼要自己造 ────────────────────────────────────────────────────────────
-- 引擎沒有過場動畫機制（`grep -i cinematic engine/` 零命中），原版
-- M/data/general/events/ 的 31 個事件也沒有任何一個做 NPC 走位。這是從零建的。
--
-- ── v2：演出不吃回合 ─────────────────────────────────────────────────────────
-- v1 把演出掛在 `Player:act()` 上，每推進一步就 `useEnergy()` 讓遊戲繼續跑。
-- 實機一測就爆了：**一段演出跑掉幾千甚至上萬回合**。原因是回合推進的速度只受
-- 引擎 tick 快慢限制，而 `wait{ms=1500}` 這種真實時間的等待每一幀都算一個回合。
-- 附帶災難：中毒、冷卻、飢餓、buff 全部在過場動畫裡飛速流逝。
--
-- v2 改成**完全不推回合**：
--   * 驅動器換成 `Game:registerTimer`（E/Game.lua:216-219）。它由 `Game:display`
--     驅動（同檔 :196-208），而 display **在 `game.paused == true` 時照樣每幀跑**——
--     這就是「畫面在動、回合不動」的那把鑰匙。
--   * 演出期間讓遊戲維持它自然的 paused 狀態，我們一根手指都不碰 `useEnergy`。
--   * NPC 走位靠 `Actor:move(x, y, true)` 直接搬，不需要能量也不需要回合；
--     動畫是 `Entity:setMoveAnim`（E/Entity.lua:567）在 C 層按幀跑的，
--     地圖重繪由 `Map:add`/`Map:remove` 各自的 `updateMap`（E/Map.lua:566,588）負責。
--   * 所以計時單位只有一種：**真實毫秒 `ms`**。v1 的 `turns` 已移除。
--
-- ⚠️ **不要為了「讓回合過去」而在演出裡呼叫 useEnergy()。** 那就是 v1 的 bug。
--    若某段劇情真的需要遊戲世界推進（例如「三天後」），那是劇情腳本該用
--    `game.turn = game.turn + n` 或原版的時間 API 明確表達的事，不是演出框架的職責。
--
-- ── 承重機制（都已回原始碼複驗）─────────────────────────────────────────────
-- 1. 幀驅動：`Game:registerTimer(seconds, cb)` → `_timers_cb`，由 display 遞減。
--    `_timers_cb` **不在 `defaultSavedFields` 白名單裡**（E/Game.lua:122-131），
--    所以不會被序列化，存檔時不會踩到「function 塞進 savefile」的雷。
-- 2. NPC 不跑自己的 AI：E/interface/ActorAI.lua:136
--    `if self.dead or not self.ai then return end` → 清掉 actor.ai 就變木偶。
-- 3. 鏡頭：E/Map.lua:864 `centerViewAround(x, y)`。
-- 4. 輸入鎖：演出期間必須有一個 dialog 攔著鍵盤，否則玩家可以在過場動畫裡亂走。
--
-- ── 單例 ──────────────────────────────────────────────────────────────────────
-- hooks/load.lua 會 dofile 本檔。dofile 每次都會重跑檔案，所以第一次執行時
-- 把自己掛進 _G，之後直接回傳同一份，避免不同呼叫端拿到不同實例。

if rawget(_G, "__tome_director") then return rawget(_G, "__tome_director") end

local Dialog   = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Chat     = require "engine.Chat"
local Astar    = require "engine.Astar"

local D = {}
D.scenes   = {}     -- id -> { steps = {...}, title = ..., on_end = fn }
D.handlers = {}     -- step 種類 -> { enter = fn, tick = fn }
D.cur      = nil    -- 進行中的演出（**刻意不掛在 game 上**，才不會被存檔序列化）
D.log_tag  = "[DIRECTOR]"

-- 幀驅動的間隔。registerTimer 的單位是秒，內部換算成 `seconds * 30` 幀，
-- 所以 1/30 = 下一幀就回來。演出的時間解析度因此就是一幀。
D.pump_interval = 1 / 30

rawset(_G, "__tome_director", D)

-- ── 工具 ─────────────────────────────────────────────────────────────────────

local function dbg(fmt, ...)
	-- 走 print 而非 game.log：verify.sh / playtest.sh log 撈得到，且不吃遊戲訊息版面。
	print(("%s " .. fmt):format(D.log_tag, ...))
end

local function now_ms() return core.game.getTime() end

--- 場景註冊。scenes/*.lua 用它把自己掛進來。
function D.scene(id, def)
	assert(type(id) == "string", "scene id 必須是字串")
	assert(type(def) == "table" and def.steps, "scene 定義必須有 steps")
	D.scenes[id] = def
end

--- 把 tag 解析成 actor。
-- tag 可以是：actor 物件本身、"player"、cast 表裡的鍵、或本層某個 actor 的 define_as。
function D:actor(tag)
	if not tag then return nil end
	if type(tag) == "table" then return tag end
	if tag == "player" then return game.player end
	local s = self.cur
	if s and s.cast[tag] then return s.cast[tag] end
	if game.level and game.level.entities then
		for _, e in pairs(game.level.entities) do
			if e and e.define_as == tag then
				if s then s.cast[tag] = e end
				return e
			end
		end
	end
	return nil
end

--- 把座標規格解析成 x, y。
-- 接受 {x=,y=}（絕對）、{dx=,dy=}（相對玩家）、或一個 tag（該 actor 所在格）。
function D:pos(spec)
	if not spec then return nil end
	if type(spec) == "string" then
		local a = self:actor(spec)
		return a and a.x, a and a.y
	end
	if spec.x and spec.y then return spec.x, spec.y end
	if spec.dx or spec.dy then
		local p = game.player
		return p.x + (spec.dx or 0), p.y + (spec.dy or 0)
	end
	return nil
end

-- ── 木偶化 ───────────────────────────────────────────────────────────────────
-- 存檔中斷的保險：把原本的 ai 存在 actor 自己身上（會跟著存檔走），
-- 讀檔後由 hooks 的 Game:changeLevel 掃描還原，避免 NPC 永遠變木頭。

function D:puppet(a)
	if not a or a == game.player then return end
	if a.__director_ai_saved ~= nil then return end
	a.__director_ai_saved = a.ai or false   -- false 代表「原本就沒有 ai」
	a.ai = nil
end

function D:unpuppet(a)
	if not a or a.__director_ai_saved == nil then return end
	a.ai = a.__director_ai_saved or nil
	a.__director_ai_saved = nil
end

--- 掃全場還原木偶。讀檔／換層後呼叫，清掉中斷演出留下的殘骸。
function D.restoreAll()
	if not game or not game.level or not game.level.entities then return 0 end
	local n = 0
	for _, e in pairs(game.level.entities) do
		if e and e.__director_ai_saved ~= nil then
			e.ai = e.__director_ai_saved or nil
			e.__director_ai_saved = nil
			n = n + 1
		end
	end
	if n > 0 then dbg("restoreAll 還原了 %d 個殘留木偶", n) end
	return n
end

-- ── 輸入鎖 / 跳過鍵 ──────────────────────────────────────────────────────────
--
-- 演出期間一定要有一個 dialog 掛著，理由有兩個：
--  1. 沒有它，玩家可以在過場動畫裡走路、施法——而且一走就消耗能量、
--     `Player:useEnergy` 會把 `game.paused` 設回 false，回合就開始跑了。
--  2. 順便當跳過鍵的載體。
--
-- ⚠️ **跳過只綁 Escape，絕不綁 Enter。** 台詞現在是對話框，玩家會連按 Enter
--    翻頁；如果 Enter 也能跳過，那在兩句台詞之間的走位空檔連按就會整段跳掉。
--    `Dialog:simplePopup` 會塞一顆 focus 在上面的 Close 按鈕（E/ui/Dialog.lua:117-119），
--    Enter 就等於 EXIT，所以這裡**不能用 simplePopup**，得自己搭。
--
-- ⚠️ `absolute = true` 是必要的：非 absolute 的 dialog 會註冊「點畫面任一處就 EXIT」
--    的滑鼠區（E/ui/Dialog.lua:508），滑鼠隨便一點就把演出跳掉了。
local function makeBlocker(title, hint, on_skip)
	local d = Dialog.new(title or "演出中", 1, 1)
	d.absolute = true
	d:loadUI{{ left = 3, top = 3, ui = Textzone.new{
		width = 260, auto_height = true, text = hint or "", can_focus = false } }}
	if on_skip then d.key:addBind("EXIT", on_skip) end
	-- 貼齊畫面上緣，別擋住演出本身（force_y 在 setupUI 裡被讀，E/ui/Dialog.lua:451）。
	--
	-- ⚠️ `force_y` 定的是**內容區**的 y，而裝飾外框會往上多長 `-frame.oy1`
	--    （E/ui/Dialog.lua:400）。直接寫 force_y = 8 會把外框頂端連標題一起推出畫面外——
	--    實測標題「演出範例」就是這樣被切掉一半的。所以要把外框的高度讓出來。
	d.force_y = 8 - math.min(0, d.frame.oy1 or 0)
	d:setupUI(true, true)
	d.__showup = nil
	game:registerDialog(d)
	return d
end

-- ── 生命週期 ─────────────────────────────────────────────────────────────────

--- 開始一場演出。
-- @param id  已註冊的 scene id
-- @param opts {cast = {TAG = actor, ...}, no_skip = bool}
-- @return true 或 nil, 錯誤字串
function D:play(id, opts)
	opts = opts or {}
	if self.cur and not self.cur.ended then return nil, "已有演出進行中" end
	local def = self.scenes[id]
	if not def then return nil, ("未知的 scene: %s"):format(tostring(id)) end
	if not game or not game.player or not game.level then return nil, "遊戲尚未就緒" end

	self.cur = {
		id = id, def = def, steps = def.steps,
		idx = 1, entered = false, ticks = 0,
		cast = opts.cast or {},
		blocked = false, ended = false,
		spawned = {},           -- 本場生出來的 actor，abort 時要收掉
		puppets = {},
		opts = opts,
		start_turn = game.turn, -- 用來自我稽核「演出真的沒吃回合」
	}

	-- 演出中無敵。這是硬性要求：玩家不能動的時候被打死是最糟的體驗。
	local p = game.player
	self.cur.old_invuln = p.invulnerable
	p.invulnerable = (p.invulnerable or 0) + 1

	-- 休息／跑步會讓引擎持續 tick（M/mod/class/Player.lua:415-419 的 restStep/runStep
	-- 迴圈），那正是「回合暴衝」的另一個來源。演出開始前先掐掉。
	if p.runStop then p:runStop("演出開始") end
	if p.restStop then p:restStop("演出開始") end

	self.cur.dialog = makeBlocker(def.title or "演出中",
		opts.no_skip and "演出進行中……" or "按 Escape 跳過。",
		(not opts.no_skip) and function() D:skip() end or nil)

	dbg("play %s steps=%d turn=%d", id, #def.steps, game.turn)

	-- ⚠️ **這裡刻意不動 `game.paused`。**
	--    設 true 而玩家當下沒能量的話，引擎不 tick、玩家也拿不回能量 → 直接卡死。
	--    正確做法是讓引擎自己收斂：`Player:act()`（M/mod/class/Player.lua:415-426）
	--    在玩家有能量且沒有輸入時會自己 `game.paused = true`，而輸入被上面那個
	--    blocker dialog 攔著，所以它會停在 paused 並待在那裡。整段演出頂多吃掉
	--    開場那不到一個回合。
	self:schedule()
	return true
end

--- 排下一次幀驅動。
function D:schedule()
	local s = self.cur
	if not s or s.ended or not game then return end
	-- 每次都給一個新的閉包：`_timers_cb` 是以函式為鍵的表（E/Game.lua:217-219），
	-- 重用同一個閉包在「還沒觸發就又註冊」時會覆寫掉原本的倒數。
	game:registerTimer(D.pump_interval, function() D:pump() end)
end

local function teardown(self, why)
	local s = self.cur
	if not s then return end
	s.ended = true

	for _, a in ipairs(s.puppets) do self:unpuppet(a) end
	if s.dialog then game:unregisterDialog(s.dialog) s.dialog = nil end

	local p = game.player
	if p then p.invulnerable = s.old_invuln end

	local spent = game.turn - (s.start_turn or game.turn)
	dbg("end %s reason=%s idx=%d/%d turns_spent=%d", s.id, why, s.idx, #s.steps, spent)
	if spent > 2 then
		-- 這是 v1 的病復發的警報。演出不該吃回合；容忍值 2 是留給開場收斂的餘裕。
		dbg("⚠ 演出吃掉了 %d 個回合——有人在演出裡推回合了，去看 useEnergy/restStep", spent)
	end

	-- ⚠️ 順序很重要：**先把 self.cur 清掉，再呼叫 on_end。**
	-- 否則 on_end 裡想接著 D:play(下一場) 會被 play() 的「已有演出進行中」擋掉，
	-- 而「一場演完接下一場」是劇情最常見的需求。
	self.cur = nil

	-- 控制權還給玩家。只在玩家真的有能量時才設 paused，否則會卡死
	-- （paused → 引擎不 tick → 玩家永遠拿不到能量 → 按什麼都沒反應）。
	if game and p and p.enoughEnergy and p:enoughEnergy() then game.paused = true end

	if s.def.on_end then
		local ok, err = pcall(s.def.on_end, s, why)
		if not ok then dbg("on_end 出錯: %s", tostring(err)) end
	end
end

function D:finish() teardown(self, "finish") end
function D:skip()   teardown(self, "skip") end
function D:abort(msg)
	dbg("abort: %s", tostring(msg))
	teardown(self, "abort")
end

--- 阻斷式步驟（say / chat）結束後由它續跑。
function D:resume()
	local s = self.cur
	if not s or s.ended then return end
	s.blocked = false
	s.idx = s.idx + 1
	s.entered = false
	self:schedule()
end

--- 讓一個 dialog 關閉時把演出接回去。
--
-- 靠覆寫該 dialog 實例的 unload：`E/Game.lua:475` 的 unregisterDialog 會呼叫它，
-- 不管玩家是按 Enter 選答案、按 Escape、還是點滑鼠關的，都會走到。
local function resumeOnClose(s, dlg)
	if not dlg then s.blocked = false return false end
	local base_unload = dlg.unload
	dlg.unload = function(sd, ...)
		if base_unload then base_unload(sd, ...) end
		D:resume()
	end
	return true
end

-- ── 主迴圈：由 Game:display 的計時器每幀呼叫一次 ─────────────────────────────
--
-- 零時間的步驟（camera / spawn / fx / log / fn）會在同一次 pump 裡連續跑完；
-- 需要時間的（wait / walk）回 "running"，排下一幀再來；
-- 阻斷式的（say / chat）把 s.blocked 設 true 就不再排，等 dialog 關閉時 resume。

function D:pump()
	local s = self.cur
	if not s or s.ended or s.blocked then return end

	local guard = 0
	while true do
		guard = guard + 1
		if guard > 200 then self:abort("pump 迴圈失控（零時間步驟串太長？）") return end

		local st = s.steps[s.idx]
		if not st then self:finish() return end

		local h = D.handlers[st.t]
		if not h then self:abort(("未知的 step 種類: %s"):format(tostring(st.t))) return end

		if st.turns ~= nil then
			-- v1 的詞彙。留著只會讓人以為它還有效。
			dbg("⚠ step %d (%s) 還在用 turns=%s——v2 只認 ms，這個欄位被忽略了",
				s.idx, tostring(st.t), tostring(st.turns))
			st.turns = nil
		end

		if not s.entered then
			s.entered, s.ticks = true, 0
			s.t_enter = now_ms()
			if h.enter then
				local ok, err = pcall(h.enter, self, st, s)
				if not ok then self:abort(("step %d (%s) enter 出錯: %s"):format(s.idx, st.t, tostring(err))) return end
			end
			if s.ended or s.blocked then return end
		end

		local r = "done"
		if h.tick then
			local ok, res = pcall(h.tick, self, st, s)
			if not ok then self:abort(("step %d (%s) tick 出錯: %s"):format(s.idx, st.t, tostring(res))) return end
			r = res
		end
		if s.ended or s.blocked then return end

		if r == "running" then
			s.ticks = s.ticks + 1
			self:schedule()
			return
		end

		s.idx = s.idx + 1
		s.entered = false
	end
end

-- ── step 處理器 ──────────────────────────────────────────────────────────────
-- 種類刻意設得少。超出這幾種的敘事寫不出來，設計時就會被逼著把小說語言
-- 轉換成遊戲事件——這是特性不是缺陷。

--- 「這一步的時間到了沒」。單位只有真實毫秒。
local function heldFor(st, s, default_ms)
	local want = st.ms or default_ms
	if not want then return true end
	return (now_ms() - (s.t_enter or 0)) >= want
end

--- camera：把鏡頭移到某人／某格。零時間。
D.handlers.camera = { enter = function(self, st)
	local x, y = self:pos(st.to)
	if x and game.level and game.level.map then game.level.map:centerViewAround(x, y) end
end }

--- say：一句台詞，**走 ToME 原生對話框**——左右各一張立繪、有邊框。
--
-- 為什麼是對話框而不是往訊息 log 丟字：訊息 log 那一行會被戰鬥訊息推走、
-- 字級小、而且沒有「玩家已經讀完了」這個訊號。實機一看就知道不對。
-- 用對話框還順手解掉節奏問題：演出停在這裡等玩家按鍵，不需要猜他讀多久。
--
-- 實作：動態組一個只有一句話、一個「繼續」選項的 chat（data/chats/_line.lua），
-- 用 `Chat.new(name, npc, player, data)` 的第四個參數把台詞餵進去——
-- `data` 會變成 chat 檔的環境 `__index`（E/Chat.lua:51,61-68），所以檔案裡
-- 直接寫 `__director_text` 就讀得到。答案沒有 action/jump 時
-- `E/dialogs/Chat.lua:118-124` 會自己 unregisterDialog，正好是我們要的。
--
-- `who` 解析不到 actor 時（旁白）退回一個簡單的文字框。
D.handlers.say = { enter = function(self, st, s)
	local text = st.text or ""
	s.blocked = true

	local dlg
	local npc = self:actor(st.who)
	if npc then
		local ch = Chat.new("director+_line", npc, game.player, {
			__director_text   = text,
			__director_answer = st.answer or "（繼續）",
		})
		ch:invoke("line")
		dlg = game.dialogs and game.dialogs[#game.dialogs]
	else
		dlg = Dialog:simplePopup(st.name or "旁白", text)
	end

	if not resumeOnClose(s, dlg) then
		dbg("say 沒能開出對話框，退回不阻斷：%s", text)
		game.log("%s", text)
	end
end }

--- log：往遊戲訊息 log 丟一行，不阻斷。
--- 適合環境敘述、旁白碎句——那種「玩家沒讀到也不影響理解」的東西。
--- 要玩家一定讀到就用 say。
D.handlers.log = { enter = function(self, st)
	local a = self:actor(st.who)
	local name = (a and a.name) or st.name or ""
	local line = (name ~= "" and ("#LIGHT_GREEN#%s#WHITE#：%s"):format(name, st.text)) or st.text
	game.log("%s", line)
end }

--- banner：畫面中央的大字（M/mod/class/BigNews.lua:42）。不阻斷。
--- 適合「第一卷 · 迷宮都市」這種章節標題。`ms` 可以讓演出在這裡停一下。
D.handlers.banner = {
	enter = function(self, st)
		if game.bignews then game.bignews:saySimple(st.big_time or 120, "%s", st.text or "") end
	end,
	tick = function(self, st, s) return heldFor(st, s) and "done" or "running" end,
}

--- wait：純粹讓真實時間過去。`ms` 是唯一單位。
D.handlers.wait = {
	tick = function(self, st, s) return heldFor(st, s, 500) and "done" or "running" end,
}

--- 木偶挪一格。
--
-- ⚠️ 兩個坑，都是實測踩到的：
--  1. `Actor:move(x, y)` 不帶 force 時**要求 self:enoughEnergy()**
--     （M/mod/class/Actor.lua:1392 `if force or self:enoughEnergy()`）。
--     演出期間沒有回合在跑，木偶永遠沒能量 → 每次都失敗、走不動。
--  2. 但 `force = true` 會**直接跳過 block_move 檢查**
--     （E/Actor.lua:243 `if not force and map:checkAllEntities(..., "block_move", ...)`），
--     木偶會穿牆，很醜。
-- 解法：**自己先檢查地形，再 force 移動**——兩個問題一起解掉。
local function stepTo(a, nx, ny)
	local map = game.level and game.level.map
	if not map then return false end
	if nx < 0 or ny < 0 or nx >= map.w or ny >= map.h then return false end
	if map:checkAllEntities(nx, ny, "block_move", a, true) then return false end
	return a:move(nx, ny, true) and true or false
end

--- walk：往目標走，走到為止。
--
-- ⚠️ **一定要用 A\*，不能只是「朝目標踏一步」。** 2026-08-01 實測：天真版在 trollmire
-- 第一步就撞牆，接下來一直原地不動直到超時。演出要能放在任意地圖上跑，就必須真的會繞路。
-- 用法抄原版護送 AI（`M/mod/ai/escort.lua:68-80`）：`Astar.new(map, actor)` →
-- `calc(sx,sy,tx,ty)` 回傳 `{{x=,y=}, ...}`；路徑會快取，頭節點不再相鄰時重算。
--
-- ⚠️ 節奏由 `speed_ms` 控制（每格幾毫秒），**不是每幀走一格**——每幀一格在 60fps 下
-- 等於一秒 60 格，看起來是瞬移。預設 150ms/格，接近正常走路。
--
-- ⚠️ 超時是硬性要求：地形變動、目標被圍死、A\* 找不到路，都不能卡死整段演出。
D.handlers.walk = {
	enter = function(self, st, s) s.__path = nil s.__stuck = 0 s.__last_step = 0 end,
	tick = function(self, st, s)
		local a = self:actor(st.who)
		if not a or not a.x then return "done" end
		local tx, ty = self:pos(st.to)
		if not tx then return "done" end

		if core.fov.distance(a.x, a.y, tx, ty) <= (st.stop_at or 0) then return "done" end

		if now_ms() - (s.t_enter or 0) >= (st.timeout_ms or 8000) then
			-- 寧可醜也不要卡住：直接放到目標旁邊。
			a:move(tx, ty, true)
			dbg("walk 超時，%s 瞬移到 (%d,%d)", tostring(a.name), tx, ty)
			return "done"
		end

		-- 節奏閘門：還沒到下一格的時間就什麼都不做，讓畫面把上一格的移動動畫播完。
		if now_ms() - (s.__last_step or 0) < (st.speed_ms or 150) then return "running" end
		s.__last_step = now_ms()

		-- 路徑快取：頭節點不再相鄰就重算（同 escort.lua:70）。
		local path = s.__path
		if path and path[1] and core.fov.distance(a.x, a.y, path[1].x, path[1].y) > 1 then path = nil end
		if not path or #path == 0 then
			-- ⚠️ 目標格若被佔住（要走到某個 NPC 旁邊時一定會），A* 直接回 nil。
			--    stop_at > 0 的話改成找目標周圍最近的空格當終點。
			local gx, gy = tx, ty
			if (st.stop_at or 0) > 0 or game.level.map:checkAllEntities(tx, ty, "block_move", a, true) then
				local best, bd
				for ox = -1, 1 do for oy = -1, 1 do
					local nx, ny = tx + ox, ty + oy
					if not (ox == 0 and oy == 0)
					   and nx >= 0 and ny >= 0 and nx < game.level.map.w and ny < game.level.map.h
					   and not game.level.map:checkAllEntities(nx, ny, "block_move", a, true) then
						local d = core.fov.distance(a.x, a.y, nx, ny)
						if not bd or d < bd then best, bd = {nx, ny}, d end
					end
				end end
				if best then gx, gy = best[1], best[2] end
			end
			path = Astar.new(game.level.map, a):calc(a.x, a.y, gx, gy)
			s.__path = path
		end

		local moved = false
		if path and path[1] then
			moved = stepTo(a, path[1].x, path[1].y)
			if moved then table.remove(path, 1) end
		end
		if not moved then
			-- A* 沒路或走不動 → 退回單步嘗試，讓它至少會蹭。
			local dx = (tx > a.x and 1) or (tx < a.x and -1) or 0
			local dy = (ty > a.y and 1) or (ty < a.y and -1) or 0
			moved = stepTo(a, a.x + dx, a.y + dy)
			if not moved and dx ~= 0 then moved = stepTo(a, a.x + dx, a.y) end
			if not moved and dy ~= 0 then moved = stepTo(a, a.x, a.y + dy) end
			s.__path = nil
		end

		-- 連續卡住就別再耗時間了，提早瞬移收場。
		s.__stuck = moved and 0 or (s.__stuck + 1)
		if s.__stuck >= (st.stuck_limit or 4) then
			a:move(tx, ty, true)
			dbg("walk 連續走不動，%s 瞬移到 (%d,%d)", tostring(a.name), tx, ty)
			return "done"
		end
		return "running"
	end,
}

--- 找一個離 (x,y) 最近、站得住人的格子。
--
-- ⚠️ **spawn 一定要做這件事。** 實測：`at = {dx=6, dy=0}` 在 trollmire 會把演員
-- 生在牆裡，接著 A* 從那格出發找不到任何路，整段 walk 只能等超時瞬移。
-- 「相對玩家幾格」這種寫法本來就不保證落在空地上，框架要自己吸收掉。
local function freeCellNear(x, y, a, max_r)
	local map = game.level and game.level.map
	if not map then return x, y end
	local function ok(cx, cy)
		return cx >= 0 and cy >= 0 and cx < map.w and cy < map.h
		   and not map:checkAllEntities(cx, cy, "block_move", a, true)
	end
	if ok(x, y) then return x, y end
	for r = 1, (max_r or 6) do
		for ox = -r, r do for oy = -r, r do
			-- 只看這一圈的最外環，避免重複檢查內圈
			if math.abs(ox) == r or math.abs(oy) == r then
				if ok(x + ox, y + oy) then return x + ox, y + oy end
			end
		end end
	end
	return x, y   -- 真的找不到就照原樣放，至少不要中斷演出
end

--- spawn：生一個 actor。
--- 兩種來源：`define_as`（從 zone 的 npc_list 撈）或 `entity`（行內定義，任何 zone 都能用）。
--- 生出來的東西預設木偶化，並記進 cast[tag] 供後續步驟引用。
--- 落點若不可站人會自動往外找空格（`exact = true` 可關掉這個行為）。
D.handlers.spawn = { enter = function(self, st, s)
	local x, y = self:pos(st.at)
	if not x then self:abort("spawn 沒有有效座標") return end

	local a
	if st.entity then
		a = require("mod.class.NPC").new(st.entity)
		a:resolve() a:resolve(nil, true)
	elseif st.define_as then
		a = game.zone:makeEntityByName(game.level, "actor", st.define_as)
	end
	if not a then self:abort(("spawn 失敗: %s"):format(tostring(st.define_as or st.tag))) return end

	if not st.exact then
		local nx, ny = freeCellNear(x, y, a, st.search or 6)
		if nx ~= x or ny ~= y then
			dbg("spawn 落點 (%d,%d) 站不了人，改放 (%d,%d)", x, y, nx, ny)
			x, y = nx, ny
		end
	end
	game.zone:addEntity(game.level, a, "actor", x, y)
	s.spawned[#s.spawned + 1] = a
	if st.tag then s.cast[st.tag] = a end
	if st.puppet ~= false then self:puppet(a) s.puppets[#s.puppets + 1] = a end
end }

--- puppet：把一個既有的 NPC 收為木偶（演出結束自動還原它的 ai）。
D.handlers.puppet = { enter = function(self, st, s)
	local a = self:actor(st.who)
	if a then self:puppet(a) s.puppets[#s.puppets + 1] = a end
end }

--- fx：放一個粒子。
--
-- ⚠️ 兩個坑，見 docs/knowledge/visuals-and-sounds-parts/01-effects-api-and-pitfalls.md：
--  1. **有些粒子檔沒有 radius 預設值**（`local radius = radius`），少傳就拋 Lua Error。
--     `particleEmitter` 的第 3 參是 radius，但粒子檔讀的是 **args 裡的同名鍵**——
--     兩個地方都要給。實測 `ball_earth` 就是這樣炸的。這裡自動補進 args。
--  2. **只用會自己停的粒子。** 持續型（如 `arcane_power`）丟給 `particleEmitter`
--     會永久留在地圖上——那種只能用 actor 的 addParticles/removeParticles 配對。
D.handlers.fx = { enter = function(self, st)
	local x, y = self:pos(st.at)
	if not x or not game.level or not game.level.map then return end
	local r = st.radius or 1
	local args = {}
	for k, v in pairs(st.args or {}) do args[k] = v end   -- clone：不要污染 scene 定義
	if args.radius == nil then args.radius = r end
	game.level.map:particleEmitter(x, y, r, st.particle, args)
end }

--- chat：開一個有分支選項的完整對話，演出暫停等它關閉。
--- 只有一句話、不需要玩家選擇的時候用 say 就好。
D.handlers.chat = { enter = function(self, st, s)
	local npc = self:actor(st.who) or game.player
	local ch = Chat.new(st.chat, npc, game.player)
	s.blocked = true
	ch:invoke(st.id)
	resumeOnClose(s, game.dialogs and game.dialogs[#game.dialogs])
end }

--- fn：逃生口。任何上面表達不了的事寫成函式。
--- 盡量少用——每多一個 fn，這段演出就少一分可被 agent 照抄的價值。
D.handlers.fn = { enter = function(self, st, s) if st.fn then st.fn(self, s) end end }

-- ── 給 probe / Lua console 用的小工具 ────────────────────────────────────────
--
-- ⚠️ 這幾個函式存在的唯一理由是**讓探測程式碼短、底線少**。
--    2026-08-01 實測：`playtest.sh` 走 xdotool 打字時，`__director_ai_saved`
--    這種欄位名的底線會**間歇性被打成空白**，於是探測讀到 nil、靜默什麼都不做；
--    而 DebugConsole 的錯誤只進 console 畫面不進 stdout，連錯誤都看不到。
--    所以凡是欄位名很長的存取，一律包成方法，別讓探測自己去打。

--- 某個 actor 被木偶化前的 ai（沒被木偶化就回 nil）。
function D.savedAI(a) return a and a.__director_ai_saved end

--- 本層所有殘留木偶的簡述。演出中斷（存檔離開、Lua Error）會留下這些，
--- 它們的 ai 是 nil、永遠不會行動——是本系統最陰的失敗模式。
function D.orphans()
	local out = {}
	if game.level and game.level.entities then
		for _, e in pairs(game.level.entities) do
			if e and e.__director_ai_saved ~= nil then
				out[#out + 1] = ("%s@%s,%s"):format(tostring(e.name), tostring(e.x), tostring(e.y))
			end
		end
	end
	return out
end

--- 一份純文字狀態報告。`tools/probes/director.lua` 只是呼叫它。
function D:report(tag)
	tag = tag or "PROBE.DIRECTOR"
	local function say(fmt, ...) print(("[" .. tag .. "] " .. fmt):format(...)) end

	local names, n_handler = {}, 0
	for id in pairs(self.scenes) do names[#names + 1] = id end
	table.sort(names)
	for _ in pairs(self.handlers) do n_handler = n_handler + 1 end
	say("scenes=%d (%s) handlers=%d", #names, table.concat(names, ","), n_handler)

	local Player = require "mod.class.Player"
	say("superload=%s game_director=%s",
		tostring(Player.__director_superload == true), tostring(game.director == self))

	local s = self.cur
	if s then
		say("playing=%s step=%d/%d ticks=%d blocked=%s ended=%s turns_spent=%d",
			tostring(s.id), s.idx, #s.steps, s.ticks or -1, tostring(s.blocked),
			tostring(s.ended), game.turn - (s.start_turn or game.turn))
	else
		say("playing=none")
	end

	local orphans = D.orphans()
	say("puppets_on_level=%d %s", #orphans, table.concat(orphans, " "))
	if #orphans > 0 and not s then
		say("WARN orphan puppets with no scene running - their ai is nil, they will never act")
	end

	-- dialogs 一起報：殘留的對話框會吃掉之後所有按鍵，表現是「按鍵沒反應」不是報錯
	-- （見 docs/knowledge/playtesting-parts/02-gameplay-and-debug.md 的第 4 個坑）。
	say("map_particles=%d paused=%s turn=%s dialogs=%d",
		game.level and #game.level.map.particles or -1,
		tostring(game.paused), tostring(game.turn), #(game.dialogs or {}))
end

--- release：提前結束演出，把控制權交回玩家（例如接著要打 boss）。
D.handlers.release = { enter = function(self) self:finish() end }

return D
