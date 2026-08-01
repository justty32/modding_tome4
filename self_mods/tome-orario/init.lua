long_name = "Orario"
short_name = "orario"
for_module = "tome"
version = { 1, 7, 6 }
addon_version = { 0, 4, 0 }
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[歐拉麗（Orario）——「在地下城邂逅」風味的異世界。

德斯城旁立起一道通往異世界的門，穿過它抵達迷宮都市歐拉麗：一座圍繞著中央大迷宮
「巴別塔」而生的城市。中央廣場四面是冒險者公會、酒館、市集與各眷族的據點。

（世界觀取材自《在地下城邂逅是否搞錯了什麼》，劇情人物不刻意還原，重點在城市機制。
 建置採 hub 城鎮方案：中央廣場為樞紐，各設施與迷宮以傳送門互連。見 PLAN-camp-and-isekai.md §B。）

v0.1：中央廣場 hub + 巴別塔大迷宮 + Eyal 大地圖入口。
v0.2：冒險者公會受付孃（廣場左上）發討伐委託，打倒巴別塔第 1 層階層主後回報領賞。
v0.3：酒館「豐饒女主人」（廣場右上）三名可招募冒險者（劍士/弓手/法師），對話即入隊、可操控、隨你成長。
v0.4：巴別塔市集（廣場頂中建築，武具/雜貨/鍛造材料三家商店，真的能買賣）＋三眷族據點（廣場底部三棟建築，赫斯緹雅/洛基/芙蕾雅，各含劇情 NPC、見面禮與 lore 書）。]]
tags = { "campaign", "zone", "worldmap", "town", "dungeon" }

data = true  -- zones/ 與 maps/ 由 changeLevel 惰性載入
hooks = true -- 把歐拉麗入口貼到 Eyal 大地圖 + selfcheck
