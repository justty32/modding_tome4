long_name = "Rune Isles"
short_name = "runeisles"
for_module = "tome"
-- 必須讓 engine.version_nearly_same({1,7,6}, version) 為真，否則 addon 被靜默移除
-- （engine/Module.lua:390 → :595，全程沒有錯誤訊息）
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
-- weight 不可省略：engine/Module.lua:437 直接 a.weight < b.weight，
-- nil 會讓整個 addon 清單的 table.sort 拋錯，拖垮使用者所有 addon。
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[符文諸島（Rune Isles）——一張全新的大世界地圖，外加一條主線劇情。

德斯城西側的平原上立起了一圈符文石環。穿過它，你會抵達北方冰封海上的一片群島：
古代刻名師在此以符文石陣鎮壓「無銘之物」，而石陣正在崩解。

承接盧恩術士（Runewright）的古弗薩克文設定，但不需要安裝它也能遊玩。]]
tags = { "campaign", "zone", "worldmap", "quest" }

data = true  -- 掛 data/ → /data-runeisles/（私有掛載點）
             -- zone 短名要寫成 "runeisles+worldmap"（engine/Zone.lua:155-165）
             -- 地圖檔要寫成 "runeisles+worldmap"（engine/generator/map/Static.lua:50-59）
hooks = true -- 把傳送門貼到 Eyal 大地圖上，並把新地磚註冊進 wilderness 的 grid_list

-- 刻意不使用 overload：master-spell-merchants 是整檔覆寫 data/maps/wilderness/eyal.lua
-- 來加傳送點的，兩個這樣做的 addon 會由 weight 決定誰贏、輸的那個改動全部靜默消失
-- （engine/Module.lua:437 排序 + :519-524 掛到根目錄）。
-- 官方 DLC（orcs）走的是 MapGeneratorStatic:subgenRegister，那是加法而非取代。
