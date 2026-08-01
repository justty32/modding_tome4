-- 洛基眷族據點地圖。13x9，必須與 data/zones/fam-loki/zone.lua 一致。
-- 氣派的演武廳內部：眷族長 'L'、事務長 'M'、壁架上的 lore 書 'r'、
-- 回中央廣場的傳送門 '<'。start 在左上。
defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('L', "FLOOR", nil, "FAM_LOKI_HEAD")
defineTile('M', "FLOOR", nil, "FAM_LOKI_CLERK")
defineTile('r', "FLOOR", "FAM_LOKI_BOOK")
defineTile('<', "FAM_LOKI_EXIT")

startx = 1
starty = 1
endx = 6
endy = 7

return {
[[#############]],
[[#...........#]],
[[#.L........<#]],
[[#...........#]],
[[#....r......#]],
[[#...........#]],
[[#...........#]],
[[#.....M.....#]],
[[#############]],
}
