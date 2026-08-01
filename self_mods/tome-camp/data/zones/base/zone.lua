-- 營地 zone。短名 "camp+base"（engine/Zone.lua:155-165 的 `+` 慣例 → /data-camp/zones/base/）。
-- 鏡像 runeisles/town-stonemark 的城鎮房間結構；不是 wilderness（一步一格的普通房間）。
return {
	name = "營地",
	level_range = { 1, 50 },
	level_scheme = "player",
	-- 沒有 max_level 會 assert 崩潰（engine/Zone.lua:124）。
	max_level = 1,
	-- 必須精確等於 data/maps/base.lua 的欄數／列數，否則 index nil 崩潰。
	width = 20, height = 12,
	all_remembered = true,
	all_lited = true,
	-- ★ persistent＝營地的靈魂：離開再回來狀態不重置（engine/Zone.lua:190）。
	persistent = "zone",

	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "camp+base",   -- → /data-camp/maps/base.lua
		},
		-- 不放隨機怪／物：generator.actor / .object 整段省略（Zone.lua:1141,1147 無 .class 即跳過）。
	},
}
