更新 `zone.lua`，加入三件事：`object_class`、物品生成器設定、`setup()` 加入物品類別：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/zone.lua

return {
    name = "地下城",
    short_name = "dungeon",
    level_range = {1, 10},
    level_scheme = "player",
    max_level = 3,
    decay = {300, 800},
    persistent = "zone",

    -- ← 加入這行：告訴 Zone 用哪個類別來代表物品
    object_class = "mod.class.Object",

    -- Zone:setup() 初始化各類 Entity 的類別
    -- 加入 object_class 讓 Zone 知道要用哪個 Object
    on_setup = function(self)
        self:setup{
            npc_class    = "mod.class.NPC",
            grid_class   = "mod.class.Grid",
            object_class = "mod.class.Object",   -- ← 新增
        }
    end,

    -- 地形、NPC 生成器與教學 01 相同
    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 8,
            rooms = {"rect"},
            lite_room_chance = 80,
            floor = "FLOOR",
            wall  = "WALL",
            up    = "UP",
            down  = "DOWN",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {5, 10},
        },
        -- ← 加入物品生成器
        object = {
            class = "engine.generator.object.Random",
            -- 每層地圖隨機散落的物品數量範圍
            nb_object = {3, 7},
        },
    },
}
```

`engine.generator.object.Random` 的工作流程：

1. 呼叫 `zone:makeEntity(level, "object", filter)` 從物品清單中依 `rarity` 隨機選一個
2. 找一個空地板格（不在牆上、不在特殊位置）
3. 呼叫 `zone:addEntity(level, o, "object", x, y)` 把物品放到地圖

---
