-- 任務 NPC：守根人 葛薇（WITCHWOOD_CRONE）——Agent C（劇情）負責。
--
-- 本檔只定義 entity，**不做任何放置**。放置由 Agent B 在
-- data/zones/witchwood/npcs.lua 處理：
--
--   1) 把本檔拉進 witchwood zone 的 npc_list（與 A 的 witchwood.lua 同款手法）：
--        load("/data-witchwood/npcs/witchwood-quest.lua")
--   2) 用 addSpot + zone.lua 的 on_enter 把她放到地圖上（本 zone 是 Roomer 隨機
--      生成，沒有靜態 defineTile 可用）。建議放在入口附近、離出口格至少一格，
--      不要壓在 change_zone 的格子（docs/knowledge/npc-and-chats.md §4 的坑）。
--
-- 放置後玩家「攻擊」她（按 G 或滑鼠點）即開對話，不用掛 hook：
--   M/mod/class/interface/Combat.lua:42-49 會把對 can_talk 目標的攻擊攔下來。
--
-- ⚠️ 已處理（原本是「給 B 的提醒」）：葛薇的 faction 是 "allied-kingdoms"
--    （照守碑人範本），而 A 的怪是 "enemies"——她在怪堆裡會被老嫗／荊棘幼苗主動
--    攻擊。她 never_move + ai="none"，既跑不掉也不會還手，死了任務就永久拿不到
--    （只有 100 點血）。本 zone 是隨機生成、怪會遊走，「放在重生範圍外」保證不了，
--    所以照原版固定劇情 NPC 的作法給 invulnerable + never_anger
--    （前例 M/data/zones/eidolon-plane/npcs.lua:31、M/data/zones/eruan/npcs.lua:45；
--     判定點 M/mod/class/Actor.lua:2415 onTakeHit 直接 return 0）。

newEntity{
	define_as = "WITCHWOOD_CRONE",
	name = "守根人 葛薇",
	type = "humanoid", subtype = "human",
	display = '@', color = colors.LIGHT_GREEN,
	image = "npc/humanoid_human_hexer.png",  -- 借原版美術（相對 /data/gfx/ 的路徑，與借用原版資產的寫法一致）
	faction = "allied-kingdoms",
	desc = "一位佝僂的老嫗，裹著苔綠色的粗布斗篷。她的左手始終按著一條沒入地下的老樹根，像在聽什麼。",

	can_talk = "witchwood+witchwood-crone",

	body = { INVEN = 10 },
	life_rating = 10,
	rank = 3,
	size_category = 3,
	exp_worth = 0,
	lite = 3,

	-- never_move / cant_be_moved 是刻意的：她「守著唯一一條老樹根、走不開」。
	-- ⚠️ 這組屬性 + can_talk 讓她變成玩家**永遠推不開的一道牆**
	--（Combat.lua:41-45 撞上去只會開對話，ActorAI.lua:332 讓 canBumpDisplace 回 false），
	-- 所以放置端**必須**保證她不站在一格寬的通道上——
	-- 規則寫在 data/zones/witchwood/zone.lua 的 post_process，別繞過它。
	never_move = true,
	cant_be_moved = true,
	no_breath = true,
	invulnerable = 1,
	never_anger = true,
	unit_power = 3000,

	autolevel = "warrior",
	ai = "none",
	stats = { str = 10, dex = 10, mag = 16, con = 10 },
}
