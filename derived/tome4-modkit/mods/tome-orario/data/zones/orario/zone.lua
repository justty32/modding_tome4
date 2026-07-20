-- 歐拉麗中央廣場（hub 樞紐）。短名 "orario+orario"（+ 慣例 → /data-orario/zones/orario/）。
-- 鏡像 town-stonemark 的城鎮房間結構（非 wilderness）。
return {
	name = "歐拉麗 中央廣場",
	level_range = { 1, 50 },
	level_scheme = "player",
	max_level = 1,
	-- 必須精確等於 data/maps/orario.lua 的欄數／列數。
	width = 26, height = 16,
	persistent = "zone",
	all_remembered = true,
	all_lited = true,

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "orario+orario",   -- → /data-orario/maps/orario.lua
		},
		-- 城鎮不放隨機怪／物（generator.actor / .object 省略）。
	},
}
