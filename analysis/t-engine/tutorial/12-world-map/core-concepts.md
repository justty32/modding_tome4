### 大地圖只是一個特殊的 Zone

TE4 沒有「World Map 系統」這個獨立概念——大地圖就是一個設定了特殊屬性的普通 Zone：

| 屬性 | 說明 |
|------|------|
| `all_remembered = true` | 所有格子從一開始就顯示在 minimap 上 |
| `all_lited = true` | 不需要光源，整張地圖都可見 |
| `persistent = "zone"` | 離開後保留玩家走過的路、踩過的地形狀態 |
| 靜態地圖 | 手工設計（ASCII），不隨機生成 |

### 地點進入機制（`change_zone` + `change_level`）

大地圖上的「地點標記」是普通地形 Grid，但帶有兩個特殊欄位：

```lua
change_level = 1,           -- 進入目標 Zone 的第幾層
change_zone  = "town_a",    -- 目標 Zone 的 short_name
```

引擎的 `CHANGE_LEVEL` 按鍵（預設 `>`）掃描玩家所站的地形，若發現這兩個欄位就呼叫 `game:changeLevel()`。

### 返回大地圖

子地圖（城鎮、地牢）的出口地形也是同樣機制，只是 `change_zone = "wilderness"`：

```lua
-- 子地圖出口
change_level = 1,
change_zone  = "wilderness",
-- 玩家返回大地圖時，會出現在進入時所在的座標（由 level.last_exit 記錄）
```

### 玩家返回位置的記錄

`game:changeLevel(lev, zone_name)` 內部會把**離開時的座標**存入新 Zone 的 Level 資料中，讓玩家從子地圖返回時出現在正確位置，而不是重回 `startx`/`starty`。

---
