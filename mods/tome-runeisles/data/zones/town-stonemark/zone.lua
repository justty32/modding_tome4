-- 碑港（Stonemark Harbor）。
return {
	name = "碑港",
	level_range = { 1, 15 },
	level_scheme = "player",
	max_level = 1,
	-- 必須等於 data/maps/towns/stonemark.lua 的欄數／列數
	width = 40, height = 24,
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	day_night = true,

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "runeisles+towns/stonemark",
		},
		-- 城鎮不放隨機怪也不放隨機物品。generator.actor / .object 整段省略即可
		-- （engine/Zone.lua:1141,1147 沒有 .class 就跳過該階段）。
	},
}
