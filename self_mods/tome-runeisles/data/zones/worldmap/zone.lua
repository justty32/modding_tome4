-- 符文諸島的大世界地圖。
--
-- zone 短名是 "runeisles+worldmap"：engine/Zone.lua:155-165 看到 `+` 就把
-- 查找路徑從硬編的 /data/zones/ 換成 /data-runeisles/zones/。
return {
	name = "符文諸島",
	level_range = { 1, 50 },
	level_scheme = "player",
	-- 沒有 max_level 會 assert 崩潰（engine/Zone.lua:124）
	max_level = 1,

	-- 必須精確等於 data/maps/worldmap.lua 的欄數／列數。
	-- engine/Map.lua:224 先用 width*height 預配格子，Static 生成時再依 ASCII 實際尺寸
	-- 寫入（engine/generator/map/Static.lua:546-547）；對不上就 index nil 崩潰。
	width = 60, height = 40,

	all_lited = true,          -- engine/Zone.lua:1068，走過的地方不再變黑
	persistent = "zone",       -- engine/Zone.lua:190；少了它每次回大地圖狀態全部重置
	wilderness = true,         -- 換掉移動語意／FOV／互動限制（mod/class/Player.lua:350-358, 557-561）
	wilderness_see_radius = 4, -- 不設會退回 20，讓 wild_fovdist 查表落空、視野漸層變硬邊

	-- 刻意不設 wda：mod/class/GameState.lua:773 沒有 wda.script 就直接 return，安全。
	-- 但只要設了 script 而檔案不存在，:787 會 error(err)，玩家第一步移動就崩。
	-- 也刻意不設 auto_placelists / prepareEntitiesList：這一版沒有隨機遭遇。

	generator = {
		map = {
			class = "engine.generator.map.Static",
			-- engine/generator/map/Static.lua:50-59 → /data-runeisles/maps/worldmap.lua
			map = "runeisles+worldmap",
		},
	},
}
