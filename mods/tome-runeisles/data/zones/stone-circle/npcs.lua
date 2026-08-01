-- 潮沒石陣的居民：被石陣困住的亡者，與看守它的潮汐守衛。
load("/data/general/npcs/skeleton.lua")
load("/data/general/npcs/ghoul.lua")

-- guardian（zone.lua 的 generator.actor.guardian）由
-- engine/generator/actor/Random.lua 的 generateGuardian 用名字撈出來放上地圖。
newEntity{ base = "BASE_NPC_SKELETON",
	define_as = "RI_TIDE_WARDEN",
	unique = true,
	name = "潮汐守衛 赫拉戈斯",
	display = 'S', color = colors.LIGHT_BLUE,
	desc = "一具被海水泡了千年的骸骨。它的肋骨間卡著一塊斷裂的符文石片。",
	level_range = { 3, nil }, exp_worth = 2,
	rank = 3.5,
	max_life = 150, life_rating = 12,
	combat_armor = 8, combat_def = 6,
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in = 2 },
	stats = { str = 18, dex = 14, con = 14 },

	-- 死掉就解鎖一段 lore（mod/class/Actor.lua:3223 讀 on_death_lore）
	on_death_lore = "runeisles-warden",

	-- 推進主線第二階段。原版同款寫法：data/zones/reknor/npcs.lua:101-110。
	on_die = function(self, who)
		if game.player:hasQuest("rune-isles") then
			game.player:setQuestStatus("rune-isles", engine.Quest.COMPLETED, "warden")
			game.logPlayer(game.player, "#LIGHT_BLUE#你從它的肋骨間取出一塊斷裂的符文石片。上面的筆畫只剩一半。")
		end
	end,
}
