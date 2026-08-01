-- 碑港的居民。目前只有一位：守碑人。

-- can_talk 的值走 engine/Chat.lua:85-88 的 "<addon>+<file>" 慣例
-- → /data-runeisles/chats/lorekeeper.lua
--
-- 一般（非大地圖）NPC 不需要自己掛 hook：玩家「攻擊」一個 can_talk 不為空的目標時，
-- mod/class/interface/Combat.lua:42-49 會把攻擊攔下來改成開對話。
newEntity{
	define_as = "RI_LOREKEEPER",
	name = "守碑人 蘇爾德",
	type = "humanoid", subtype = "human",
	display = '@', color = colors.LIGHT_BLUE,
	image = "npc/humanoid_human_apprentice_mage.png",
	faction = "allied-kingdoms",
	desc = "一位裹著厚重毛皮的老人。他的雙手佈滿刻刀留下的舊疤。",

	can_talk = "runeisles+lorekeeper",

	body = { INVEN = 10 },
	life_rating = 10,
	rank = 3,
	size_category = 3,
	exp_worth = 0,
	lite = 3,

	never_move = true,
	cant_be_moved = true,
	no_breath = true,
	unit_power = 3000,

	autolevel = "warrior",
	ai = "none",
	stats = { str = 10, dex = 10, mag = 14, con = 10 },
}
