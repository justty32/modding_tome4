-- 跑演出系統的「台詞框」自我驗證場景（selftest-say）。
--
-- 為什麼要獨立一支：台詞現在走 ToME 原生對話框，會**停下來等玩家按鍵**。
-- 那條路徑不能混在 selftest 裡跑（selftest 是無人值守的），所以拆開。
-- 這支場景自己會排一個計時器扮演玩家把對話框關掉，走的是
-- unregisterDialog -> unload -> D:resume() 這條真實路徑。
--
--   tools/playtest.sh probe director_say
--   sleep 6
--   tools/playtest.sh log | grep 'DIRECTOR.TEST'
--
-- 判定：看 `[DIRECTOR.TEST] overall = PASS`。
--
-- ⚠️ 探測的**程式碼**只能用 ASCII（playtest.sh 走 xdotool type）。註解可以中文。
-- ⚠️ 入口用 `game.director`，不要用 `rawget(_G, "__tome_director")`——xdotool 會把
--    底線間歇性打成空白，那條路徑會靜默失敗。理由詳見 probes/director.lua 檔頭。
local D = game.director
if not D then print("[DIRECTOR.TEST] overall = FAIL (game.director is nil)") return end
if not D.scenes["selftest-say"] then print("[DIRECTOR.TEST] overall = FAIL (selftest-say not registered)") return end

if D.cur and not D.cur.ended then
	print(("[DIRECTOR.TEST] overall = FAIL (a scene is already playing: %s)"):format(tostring(D.cur.id)))
	return
end

-- 延後 6 秒開演，理由同 director_selftest：playtest.sh 收尾的 Escape 是跳過鍵。
game:registerTimer(6, function()
	local ok, err = D:play("selftest-say")
	if not ok then print(("[DIRECTOR.TEST] overall = FAIL (play failed: %s)"):format(tostring(err))) end
end)
print("[DIRECTOR.TEST] scheduled selftest-say - starts in 6s, then grep the log")
