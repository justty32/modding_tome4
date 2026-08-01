-- ★ 這是給 agent 照抄的範本。看懂這一支就會寫演出了。
--
-- 場景：一名劍士從遠處跑來、說話、一頭怪物破土而出、劍士斬殺它、留下一句話走人。
-- 刻意做成**任何 zone 都能跑**：NPC 用行內 `entity` 定義生成，不依賴 zone 的 npc_list
-- （用 define_as 的話，該 zone 的 npcs.lua 沒載入對應清單就會生不出來）。
--
-- ── 寫作要點 ─────────────────────────────────────────────────────────────────
--  1. 一個 step 只做一件事。零時間的（camera/spawn/fx/log/fn）會在同一幀連續跑完。
--  2. **演出一個回合都不吃。** 計時單位只有真實毫秒 `ms`；v1 的 `turns` 已經移除
--     （它會讓過場動畫跑掉上萬回合，順帶把中毒、冷卻、飢餓全部快轉）。
--  3. **台詞用 `say`，它會開原生對話框並停下來等玩家按鍵。**
--     所以台詞不需要猜「停多久玩家才讀完」——那是 v1 用 `ms` 在解的問題，現在不必了。
--     不想打斷節奏的環境敘述用 `log`（只寫進訊息列，不阻斷）。
--  4. 要玩家做選擇才用 `chat`（有分支選項的完整對話）。
--  5. 章節標題之類的大字用 `banner`。
--  6. 盡量不要用 `fn`。每多一個 fn，這段演出就少一分可被照抄的價值。
--
-- 跳過鍵是 **Escape**，不是 Enter——Enter 要留給翻台詞用。

local D = rawget(_G, "__tome_director")
-- ⚠️ `colors` 本來就是全域表，不要 require "engine.colors"——那個模組沒有 return，
--    Lua 會讓 require 回傳 true，於是 colors.LIGHT_BLUE 變成「index a boolean」而崩。

-- 行內 NPC 定義。貼圖沿用原版現成的 npc/*.png（美術成本 0，
-- 見 docs/knowledge/npc-and-chats.md §4.5）。
local SWORDSMAN = {
	type = "humanoid", subtype = "human",
	name = "劍士（演出用）",
	display = '@', color = colors.LIGHT_BLUE,
	image = "npc/humanoid_human_apprentice_mage.png",
	faction = "allied-kingdoms",
	max_life = 500, life_rating = 20, rank = 3, size_category = 3,
	body = { INVEN = 10 },
	autolevel = "warrior", level_range = { 1, nil },
	exp_worth = 0, no_drops = true, no_gold_drops = true,
	stats = { str = 20, dex = 20, con = 20 },
	-- 不給 ai：本來就是要被導演操控的木偶。
}

local BEAST = {
	type = "animal", subtype = "canine",
	name = "破土而出的野獸（演出用）",
	display = 'C', color = colors.LIGHT_RED,
	image = "npc/animal_canine_wolf.png",
	faction = "enemies",
	max_life = 40, life_rating = 5, rank = 2, size_category = 3,
	body = { INVEN = 10 },
	autolevel = "warrior", level_range = { 1, nil },
	exp_worth = 0, no_drops = true, no_gold_drops = true,
	stats = { str = 10, dex = 10, con = 10 },
}

D.scene("demo", {
	title = "演出範例",

	steps = {
		-- ① 生出演員。tag 讓後面的步驟能用名字引用它們。
		--    at 用 {dx=,dy=} 是相對玩家的位移，所以在任何地圖上都成立。
		{ t = "spawn", tag = "SWORD", at = { dx = 6, dy = 0 }, entity = SWORDSMAN },

		-- ② 鏡頭切到劍士，讓玩家知道要看哪裡。
		{ t = "camera", to = "SWORD" },

		-- ③ 台詞。say 會開對話框（左右立繪 + 邊框），演出停在這裡等玩家按 Enter。
		{ t = "say", who = "SWORD", text = "別過來——這裡由我來擋！" },

		-- ④ 走過來。停在距離玩家 2 格的地方。speed_ms 是每格幾毫秒（預設 150）。
		{ t = "walk", who = "SWORD", to = "player", stop_at = 2 },

		-- ⑤ 地面震動，野獸破土。這裡用 log 而不是 say——不想為了一句環境描述
		--    打斷玩家看破土的動作。
		{ t = "fx", at = { dx = 3, dy = 3 }, particle = "ball_earth", radius = 1 },
		{ t = "wait", ms = 600 },
		{ t = "spawn", tag = "BEAST", at = { dx = 3, dy = 3 }, entity = BEAST },
		{ t = "camera", to = "BEAST" },
		{ t = "log", text = "地面裂開，一頭野獸破土而出。" },
		{ t = "wait", ms = 500 },

		-- ⑥ 劍士衝過去。speed_ms 調小 = 衝刺感。
		{ t = "walk", who = "SWORD", to = "BEAST", stop_at = 1, speed_ms = 90 },
		{ t = "fx", at = "BEAST", particle = "blood", radius = 1 },
		{ t = "say", who = "SWORD", text = "太慢了。" },

		-- ⑦ 野獸倒下。這種「殺掉一個演員」的事沒有專用 step，用 fn 逃生口。
		--    （若這種需求變常見，就該加一個 kill 處理器，而不是到處寫 fn。）
		{ t = "fn", fn = function(dir, s)
			local b = dir:actor("BEAST")
			if b and not b.dead then b:die(dir:actor("SWORD")) end
		end },
		{ t = "wait", ms = 800 },

		-- ⑧ 收尾：鏡頭回到玩家，劍士說完話走掉。
		{ t = "camera", to = "player" },
		{ t = "say", who = "SWORD", text = "……你也小心點。" },
		{ t = "walk", who = "SWORD", to = { dx = 10, dy = 0 }, timeout_ms = 6000 },
		{ t = "fn", fn = function(dir, s)
			local a = dir:actor("SWORD")
			if a and not a.dead then a:die(nil) end   -- 演員退場
		end },

		-- ⑨ 交還控制權。不寫也會在跑完最後一步時自動結束，寫出來意圖比較清楚。
		{ t = "release" },
	},

	-- 演出結束（正常跑完 / 被跳過 / 出錯）都會呼叫。why = "finish"|"skip"|"abort"。
	-- 收乾淨是這裡的責任：任務狀態、旗標、殘留演員。
	on_end = function(s, why)
		print(("[DIRECTOR] demo 結束，why=%s"):format(tostring(why)))
		-- 被跳過時演員可能還在場上，收掉。
		for _, a in ipairs(s.spawned) do
			if a and not a.dead and a.x then a:die(nil) end
		end
	end,
})
