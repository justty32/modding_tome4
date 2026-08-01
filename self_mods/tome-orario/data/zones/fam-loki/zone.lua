-- 洛基眷族據點。短名 "orario+fam-loki"（+ 慣例 → /data-orario/zones/fam-loki/）。
-- 掌控巴別塔中層秩序的大眷族：氣派的演武廳，眷族長弗羅斯特與事務長莉朵駐守。
-- 從中央廣場的傳送門（ORARIO_FAM_LOKI）進入；據點內的 '<' 通回中央廣場。
return {
	name = "洛基眷族 據點",
	level_range = { 1, 50 },
	level_scheme = "player",
	max_level = 1,
	-- 必須精確等於 data/maps/fam-loki.lua 的欄數／列數。
	width = 13, height = 9,
	persistent = "zone",
	all_remembered = true,
	all_lited = true,

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "orario+fam-loki",   -- → /data-orario/maps/fam-loki.lua
		},
		-- 城鎮內部不放隨機怪／物（NPC 與 lore 書焊在靜態地圖上）。
	},
}
