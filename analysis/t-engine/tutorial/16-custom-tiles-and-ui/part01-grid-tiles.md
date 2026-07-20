### 1.1 基本 Grid 顯示欄位

每個地形實體（Grid entity）有以下顯示相關欄位：

```lua
newEntity{
    define_as = "FLOOR",
    type = "floor", subtype = "floor",
    name  = "floor",

    -- 主貼圖，路徑相對於 /data/gfx/
    image = "terrain/marble_floor.png",

    -- ASCII 模式下的字元（fallback）
    display     = '.',
    color_r     = 255, color_g = 255, color_b = 255,
    back_color  = colors.DARK_GREY,

    -- Z 層級：1=地板，3=牆壁，18=牆頂蓋（顯示在角色之上）
    z = 1,
}
```

### 1.2 多層貼圖：`add_mos` 與 `add_displays`

| 欄位 | 用途 | 渲染方式 |
|------|------|---------|
| `add_mos` | 在同一 z 層疊加多張圖片（如裝飾圖案） | 同一渲染批次 |
| `add_displays` | 額外的虛擬實體，各自有獨立的 z/image | 分別進入渲染佇列 |

`add_mos` 範例（在地板上疊加出口標記）：
```lua
newEntity{
    define_as = "STAIRS_DOWN",
    type = "floor", subtype = "floor",
    name  = "stairs down",
    image = "terrain/marble_floor.png",
    add_mos = {
        {image = "terrain/dungeon_stairs_down.png"},
    },
    notice = true,
    change_level = 1,
}
```

`add_displays` 範例（牆壁 + 頂部蓋片）：
```lua
newEntity{
    define_as = "WALL_NORTH",
    base  = "WALL",
    -- 牆壁本體在 z=3
    image = "terrain/granite_wall1_1.png", z = 3,
    -- 牆頂蓋片在 z=18（渲染在角色之上，製造 3D 效果）
    add_displays = {
        class.new{image = "terrain/granite_wall3.png", z = 18, display_y = -1},
    },
}
```

> `display_y = -1`：圖片向上偏移一格顯示，`display_h = 2` 表示高度佔 2 格。這是 TE4 偽 3D 牆頂的關鍵技法。

---

### 1.3 簡單變體：隨機地板紋路

最基本的「讓地板看起來更豐富」做法是準備多張紋路圖，讓 NicerTiles 隨機選一張：

```lua
newEntity{
    define_as = "GRASS",
    type = "floor", subtype = "grass",
    name  = "grass",
    image = "terrain/grass/grass_main_01.png",
    display = '.', color = colors.LIGHT_GREEN,
    -- NicerTiles 以 nice_tiler.replace 隨機替換為 GRASS_PATCH1 ~ GRASS_PATCH14
    nice_tiler = { method="replace", base={"GRASS_PATCH", 100, 1, 14} },
}
-- 批次產生 14 個變體
for i = 1, 14 do
    newEntity{
        base       = "GRASS",
        define_as  = "GRASS_PATCH"..i,
        image      = ("terrain/grass/grass_main_%02d.png"):format(i),
    }
end
```

`nice_tiler.base` 格式：`{前綴, 出現機率%, 最小編號, 最大編號}`
- `{"GRASS_PATCH", 100, 1, 14}` → 必定替換，從 `GRASS_PATCH1` ~ `GRASS_PATCH14` 隨機選一個

---

### 1.4 `nice_tiler` 方法總覽

NicerTiles 在地圖生成後（`postProcessLevelTiles`）遍歷每個格子，依 `nice_tiler.method` 進行後處理：

| 方法 | 說明 | 典型用途 |
|------|------|---------|
| `"replace"` | 按機率隨機替換為一組變體 | 地板紋路隨機化 |
| `"wall3d"` | 偵測周圍格子，替換為正確的牆壁方向（柱子/北壁/南壁…） | 石牆、地牢牆壁 |
| `"wall3dSus"` | 進階牆壁，偵測對角格子，支援圓角 | 高精細地牢 |
| `"door3d"` | 門的方向偵測（水平門/垂直門） | 門 |
| `"singleWall"` | 單像素牆 | 特殊地形 |
| `"water"` | 水岸過渡（偵測周圍是否為草地/沙地） | 水岸邊緣 |
| `"genericBorders"` | 通用邊框過渡 | 任意兩種地形的邊界 |
| `"mountain3d"` | 山地地形 3D 效果 | 山嶺 |

