-- 芙蕾雅眷族據點。短名 "orario+fam-freya"（+ 慣例 → /data-orario/zones/fam-freya/）。
-- 歐拉麗最深不可測的眷族：昏暗華麗的大廳，眷族長夜語與情報屋嵐駐守。
-- 從中央廣場的傳送門（ORARIO_FAM_FREYA）進入；據點內的 '<' 通回中央廣場。
return {
	name = "芙蕾雅眷族 據點",
	level_range = { 1, 50 },
	level_scheme = "player",
	max_level = 1,
	-- 必須精確等於 data/maps/fam-freya.lua 的欄數／列數。
	width = 13, height = 9,
	persistent = "zone",
	all_remembered = true,
	all_lited = true,

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "orario+fam-freya",   -- → /data-orario/maps/fam-freya.lua
		},
		-- 城鎮內部不放隨機怪／物（NPC 與 lore 書焊在靜態地圖上）。
	},
}
