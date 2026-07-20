地形（Grid）是地圖的基礎元素。我們在 `data/zones/dungeon/grids.lua` 定義此地城使用的地形：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/grids.lua

-- 上一層樓梯（回到上一層）
newEntity{
    define_as = "UP",
    name = "previous level",
    display = '<', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice = true,           -- 玩家奔跑時會注意到
    always_remember = true,  -- 即使離開 FOV 也保持記憶
    change_level = -1,       -- 往上走（-1 = 上一層）
}

-- 下一層樓梯
newEntity{
    define_as = "DOWN",
    name = "next level",
    display = '>', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice = true,
    always_remember = true,
    change_level = 1,        -- 往下走（+1 = 下一層）
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
    air_level = -20,              -- 此格無空氣（地下）
    dig = "FLOOR",                -- 挖掘後變成地板
}

-- 門（關閉）
newEntity{
    define_as = "DOOR",
    name = "door",
    display = '+', color_r=238, color_g=154, color_b=77,
    back_color = colors.DARK_UMBER,
    notice = true,
    always_remember = true,
    block_sight = true,
    door_opened = "DOOR_OPEN",   -- 開啟後替換為此定義
    dig = "DOOR_OPEN",
}

-- 門（開啟）
newEntity{
    define_as = "DOOR_OPEN",
    name = "open door",
    display = "'", color_r=238, color_g=154, color_b=77,
    back_color = colors.DARK_GREY,
    always_remember = true,
    door_closed = "DOOR",        -- 關閉後替換為此定義
}
```

**`define_as`** 是一個全大寫的識別符，讓你在 `zone.lua` 中用字元對應（`['.'] = "FLOOR"`）。

---
