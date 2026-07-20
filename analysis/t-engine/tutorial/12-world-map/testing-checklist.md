```lua
-- 按 ` 或 F1 開啟 Cheat Console

-- 1. 確認從大地圖開始
print("當前 Zone：", game.zone.short_name)   -- 應為 "wilderness"
print("地圖尺寸：", game.level.map.w, game.level.map.h)  -- 應為 50 30

-- 2. 確認地點標記存在（查 ASCII 地圖中 A 的位置）
local Map = require "engine.Map"
local t = game.level.map(10, 20, Map.TERRAIN)   -- A 在 (10,20)
print("地點標記：", t and t.name, t and t.change_zone)
-- 預期：起點村莊  town_a

-- 3. 進入城鎮
game:changeLevel(1, "town_a")
print("Zone：", game.zone.short_name)   -- 應為 "town_a"

-- 4. 返回大地圖
game:changeLevel(1, "wilderness")
print("Zone：", game.zone.short_name)   -- 應為 "wilderness"
print("玩家位置：", game.player.x, game.player.y)  -- 應在上次離開位置

-- 5. 進入地牢（多層測試）
game:changeLevel(1, "dungeon_forest")
print("地牢 Zone：", game.zone.short_name)   -- "dungeon_forest"
print("當前層：", game.level.level)           -- 1

-- 進入第 2 層
game:changeLevel(2, nil)   -- nil 表示同 Zone
print("第 2 層：", game.level.level)          -- 2

-- 6. 確認 persistent
game:changeLevel(1, "wilderness")
-- 重進大地圖，確認地形狀態保留
local t2 = game.level.map(10, 20, Map.TERRAIN)
print("持久化後地點仍存在：", t2 and t2.name)

-- 7. 動態解鎖測試
game:unlockWorldLocation(25, 5, "DUNGEON_FOREST_ENTRANCE")
-- 查看大地圖 (25,5) 是否出現地牢標記
```

---
