-- 把導演掛到 `game.director`，給人和 probe 一個好打的入口。
--
-- ── 為什麼需要 ────────────────────────────────────────────────────────────────
-- 導演的正本活在 `_G.__tome_director`（刻意不掛在 game 上，才不會被存檔序列化）。
-- 但那個名字要在 Lua console 裡手打實在太糟：2026-08-01 實測，`playtest.sh` 走
-- xdotool 送 `rawget(_G, "__tome_director")` 時**底線會間歇性被打成空白**
-- （變成 `"  tome director"`），於是 D 是 nil、探測靜默什麼都不做——
-- 而 DebugConsole 的錯誤只進 console 畫面、不進 stdout，所以連錯誤都看不到。
-- 換成 `game.director:play("demo")` 之後，人跟 probe 都好過。
--
-- ── 為什麼掛在 run() ──────────────────────────────────────────────────────────
-- `Game:run()`（M/mod/class/Game.lua:95）在**新開遊戲與讀檔後都會跑**，
-- 是唯一兩條路都覆蓋得到的點。
--
-- ── 為什麼不會被存進存檔 ─────────────────────────────────────────────────────
-- `Game:save()`（M/mod/class/Game.lua:747）把 `self:defaultSavedFields{...}`
-- 當**白名單**傳給 class.save。`director` 不在白名單裡，所以不會被序列化——
-- 這很重要，因為導演身上掛滿 function，塞進存檔會直接壞掉。

local _M = loadPrevious(...)

local base_run = _M.run
function _M:run(...)
	self.director = rawget(_G, "__tome_director")
	return base_run(self, ...)
end

return _M
