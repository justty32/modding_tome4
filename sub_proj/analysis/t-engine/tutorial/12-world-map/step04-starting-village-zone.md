### 檔案：`mod/data/zones/town_a/zone.lua`

城鎮使用靜態地圖（手工設計），並設定持久化。

```lua
-- mod/data/zones/town_a/zone.lua
-- 起點村莊

local Zone = require "engine.Zone"

return Zone.new("town_a", {
    name        = "起點村莊",
    level_range = {1, 1},
    max_level   = 1,

    width  = 30,
    height = 25,

    persistent    = "zone",
    all_remembered = true,
    all_lited      = true,

    grid_list = require("mod.class.Grid"):loadList{
        "mod/data/grids/general.lua",
        "mod/data/grids/town.lua",    -- 城鎮專用地形
    },
    npc_list = require("mod.class.NPC"):loadList{
        "mod/data/npcs/town_a_npcs.lua",  -- 村莊居民、商人
    },
    object_list = require("mod.class.Object"):loadList{
        "mod/data/objects/consumables.lua",
        "mod/data/objects/equipment.lua",
    },

    generator = {
        map   = {class = "engine.generator.map.Static", map = "town_a"},
        actor = {class = "engine.generator.actor.OnceAtCoord"},
    },

    on_enter = function(lev, old_lev)
        game.logPlayer(game.player, "#YELLOW#你進入了起點村莊。")
    end,
})
```

### 城鎮出口地形（`mod/data/grids/town.lua` 摘錄）

每個城鎮都需要一個「出口」地形，讓玩家返回大地圖：

```lua
-- mod/data/grids/town.lua（摘錄）

-- 城鎮通用地板 / 牆壁
newEntity{define_as="TOWN_FLOOR", name="石板地",
    display='.', color_r=180, color_g=180, color_b=160,
    back_color=colors.DARK_GREY}

newEntity{define_as="TOWN_WALL", name="石牆",
    display='#', color_r=150, color_g=150, color_b=150,
    back_color=colors.DARK_GREY,
    always_remember=true, does_block_move=true, block_sight=true}

-- ★ 關鍵：城鎮出口 → 返回大地圖
newEntity{
    define_as = "TOWN_EXIT",
    name = "城鎮出口",
    display = '<', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice          = true,
    always_remember = true,

    -- 返回 wilderness Zone 的第 1 層
    change_level = 1,
    change_zone  = "wilderness",
}
```

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
