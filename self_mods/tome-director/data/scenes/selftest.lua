-- 演出系統的自我驗證場景。
--
-- 為什麼要有它：verify.sh 只能證明「定義註冊成功」，證明不了演出真的會跑。
-- 這支場景把每一種 step 都跑一遍，並在關鍵點斷言狀態，印出可被 grep 的
--   [DIRECTOR.TEST] <項目> = PASS/FAIL
-- 所以「演出能動」變成一條可自動化的判定，不必看畫面。
--
-- ★ v2 的重點斷言是 **`*.no_turn_cost`**。實機回報的病是「演出跑掉幾千上萬回合」，
--   所以「演出不吃回合」從此是一條有測試守著的硬規則，不是註解裡的期望。
--
-- 用法：
--   tools/playtest.sh start tome-director --cheat --birth default
--   tools/playtest.sh probe director_selftest
--   sleep 12
--   tools/playtest.sh log | grep 'DIRECTOR.TEST'
--
-- ⚠️ 這支刻意**不**放進 demo.lua。demo 是給人照抄的範本，要好讀；
--    測試要嚴謹，兩者的寫法目標不同，混在一起兩邊都會變糟。

local D = rawget(_G, "__tome_director")

local T = { results = {}, n_pass = 0, n_fail = 0 }
D.__selftest = T

function T.reset()
	T.results, T.n_pass, T.n_fail = {}, 0, 0
end

