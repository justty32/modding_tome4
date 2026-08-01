-- 演出期間的防護欄。
--
-- ── v1 做了什麼、為什麼拆掉 ──────────────────────────────────────────────────
-- v1 把演出的驅動器掛在這裡：每次 act() 就推進一步演出並 `useEnergy()`，
-- 靠 `Player:useEnergy`（M/mod/class/Player.lua:433-439）把 `game.paused` 設回 false
-- 讓回合繼續跑。實機一測就爆了——**一段演出跑掉幾千上萬回合**，
-- 因為回合推進完全沒有節流，而真實時間的等待每一幀都算一個回合。
--
-- v2 的驅動器改成 `Game:registerTimer`（由 `Game:display` 每幀遞減，
-- 在 `game.paused == true` 時照樣跑），所以演出**一個回合都不吃**。
-- 詳見 data/lib/director.lua 檔頭。
--
-- ── 那這個 superload 現在做什麼 ──────────────────────────────────────────────
-- 只當防護欄，不驅動任何東西：
--  1. 掐掉休息／跑步。它們的 `restStep`/`runStep` 迴圈
--     （M/mod/class/Player.lua:415-419）會讓引擎持續 tick，是回合暴衝的另一個來源。
--  2. 演出期間若有東西把 `game.paused` 弄成 false，把它扳回來。
--     **只在玩家真的有能量時才扳**——paused 而玩家沒能量會讓引擎不 tick、
--     玩家也永遠拿不回能量，直接卡死。

local _M = loadPrevious(...)

local base_act = _M.act
function _M:act()
	local r = base_act(self)

	local D = rawget(_G, "__tome_director")
	if self.player and D and D.cur and not D.cur.ended then
		if self.runStop then self:runStop() end
		if self.restStop then self:restStop() end
		if self:enoughEnergy() then game.paused = true end
	end

	return r
end

-- 給 hooks/load.lua 的 selfcheck 用：確認這個 superload 真的疊上去了。
_M.__director_superload = true

return _M
