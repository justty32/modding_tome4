```lua
-- 按 ` 或 F1 開啟 Cheat Console

-- 1. 進入據點
game:changeLevel(1, "camp")
print(game.zone.short_name)           -- 應印出 "camp"

-- 2. 確認持久化模式
print(game.zone.persistent)           -- 應印出 "zone"

-- 3. 確認地圖尺寸
print(game.level.map.w, game.level.map.h)   -- 應印出 25  20

-- 4. 確認篝火地形（查 ASCII 地圖中 * 的位置）
local Map     = require "engine.Map"
local terrain = game.level.map(8, 6, Map.TERRAIN)   -- * 在 (8,6)
print(terrain and terrain.name, terrain and terrain.camp_heal)
-- 預期：篝火  true

-- 5. 確認工作台 NPC（查 ASCII 地圖中 w 的位置）
local npc = game.level.map(7, 11, Map.ACTOR)        -- w 在 (7,11)
print(npc and npc.name)
-- 預期：合成工作台

-- 6. 測試持久化（離開再進來）
game:changeLevel(1, "wilderness")
game:changeLevel(1, "camp")
print("level 物件 uid:", game.level.uid)   -- 兩次進入應相同
```

---
