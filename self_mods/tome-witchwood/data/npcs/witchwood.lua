-- tome-witchwood：女巫森林原生怪（Agent A 負責）
--
-- 三隻怪的 id 是契約硬性規定（CONTRACT.md），其他 agent 會直接引用：
--   WITCHWOOD_HAG       林中老嫗  施法者：下毒＋詛咒，本區主要威脅
--   WITCHWOOD_THORNLING 荊棘幼苗  近戰雜兵：數量多、單體弱
--   WITCHWOOD_CAULDRON  遊走坩堝  耐打：噴藥霧（範圍效果）
--
-- 寫法對照：
--   施法者  → vendor/t-engine4/modules/tome/data/general/npcs/elven-caster.lua
--   植物    → vendor/t-engine4/modules/tome/data/general/npcs/plant.lua（treant 模式：immovable + never_move=0）
--   構造體  → vendor/t-engine4/modules/tome/data/general/npcs/construct.lua
-- 天賦全部用原版既有的 NPC 天賦（data/talents/misc/npcs.lua、corruptions/*.lua），不新增自訂天賦。
--
-- 本檔由 zone 的 npcs.lua 用 load("/data-witchwood/npcs/witchwood.lua") 載入（hooks/load.lua 註解），
-- 所以這裡直接 newEntity 即可，不需要自己掛 hook。

local Talents = require("engine.interface.ActorTalents")

-- ============================================================================
-- WITCHWOOD_HAG — 林中老嫗
-- 彎腰駝背的老巫婆，會吐毒、施放削弱詛咒、吸血。等級 4-14，tier1 偏上，本區主要威脅。
-- ============================================================================
newEntity{
	define_as = "WITCHWOOD_HAG",
	-- name 不可省：擊殺時 M/mod/class/Actor.lua:3451 會做 p.all_kills[self.name]，
	-- nil 會直接拋「table index is nil」。verify 抓不到，只有實際殺死才觸發。
	name = "林中老嫗",
	type = "humanoid", subtype = "human",
	display = "@", color = colors.GREY,
	image = "npc/witchwood_hag.png",
	female = 1,
	faction = "enemies",
	desc = "一位裹著破布斗篷的駝背老婦。她的眼睛像沼澤裡的死水，乾枯的手指泛著淡綠的光澤，空氣中瀰漫著藥草與腐葉的氣味。",

	combat = { dam = resolvers.rngavg(5, 9), atk = 4, apr = 4, dammod = { mag = 0.8 } },

	body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, BODY = 1, CLOAK = 1 },
	resolvers.drops{ chance = 30, nb = 1, {} },
	resolvers.drops{ chance = 15, nb = 1, { type = "money" } },

	max_life = resolvers.rngavg(60, 75), life_rating = 11,
	max_mana = 120, mana_regen = 5,
	rank = 2,
	rarity = 1,
	level_range = { 4, 14 }, exp_worth = 1,
	size_category = 3,
	infravision = 10,
	lite = 2,

	open_door = true,

	resolvers.equip{
		{ type = "weapon", subtype = "staff", forbid_power_source = { antimagic = true }, autoreq = true },
	},
	resolvers.talents{
		[Talents.T_STAFF_MASTERY] = { base = 1, every = 10, max = 5 },
		[Talents.T_SPIT_POISON] = { base = 2, every = 5, max = 6 },               -- 吐毒（misc/npcs.lua:885）
		[Talents.T_CURSE_OF_IMPOTENCE] = { base = 1, every = 6, max = 5 },        -- 詛咒：削弱目標傷害
		[Talents.T_CURSE_OF_DEFENSELESSNESS] = { base = 1, every = 6, max = 5 },  -- 詛咒：削弱目標防禦
		[Talents.T_DRAIN] = { base = 2, every = 5, max = 6 },                     -- 吸血自保（corruptions/sanguisuge.lua:21）
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move = "move_complex", talent_in = 1, },
	stats = { str = 8, dex = 10, mag = 22, wil = 18, cun = 14, con = 12 },
	power_source = { arcane = true },
}

-- ============================================================================
-- WITCHWOOD_THORNLING — 荊棘幼苗
-- 被詛咒的荊棘叢長出的活體幼苗，根鬚當腳走動。近戰帶毒，單體弱、成群出沒。等級 1-12。
-- 移動植物照 treant 先例：type="immovable" + never_move=0（plant.lua:69）。
-- ============================================================================
newEntity{
	define_as = "WITCHWOOD_THORNLING",
	-- name 不可省：擊殺時 M/mod/class/Actor.lua:3451 會做 p.all_kills[self.name]，
	-- nil 會直接拋「table index is nil」。verify 抓不到，只有實際殺死才觸發。
	name = "荊棘幼苗",
	type = "immovable", subtype = "plants",
	display = "#", color = colors.GREEN,
	image = "npc/witchwood_thornling.png",
	blood_color = colors.GREEN,
	faction = "enemies",
	desc = "一株嫩綠的荊棘幼苗，根鬚像腳一樣在泥土上蠕動。它的尖刺飽含淡綠的毒液，散發著令人發癢的孢子氣味。",

	combat = { dam = resolvers.rngavg(4, 7), atk = 12, apr = 4, damtype = DamageType.POISON, dammod = { dex = 0.6 } },
	melee_project = { [DamageType.POISON] = resolvers.rngavg(3, 5) },

	body = { INVEN = 10 },
	resolvers.drops{ chance = 15, nb = 1, {} },

	max_life = resolvers.rngavg(15, 25), life_rating = 8,
	rank = 1,
	rarity = 1,
	level_range = { 1, 12 }, exp_worth = 1,
	size_category = 1,
	infravision = 10,

	never_move = 0,   -- 會移動的植物（對照 treant）
	cut_immune = 1,
	poison_immune = 0.5,
	resists = { [DamageType.NATURE] = 20, [DamageType.FIRE] = -30 },

	resolvers.talents{
		[Talents.T_CONSTRICT] = { base = 1, every = 8, max = 4 },  -- 纏繞（misc/npcs.lua:262）
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move = "move_complex", talent_in = 2, },
	stats = { str = 12, dex = 14, mag = 3, wil = 8, cun = 8, con = 10 },
	not_power_source = { arcane = true },
	power_source = { nature = true },
}

-- ============================================================================
-- WITCHWOOD_CAULDRON — 遊走坩堝
-- 被魔法點燃的鐵鍋，鍋裡滾著毒藥。血厚、走得慢，會釋放毒風暴（範圍）與吐毒。等級 5-15。
-- ============================================================================
newEntity{
	define_as = "WITCHWOOD_CAULDRON",
	-- name 不可省：擊殺時 M/mod/class/Actor.lua:3451 會做 p.all_kills[self.name]，
	-- nil 會直接拋「table index is nil」。verify 抓不到，只有實際殺死才觸發。
	name = "遊走坩堝",
	type = "construct", subtype = "golem",
	display = "g", color = colors.UMBER,
	image = "npc/witchwood_cauldron.png",
	blood_color = colors.GREEN,
	faction = "enemies",
	desc = "一只有手有腳的鐵坩堝，鍋裡滾著冒泡的綠色藥液。它每走一步都灑出灼人的藥霧，活像一爐被詛咒的煉藥鍋。",

	combat = { dam = resolvers.rngavg(6, 10), atk = 10, apr = 3, dammod = { str = 0.8 } },

	body = { INVEN = 10 },
	resolvers.drops{ chance = 30, nb = 1, { type = "gem" } },
	resolvers.drops{ chance = 20, nb = 1, { type = "money" } },

	max_life = resolvers.rngavg(90, 110), life_rating = 20,
	rank = 2,
	rarity = 1,
	level_range = { 5, 15 }, exp_worth = 1,
	size_category = 3,
	infravision = 10,
	lite = 2,

	open_door = true,
	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 0.9,
	disease_immune = 1,
	no_breath = 1,
	global_speed_base = 0.8,
	combat_armor = 8, combat_def = 2,

	resolvers.talents{
		[Talents.T_POISON_STORM] = { base = 1, every = 7, max = 6 },  -- 範圍毒風暴（corruptions/blight.lua:153）
		[Talents.T_SPIT_POISON] = { base = 2, every = 6, max = 6 },   -- 單體吐毒
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_move = "move_complex", talent_in = 1, },
	stats = { str = 16, dex = 5, mag = 16, wil = 10, cun = 6, con = 20 },
	not_power_source = { nature = true },
	power_source = { arcane = true },
}
