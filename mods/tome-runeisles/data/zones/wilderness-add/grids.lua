-- 追加到「原版 Eyal 大地圖」grid_list 的地磚。
--
-- 這個檔案不會被引擎自動載入。hooks/load.lua 掛在 Entity:loadList
-- （engine/Entity.lua:1267）上，等原版的 /data/zones/wilderness/grids.lua
-- 載完之後，把本檔以同一個 res 表再載一次——所以下面 base="PLAINS" 找得到。
-- 這一手是照抄官方 DLC orcs 的 wilderness-add/grids.lua。

-- 符文石環：德斯城西側，通往符文諸島。
--
-- change_level_check 會在 mod/class/Game.lua:2291 被呼叫，早於 :2292 的 changeLevel。
-- 我們趁這個時機把「大地圖座標」換掉——見下方長註解。
newEntity{
	base = "PLAINS",
	define_as = "RUNEISLES_PORTAL",
	name = "符文石環",
	desc = "一圈半埋在土裡的古代立石，石面上的符文仍在發亮。",
	-- 沒有 add_displays 的話，這一格在畫面上就只是一片草地——玩家根本找不到入口。
	-- 沿用原版安格文傳送門的貼圖手法（data/zones/wilderness/grids.lua:524-530）。
	display = '&', color = colors.LIGHT_BLUE, back_color = colors.DARK_GREEN,
	image = "terrain/grass.png",
	add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
	special_minimap = colors.LIGHT_BLUE,
	notice = true, show_tooltip = true, glow = true,
	nice_tiler = false,
	can_encounter = false,

	change_level = 1,
	change_zone = "runeisles+worldmap",
	-- 第一次過去時的落腳點：符文諸島南島的登陸點（就是那邊的回程石環）
	ri_arrive = { x = 24, y = 31 },

	--- 兩張大地圖共用同一組 wild_x/wild_y，所以切換時必須手動換存。
	--
	-- mod/class/Game.lua:1238-1248：進入任何 wilderness zone 時，玩家一律被放到
	-- player.wild_x/wild_y。但那**只有一組**，不是每張大地圖各存一份。
	-- 玩家在符文諸島上走一步，mod/class/Player.lua:354 就把它覆寫成島上的座標；
	-- 回到 Eyal 時就會被丟到 Eyal 的那個座標——輕則跳海，重則越界。
	--
	-- 原版沒有這個 bug，因為原版只有一張大地圖。這是「第二張世界地圖」的固有問題。
	--
	-- 回傳 false 讓 Game.lua:2291 的檢查通過、繼續換關。
	-- 不可有 upvalue：這個 grid 存在 persistent="zone" 的大地圖存檔裡會被序列化。
	-- （原版 TOWN_ANGOLWEN_PORTAL 也在同一張圖上掛 change_level_check，
	--   見 data/zones/wilderness/grids.lua:528，證明這條路可行。）
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
