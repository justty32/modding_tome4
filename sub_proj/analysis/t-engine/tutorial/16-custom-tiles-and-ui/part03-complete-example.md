### 3.1 範例：建立洞穴主題地塊

```lua
-- mod/data/general/grids/cave.lua

-- 地板（14 種隨機紋路）
newEntity{
    define_as = "CAVE_FLOOR",
    type = "floor", subtype = "cave",
    name = "cave floor",
    image = "terrain/cave/floor_01.png",
    display = '.', color = colors.GREY,
    nice_tiler = { method="replace", base={"CAVE_FLOOR", 100, 1, 14} },
}
for i = 1, 14 do
    newEntity{ base="CAVE_FLOOR", define_as="CAVE_FLOOR"..i,
        image=("terrain/cave/floor_%02d.png"):format(i) }
end

-- 牆壁（使用 wall3d 方法）
newEntity{
    define_as  = "CAVE_WALL",
    type       = "wall", subtype = "cave",
    name       = "cave wall",
    image      = "terrain/cave/wall1_01.png",
    display    = '#', color = colors.GREY,
    z          = 3,
    nice_tiler = {
        method       = "wall3d",
        inner        = {"CAVE_WALL_INNER", 100, 1, 5},
        north        = {"CAVE_WALL_NORTH", 100, 1, 3},
        south        = {"CAVE_WALL_SOUTH", 100, 1, 5},
        north_south  = "CAVE_WALL_NS",
        small_pillar = "CAVE_WALL_PILLAR_SMALL",
        pillar_2     = "CAVE_WALL_PILLAR_2",
        pillar_8     = {"CAVE_WALL_PILLAR_8", 100, 1, 3},
        pillar_4     = "CAVE_WALL_PILLAR_4",
        pillar_6     = "CAVE_WALL_PILLAR_6",
    },
    does_block_move = true,
    block_sight     = true,
    always_remember = true,
    dig             = "CAVE_FLOOR",
}

-- 牆壁內部（被牆包圍）
for i = 1, 5 do
    newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_INNER"..i, z=3,
        image=("terrain/cave/wall1_%02d.png"):format(i) }
end

-- 北牆（頂部有牆蓋）
local wall_top = class.new{image="terrain/cave/wall3.png", z=18, display_y=-1}
for i = 1, 3 do
    newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_NORTH"..i, z=3,
        image=("terrain/cave/wall1_%02d.png"):format(i),
        add_displays={wall_top} }
end

-- 南牆
for i = 1, 5 do
    newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_SOUTH"..i, z=3,
        image=("terrain/cave/wall2_%02d.png"):format(i) }
end

-- 北南牆（獨立橫條）
newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_NS", z=3,
    image="terrain/cave/wall2.png", add_displays={wall_top} }

-- 柱子（略，同上模式）

-- 樓梯
newEntity{
    define_as    = "CAVE_STAIRS_DOWN",
    type         = "floor", subtype = "cave",
    name         = "stairs down",
    image        = "terrain/cave/floor_01.png",
    add_mos      = {{image="terrain/dungeon_stairs_down.png"}},
    display      = '>', color = colors.YELLOW,
    notice       = true,
    always_remember = true,
    change_level = 1,
}
```

### 3.2 範例：羊皮紙主題 UI

```lua
-- mod/data/gfx/ui/definitions/parchment_custom.lua
parchment_custom = {
    frame_shadow = {x=6, y=6, a=0.35},
    frame_alpha  = 1.0,
    frame_ox1    = -12,
    frame_ox2    =  12,
    frame_oy1    = -12,
    frame_oy2    =  12,
}
```

```
-- 所需 PNG 目錄結構
mod/data/gfx/parchment_custom-ui/
    dialogframe_1.png   ← 羊皮紙左下角
    dialogframe_2.png   ← 下邊（平鋪）
    ...（共 9 張）
```

```lua
-- mod/load.lua
local UIBase = require "engine.ui.Base"
UIBase:loadUIDefinitions("/data/gfx/ui/definitions/parchment_custom.lua")
UIBase:changeDefault("parchment_custom")
```

只針對特定對話框：
```lua
-- 在 Dialog subclass 或 Dialog.new 呼叫時
self.ui = "parchment_custom"
```

---
