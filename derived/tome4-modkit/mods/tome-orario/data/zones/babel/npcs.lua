-- 巴別塔的怪物。載入幾組低階怪的基底，交給 Random actor 生成器依樓層等級挑選。
-- 這些檔案都在原版 modules/tome/data/general/npcs/ 底下，確認存在。
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/rodent.lua")
load("/data/general/npcs/canine.lua")
load("/data/general/npcs/ant.lua")
load("/data/general/npcs/snake.lua")
load("/data/general/npcs/jelly.lua")

-- 討伐委託的目標：巴別塔階層主。
-- zone.lua 的 actor 生成器用 guardian = "ORARIO_BOUNTY_BOSS" + guardian_level = 1
-- 保證它出現在第 1 層（Random.lua:50-56：guardian 只在 guardian_level／zone.max_level 那層生成）。
-- 死亡 → 把討伐委託標為 COMPLETED（回公會回報領賞）。抄 runeisles 的具名 boss on_die 手法。
newEntity{ base = "BASE_NPC_CANINE",
	define_as = "ORARIO_BOUNTY_BOSS",
	unique = true,
	name = "巴別塔階層主・格鲁勒",
	display = 'C', color = colors.LIGHT_RED,
	desc = "盤踞在巴別塔第一階層的巨獸，凶暴到連老練的冒險者都繞路。公會為它掛上了討伐賞金。",
	level_range = { 2, nil }, exp_worth = 2,
	rank = 3,
	max_life = 180, life_rating = 14,
	combat_armor = 6, combat_def = 4,
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in = 2 },
	stats = { str = 20, dex = 14, con = 16 },

	on_die = function(self, who)
		if game.player:hasQuest("orario-bounty") then
			game.player:setQuestStatus("orario-bounty", engine.Quest.COMPLETED)
			game.logPlayer(game.player, "#LIGHT_GREEN#你討伐了巴別塔階層主。回中央廣場的公會回報吧。#WHITE#")
		end
	end,
}