function T.check(name, ok, detail)
	T.results[#T.results + 1] = { name = name, ok = ok and true or false, detail = detail }
	if ok then T.n_pass = T.n_pass + 1 else T.n_fail = T.n_fail + 1 end
	print(("[DIRECTOR.TEST] %s = %s%s"):format(name, ok and "PASS" or "FAIL",
		detail and ("  (" .. tostring(detail) .. ")") or ""))
end

function T.summary()
	print(("[DIRECTOR.TEST] --- %d PASS / %d FAIL ---"):format(T.n_pass, T.n_fail))
	print(("[DIRECTOR.TEST] overall = %s"):format(T.n_fail == 0 and "PASS" or "FAIL"))
end

-- 演出開場那一瞬間，引擎可能還在把玩家的能量補回來（例如演出是從一個
-- 消耗能量的天賦裡觸發的），那期間會過掉不到一個回合。容忍值就是為此而留。
local TURN_SLACK = 2

-- 測試用的臨時演員。刻意給 ai，才能驗證木偶化真的把它清掉、結束後真的還原。
local DUMMY = {
	type = "humanoid", subtype = "human",
	name = "測試演員",
	display = '@', color = colors.WHITE,
	image = "npc/humanoid_human_apprentice_mage.png",
	faction = "allied-kingdoms",
	max_life = 1000, life_rating = 20, rank = 3, size_category = 3,
	body = { INVEN = 10 },
	autolevel = "warrior", level_range = { 1, nil },
	exp_worth = 0, no_drops = true, no_gold_drops = true,
	stats = { str = 10, dex = 10, con = 10 },
	ai = "tactical", ai_state = { talent_in = 2 },   -- ← 木偶化要清掉的就是這個
}

D.scene("selftest", {
	title = "演出自我驗證",

	steps = {
		-- ── spawn ────────────────────────────────────────────────────────────
		{ t = "fn", fn = function(dir, s)
			T.reset()
			-- ⚠️ 不要在這裡記 invulnerable 當基準——play() 已經先加過 1 了。
			--    要比對的基準是導演自己存的 s.old_invuln（演出前的原值）。
			T.check("scene.started", dir.cur ~= nil and dir.cur.id == "selftest")
			T.check("player.invulnerable", (game.player.invulnerable or 0) > 0,
				"演出中玩家必須無敵")
		end },
		{ t = "spawn", tag = "DUMMY", at = { dx = 4, dy = 0 }, entity = DUMMY },
		{ t = "fn", fn = function(dir, s)
			local a = dir:actor("DUMMY")
			T.check("spawn.exists", a ~= nil and a.x ~= nil, a and (a.x .. "," .. a.y))
			T.check("spawn.on_map", a and game.level.map(a.x, a.y, game.level.map.ACTOR) == a)
			T.check("puppet.ai_cleared", a and a.ai == nil, "木偶的 ai 必須是 nil")
			T.check("puppet.ai_saved", a and a.__director_ai_saved == "tactical",
				a and tostring(a.__director_ai_saved))
			s.__spawn_x, s.__spawn_y = a and a.x, a and a.y
		end },

		-- ── camera / log / fx（零時間，同一幀跑完）───────────────────────────
		{ t = "fn", fn = function(dir, s) s.__zero_turn = game.turn end },
		{ t = "camera", to = "DUMMY" },
		{ t = "log", who = "DUMMY", text = "自我驗證中。" },
		{ t = "fx", at = "DUMMY", particle = "ball_earth", radius = 1 },
		{ t = "fn", fn = function(dir, s)
			T.check("zerostep.no_turn_cost", game.turn == s.__zero_turn,
				("turn %d -> %d"):format(s.__zero_turn, game.turn))
			s.__parts_after_fx = #game.level.map.particles
			T.check("fx.emitted", s.__parts_after_fx > 0, s.__parts_after_fx)
		end },

		-- ── wait：真實時間要過去，但回合**不准**動 ──────────────────────────
		-- 這一組就是 v1「幾千上萬回合」那個 bug 的回歸測試。
		{ t = "fn", fn = function(dir, s)
			s.__wait_turn = game.turn
			s.__wait_t0 = core.game.getTime()
		end },
		{ t = "wait", ms = 700 },
		{ t = "fn", fn = function(dir, s)
			local dt = core.game.getTime() - s.__wait_t0
			T.check("wait.real_time_elapsed", dt >= 650, ("%d ms"):format(dt))
			T.check("wait.no_turn_cost", game.turn == s.__wait_turn,
				("turn %d -> %d（演出不准推回合）"):format(s.__wait_turn, game.turn))
		end },

		-- ── walk：要真的走到，而且同樣不准吃回合 ────────────────────────────
		{ t = "fn", fn = function(dir, s) s.__walk_turn = game.turn end },
		{ t = "walk", who = "DUMMY", to = "player", stop_at = 1, timeout_ms = 10000 },
		{ t = "fn", fn = function(dir, s)
			local a, p = dir:actor("DUMMY"), game.player
			local d = a and core.fov.distance(a.x, a.y, p.x, p.y) or 999
			T.check("walk.arrived", d <= 1, ("dist=%d"):format(d))
			T.check("walk.actually_moved", a and (a.x ~= s.__spawn_x or a.y ~= s.__spawn_y),
				("(%s,%s) -> (%s,%s)"):format(tostring(s.__spawn_x), tostring(s.__spawn_y),
					tostring(a and a.x), tostring(a and a.y)))
			T.check("walk.no_turn_cost", game.turn == s.__walk_turn,
				("turn %d -> %d"):format(s.__walk_turn, game.turn))
		end },

		-- ── 走去一個一定到不了的地方，驗證超時保護真的接得住 ────────────────
		{ t = "walk", who = "DUMMY", to = { x = 0, y = 0 }, stop_at = 0,
		  timeout_ms = 1200, stuck_limit = 999 },
		{ t = "fn", fn = function(dir, s)
			T.check("walk.timeout_survived", dir.cur ~= nil and not dir.cur.ended,
				"超時不可以讓演出中斷")
		end },
	},

	on_end = function(s, why)
		-- 這些只有在演出真的結束後才驗得到。
		T.check("end.reason_finish", why == "finish", tostring(why))

		local a = s.cast and s.cast.DUMMY
		T.check("end.ai_restored", a and a.ai == "tactical", a and tostring(a.ai))
		T.check("end.ai_flag_cleared", a and a.__director_ai_saved == nil)
		T.check("end.invuln_restored", game.player.invulnerable == s.old_invuln,
			("%s (pre-scene was %s)"):format(tostring(game.player.invulnerable), tostring(s.old_invuln)))
		T.check("end.control_returned", game.paused == true, tostring(game.paused))
		-- on_end 執行時 D.cur 必須已經是 nil，否則在 on_end 裡接下一場會被擋掉。
		T.check("end.director_cleared", rawget(_G, "__tome_director").cur == nil)

		-- ★ 整場的總帳：演出從頭到尾不該讓遊戲世界前進。
		local spent = game.turn - (s.start_turn or game.turn)
		T.check("end.scene_cost_no_turns", spent <= TURN_SLACK,
			("整場吃掉 %d 個回合（容忍 %d）"):format(spent, TURN_SLACK))

		-- 粒子不可以殘留（ball_earth 是會自己停的粒子）。
		-- 這裡只記數字；真正的殘留判定要隔幾秒再看，由 probe 負責。
		print(("[DIRECTOR.TEST] map_particles_at_end = %d"):format(#game.level.map.particles))

		-- 收掉演員，別留在玩家的地圖上。
		for _, e in ipairs(s.spawned) do
			if e and not e.dead and e.x then e:die(nil) end
		end

		T.summary()
	end,
})

-- 一個獨立的小場景：專門驗 `say` 這個**阻斷式台詞框**。
--
-- say 現在會開 ToME 原生對話框並停下來等玩家按鍵，所以測試必須自己扮演玩家：
-- 用 `game:registerTimer` 排一個幾幀後的回呼去檢查對話框真的開了、演出真的
-- 被 blocked，然後自己把它關掉——走的是 unregisterDialog → unload → D:resume()
-- 這條真實路徑，不是偷偷改狀態。
--
-- ⚠️ 用 registerTimer 而不是外部送鍵，是為了讓這支測試能無人值守跑完。
--    「真的按鍵有效」由 selftest-skip 負責驗（那支需要外部送 Escape）。
D.scene("selftest-say", {
	title = "台詞框驗證",
	steps = {
		{ t = "fn", fn = function(dir, s)
			T.reset()
			s.__say_reached = false
			s.__say_turn = game.turn
			-- 3 幀後：對話框此時一定已經開著（say 的 enter 在下一幀的 pump 裡跑）。
			game:registerTimer(4 / 30, function()
				local d = game.dialogs and game.dialogs[#game.dialogs]
				T.check("say.dialog_opened", d ~= nil and d.chat ~= nil,
					d and tostring(d.__CLASSNAME) or "nil")
				T.check("say.blocked", dir.cur ~= nil and dir.cur.blocked == true,
					dir.cur and tostring(dir.cur.blocked))
				if d then game:unregisterDialog(d) end
			end)
		end },
		{ t = "spawn", tag = "SAYDUMMY", at = { dx = 2, dy = 0 }, entity = DUMMY },
		{ t = "say", who = "SAYDUMMY", text = "這句話應該出現在對話框裡。" },
		{ t = "fn", fn = function(dir, s)
			s.__say_reached = true
			T.check("say.resumed", true, "對話框關閉後演出有接著跑")
			T.check("say.no_turn_cost", game.turn == s.__say_turn,
				("turn %d -> %d"):format(s.__say_turn, game.turn))
		end },
	},
	on_end = function(s, why)
		T.check("say.reason_finish", why == "finish", tostring(why))
		T.check("say.reached_next_step", s.__say_reached == true, "say 之後的步驟必須跑到")
		T.check("say.control_returned", game.paused == true, tostring(game.paused))
		for _, e in ipairs(s.spawned) do
			if e and not e.dead and e.x then e:die(nil) end
		end
		T.summary()
	end,
})

-- 一個獨立的小場景：專門驗 `chat`（有分支選項的完整對話）。
--
-- 續跑靠覆寫該 dialog 實例的 unload（`E/Game.lua:475` 的 unregisterDialog 會呼叫它）。
-- 驗法：開場 → 確認被 blocked → 外部送 Enter 關對話 → 確認演出真的接下去跑完。
D.scene("selftest-chat", {
	title = "對話步驟驗證",
	steps = {
		{ t = "fn", fn = function(dir, s)
			T.reset()
			s.__reached_after_chat = false
		end },
		-- 對話檔路徑慣例是 "<addon>+<檔名>"（E/Chat.lua:85-88），不需要 overload。
		{ t = "chat", who = "player", chat = "director+director-test" },
		{ t = "fn", fn = function(dir, s)
			s.__reached_after_chat = true
			T.check("chat.resumed", true, "對話關閉後演出有接著跑")
		end },
		{ t = "wait", ms = 200 },
	},
	on_end = function(s, why)
		T.check("chat.reason_finish", why == "finish", tostring(why))
		T.check("chat.reached_next_step", s.__reached_after_chat == true,
			"chat 之後的步驟必須跑到")
		T.check("chat.control_returned", game.paused == true, tostring(game.paused))
		T.summary()
	end,
})

-- 一個獨立的小場景：專門驗「跳過」。
--
-- ⚠️ 跳過鍵是 **Escape**（EXIT），不是 Enter。Enter 要留給翻台詞用——
--    如果 Enter 也能跳過，玩家連按翻台詞時會在走位空檔把整段演出跳掉。
D.scene("selftest-skip", {
	title = "跳過驗證",
	steps = {
		{ t = "spawn", tag = "SKIPDUMMY", at = { dx = 2, dy = 0 }, entity = DUMMY },
		{ t = "wait", ms = 120000 },       -- 不跳過就會停在這兩分鐘
		{ t = "fn", fn = function() T.check("skip.should_not_reach", false, "跳過後不該跑到這裡") end },
	},
	on_end = function(s, why)
		T.check("skip.reason", why == "skip", tostring(why))
		local a = s.cast and s.cast.SKIPDUMMY
		T.check("skip.ai_restored", a and a.ai == "tactical", a and tostring(a.ai))
		T.check("skip.control_returned", game.paused == true, tostring(game.paused))
		local spent = game.turn - (s.start_turn or game.turn)
		T.check("skip.no_turn_cost", spent <= TURN_SLACK, ("吃掉 %d 個回合"):format(spent))
		for _, e in ipairs(s.spawned) do
			if e and not e.dead and e.x then e:die(nil) end
		end
		T.summary()
	end,
})
