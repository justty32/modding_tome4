# 教學 12：自訂大地圖（World Map）

## 本章目標

建立一個完整的自訂世界——一張玩家可自由走動的**大地圖**，地圖上散佈著可進入的地點：

- **起點村莊**：玩家出生的城鎮
- **野外據點**：Tutorial 10/11 的 Base Camp
- **森林地牢**：有多層的隨機地牢
- **山區要塞**：特殊 Boss 地牢
- **海邊港口**：另一個城鎮

玩家在大地圖上移動到地點標記後按 `>` 進入，子地圖內有出口可返回大地圖，且記得上次在大地圖上的位置。

---

## 系統核心概念

### 大地圖只是一個特殊的 Zone

TE4 沒有「World Map 系統」這個獨立概念——大地圖就是一個設定了特殊屬性的普通 Zone：

| 屬性 | 說明 |
|------|------|
| `all_remembered = true` | 所有格子從一開始就顯示在小地圖上 |
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

## 完整檔案結構

```
mygame/
  mod/
    class/
      Game.lua                      ← 修改 newGame() 起始於大地圖
    data/
      grids/
        wilderness.lua              ← 大地圖地形（草地、森林、山、水、路、地點標記）
      zones/
        wilderness/
          zone.lua                  ← 大地圖 Zone 定義
        town_a/
          zone.lua                  ← 起點村莊 Zone
        town_b/
          zone.lua                  ← 海邊港口 Zone
        dungeon_forest/
          zone.lua                  ← 森林地牢 Zone
        dungeon_fortress/
          zone.lua                  ← 山區要塞 Zone
      maps/
        wilderness.lua              ← 大地圖靜態 ASCII（50×30）
        town_a.lua                  ← 起點村莊靜態地圖
```
