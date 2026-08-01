-- 給角色加一點天賦，不必去點升級畫面的圖示。
-- 用法： tools/playtest.sh probe learn T_WEAPONS_MASTERY
--
-- ARG1 是天賦常數名。actor 身上有這些常數（p.T_XXX），先跑 probe talents 看有哪些。
--
-- 兩個容易踩的：
--   * learnTalent(tid, force) 的 force=true 會**跳過前置需求檢查**。
--     要驗前置條件本身時不要給 force。
--   * learnTalent **不會**自動扣 unused_talents，要自己扣，否則後面的點數斷言會對不上。
local p = game.player
if not p then print("[PROBE.LEARN] not in game yet") return end
local tid = p[ARG1]
if not tid then print("[PROBE.LEARN] no such talent constant: " .. ARG1 .. " (run: probe talents)") return end
local before = p:getTalentLevelRaw(tid)
p:learnTalent(tid, true)
p.unused_talents = math.max(0, (p.unused_talents or 0) - 1)
print("[PROBE.LEARN] " .. ARG1 .. " " .. before .. " -> " .. p:getTalentLevelRaw(tid) .. " unused_tal=" .. p.unused_talents)
