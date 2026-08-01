-- 赫斯緹雅眷族據點地圖。13x9，必須與 data/zones/fam-hearth/zone.lua 一致。
-- 樸素的舊神祠內部：眷族長 'H'、見習冒險者 'T'、爐灶旁的 lore 書 'r'、
-- 回中央廣場的傳送門 '<'。start 在左上。
defineTile('#', "HARDWALL")
defineTile('.', "FLOOR")
defineTile('H', "FLOOR", nil, "FAM_HEARTH_HEAD")
defineTile('T', "FLOOR", nil, "FAM_HEARTH_APPRENTICE")
defineTile('r', "FLOOR", "FAM_HEARTH_BOOK")
defineTile('<', "FAM_HEARTH_EXIT")

startx = 1
starty = 1
endx = 6
endy = 7

return {
[[#############]],
[[#...........#]],
[[#.H........<#]],
[[#...........#]],
[[#..r........#]],
[[#...........#]],
[[#...........#]],
[[#.....T.....#]],
[[#############]],
}
