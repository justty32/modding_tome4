-- 歐拉麗中央廣場地圖。26x16，必須與 data/zones/orario/zone.lua 的 width/height 一致。
-- 四角的 3x3 方塊是建築門面：
--   左上 = 冒險者公會（受付孃 'G' 在前）
--   頂中 = 巴別塔市集（'1'/'2'/'3' 三個商店入口焊在門面牆上，見 traps.lua）
--   右上 = 酒館「豐饒女主人」（三名可招募冒險者 abc 在前）
--   底部三棟 = 眷族據點傳送門（p/q/r，見 grids.lua），**南牆中央必須留一格門口**
-- 中央開闊廣場：巴別塔入口 '>' 在上、回大地圖 '<' 在下。startx/starty 是傳入落點。
--
-- ★ 連通性：entrance(startx,starty) 到預設出口(地圖中心)必須有路（見 worldmap-and-zones.md
--   「Level unconnected」坑）。中央廣場整片開闊、start 與中心同在上半廣場，通。
--
-- ★★ 2026-08-01 bug：底部三棟原本畫成密閉 3x3（`###` / `#p#` / `###`），
--   p/q/r 本身可通行，但八格全是 HARDWALL——玩家永遠走不進去。當時的無頭驗證是用
--   `game:changeLevel()` **直接跳進**據點，所以「走得到嗎」從沒被驗過。
--   修法：南牆（下面那排 `###`）中央開一格 '.' 當門口，玩家從廣場往上走兩格踩到傳送門。
--   驗收方式（唯一算數的）：在遊戲裡對每個 change_zone 格跑 engine.Astar，path 不得為 nil。
--   頂排三棟是純門面裝飾（內部那格 '.' 本來就進不去），商店 '1'/'2'/'3' 焊在牆面上，
--   玩家站廣場朝它按方向鍵即開店，不需要門口——別照抄頂排的畫法到底部。

defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('>', "ORARIO_TOWER")
defineTile('<', "ORARIO_EXIT")
-- 市集商店（陷阱層，第 5 參 = trap，抄 town-derth/maps/towns/derth.lua 的寫法）。
-- 玩家站在門面牆外按方向鍵即開店（mod/class/Player.lua:315-318）。
defineTile('1', "HARDWALL", nil, nil, "ORARIO_WEAPON_STORE")
defineTile('2', "HARDWALL", nil, nil, "ORARIO_SUPPLIES_STORE")
defineTile('3', "HARDWALL", nil, nil, "ORARIO_MATERIAL_STORE")
-- 眷族據點傳送門（底部三棟建築的門內）。
defineTile('p', "ORARIO_FAM_HEARTH")
defineTile('q', "ORARIO_FAM_LOKI")
defineTile('r', "ORARIO_FAM_FREYA")
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
[[#..###......123......###.#]],
[[#..#.#......#.#......#.#.#]],
[[#..###......###......###.#]],
[[#...G...............abc..#]],
[[#........................#]],
[[#...........>............#]],
[[#........................#]],
[[#........................#]],
[[#..###......###......###.#]],
[[#..#p#......#q#......#r#.#]],
[[#..#.#......#.#......#.#.#]],
[[#........................#]],
[[#...........<............#]],
[[##########################]],
}
