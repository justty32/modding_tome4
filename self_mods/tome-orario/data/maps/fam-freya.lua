-- 芙蕾雅眷族據點地圖。13x9，必須與 data/zones/fam-freya/zone.lua 一致。
-- 昏暗華麗的大廳：眷族長 'F'、情報屋 'N'、陰影裡的 lore 書 'r'、
-- 回中央廣場的傳送門 '<'。start 在左上。
defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('F', "FLOOR", nil, "FAM_FREYA_HEAD")
defineTile('N', "FLOOR", nil, "FAM_FREYA_ROGUE")
defineTile('r', "FLOOR", "FAM_FREYA_BOOK")
defineTile('<', "FAM_FREYA_EXIT")

startx = 1
starty = 1
endx = 6
endy = 7

return {
[[#############]],
[[#...........#]],
[[#.F........<#]],
[[#...........#]],
[[#.......r...#]],
[[#...........#]],
[[#...........#]],
[[#.....N.....#]],
[[#############]],
}
