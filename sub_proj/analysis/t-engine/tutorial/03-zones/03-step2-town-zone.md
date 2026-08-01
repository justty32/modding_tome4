城鎮是一個簡單的 Zone，只有 1 層，用 `Static`（靜態地圖）生成器，或暫時用 `Roomer` 也可以。

### 3.1 city/zone.lua

```lua
-- game/modules/hellodungeon/data/zones/town/zone.lua

return {
    name = "賢者城鎮",
    short_name = "town",
    level_range = {1, 1},
    level_scheme = "player",
    max_level = 1,

    -- 城鎮永久保存（玩家離開後地圖狀態不重置）
    persistent = "zone",

    -- 城鎮所有格子都亮著
    all_lited = true,

    -- 城鎮 NPC 不重新生成
    decay = {300, 800, no_respawn=true},

    -- 告訴 Zone 使用哪些類別
    on_setup = function(self)
        self:setup{
            npc_class    = "mod.class.NPC",
            grid_class   = "mod.class.Grid",
            object_class = "mod.class.Object",
        }
    end,

    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 5,
            rooms = {"rect"},
            lite_room_chance = 100,
            floor = "FLOOR",
            wall  = "WALL",
            up    = "EXIT_TOWN",    -- 城鎮出口（進入地城）
            down  = "EXIT_TOWN",    -- 單層地區不需要向下
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {3, 5},        -- 幾個城鎮 NPC（村民等）
        },
        object = {
            class = "engine.generator.object.Random",
            nb_object = {0, 2},
        },
    },
}
```

### 3.2 town/grids.lua

```lua
-- game/modules/hellodungeon/data/zones/town/grids.lua

-- 載入共用地形
load("/data/general/grids/basic.lua")

-- 城鎮出口（進入地城第 1 層）
newEntity{
    define_as = "EXIT_TOWN",
    name = "地城入口",
    display = '>', color_r=200, color_g=100, color_b=50,
    always_remember = true,
    notice = true,
    -- change_zone：進入 "dungeon" 地區
    -- change_level：目標地區的第幾層（1 = 第一層）
    change_level = 1,
    change_zone = "dungeon",
}
```

### 3.3 town/npcs.lua 和 town/objects.lua

```lua
-- game/modules/hellodungeon/data/zones/town/npcs.lua
-- 暫時空白，或加入村民 NPC
```

```lua
-- game/modules/hellodungeon/data/zones/town/objects.lua
-- 暫時空白
```

### 3.4 更新地城地形：加入返回城鎮的出口

在 `data/zones/dungeon/grids.lua` 中更新 UP 地形，讓它能帶玩家回城鎮：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/grids.lua

load("/data/general/grids/basic.lua")

-- 覆蓋 UP 地形：第一層的上樓會回到城鎮
-- （需要在 Game:changeLevel 中判斷第一層特殊處理）
newEntity{
    define_as = "UP",
    name = "返回城鎮",
    display = '<', color_r=255, color_g=200, color_b=50,
    always_remember = true,
    notice = true,
    -- 第一層的 UP 指向城鎮，其他層指向上一層
    -- 具體邏輯在 CHANGE_LEVEL 事件中處理（見第四步）
    change_level = -1,      -- 預設：上一層（Game:changeLevel 會做特殊判斷）
}
```

更優雅的方式是在第一層放一個專用地形（`DUNGEON_EXIT`）：

```lua
newEntity{
    define_as = "DUNGEON_EXIT",
    name = "離開地城",
    display = '<', color_r=255, color_g=200, color_b=50,
    always_remember = true,
    notice = true,
    change_level = 1,       -- 城鎮只有 1 層
    change_zone = "town",   -- 回到城鎮
}
```

並在 `zone.lua` 的生成器中把第 1 層的 `up` 改為 `"DUNGEON_EXIT"`（可在 `post_process` 中動態替換）。

---
