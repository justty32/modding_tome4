-- 驗證「演出中途存檔離開」的復原路徑。
--
-- 為什麼要單獨一支：這條路徑沒辦法在一般 selftest 場景裡驗——它要模擬的正是
-- 「導演不見了、木偶還在」。導演刻意只活在 _G 裡不被序列化，所以讀檔後 D.cur 是 nil，
-- 而 NPC 身上的 ai 已經被清掉、原值存在 __director_ai_saved（那個會跟著存檔走）。
-- 沒有復原機制的話，那些 NPC 會永遠不動——這是本系統最陰的失敗模式。
--
-- 這支直接把 D.cur 設成 nil 來模擬讀檔，再呼叫 restoreAll()。
--
--   tools/playtest.sh probe director_recovery
--   sleep 3
--   tools/playtest.sh log | grep 'DIRECTOR.RECOVERY'
--
-- ⚠️ 探測的**程式碼**只能用 ASCII（playtest.sh 走 xdotool type）。註解可以中文。
-- ⚠️ 入口用 `game.director`，欄位存取用 `D.savedAI(a)` 而不是自己打
--    `a.__director_ai_saved`——xdotool 會把底線間歇性打成空白，
--    那種欄位名一送就爛。理由詳見 probes/director.lua 檔頭。
local D = game.director
if not D then print("[DIRECTOR.RECOVERY] overall = FAIL (game.director is nil)") return end

local function ck(name, ok, detail)
	print(("[DIRECTOR.RECOVERY] %s = %s %s"):format(name, ok and "PASS" or "FAIL", detail or ""))
	return ok
end

if D.cur and not D.cur.ended then D:skip() end

local ok, err = D:play("selftest-skip", { no_skip = true })
if not ok then print(("[DIRECTOR.RECOVERY] overall = FAIL (play: %s)"):format(tostring(err))) return end

-- 推一次讓 spawn 真的發生（spawn 是零時間步驟，pump 一次就會跑到 wait 並停住）。
D:pump()

-- 演出期間有一個 blocker dialog 掛著攔鍵盤。下面要模擬「導演消失」，
-- 若不先把它收掉，它會留在 game.dialogs 裡永遠吃掉所有按鍵——
-- 那正是 playtesting-parts/02 記的「後續按鍵全部失效」那個坑。
local blocker = D.cur and D.cur.dialog

local a = D.cur and D.cur.cast and D.cur.cast.SKIPDUMMY
local all = true
all = ck("puppet_spawned", a ~= nil and a.x ~= nil) and all
all = ck("ai_cleared", a and a.ai == nil, tostring(a and a.ai)) and all
all = ck("ai_saved", D.savedAI(a) == "tactical", tostring(D.savedAI(a))) and all

-- 模擬讀檔：導演狀態機整個消失，木偶留在場上。
if blocker then game:unregisterDialog(blocker) end
D.cur = nil
local n = D.restoreAll()

all = ck("restore_count", n >= 1, "n=" .. tostring(n)) and all
all = ck("ai_restored", a and a.ai == "tactical", tostring(a and a.ai)) and all
all = ck("flag_cleared", a ~= nil and D.savedAI(a) == nil) and all

-- 收掉測試演員，別留在地圖上。
if a and not a.dead and a.x then a:die(nil) end
if game.player then game.player.invulnerable = nil end
game.paused = true

print(("[DIRECTOR.RECOVERY] overall = %s"):format(all and "PASS" or "FAIL"))
