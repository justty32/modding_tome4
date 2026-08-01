-- 列出本層所有生物，依距離排序（最近的在前）。
--
-- game.level.entities 也含非生物實體，用 a.life 過濾出 actor。
--
-- ⚠️ 這裡的 a.name 是**英文原名**（未經 _t() 翻譯），所以可以安全地拿來字串比對。
--    天賦的 t.name 相反——那個被翻譯過，拿去比對英文會在中文語系下永遠比不中，
--    盧恩術士就是這樣壞掉的（見 knowledge/playtesting-parts/01-why-and-usage.md）。
local p = game.player
if not p or not game.level then print("[PROBE.ACTORS] not in game yet") return end
local function dist(a) return math.max(math.abs(a.x - p.x), math.abs(a.y - p.y)) end
local list = {}
for _, a in pairs(game.level.entities) do
if a.life and a ~= p then list[#list + 1] = a end
end
table.sort(list, function(x, y) return dist(x) < dist(y) end)
print("[PROBE.ACTORS] total=" .. #list .. " (listing nearest 12)")
for i = 1, math.min(#list, 12) do
local a = list[i]
print("[PROBE.ACTORS] " .. tostring(a.name) .. " @" .. a.x .. "," .. a.y .. " hp=" .. math.floor(a.life) .. " dist=" .. dist(a))
end
