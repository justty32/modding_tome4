# 教學 10：據點系統基礎版

## 本章目標

建立一個玩家可反覆進出、**狀態完整持久化**的野外據點（Base Camp）。據點由手工設計的靜態地圖構成，包含：

- **篝火**：踩上後自動恢復 HP（有冷卻，用旗標驅動）
- **合成工作台**：透過 NPC 對話合成物品（消耗材料 → 產出產品）
- **出口**：傳送回大地圖（Wilderness）

玩家在大地圖找到據點入口進入後，可使用各設施；離開後再回來，地圖狀態完整保留（NPC 位置、已消耗物品等不重置）。

---

## 系統核心概念

### `persistent = "zone"` 如何運作

TE4 的 Zone 有四種持久化模式：

| 值 | 行為 |
|----|------|
| `false`（預設） | 離開即重新生成，不保留任何狀態 |
| `"memory"` | 存在 `game.memory_levels` 中，存檔後消失 |
| `"zone"` | 整個 Zone 以 `.teaz` 檔儲存，下次進入從檔案載入 |
| `true` | 每一層都獨立存檔 |

據點使用 `"zone"`：Zone 離開時把每一層的 Level 物件存入 `self.memory_levels[level_num]`，並在 Zone 存檔時寫入磁碟。下次 `zone:getLevel()` 時優先從 `memory_levels` 取出，而不是重新生成。

**結果**：你在據點放下的箱子、NPC 的當前狀態，下次進入都還在。

### Static Map 產生器

靜態地圖由一個 Lua 檔描述。產生器讀取這個檔案並把 ASCII 字元對映到具體的 Grid / NPC / Object 實體：

```lua
defineTile(char, grid_define_as, object_define_as, actor_define_as, trap_define_as)
-- 後三個參數可傳 nil 表示「不放置」
return [[
  ASCII地圖字串
]]
```

### 旗標驅動行為 vs. 函式欄位

TE4 的序列化系統**無法序列化匿名函式**。如果在 `newEntity{}` 裡直接寫 `on_move = function(...) end`，存檔重載後這個函式將遺失。

正確模式：
- **資料放在實體欄位**（`camp_heal = true`）
- **行為放在有名稱的類別方法**（`Grid:on_move()` 根據旗標分派）

---

## 完整檔案結構

```
mygame/
  mod/
    class/
      Grid.lua                          ← 覆寫 on_move，根據旗標分派行為
    data/
      grids/
        camp.lua                        ← 據點專用地形（篝火、出口、門…）
      npcs/
        camp_npcs.lua                   ← 工作台 NPC 定義
      chats/
        workbench.lua                   ← 工作台對話（含合成邏輯）
      zones/
        camp/
          zone.lua                      ← 據點 Zone 定義
      maps/
        camp.lua                        ← 靜態地圖（ASCII）
```
