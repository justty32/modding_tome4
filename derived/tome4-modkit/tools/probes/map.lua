-- 把玩家周圍的地形與生物畫成 ASCII 圖。
--
-- game.level.map 是 engine.Map 的實例，ACTOR / TERRAIN / OBJECT / TRAP 這些常數
-- 可以直接從實例取（走 metatable 找到 class 欄位），不需要 require "engine.Map"。
--
-- 標籤用 [PROBE.MAP] 而不是 [MAP]：引擎自己會印 "[MAP] Reseting tiles caches"，
-- 用 [MAP] 撈會混到它。
local p = game.player
if not p or not game.level then print("[PROBE.MAP] not in game yet") return end
local m = game.level.map
local radius = 4
local out = {}
for j = p.y - radius, p.y + radius do
local row = {}
for i = p.x - radius, p.x + radius do
local a = m(i, j, m.ACTOR)
local t = m(i, j, m.TERRAIN)
local c = "."
if not t then c = "?" elseif t.does_block_move then c = "#" end
if a then c = (a == p) and "@" or "M" end
row[#row + 1] = c
end
out[#out + 1] = table.concat(row)
end
print("[PROBE.MAP] center=" .. p.x .. "," .. p.y .. " radius=" .. radius .. " legend: @=me M=actor #=blocked .=walkable ?=offmap")
for k = 1, #out do print("[PROBE.MAP] " .. out[k]) end
