# 教學 16：地塊貼圖與自訂 UI 風格（續）

### 2.5 完整 UI 主題 PNG 清單

未提供者自動 fallback 到 `dark-ui/`：

**對話框框架**（9 片 + 標題列變體）：
```
dialogframe_{1-9}.png
title_dialogframe_7.png / _8.png / _9.png  ← 有標題欄時頂邊變體
```

**按鈕**（各 9 片）：
```
button{1-9}.png           ← 普通態
button_sel{1-9}.png       ← 懸停態
```

**列表選擇器**（各 9 片）：
```
selector{1-9}.png / selector-sel{1-9}.png / selector-green{1-9}.png
heading{1-9}.png / heading-sel{1-9}.png
```

**文字輸入框**（各 9 片 + 游標）：
```
textbox{1-9}.png / textbox-sel{1-9}.png / textbox-cursor.png
```

**捲軸**：`scrollbar.png` / `scrollbar-sel.png` / `scrollbar_top.png` / `scrollbar_bottom.png`

**其他**：`checkbox.png` / `checkbox-ok.png` / `minus.png` / `plus.png` / `border_hor_*` / `border_vert_*` / `bar_title_*`

**子資料夾**：`tooltip/{1-9}.png + frame{1-9}.png` / `icon-frame/frame{1-9}.png` / `waiter/`

### 2.6 最小可用主題

只替換框架，其餘預設：

```
mod/data/gfx/mytheme-ui/
    dialogframe_1.png ~ dialogframe_9.png   ← 只需 9 張
```

定義檔：`frame_shadow={x=5,y=5,a=0.3}`, `frame_alpha=0.95`, `frame_ox#` 視邊框設 6~12。

---

## 第三部分：完整範例

### 3.1 洞穴主題地塊

```lua
-- 地板（14 種隨機紋路）
newEntity{ define_as="CAVE_FLOOR", type="floor", subtype="cave",
    name="cave floor", image="terrain/cave/floor_01.png",
    display='.', color=colors.GREY,
    nice_tiler={method="replace", base={"CAVE_FLOOR", 100, 1, 14}} }
for i=1,14 do
    newEntity{ base="CAVE_FLOOR", define_as="CAVE_FLOOR"..i,
        image=("terrain/cave/floor_%02d.png"):format(i) }
end

-- 牆壁（wall3d）
newEntity{ define_as="CAVE_WALL", type="wall", subtype="cave",
    name="cave wall", image="terrain/cave/wall1_01.png",
    display='#', color=colors.GREY, z=3,
    nice_tiler={method="wall3d",
        inner={"CAVE_WALL_INNER",100,1,5},
        north={"CAVE_WALL_NORTH",100,1,3},
        south={"CAVE_WALL_SOUTH",100,1,5},
        north_south="CAVE_WALL_NS",
        small_pillar="CAVE_WALL_PILLAR_SMALL",
        pillar_2="CAVE_WALL_PILLAR_2",
        pillar_8={"CAVE_WALL_PILLAR_8",100,1,3},
        pillar_4="CAVE_WALL_PILLAR_4",
        pillar_6="CAVE_WALL_PILLAR_6",
    }, does_block_move=true, block_sight=true,
    always_remember=true, dig="CAVE_FLOOR" }

-- 內部牆
for i=1,5 do newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_INNER"..i,
    z=3, image=("terrain/cave/wall1_%02d.png"):format(i) } end
-- 北牆（牆蓋）
local wall_top=class.new{image="terrain/cave/wall3.png",z=18,display_y=-1}
for i=1,3 do newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_NORTH"..i,
    z=3, image=("terrain/cave/wall1_%02d.png"):format(i), add_displays={wall_top} } end
-- 南牆
for i=1,5 do newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_SOUTH"..i,
    z=3, image=("terrain/cave/wall2_%02d.png"):format(i) } end
-- NS 牆
newEntity{ base="CAVE_WALL", define_as="CAVE_WALL_NS", z=3,
    image="terrain/cave/wall2.png", add_displays={wall_top} }

-- 樓梯
newEntity{ define_as="CAVE_STAIRS_DOWN", type="floor", subtype="cave",
    name="stairs down", image="terrain/cave/floor_01.png",
    add_mos={{image="terrain/dungeon_stairs_down.png"}},
    display='>', color=colors.YELLOW, notice=true, change_level=1 }
```

### 3.2 羊皮紙主題 UI

```lua
-- mod/data/gfx/ui/definitions/parchment_custom.lua
parchment_custom = {
    frame_shadow={x=6,y=6,a=0.35}, frame_alpha=1.0,
    frame_ox1=-12, frame_ox2=12, frame_oy1=-12, frame_oy2=12,
}
```

```
mod/data/gfx/parchment_custom-ui/dialogframe_{1-9}.png
```

```lua
-- mod/load.lua
UIBase:loadUIDefinitions("/data/gfx/ui/definitions/parchment_custom.lua")
UIBase:changeDefault("parchment_custom")
```

---

## 總結

**地塊貼圖**
- `image` → `/data/gfx/` 相對路徑 PNG
- `add_mos` → 同 z 層疊加
- `add_displays` → 不同 z 層子實體（牆頂蓋 z=18, display_y=-1）
- `nice_tiler{method="replace", base={...}}` → 隨機紋路
- `nice_tiler{method="wall3d", ...}` → 自動牆壁方向

**UI 主題**
- PNG 放 `/data/gfx/THEMENAME-ui/`
- 定義檔設定 `frame_ox`、`frame_shadow`
- `UIBase:loadUIDefinitions(file)` → `UIBase:changeDefault("name")`
- `Dialog.new(title,w,h,nil,nil,"theme")` → 單一 Dialog 套用
- 缺少的 PNG 自動 fallback 到 `dark-ui/`