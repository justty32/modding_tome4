# 教學 16：地塊貼圖與自訂 UI 風格（續）

### 1.6 `nice_editer`：不替換只疊加邊框

```lua
local grass_editer = {method="borders_def", def="grass"}

newEntity{ define_as="GRASS", type="floor", subtype="grass",
    nice_tiler={method="replace", base={"GRASS_PATCH", 100, 1, 14}},
    nice_editer=grass_editer,  -- 疊加草地邊框
}
```

`borders_def` 使用 NicerTiles.lua 中 `defs` 表預定義的邊框規則。自訂邊框只需在模組 NicerTiles 繼承類中擴充 `defs`。

### 1.7 PNG 規格（地塊）

- 尺寸：**64×64** 像素（標準格子大小）
- 格式：RGBA
- 命名：`terrain/CATEGORY/TILENAME_NN.png`（NN 為 2 位數字補零）
- 牆頂蓋片（`display_y=-1`）可 64×64 或更高

---

## 第二部分：自訂 UI 風格

### 2.1 UI 主題系統

所有 UI 元件繼承自 `engine.ui.Base`，使用 **9-slice** 繪製可縮放框架：

```
getUITexture("ui/dialogframe_1.png")
  ├─ 先找 /data/gfx/{ui_name}-ui/dialogframe_1.png
  └─ 找不到 → /data/gfx/{defaultui}-ui/dialogframe_1.png
```

### 2.2 主題定義檔

```lua
-- ui/definitions/*.lua 中（setfenv 到 ui_conf）
mytheme = {
    frame_shadow = {x=10, y=10, a=0.5},  -- 陰影偏移與透明度（nil=不顯示）
    frame_alpha  = 0.95,                  -- 整體透明度
    frame_ox1    = -42,                   -- 左/上外擴
    frame_ox2    =  42,                   -- 右/下外擴
    frame_oy1    = -42,
    frame_oy2    =  42,
    title_bar    = {x=0, y=-18, w=4, h=25},
}
```

> `frame_ox` 控制框架圖片相對內容區域的外擴。`dark` 主題 42px 對應華麗邊框圖；簡單邊框設小（如 2px）。

### 2.3 建立自訂 UI 主題

**步驟一：PNG 資料夾**

```
mod/data/gfx/mytheme-ui/
    dialogframe_1.png ~ dialogframe_9.png  ← 9-slice 框架
    button1.png ~ button9.png              ← 按鈕（普通態）
    button_sel1.png ~ button_sel9.png      ← 按鈕（懸停態）
    [其餘元件可從 dark-ui 複製]
```

9-slice 編號對應數字鍵盤：
```
7 ─ 8 ─ 9
│       │
4   5   6
│       │
1 ─ 2 ─ 3
```

**步驟二：定義檔**

```lua
-- mod/data/gfx/ui/definitions/mytheme.lua
mytheme = {
    frame_shadow={x=8, y=8, a=0.4}, frame_alpha=1.0,
    frame_ox1=-6, frame_ox2=6, frame_oy1=-6, frame_oy2=6,
}
```

**步驟三：註冊主題**

```lua
-- mod/load.lua
local UIBase = require "engine.ui.Base"
UIBase:loadUIDefinitions("/data/gfx/ui/definitions/mytheme.lua")
UIBase:changeDefault("mytheme")
```

### 2.4 特定 Dialog 使用自訂主題

```lua
-- Dialog.new(title, w, h, nil, nil, "mytheme")
-- 或子類設定預設值：
_M.ui = "mytheme"   -- 此類所有對話框使用 mytheme
```

---（續 part3）---