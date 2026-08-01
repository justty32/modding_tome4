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

### 地牢的樓梯地形（`mod/data/grids/dungeon_forest.lua` 摘錄）

地牢各層之間用樓梯連接，最底層（第 3 層）的向上樓梯返回大地圖：

```lua
-- mod/data/grids/dungeon_forest.lua（摘錄）

newEntity{define_as="DUNGEON_FLOOR", name="泥土地板",
    display='.', color_r=100, color_g=80, color_b=60,
    back_color=colors.DARK_UMBER}

newEntity{define_as="DUNGEON_WALL", name="泥土牆壁",
    display='#', color_r=80, color_g=60, color_b=40,
    back_color=colors.DARK_UMBER,
    always_remember=true, does_block_move=true, block_sight=true}

newEntity{define_as="DUNGEON_DOOR", name="木門",
    display='+', color_r=140, color_g=100, color_b=60,
    back_color=colors.DARK_UMBER,
    notice=true, always_remember=true, block_sight=true,
    door_opened="DUNGEON_DOOR_OPEN"}

newEntity{define_as="DUNGEON_DOOR_OPEN", name="木門（開）",
    display="'", color_r=140, color_g=100, color_b=60,
    back_color=colors.DARK_GREY, always_remember=true,
    door_closed="DUNGEON_DOOR"}

-- 向下樓梯（進入下一層）
newEntity{
    define_as = "DUNGEON_STAIRS_DOWN",
    name = "向下的樓梯",
    display = '>', color_r=200, color_g=200, color_b=200,
    back_color = colors.DARK_GREY,
    notice=true, always_remember=true,
    change_level = 1,   -- +1 層（相對值，非 change_zone 時用此）
}

-- 向上樓梯（返回上一層，或從第 1 層返回大地圖）
newEntity{
    define_as = "DUNGEON_STAIRS_UP",
    name = "向上的樓梯",
    display = '<', color_r=200, color_g=200, color_b=200,
    back_color = colors.DARK_GREY,
    notice=true, always_remember=true,
    change_level = -1,  -- -1 層（相對值）
    -- 注意：在第 1 層時，change_level = -1 會讓 changeLevel 呼叫
    -- game:changeLevel(0, nil)，引擎會自動解析為返回大地圖
    -- 若要更明確控制，可在 on_enter 中動態修改此欄位
}
```

> **樓梯相對值 vs. 絕對值：**
>
> - `change_level = 1`（正數）：下一層（相對）
> - `change_level = -1`（負數）：上一層（相對）
> - `change_level = 1, change_zone = "wilderness"`：回大地圖的**絕對**指定
>
> 如果希望地牢第 1 層的向上樓梯**明確**回到大地圖，最安全的做法是在 Zone 的 `on_enter` 中，動態把第 1 層的向上樓梯替換為帶 `change_zone` 的版本：

```lua
-- dungeon_forest/zone.lua → on_enter（精確控制版）
on_enter = function(lev, old_lev)
    if lev == 1 and (not old_lev or old_lev > 1) then
        -- 讓第 1 層的所有向上樓梯明確指向大地圖
        local Map = require "engine.Map"
        for y = 0, game.level.map.h - 1 do
            for x = 0, game.level.map.w - 1 do
                local t = game.level.map(x, y, Map.TERRAIN)
                if t and t.define_as == "DUNGEON_STAIRS_UP" then
                    -- 複製一份並修改 change_zone
                    local exit_tile = t:clone()
                    exit_tile.change_level = 1
                    exit_tile.change_zone  = "wilderness"
                    game.level.map(x, y, Map.TERRAIN, exit_tile)
                end
            end
        end
    end
end,
```

---
