-- 符文諸島大地圖的地形。
--
-- 直接沿用原版 wilderness 的地磚當 base，才能拿到它的貼圖、邊界拼接（nice_editer）
-- 與地磚變體（nice_tiler）。自己從零定義的話畫面會是一格一格的死色塊。
load("/data/zones/wilderness/grids.lua")

------------------------------------------------------------------- 地形
-- POLAR_CAP / FROZEN_SEA 都是「可走的」冰原地形（data/zones/wilderness/grids.lua:210-227），
-- 真正擋路的海是 WATER_BASE_DEEP（:343，does_block_move=true）。
newEntity{ base = "WATER_BASE_DEEP", define_as = "RI_SEA", name = "冰封之海" }
newEntity{ base = "FROZEN_SEA", define_as = "RI_PACK_ICE", name = "浮冰道" }
newEntity{ base = "POLAR_CAP", define_as = "RI_SNOW", name = "雪原" }
newEntity{ base = "COLD_FOREST", define_as = "RI_FOREST", name = "霜杉林" }
newEntity{ base = "MOUNTAIN", define_as = "RI_MOUNTAIN", name = "冰脊" }

------------------------------------------------------------------- 回程
-- 回原版 Eyal 大地圖。change_level_check 的用途與注意事項，
-- 見 data/zones/wilderness-add/grids.lua 的長註解（那是同一段邏輯的另一端）。
newEntity{
	base = "POLAR_CAP",
	define_as = "RI_RETURN_PORTAL",
	name = "回程石環",
	desc = "與德斯城旁那一圈同源的立石。踏上去就能回到馬基埃亞爾。",
	display = '&', color = colors.LIGHT_BLUE, back_color = colors.WHITE,
	image = "terrain/frozen_ground.png",
	add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
	special_minimap = colors.LIGHT_BLUE,
	notice = true, show_tooltip = true, glow = true,
	nice_tiler = false,
	can_encounter = false,

	change_level = 1,
	change_zone = "wilderness",
	-- 只有在玩家從未踏上過 Eyal 大地圖時才會用到（實務上不會發生，
	-- 因為一定是先從那邊走過來的），但留著避免 nil 座標。
	ri_arrive = { x = 23, y = 17 },

	change_level_check = function(self, who)
		who.ri_wild_pos = who.ri_wild_pos or {}
		if game.zone and game.zone.wilderness and game.zone.short_name then
			who.ri_wild_pos[game.zone.short_name] = { x = who.wild_x, y = who.wild_y }
		end
		local saved = who.ri_wild_pos[self.change_zone]
		if saved then
			who.wild_x, who.wild_y = saved.x, saved.y
		elseif self.ri_arrive then
			who.wild_x, who.wild_y = self.ri_arrive.x, self.ri_arrive.y
		end
		return false
	end,
}

------------------------------------------------------------------- 地標（入口）
-- zone 短名一律要帶 "runeisles+" 前綴，engine/Zone.lua:155-165 才會去 /data-runeisles/ 找。
-- 指向一個不存在的 zone 不會在載入大地圖時炸，而是玩家踩上去按 `>` 的當下才 error。
newEntity{
	base = "POLAR_CAP", define_as = "RI_TOWN_STONEMARK",
	name = "碑港",
	desc = "符文諸島上唯一的聚落。整座鎮子繞著四塊符文石碑蓋起來。",
	change_level = 1, change_zone = "runeisles+town-stonemark",
	glow = true,
	display = '*', color = colors.WHITE, back_color = colors.DARK_GREY,
	add_mos = { { image = "terrain/village_01.png" } },
	special_minimap = colors.WHITE,
	notice = true, show_tooltip = true, nice_tiler = false,
}
newEntity{
	base = "POLAR_CAP", define_as = "RI_ZONE_STONE_CIRCLE",
	name = "潮沒石陣",
	desc = "半沉在浮冰底下的環狀立石。海水在石縫間發出不像水聲的聲音。",
	change_level = 1, change_zone = "runeisles+stone-circle",
	glow = true,
	display = '>', color = colors.LIGHT_GREEN, back_color = colors.DARK_GREY,
	add_displays = { mod.class.Grid.new{ image = "terrain/dungeon_entrance02.png", z = 4 } },
	special_minimap = colors.LIGHT_GREEN,
	notice = true, show_tooltip = true, nice_tiler = false,
}
newEntity{
	base = "POLAR_CAP", define_as = "RI_ZONE_TOMB",
	name = "無銘之墓",
	desc = "冰脊環抱的一道裂口。走近時，你會忘記自己正要去哪裡。",
	change_level = 1, change_zone = "runeisles+unnamed-tomb",
	glow = true,
	display = '>', color = colors.LIGHT_RED, back_color = colors.DARK_GREY,
	add_displays = { mod.class.Grid.new{ image = "terrain/dungeon_entrance02.png", z = 4 } },
	special_minimap = colors.LIGHT_RED,
	notice = true, show_tooltip = true, nice_tiler = false,

	-- 拿到符文石片之前進不去。回傳 true 會讓 mod/class/Game.lua:2291 直接 return，
	-- 換關不會發生。原版同款寫法：data/zones/wilderness/grids.lua:687（瑞爾島隧道）。
	-- 不可有 upvalue：這一格會被序列化進 persistent 大地圖的存檔。
	change_level_check = function(self, who)
		local p = game.party:findMember{ main = true }
		local q = p and p:hasQuest("rune-isles")
		if q and q:isCompleted("warden") then return false end
		require("engine.ui.Dialog"):simplePopup("無銘之墓",
			"你走到裂口前，然後發現自己正在往回走。\n你想不起來自己本來要做什麼。\n\n（你還沒有它的名字。）")
		return true
	end,
}
