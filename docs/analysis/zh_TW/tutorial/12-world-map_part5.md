### 城鎮靜態地圖（`mod/data/maps/town_a.lua`）

```lua
-- mod/data/maps/town_a.lua
-- 起點村莊（30×25）

defineTile('.', "TOWN_FLOOR")
defineTile('#', "TOWN_WALL")
defineTile('+', "TOWN_DOOR")
defineTile('<', "TOWN_EXIT")
defineTile('t', "TOWN_TREE")
defineTile('s', "TOWN_FLOOR", nil, "SHOPKEEPER_NPC")  -- 商人
defineTile('q', "TOWN_FLOOR", nil, "QUEST_GIVER_NPC") -- 任務發布者

startx = 15
starty = 22   -- 玩家進入時出現在出口附近

return [[
##############################
#............................#
#............................#
#....t....#######....t.......#
#.........#.....#............#
#.........#..s..#............#
#.........#.....#............#
#.........+.....+............#
#..........#####.............#
#............................#
#......#########.............#
#......#.......#.............#
#......#...q...#.............#
#......#.......#.............#
#......+.......+.............#
#......#########.............#
#............................#
#............................#
#..t.......................t.#
#............................#
#............................#
#............................#
#............................#
#...............<............#
##############################
]]
```

---

## 步驟五：地牢 Zone（隨機生成）

與城鎮不同，地牢使用**隨機生成**（`Roomer` 演算法），有多層，且不持久化（每次進入重新生成）。

### 檔案：`mod/data/zones/dungeon_forest/zone.lua`

```lua
-- mod/data/zones/dungeon_forest/zone.lua
-- 森林地牢（3 層，隨機生成）

local Zone = require "engine.Zone"

return Zone.new("dungeon_forest", {
    name        = "森林地牢",
    level_range = {1, 3},   -- 第 1 ~ 3 層
    max_level   = 3,

    width  = 50,
    height = 50,

    -- 地牢不需要持久化：每次進入重新生成（更有新鮮感）
    -- 若要保留探索狀態，設為 persistent = "zone"
    persistent = false,

    -- 地牢黑暗，需要光源 / FOV
    all_remembered = false,
    all_lited      = false,

    grid_list = require("mod.class.Grid"):loadList{
        "mod/data/grids/dungeon_forest.lua",
    },
    npc_list = require("mod.class.NPC"):loadList{
        "mod/data/npcs/forest_monsters.lua",
    },
    object_list = require("mod.class.Object"):loadList{
        "mod/data/objects/consumables.lua",
        "mod/data/objects/equipment.lua",
        "mod/data/objects/materials.lua",
    },

    -- 隨機地圖產生
    generator = {
        map = {
            class  = "engine.generator.map.Roomer",
            floor  = "DUNGEON_FLOOR",
            wall   = "DUNGEON_WALL",
            door   = "DUNGEON_DOOR",
            up     = "DUNGEON_STAIRS_UP",
            down   = "DUNGEON_STAIRS_DOWN",
            -- 房間數量與尺寸
            rooms  = {6, 12},
            lite_room = false,
        },
        actor = {
            class    = "engine.generator.actor.Random",
            nb_npc   = {5, 10},    -- 每層 5~10 個敵人
            guardian = "FOREST_BOSS",  -- 最後一層有 Boss（可選）
        },
        object = {
            class  = "engine.generator.object.Random",
            nb_obj = {3, 6},
        },
    },

    -- 最深層（第 3 層）的進入回呼
    on_enter = function(lev, old_lev)
        if lev == 3 then
            game.logPlayer(game.player,
                "#RED#你感受到一股強烈的邪惡氣息……這裡住著什麼強大的東西。")
        end
    end,
})
```
