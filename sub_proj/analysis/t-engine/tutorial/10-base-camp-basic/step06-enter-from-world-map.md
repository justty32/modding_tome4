### 大地圖上的「據點入口」地形

在大地圖（Wilderness）的地形列表中加入一個特殊地形，玩家站上後按 `>` 即可進入：

```lua
-- mod/data/grids/wilderness.lua（在現有檔案中追加）
newEntity{
    define_as = "CAMP_ENTRANCE",
    name = "野外據點入口",
    display = 'C', color_r=0, color_g=255, color_b=150,
    back_color = colors.DARK_GREY,
    notice          = true,
    always_remember = true,

    -- 按下 CHANGE_LEVEL 鍵（預設 >）時：切換到 "camp" Zone 的第 1 層
    change_level = 1,
    change_zone  = "camp",
}
```

在大地圖靜態地圖中用字元 `C` 放置這個格子即可。

### Zone 進入後的玩家位置

`changeLevel` 結束後，玩家的初始位置由 Level 的 `default_up` / `default_down` 決定。Static 地圖產生器會自動把 `startx`/`starty` 設定為 `level.default_up`：

```lua
-- Static 產生器內部邏輯（引擎已實作）
level.default_up   = {x = startx, y = starty}
level.default_down = {x = startx, y = starty}
```

因此在 `camp.lua` 中設定 `startx = 12, starty = 17`（出口附近），進入據點時玩家就會出現在那裡。

---
