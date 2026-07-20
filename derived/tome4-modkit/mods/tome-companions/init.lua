long_name = "Companions"
short_name = "companions"
for_module = "tome"
-- 必須讓 engine.version_nearly_same({1,7,6}, version) 為真，否則 addon 被靜默移除。
version = { 1, 7, 6 }
addon_version = { 0, 1, 0 }
-- weight 不可省略：Module.lua:437 的 table.sort 對 nil 比較會拖垮所有 addon。
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[同伴系統（Companions）——招募、培養、免傷。

一個「契約召募」天賦（建角自動學會），對準附近的非傳奇生物即可將其收為契約夥伴：
- 招募：加入隊伍成為可操控同伴（faction 轉為玩家、不因誤傷反目）。
- 培養：立即拉到與你同級，且此後隨你每次升級一起成長。
- 免傷：契約夥伴完全免疫「你」造成的傷害（含你的 AOE），但仍會被敵人攻擊。
  ——基礎遊戲沒有這個開關，本 addon 用 superload 的 onTakeHit 補上。]]
tags = { "companion", "party" }

data = true      -- talents/ → 在 hooks 的 ToME:load 手動 loadDefinition
hooks = true     -- 載入天賦定義 + ToME:birthDone 教會玩家契約天賦 + selfcheck
superload = true -- 疊加 mod/class/Actor.lua：onTakeHit 讓契約夥伴免疫主人傷害
