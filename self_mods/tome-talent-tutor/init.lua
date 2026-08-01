long_name = "Talent Tutor"
short_name = "talent-tutor"
for_module = "tome"
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[技藝導師：在大地圖上（德斯城附近）放一位 NPC，免費傳授遊戲中的所有技能樹。

對話依大類分頁：戰技、靈巧、法術、星辰、時空、腐化、詛咒、靈能、自然……
技能樹清單在對話開啟時動態產生，所以其他 addon 新增的技能樹也會自動出現。]]
tags = { "trainer", "talent", "unlock", "cheat" }

data = true    -- 掛 data/ → /data-talent-tutor/（對話檔靠 "talent-tutor+tutor" 這個慣例被找到）
hooks = true   -- 進入大地圖時放置 NPC

-- 刻意不使用 overload：參考的 master-spell-merchants 用 overload 整檔覆蓋原版
-- data/chats/*.lua，任何同樣覆蓋那些檔的 addon 都會跟它打架。
-- engine/Chat.lua:83-90 支援 "<addon>+<file>" 的路徑慣例，可以完全不碰原版檔案。
