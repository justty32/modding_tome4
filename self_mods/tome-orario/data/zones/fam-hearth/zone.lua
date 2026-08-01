-- 赫斯緹雅眷族據點。短名 "orario+fam-hearth"（+ 慣例 → /data-orario/zones/fam-hearth/）。
-- 歐拉麗最樸素的眷族：舊神祠改建的小據點，住著眷族長希爾妲與見習冒險者堤姆。
-- 從中央廣場的傳送門（ORARIO_FAM_HEARTH）進入；據點內的 '<' 通回中央廣場。
return {
	name = "赫斯緹雅眷族 據點",
	level_range = { 1, 50 },
	level_scheme = "player",
	max_level = 1,
	-- 必須精確等於 data/maps/fam-hearth.lua 的欄數／列數。
	width = 13, height = 9,
	persistent = "zone",
	all_remembered = true,
	all_lited = true,

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "orario+fam-hearth",   -- → /data-orario/maps/fam-hearth.lua
		},
		-- 城鎮內部不放隨機怪／物（NPC 與 lore 書焊在靜態地圖上）。
	},
}
