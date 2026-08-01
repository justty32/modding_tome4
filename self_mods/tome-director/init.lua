long_name = "Director"
short_name = "director"
for_module = "tome"
-- 必須讓 engine.version_nearly_same({1,7,6}, version) 為真，否則 addon 被靜默移除。
version = { 1, 7, 6 }
addon_version = { 0, 2, 0 }
-- weight 不可省略：Module.lua:437 的 table.sort 對 nil 比較會拖垮所有 addon。
weight = 100
author = { "tome4-modkit" }
homepage = "-"
description = [[演出導演（Director）——讓 NPC 照腳本表演的框架。

原版引擎沒有過場動畫機制（grep -i cinematic 零命中），data/general/events/ 的 31 個事件
也沒有任何一個做 NPC 走位。本 addon 從零建一套，供劇情向 addon 照抄。

提供：
- 一個演出狀態機（camera / say / log / banner / walk / wait / spawn / puppet / fx / chat / fn / release）
- **演出不吃遊戲回合**：驅動器是 Game:registerTimer（由 display 每幀遞減，paused 時照樣跑），
  所以過場動畫期間中毒、冷卻、飢餓都不會快轉
- 台詞走 ToME 原生對話框（左右立繪），停下來等玩家按鍵，不必猜停留時間
- NPC 木偶化（清 ai → doAI 空轉 → 由導演逐幀下令）
- 必備的輸入鎖與跳過鍵（Escape）、演出中無敵、走位超時、讀檔中斷後自動還原

自己不含任何劇情內容，是給其他 addon 用的函式庫。附一個 demo 場景可直接跑。]]
tags = { "library", "cutscene", "story" }

data = true      -- lib/ 與 scenes/ 由 hooks 的 ToME:load 手動 dofile（data/ 是私有掛載點）
hooks = true     -- 載入 lib、註冊 demo 場景、教除錯天賦、selfcheck
superload = true -- 疊加 mod/class/Player.lua：演出期間的防護欄（掐掉休息/跑步、扳回 paused）
