-- 歐拉麗中央廣場地圖。26x16，必須與 data/zones/orario/zone.lua 的 width/height 一致。
-- 四角的 3x3 方塊是建築（公會/酒館/市集/眷族的門面，後續增量放 NPC 與入口）；
-- 中央開闊廣場：巴別塔入口 '>' 在上、回大地圖 '<' 在下。startx/starty 是傳入落點。
--
-- ★ 連通性：entrance(startx,starty) 到預設出口(地圖中心)必須有路（見 worldmap-and-zones.md
--   「Level unconnected」坑）。中央廣場整片開闊、start 與中心同在上半廣場，通。

defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('>', "ORARIO_TOWER")
defineTile('<', "ORARIO_EXIT")
-- 冒險者公會受付孃焊在門面（左上建築）前的廣場（第 4 參 = actor，見 npcs.lua）。
defineTile('G', "FLOOR", nil, "ORARIO_GUILDMASTER")
-- 酒館「豐饒女主人」的三名可招募冒險者（右上建築前）。
defineTile('a', "FLOOR", nil, "ORARIO_TAVERN_WARRIOR")
defineTile('b', "FLOOR", nil, "ORARIO_TAVERN_ARCHER")
defineTile('c', "FLOOR", nil, "ORARIO_TAVERN_MAGE")

startx = 12
starty = 8

return {
[[##########################]],
[[#........................#]],
[[#..###......###......###.#]],
[[#..#.#......#.#......#.#.#]],
[[#..###......###......###.#]],
[[#...G...............abc..#]],
[[#........................#]],
[[#...........>............#]],
[[#........................#]],
[[#........................#]],
[[#..###......###......###.#]],
[[#..#.#......#.#......#.#.#]],
[[#..###......###......###.#]],
[[#........................#]],
[[#...........<............#]],
[[##########################]],
}
