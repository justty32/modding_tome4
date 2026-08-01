-- 演出系統（tome-director）的狀態探測。
-- 沒裝那個 addon 就直接說沒裝，不要讓呼叫端誤以為「沒輸出＝沒問題」。
--
-- ⚠️ 探測的**程式碼**只能用 ASCII（playtest.sh 走 xdotool type 送進遊戲）。
--    註解可以寫中文（送出前會被剝掉），但字串字面值不行。
--
-- ⚠️ **底線越少越好。** 2026-08-01 實測：xdotool 會間歇性把底線打成空白，
--    `rawget(_G, "__tome_director")` 就這樣變成 `rawget(_G, "  tome director")`
--    而靜默失敗（DebugConsole 的錯誤只進 console 畫面、不進 stdout，連錯誤都看不到）。
--    所以入口改用 `game.director`（superload/mod/class/Game.lua 在 run() 裡掛的），
--    報告內容由 addon 自己的 D:report() 印，探測只負責按下按鈕。
local D = game.director
if not D then print("[PROBE.DIRECTOR] not loaded (game.director is nil)") return end

D:report("PROBE.DIRECTOR")
