# 教學 16：地塊貼圖與自訂 UI 風格

## 第一部分：地圖地塊（Grid）貼圖

### 1.1 基本 Grid 顯示欄位

```lua
newEntity{
    define_as="FLOOR", type="floor", subtype="floor", name="floor",
    image="terrain/marble_floor.png",  -- 相對 /data/gfx/
    display='.', color_r=255, color_g=255, color_b=255,
    back_color=colors.DARK_GREY,       -- ASCII fallback
    z=1,                               -- Z 層級：1=地板，3=牆壁，18=牆頂蓋
}
```

### 1.2 多層貼圖：`add_mos` vs `add_displays`

| 欄位 | 用途 | 渲染 |
|------|------|------|
| `add_mos` | 同一 z 層疊加多張圖片 | 同一批次 |
| `add_displays` | 各自獨立 z/image 的虛擬實體 | 分別入渲染佇列 |

```lua
-- add_mos：地板疊加出口標記
newEntity{ define_as="STAIRS_DOWN", type="floor", name="stairs down",
    image="terrain/marble_floor.png",
    add_mos={{image="terrain/dungeon_stairs_down.png"}}, notice=true, change_level=1 }

-- add_displays：牆壁 + 頂部蓋片（偽 3D）
newEntity{ define_as="WALL_NORTH", base="WALL",
    image="terrain/granite_wall1_1.png", z=3,
    add_displays={class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}} }
```

> `display_y=-1`：向上偏移一格；`display_h=2` 佔 2 格高度。偽 3D 牆頂關鍵技法。

### 1.3 簡單隨機地板紋路

```lua
newEntity{ define_as="GRASS", type="floor", subtype="grass", name="grass",
    image="terrain/grass/grass_main_01.png", display='.', color=colors.LIGHT_GREEN,
    nice_tiler={method="replace", base={"GRASS_PATCH", 100, 1, 14}} }
for i = 1, 14 do
    newEntity{ base="GRASS", define_as="GRASS_PATCH"..i,
        image=("terrain/grass/grass_main_%02d.png"):format(i) }
end
```

`nice_tiler.base` 格式：`{前綴, 機率%, 最小編號, 最大編號}`。

---

## 1.4 `nice_tiler` 方法總覽

NicerTiles 在地圖生成後（`postProcessLevelTiles`）遍歷每個格子後處理：

| 方法 | 說明 | 用途 |
|------|------|------|
| `"replace"` | 機率替換為變體 | 地板隨機化 |
| `"wall3d"` | 偵測鄰格替換為正確牆方向 | 石牆、地牢 |
| `"wall3dSus"` | 進階牆壁，支援對角線與圓角 | 高精細地牢 |
| `"door3d"` | 門方向偵測 | 門 |
| `"singleWall"` | 單像素牆 | 特殊地形 |
| `"water"` | 水岸過渡 | 水岸邊緣 |
| `"genericBorders"` | 任意兩地形邊界 | 通用邊框 |
| `"mountain3d"` | 山地 3D 效果 | 山嶺 |

### 1.5 `wall3d` 詳解

偵測 4 方向（NSWE），依鄰居類型選取對應 Grid：

```lua
newEntity{ define_as="WALL", type="wall", subtype="cave", name="wall",
    image="terrain/cave_wall1.png", z=3,
    nice_tiler={
        method="wall3d",
        inner={"CAVE_WALL", 100, 1, 5},        -- 牆包圍（內部）
        north={"CAVE_WALL_NORTH", 100, 1, 3},   -- 北側有地板
        south={"CAVE_WALL_SOUTH", 100, 1, 5},   -- 南側有地板
        north_south="CAVE_WALL_NS",             -- 北南都有地板
        small_pillar="CAVE_WALL_SMALL_PILLAR",  -- 四邊地板（柱子）
        pillar_2="CAVE_WALL_PILLAR_2",
        pillar_8={"CAVE_WALL_PILLAR_8", 100, 1, 3},
        pillar_4="CAVE_WALL_PILLAR_4",
        pillar_6="CAVE_WALL_PILLAR_6",
    },
    does_block_move=true, block_sight=true, dig="CAVE_FLOOR" }
```

然後定義所有被引用的 Grid 變體（循環產生對應紋路編號的圖片）。

---（續 part2）---