-- 營地地圖。20x12，必須與 data/zones/base/zone.lua 的 width/height 一致。
-- startx/starty＝玩家傳入時的落點（engine/generator/map/Static.lua:520-521）。
--
-- ★ 必須是「連通」的開放房間：引擎會檢查 entrance(startx,starty) 到 exit(預設地圖中心)
--   有沒有路可走（Zone:newLevel「Level unconnected」→ 反覆重生 → 生成失敗）。留成開放房間。

defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('*', "CAMP_FIRE")
defineTile('<', "CAMP_EXIT")

startx = 2
starty = 2

return {
[[####################]],
[[#..................#]],
[[#..................#]],
[[#..................#]],
[[#..................#]],
[[#........*.........#]],
[[#..................#]],
[[#..................#]],
[[#..............<...#]],
[[#..................#]],
[[#..................#]],
[[####################]],
}
