long_name = "Witchwood"
short_name = "witchwood"
for_module = "tome"
-- 必須讓 natural_compatible 為真，否則 addon 被靜默移除（engine/Module.lua:390 → :595）
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
-- weight 不可省：engine/Module.lua:437 直接比大小，nil 會讓整個 addon 清單的
-- table.sort 拋錯，拖垮使用者所有 addon。
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[女巫森林（Witchwood）——瑞文谷西北方一片被詛咒的老林。

接續女巫職業（tome-witch）的設定：這裡是女巫的源頭。含全新地區、
三種原生怪物、與一條支線任務。]]
tags = { "zone", "quest", "npc" }

data = true       -- data/ → /data-witchwood/（私有掛載點，PNG 放這裡讀不到）
hooks = true      -- hooks/load.lua
overload = true   -- overload/ → prepend 掛在 VFS 根，自製美術放這裡
