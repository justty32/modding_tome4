-- 我是誰、我在哪。也是判斷「現在到底在哪個畫面」最省事的方式：
-- game.level 是 nil 就代表還沒進遊戲（可能還卡在主選單或建角畫面）。
local p = game.player
if not p or not game.level then print("[PROBE.STATE] not in game yet (game.level is nil)") return end
local d = p.descriptor or {}
print("[PROBE.STATE] name=" .. tostring(p.name) .. " " .. tostring(d.subrace) .. "/" .. tostring(d.subclass) .. " lvl=" .. tostring(p.level))
print("[PROBE.STATE] zone=" .. tostring(game.zone and game.zone.short_name) .. " depth=" .. tostring(game.level.level) .. " pos=" .. p.x .. "," .. p.y .. " turn=" .. tostring(game.turn))
print("[PROBE.STATE] hp=" .. math.floor(p.life) .. "/" .. math.floor(p.max_life) .. " unused_tal=" .. tostring(p.unused_talents) .. " unused_gen=" .. tostring(p.unused_generics))
