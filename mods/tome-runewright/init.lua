long_name = "Runewright"
short_name = "runewright"
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
description = [[盧恩術士（Runewright）——把銘文系統從消耗品插槽變成職業核心的奧術職業。

他不是使用符文，他書寫符文。觸發任何銘文都會累積「符文充能」，而特定的銘文組合會產生「共鳴」，帶來湧現式的被動效果。]]
tags = { "class", "arcane" }

data = true      -- 掛 data/ → /data-runewright/（私有掛載點，需手動 loadDefinition）
hooks = true     -- 掛 hooks/ → 用 ToME:load 手動註冊定義
superload = true -- 疊加 mod/class/Actor.lua，攔截銘文使用
overload = true  -- 只放 mod/dialogs/RunewrightRuneBoard.lua（符文盤面板）
                 -- require("mod.dialogs.X") 走 VFS 的 /mod/，data/ 的私有掛載點搆不到，
                 -- 只有 overload/ 會掛到根目錄（engine/Module.lua:519-524）。
                 -- 這是**新增**檔案而非覆寫原版，所以沒有「兩個 addon 互相吃掉」的問題。
