-- 把符文諸島接進遊戲：一格傳送門貼到原版 Eyal 大地圖上。
--
-- 這裡完全不覆寫任何原版檔案，兩個 hook 各司其職：
--   Entity:loadList            → 讓 RUNEISLES_PORTAL 這個地磚定義出現在 wilderness 的 grid_list
--   MapGeneratorStatic:subgenRegister → 把那格地磚 overlay 到 eyal 地圖的指定座標
--
-- 這是官方 DLC「Embers of Rage」加克魯克半島用的同一組接點。

-- 這些必須在這裡 require：它們在 modules/tome/mod/load.lua 是 local 不是全域，
-- hook 的閉包看不到，runtime 會 nil index。
local class = require "engine.class"
local PartyLore = require "mod.class.interface.PartyLore"

local WILD_GRIDS = "/data/zones/wilderness/grids.lua"
local ADD_GRIDS = "/data-runeisles/zones/wilderness-add/grids.lua"

-- 德斯城（Derth）在 eyal 地圖上是 (25,17)；(23,17) 是它正西邊第二格的平原，
-- 緊鄰農田，任何一級角色都走得到。（座標由 data/maps/wilderness/eyal.lua 的 ASCII 直接數出）
local PORTAL_X, PORTAL_Y = 23, 17

--- 讓原版 wilderness 的 grid_list 多認得一個地磚。
--
-- engine/Entity.lua:1267 在每個 entity 清單載入完之後廣播這個 hook，並把同一個 `res`
-- 表交出來。用同一個 res 再載一次我們的檔案，等於 append——所以我們的
-- newEntity{ base="PLAINS" } 找得到已經定義好的 PLAINS（engine/Entity.lua:1228 查 res[t.base]）。
--
-- 抄自 orcs DLC 的 OrcCampaign.lua:119-120。
class:bindHook("Entity:loadList", function(self, data)
	if data.file ~= WILD_GRIDS then return end
	self:loadList(ADD_GRIDS, data.no_default, data.res, data.mod, data.loaded)
end)

--- 把傳送門那一格 overlay 到 eyal 大地圖上。
--
-- engine/generator/map/Static.lua:696 在畫完主地圖、跑子生成器之前廣播這個 hook，
-- 我們往 data.list 塞一筆 {x,y,w,h,overlay=true,...}，:698-720 就會生成一張 3x3 的
-- 子地圖，再 self.map:overlay(map, x, y) 貼上去。
--
-- overlay 只複製「有東西的格子」（engine/Map.lua:1063，nil 格直接跳過），
-- 而我們的子地圖除了正中央那格之外全是未 defineTile 的 '?'
-- （engine/generator/map/Static.lua:557 resolve 不到就 return nil，:578 的 `if g then` 跳過）。
-- 所以周圍 8 格會原封不動保留原版地形，對其他 addon 是純加法。
class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
	if data.mapfile ~= "wilderness/eyal" then return end
	data.list[#data.list + 1] = {
		x = PORTAL_X - 1, y = PORTAL_Y - 1, w = 3, h = 3,
		overlay = true,
		generator = "engine.generator.map.Static",
		data = { map = "runeisles+eyal-portal" },
	}
end)

-- 自我檢查：給 tools/verify.sh grep 用。
-- 這裡只能查「檔案在不在」——grid_list 要等玩家真的進大地圖才會建，
-- 那部分只能靠 tools/playtest.sh 走過去看。
class:bindHook("ToME:load", function(self, data)
	-- lore 是開機批次載入的（原版在 mod/load.lua:111 對 /data/lore/lore.lua 做這件事），
	-- addon 的 data/ 掛在私有的 /data-runeisles/ 不會被自動掃到，必須自己補一次。
	-- 漏了的話，NPC 一死觸發 on_death_lore 就會 nil index。
	-- quest 不需要這樣做——它是 grantQuest 當下才 loadfile 的惰性載入。
	PartyLore:loadDefinition("/data-runeisles/lore/lore.lua")

	local checks = {
		{ "worldmap_zone", fs.exists("/data-runeisles/zones/worldmap/zone.lua") },
		{ "worldmap_map", fs.exists("/data-runeisles/maps/worldmap.lua") },
		{ "eyal_portal_map", fs.exists("/data-runeisles/maps/eyal-portal.lua") },
		{ "wilderness_add", fs.exists(ADD_GRIDS) },
		{ "town_zone", fs.exists("/data-runeisles/zones/town-stonemark/zone.lua") },
		{ "dungeon_zones", fs.exists("/data-runeisles/zones/stone-circle/zone.lua")
			and fs.exists("/data-runeisles/zones/unnamed-tomb/zone.lua") },
		{ "quest", fs.exists("/data-runeisles/quests/rune-isles.lua") },
		{ "chat", fs.exists("/data-runeisles/chats/lorekeeper.lua") },
		{ "lore", (PartyLore.lore_defs or {})["runeisles-warden"] ~= nil
			and (PartyLore.lore_defs or {})["runeisles-unnamed"] ~= nil },
	}
	for _, c in ipairs(checks) do
		print(("[RUNEISLES] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
	end
	print("[RUNEISLES] hook complete")
end)
