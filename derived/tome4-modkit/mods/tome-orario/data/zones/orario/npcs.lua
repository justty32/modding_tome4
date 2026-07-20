-- 歐拉麗中央廣場的焊死 NPC。
-- 城鎮 NPC 只要 faction 非敵對 + can_talk 就會「攻擊即開對話」（Combat.lua:42-49，
-- 見 knowledge/npc-and-chats.md §5），不需自己掛 hook。
-- 焊在靜態地圖上：orario.lua map 的 defineTile 第 4 參 = actor 的 define_as。

local Talents = require("engine.interface.ActorTalents")

-- 冒險者公會・受付孃。發討伐委託、收委託回報領賞。對話 = "orario+guild"。
newEntity{
	define_as = "ORARIO_GUILDMASTER",
	type = "humanoid", subtype = "human",
	name = "冒險者公會・受付孃",
	display = 'p', color = colors.GOLD,
	desc = "冒險者公會的受付。她負責發放巴別塔的討伐委託，並在你完成後結算報酬。",
	faction = "allied-kingdoms",
	can_talk = "orario+guild",

	body = { INVEN = 10 },
	life_rating = 100, max_life = 5000,
	rank = 3, size_category = 3,
	exp_worth = 0,
	-- 只當招牌，不動也不打架：不給 ai、never_move、不可被推。
	never_move = 1, cant_be_moved = 1,
	no_drops = true, no_gold_drops = true,
	autolevel = "none",
	stats = { str = 10, dex = 10, mag = 10, con = 10 },
}

-- ── 酒館「豐饒女主人」的可招募冒險者（廣場右上門面前）──────────────────────
-- 對話 = "orario+tavern"；招募走 tome-companions 的 doRecruit 同套機制
-- （addMember control=full + co_owner + max_level=nil + forceLevelup，見 chats/tavern.lua）。
-- 用引擎標準的 base= 繼承（子欄位覆寫 base，同 town-derth 的 BASE_NPC_DERTH_TOWN 手法）。
newEntity{
	define_as = "BASE_NPC_ORARIO_TAVERN",
	type = "humanoid", subtype = "human",
	display = 'p', color = colors.WHITE,
	faction = "allied-kingdoms",
	can_talk = "orario+tavern",
	body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, BODY = 1, QUIVER = 1 },
	rank = 2, size_category = 3,
	infravision = 10, lite = 3,
	exp_worth = 0,
	-- 招牌狀態不亂跑；招募時 chat 會把 never_move 清掉。
	never_move = 1,
	open_door = true,
	level_range = { 2, nil },
	ai = "tactical", ai_state = { talent_in = 2 },
}

newEntity{ base = "BASE_NPC_ORARIO_TAVERN",
	define_as = "ORARIO_TAVERN_WARRIOR",
	name = "傭兵劍士・貝爾嘉", color = colors.LIGHT_UMBER,
	desc = "酒館角落一位配著長劍的女劍士，正在等一支願意帶她下巴別塔的隊伍。",
	max_life = 90, life_rating = 13,
	combat_armor = 4, combat_def = 2,
	autolevel = "warrior",
	stats = { str = 18, dex = 14, con = 15, mag = 8 },
	resolvers.equip{
		{ type = "weapon", subtype = "longsword", not_properties = { "unique" }, autoreq = true },
		{ type = "armor", subtype = "shield", not_properties = { "unique" }, autoreq = true },
		{ type = "armor", subtype = "heavy", not_properties = { "unique" }, autoreq = true },
	},
	resolvers.talents{ [Talents.T_RUSH] = 1, [Talents.T_WEAPONS_MASTERY] = 2, [Talents.T_PERFECT_STRIKE] = 1 },
}

newEntity{ base = "BASE_NPC_ORARIO_TAVERN",
	define_as = "ORARIO_TAVERN_ARCHER",
	name = "遊俠弓手・琉", color = colors.LIGHT_GREEN,
	desc = "背著長弓、話不多的遊俠，出手快得像影子。",
	max_life = 70, life_rating = 11,
	combat_armor = 2, combat_def = 4,
	autolevel = "archer",
	ai_state = { talent_in = 2, ai_move = "move_complex" },
	stats = { str = 14, dex = 18, con = 12, mag = 8 },
	resolvers.equip{
		{ type = "weapon", subtype = "longbow", not_properties = { "unique" }, autoreq = true },
		{ type = "ammo", subtype = "arrow", not_properties = { "unique" }, autoreq = true },
		{ type = "armor", subtype = "light", not_properties = { "unique" }, autoreq = true },
	},
	resolvers.talents{ [Talents.T_SHOOT] = 1, [Talents.T_STEADY_SHOT] = 1 },
}

newEntity{ base = "BASE_NPC_ORARIO_TAVERN",
	define_as = "ORARIO_TAVERN_MAGE",
	name = "流浪法師・莉維菈", color = colors.LIGHT_BLUE,
	desc = "披著星紋斗篷的年輕法師，指尖不時竄過奧術的火花。",
	max_life = 55, life_rating = 9,
	combat_armor = 1, combat_def = 3,
	autolevel = "caster",
	ai_state = { talent_in = 1, ai_move = "move_complex" },
	stats = { str = 8, dex = 12, con = 11, mag = 18 },
	resolvers.equip{
		{ type = "weapon", subtype = "staff", not_properties = { "unique" }, autoreq = true },
		{ type = "armor", subtype = "cloth", not_properties = { "unique" }, autoreq = true },
	},
	resolvers.talents{ [Talents.T_MANATHRUST] = 2, [Talents.T_FLAME] = 1 },
}
