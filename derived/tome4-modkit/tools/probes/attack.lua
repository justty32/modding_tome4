-- 走到某個生物旁邊並攻擊它，印出攻擊前後的血量。
-- 用法： tools/playtest.sh probe attack "large white snake"
--
-- ARG1 是生物名稱的**片段**（英文原名，見 actors.lua 的說明），用 find 做子字串比對。
-- 先跑 tools/playtest.sh probe actors 看有哪些目標。
--
-- 建議先裝 logmirror，才看得到「造成 N 點 X 傷害」那幾行。
--
-- p:move(x, y, true) 的 force=true 是**瞬移**（跳過地形與耗時檢查），純粹為了快速擺位。
-- 要驗移動規則本身（阻擋、陷阱觸發、耗時）就不要給 force。
--
-- attackTarget 是同步的，所以前後血量可以在同一支 probe 裡讀完。
-- 但怪物的反擊不是——那要等遊戲主迴圈，得隔一次呼叫再撈 log。
local p = game.player
if not p or not game.level then print("[PROBE.ATTACK] not in game yet") return end
local target = nil
for _, a in pairs(game.level.entities) do
if a.life and a ~= p and a.name and a.name:find(ARG1, 1, true) then target = a break end
end
if not target then print("[PROBE.ATTACK] no actor whose name contains: " .. ARG1 .. " (run: probe actors)") return end
p:move(target.x - 1, target.y, true)
print("[PROBE.ATTACK] target=" .. target.name .. " @" .. target.x .. "," .. target.y .. " pre_hp=" .. math.floor(target.life) .. " me@" .. p.x .. "," .. p.y .. " turn=" .. tostring(game.turn))
p:attackTarget(target)
print("[PROBE.ATTACK] post_hp=" .. math.floor(target.life) .. " dead=" .. tostring(target.dead))
