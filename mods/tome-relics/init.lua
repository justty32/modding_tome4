long_name = "Relics of the Lost Excavators"
short_name = "relics"
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
description = [[失落挖掘者的遺物（Relics of the Lost Excavators）——一組考古主題的物品／神器 addon。

舊帝國的考古隊在探勘遠古遺跡時失蹤了，他們的行頭散落於世：一盞能拓印牆上銘文的燈、
一副能看穿黑暗的護目鏡與手套（成套穿戴才顯真章）、以及一柄會「記錄」每次擊殺、
愈用愈利的銘紀之鎬。此外，凡是出自那個年代的武器與防甲，都可能帶有考古匠人的詞綴。

純加法：不覆寫任何原版檔案，只透過 Entity:loadList hook 把新物品與新 ego 追加進既有清單。]]
tags = { "items", "artifact", "ego" }

data = true  -- 掛 data/ → /data-relics/（私有掛載點）。
             -- 物品／ego 檔不靠 loadDefinition，而是在 hooks 裡用 Entity:loadList 追加。
             -- locales/*.lua 仍會被自動載入（engine/Module.lua:505-508）。
hooks = true -- Entity:loadList：把 relics-artifacts / egos-weapon / egos-armor 追加進
             -- 原版對應清單（nullpack/hooks/load.lua:41-57 前例）。純加法，無覆寫衝突。

-- 刻意不使用 overload / superload：本 addon 完全不改動任何原版檔案或類別，
-- 所有內容都是往既有 res 清單 append 新 entity（engine/Entity.lua:1238 的 res[#res+1]=e）。
