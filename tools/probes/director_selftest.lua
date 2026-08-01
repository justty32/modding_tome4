-- 跑演出系統的自我驗證場景。
--
-- 這支只是「按下開始」——演出本身要花好幾秒真實時間才跑得完，所以斷言結果
-- 是**非同步**印出來的。呼叫端要等一下再撈 log：
--
--   tools/playtest.sh probe director_selftest
--   sleep 12
--   tools/playtest.sh log | grep 'DIRECTOR.TEST'
--
-- 判定：看最後那行 `[DIRECTOR.TEST] overall = PASS`。
-- 沒有那行就代表演出中途斷了（去看 `[DIRECTOR] abort:`）。
--
-- ⚠️ 探測的**程式碼**只能用 ASCII（playtest.sh 走 xdotool type）。註解可以中文。
-- ⚠️ 入口用 `game.director`，不要用 `rawget(_G, "__tome_director")`——xdotool 會把
--    底線間歇性打成空白，那條路徑會靜默失敗。理由詳見 probes/director.lua 檔頭。
local D = game.director
if not D then print("[DIRECTOR.TEST] overall = FAIL (game.director is nil)") return end
if not D.scenes.selftest then print("[DIRECTOR.TEST] overall = FAIL (selftest scene not registered)") return end

if D.cur and not D.cur.ended then
	print(("[DIRECTOR.TEST] overall = FAIL (a scene is already playing: %s)"):format(tostring(D.cur.id)))
	return
end

-- ⚠️ **不要馬上開演，要延後 6 秒。**
--    `playtest.sh` 送完程式碼後會補一個 Escape 去關 Lua console，而 Escape 正是
--    演出的跳過鍵——馬上開演的話那個 Escape 會打在演出的 blocker dialog 上，
--    場景會在第 15 步左右被跳掉（實測：19 PASS / 1 FAIL，唯一的 FAIL 是
--    end.reason_finish 拿到 "skip"）。延後開場就讓那個 Escape 空砍在沒有演出的畫面上。
--    registerTimer 由 Game:display 驅動，在 paused 時照樣倒數，所以這招是可靠的。
game:registerTimer(6, function()
	local ok, err = D:play("selftest")
	if not ok then print(("[DIRECTOR.TEST] overall = FAIL (play failed: %s)"):format(tostring(err))) end
end)
print("[DIRECTOR.TEST] scheduled - scene starts in 6s, then grep the log")
