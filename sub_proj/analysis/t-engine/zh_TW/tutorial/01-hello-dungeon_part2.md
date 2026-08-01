## 5. 地形定義（grids/）

在 `data/zones/dungeon/grids.lua` 定義地形：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/grids.lua

-- 上一層樓梯
newEntity{
    define_as = "UP",
    name = "previous level",
    display = '<', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice = true,           -- 奔跑時會注意
    always_remember = true,  -- 離開 FOV 仍記憶
    change_level = -1,       -- 往上走
}

-- 下一層樓梯
newEntity{
    define_as = "DOWN",
    name = "next level",
    display = '>', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice = true,
    always_remember = true,
    change_level = 1,        -- 往下走
}

-- 地板
newEntity{
    define_as = "FLOOR",
    name = "floor",
    display = '.', color_r=200, color_g=200, color_b=200,
    back_color = colors.DARK_GREY,
}

-- 牆壁
newEntity{
    define_as = "WALL",
    name = "wall",
    display = '#', color_r=255, color_g=255, color_b=255,
    back_color = colors.GREY,
    always_remember = true,
    does_block_move = true,       -- 阻擋移動
    can_pass = {pass_wall=1},     -- 穿牆技能可通過
    block_sight = true,           -- 阻擋視線
    air_level = -20,              -- 無空氣
    dig = "FLOOR",                -- 挖掘後變地板
}

-- 門（關閉）
newEntity{
    define_as = "DOOR",
    name = "door",
    display = '+', color_r=238, color_g=154, color_b=77,
    back_color = colors.DARK_UMBER,
    notice = true, always_remember = true,
    block_sight = true,
    door_opened = "DOOR_OPEN",   -- 開啟後替換此定義
    dig = "DOOR_OPEN",
}

-- 門（開啟）
newEntity{
    define_as = "DOOR_OPEN",
    name = "open door",
    display = "'", color_r=238, color_g=154, color_b=77,
    back_color = colors.DARK_GREY,
    always_remember = true,
    door_closed = "DOOR",        -- 關閉後替換此定義
}
```

**`define_as`** 為大寫識別符，zone.lua 中用字元對應（`['.'] = "FLOOR"`）。

---

## 6. 地區設定（zone.lua）

Zone 定義地城區域的生成規則：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/zone.lua

return {
    name = _t"古老遺跡",       -- _t 包裝支援多語言
    level_range = {1, 1},      -- 怪物等級範圍
    max_level = 10,            -- 最多幾層
    decay = {300, 800},        -- 關卡在快取中的存活回合範圍
    width = 50, height = 50,   -- 地圖尺寸（格）

    -- 持久保存 zone（非 level）
    persistent = "zone",

    generator = {
        map = {
            class = "engine.generator.map.Roomer",  -- 房間生成器
            nb_rooms = 10,                          -- 約 10 間房
            rooms = {"simple", "pilar"},            -- 房間模板
            lite_room_chance = 100,                 -- 100% 有燈光

            -- 字元 → Grid define_as 對應
            ['.'] = "FLOOR",
            ['#'] = "WALL",
            up    = "UP",
            down  = "DOWN",
            door  = "DOOR",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {20, 30},   -- 每層生成 20~30 個
        },
    },

    levels = {
        -- [5] = { name = "Boss Floor" },
    },
}
```

**Roomer 主要參數**：

| 參數 | 說明 |
|------|------|
| `nb_rooms` | 房間數量 |
| `rooms` | 模板（`"simple"` 矩形，`"pilar"` 柱廊）|
| `lite_room_chance` | 房間預亮機率 (0~100) |
| `['.']` / `['#']` | 字元到 Grid 定義映射 |
