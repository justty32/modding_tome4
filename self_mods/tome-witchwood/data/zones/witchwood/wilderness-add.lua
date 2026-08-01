-- 追加到「原版 Eyal 大地圖」grid_list 的地磚：女巫森林入口。
--
-- 這個檔案不會被引擎自動載入。hooks/load.lua 的 Entity:loadList hook
-- （engine/Entity.lua:1267，照 runeisles 範本）等原版 /data/zones/wilderness/grids.lua
-- 載完之後，把本檔以同一個 res 表再載一次——所以下面 base="PLAINS" 找得到。
--
-- ⚠️ change_zone 為什麼是 "witchwood+witchwood" 而不是 "witchwood"：
-- engine/Zone.lua:160-166 getBaseName 看到 `+` 才把 zone 查找路徑換成
-- /data-witchwood/zones/<name>/；寫 "witchwood" 會去讀原版 /data/zones/witchwood/，
-- 那個目錄不存在，進圖直接失敗。runeisles 的入口同樣寫 "runeisles+worldmap"。
newEntity{
	base = "PLAINS",
	define_as = "WITCHWOOD_PORTAL",
	name = "女巫森林入口",
	desc = "兩棵糾結的老樹之間，一條幾乎被荊棘吞沒的小徑沒入陰影裡。你能聽見林深處有鍋鏟敲擊的聲響。",
	-- 沒有 add_displays 的話，這一格在畫面上只是一片草地，玩家根本找不到入口。
	-- 沿用原版安格文傳送門的貼圖手法（data/zones/wilderness/grids.lua:524-530）。
	display = '&', color = colors.DARK_GREEN, back_color = colors.DARK_GREEN,
	image = "terrain/grass.png",
	add_displays = { class.new{ image = "terrain/witchwood_portal.png", display_h = 2, display_y = -1 } },
	special_minimap = colors.DARK_GREEN,
	notice = true, show_tooltip = true, glow = true,
	nice_tiler = false,
	can_encounter = false,

	change_level = 1,
	change_zone = "witchwood+witchwood",
}
