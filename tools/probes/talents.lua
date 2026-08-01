-- 列出玩家目前所有天賦與等級，加上還沒配的點數。
-- 驗自訂職業的起手天賦、驗 unlockTalents、驗天賦等級縮放，都從這裡開始。
local p = game.player
if not p then print("[PROBE.TALENTS] not in game yet") return end
local ids = {}
for tid, lev in pairs(p.talents) do ids[#ids + 1] = tid .. "=" .. lev end
table.sort(ids)
print("[PROBE.TALENTS] count=" .. #ids .. " unused_tal=" .. tostring(p.unused_talents) .. " unused_gen=" .. tostring(p.unused_generics))
for i = 1, #ids do print("[PROBE.TALENTS] " .. ids[i]) end