### 1.5 `wall3d` 方法詳解

`wall3d` 是最常用的方法，它偵測 4 個方向（NSWE），根據鄰居類型選取對應的牆壁 Grid：

```lua
newEntity{
    define_as = "WALL",
    type = "wall", subtype = "cave",
    name  = "wall",
    image = "terrain/cave_wall1.png",
    z     = 3,
    nice_tiler = {
        method       = "wall3d",
        -- 牆壁包圍（內部）
        inner        = {"CAVE_WALL", 100, 1, 5},
        -- 北側有地板（牆頂暴露）
        north        = {"CAVE_WALL_NORTH", 100, 1, 3},
        -- 南側有地板（低邊）
        south        = {"CAVE_WALL_SOUTH", 100, 1, 5},
        -- 北南都有地板（獨立一格牆）
        north_south  = "CAVE_WALL_NORTH_SOUTH",
        -- 獨立小柱子（四邊都是地板）
        small_pillar = "CAVE_WALL_SMALL_PILLAR",
        -- 東西南都有地板（北邊牆）
        pillar_2     = "CAVE_WALL_PILLAR_2",
        -- 其他柱子形狀
        pillar_8     = {"CAVE_WALL_PILLAR_8", 100, 1, 3},
        pillar_4     = "CAVE_WALL_PILLAR_4",
        pillar_6     = "CAVE_WALL_PILLAR_6",
    },
    does_block_move = true,
    block_sight     = true,
    dig             = "CAVE_FLOOR",
}
```

接著定義所有被 `wall3d` 引用的 Grid 變體：
```lua
-- 內部牆（被牆包圍），5 個紋路
for i = 1, 5 do
    newEntity{ base="WALL", define_as="CAVE_WALL"..i,
        image = ("terrain/cave_wall1_%d.png"):format(i), z=3 }
end
-- 北牆（頂部有牆頂蓋）
for i = 1, 3 do
    newEntity{ base="WALL", define_as="CAVE_WALL_NORTH"..i,
        image = ("terrain/cave_wall1_%d.png"):format(i), z=3,
        add_displays = {
            class.new{image="terrain/cave_wall3.png", z=18, display_y=-1},
        },
    }
end
-- 南牆
for i = 1, 5 do
    newEntity{ base="WALL", define_as="CAVE_WALL_SOUTH"..i,
        image = ("terrain/cave_wall2_%d.png"):format(i), z=3 }
end
newEntity{ base="WALL", define_as="CAVE_WALL_NORTH_SOUTH",
    image="terrain/cave_wall2.png", z=3,
    add_displays={class.new{image="terrain/cave_wall3.png",z=18,display_y=-1}}}
-- 其他柱子略...
```

### 1.6 `nice_editer`：不替換只疊加邊框

`nice_editer` 不替換整個格子，而是在現有格子上疊加邊框裝飾（如草地和石地的接縫）：

```lua
local grass_editer = { method="borders_def", def="grass" }

newEntity{
    define_as = "GRASS",
    type = "floor", subtype = "grass",
    ...
    nice_tiler  = { method="replace", base={"GRASS_PATCH", 100, 1, 14} },
    nice_editer = grass_editer,   -- 疊加草地邊框（與其他 subtype 的接縫）
}
```

`borders_def` 使用在 `NicerTiles.lua` 中 `local defs` 表預先定義的邊框規則：
```lua
-- NicerTiles.lua 中的定義（節錄）
defs.grass = {
    method = "borders",
    type   = "grass",
    forbid = {lava=true, rock=true},
    -- 南側有非草地 → 疊加北側草邊
    default8 = {add_mos={{image="terrain/grass/grass_2_%02d.png", display_y=-1}}, min=1, max=2},
    -- 北側有非草地 → 疊加南側草邊
    default2 = {add_mos={{image="terrain/grass/grass_8_%02d.png", display_y=1}},  min=1, max=2},
    ...
}
```

若要新增自訂的 `borders_def`，只需在模組自己的 NicerTiles 繼承類中擴充 `defs` 表。

### 1.7 PNG 檔案規格（地塊）

- 尺寸：**64×64** 像素（TE4 標準格子大小）
- 格式：RGBA（可有透明區域）
- 命名慣例：`terrain/CATEGORY/TILENAME_NN.png`（NN 為 2 位數字補零）
- 牆頂蓋片（`display_y=-1` 用）尺寸可以是 64×64 或更高

---
