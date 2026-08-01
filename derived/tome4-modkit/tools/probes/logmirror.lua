-- 把 game.log 攔截、鏡射到 stdout。**整套探測裡最重要的一支。**
--
-- 裝上之後，遊戲內每一條訊息都會自動以 [GAMELOG] 前綴進 run.log，於是
-- 命中、傷害數字、傷害類型、擊殺、回合推進全部變成可以 grep 的純文字。
-- 這就是 AI 能「觀察該回合發生了什麼」的方式。
--
-- 建議在做任何動作**之前**先裝這支。
--
-- 撈法： tools/playtest.sh log 'GAMELOG'
--
-- 讀訊息時要知道的：
--   * 內容含 #COLOR# / #{bold}# / #UID:...# 這類標記，做斷言前先剝掉或改用片段比對。
--   * 同一條訊息常出現兩次：一次是原始 format 字串（"Game Turn %d 9"），
--     一次是翻譯後的成品（"遊戲回合 9"）。
--
-- 同樣手法可以套在任何函式上，用來抓 addon 自己的呼叫時序：
--   local f = SomeClass.someMethod
--   SomeClass.someMethod = function(s, ...) print("[SPY] called") return f(s, ...) end
if game._modkit_log_mirror then print("[PROBE.LOGMIRROR] already installed, skipping (double-wrapping would recurse)") return end
game._modkit_log_mirror = game.log
game.log = function(...)
local t = {}
for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end
print("[GAMELOG] " .. table.concat(t, " "))
return game._modkit_log_mirror(...)
end
print("[PROBE.LOGMIRROR] installed; every in-game message now goes to run.log with a [GAMELOG] prefix")
