long_name = "Witch"
short_name = "witch"
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
description = [[女巫（Witch）——以草藥與魔藥為核心的全新職業。

她們不吟唱毀天滅地的咒語，而是與草藥共鳴：調配劇毒魔藥、萃取生命藥露、
以藥草知識強化自身。本版本先實作招牌技能樹「草藥」（spell/herbalism），
其餘留待日後擴充。]]
tags = { "class", "nature" }

data = true      -- 掛 data/ → /data-witch/（私有掛載點，需手動 loadDefinition）
hooks = true     -- 掛 hooks/ → 用 ToME:load 手動註冊定義
