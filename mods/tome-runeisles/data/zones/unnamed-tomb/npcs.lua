-- 無銘之墓的居民。
load("/data/general/npcs/bone-giant.lua")
load("/data/general/npcs/ghost.lua")
load("/data/general/npcs/skeleton.lua")

-- 主線的最終 boss。
--
-- 「無銘之物」沒有名字——古代刻名師鎮壓它，靠的是不讓任何符文能指涉它。
-- 玩家在潮沒石陣拿到殘缺的名字，在這裡把它刻完，它才會變得可以被殺死。
newEntity{ base = "BASE_NPC_BONE_GIANT",
	define_as = "RI_THE_UNNAMED",
	unique = true,
	name = "無銘之物",
	display = 'U', color = colors.LIGHT_RED,
	desc = "一個你的眼睛拒絕記住的輪廓。你能看見它，卻無法在心裡稱呼它。",
	level_range = { 10, nil }, exp_worth = 4,
	rank = 4,
	max_life = 400, life_rating = 18,
	combat_armor = 14, combat_def = 10,
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in = 1 },
	stats = { str = 24, dex = 16, mag = 20, con = 18 },

	on_death_lore = "runeisles-unnamed",

	on_die = function(self, who)
		if game.player:hasQuest("rune-isles") then
			game.player:setQuestStatus("rune-isles", engine.Quest.COMPLETED, "unnamed")
		end
	end,
}
