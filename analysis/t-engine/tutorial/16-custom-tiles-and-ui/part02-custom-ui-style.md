### 2.1 UI 主題系統原理

TE4 的所有 UI 元件都繼承自 `engine.ui.Base`，使用 **9-slice** 技術繪製可縮放的框架。

主題名稱（如 `"dark"`、`"metal"`、`"stone"`）決定 PNG 的查找路徑：

```
getUITexture("ui/dialogframe_1.png")
  ├─ 先找 /data/gfx/{ui_name}-ui/dialogframe_1.png
  └─ 找不到就 fallback → /data/gfx/{defaultui}-ui/dialogframe_1.png
```

例如主題為 `"dark"` 時，查找路徑是 `/data/gfx/dark-ui/dialogframe_1.png`。

### 2.2 主題定義檔

主題除了 PNG 外，還需要一個 Lua 配置檔說明框架的邊距和陰影：

```lua
-- 格式：在 ui/definitions/*.lua 中（setfenv 到 ui_conf）
mytheme = {
    frame_shadow = {x=10, y=10, a=0.5},  -- 陰影偏移和透明度（nil=不顯示陰影）
    frame_alpha  = 0.95,                  -- 整體透明度
    frame_ox1    = -42,                   -- 左/上邊外擴距離（像素）
    frame_ox2    =  42,                   -- 右/下邊外擴距離
    frame_oy1    = -42,
    frame_oy2    =  42,
    title_bar    = {x=0, y=-18, w=4, h=25},  -- 標題欄配置（可省略）
}
```

> `frame_ox` 控制框架圖片相對於對話框內容區域的外擴量。`dark` 主題的 42px 對應其華麗的邊框圖。若使用簡單邊框，設小一些（如 2px）。

### 2.3 建立自訂 UI 主題（逐步說明）

**步驟一：建立 PNG 資料夾**

```
mod/data/gfx/mytheme-ui/
    dialogframe_1.png   ← 左下角
    dialogframe_2.png   ← 下邊（水平平鋪）
    dialogframe_3.png   ← 右下角
    dialogframe_4.png   ← 左邊（垂直平鋪）
    dialogframe_5.png   ← 中央（水平+垂直平鋪）
    dialogframe_6.png   ← 右邊（垂直平鋪）
    dialogframe_7.png   ← 左上角
    dialogframe_8.png   ← 上邊（水平平鋪）
    dialogframe_9.png   ← 右上角
    button1.png ~ button9.png        ← 按鈕（9-slice）
    button_sel1.png ~ button_sel9.png ← 按鈕（懸停/選中態）
    [其餘元件，可從 dark-ui 複製後修改]
```

9-slice 角位置圖示（對應數字鍵盤位置）：
```
7 ─ 8 ─ 9
│       │
4   5   6
│       │
1 ─ 2 ─ 3
```

**步驟二：建立主題定義檔**

```lua
-- mod/data/gfx/ui/definitions/mytheme.lua
mytheme = {
    frame_shadow = {x=8, y=8, a=0.4},
    frame_alpha  = 1.0,
    frame_ox1    = -6,
    frame_ox2    =  6,
    frame_oy1    = -6,
    frame_oy2    =  6,
}
```

**步驟三：在遊戲載入時註冊主題**

```lua
-- mod/load.lua（模組入口）
local UIBase = require "engine.ui.Base"

-- 載入主題定義
UIBase:loadUIDefinitions("/data/gfx/ui/definitions/mytheme.lua")

-- 將全域預設 UI 切換為新主題
UIBase:changeDefault("mytheme")
```

### 2.4 只對特定對話框套用自訂主題

不需要全域切換，也可以在建立 Dialog 時指定 `ui` 欄位：

```lua
local d = require("engine.ui.Dialog").new(
    "我的對話框", 400, 300,
    nil, nil,
    "mytheme"    -- 只有這個 dialog 使用自訂主題
)
d:loadUI{
    ...
}
```

或在模組自己的 Dialog 子類中設定預設值：

```lua
module(..., package.seeall, class.inherit(engine.ui.Dialog))

_M.ui = "mytheme"   -- 此類所有對話框都使用 mytheme
```

### 2.5 完整 UI 主題 PNG 清單

以下是 `dark-ui` 主題中完整的 PNG 清單，建立新主題時可以參考（只需提供想修改的，其餘自動 fallback）：

**對話框框架**（9 片）：
```
dialogframe_1.png ~ dialogframe_9.png
title_dialogframe_7.png / _8.png / _9.png  ← 有標題欄時的頂邊變體
```

**按鈕**（各 9 片）：
```
button1.png ~ button9.png           ← 普通態
button_sel1.png ~ button_sel9.png   ← 選中/懸停態
```

**列表選擇器**（各 9 片）：
```
selector1-9.png        ← 普通選擇條
selector-sel1-9.png    ← 選中態
selector-green1-9.png  ← 綠色變體（用於確認類操作）
heading1-9.png         ← 標題行
heading-sel1-9.png     ← 標題行選中態
```

**文字輸入框**（各 9 片 + 游標）：
```
textbox1-9.png
textbox-sel1-9.png
textbox-cursor.png
```

**捲軸**：
```
scrollbar.png / scrollbar-sel.png
scrollbar_top.png / scrollbar_bottom.png
```

**其他**：
```
checkbox.png / checkbox-ok.png
minus.png / plus.png
border_hor_left/middle/right.png
border_vert_top/middle/bottom.png
bar_title_left/middle/right.png
```

**子資料夾**：
```
tooltip/1-9.png + tooltip/frame1-9.png  ← tooltip 框架
icon-frame/frame1-9.png                 ← 技能/物品圖示邊框
waiter/left_basic.png + right_basic.png ← 進度條
```

### 2.6 最小可用主題

若只想替換對話框框架，其餘元件保持預設，只需提供 9 張圖：

```
mod/data/gfx/mytheme-ui/
    dialogframe_1.png ~ dialogframe_9.png
```

定義檔：
```lua
mytheme = {
    frame_shadow = {x=5, y=5, a=0.3},
    frame_alpha  = 0.95,
    frame_ox1    = -8,
    frame_ox2    =  8,
    frame_oy1    = -8,
    frame_oy2    =  8,
}
```

其他元件（按鈕、選擇器等）會自動 fallback 到 `dark-ui/` 的對應 PNG。

---
