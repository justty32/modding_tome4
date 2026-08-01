| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 大地圖 Zone | `zones/wilderness/zone.lua` | `all_remembered`, `all_lited`, `persistent = "zone"` |
| 靜態大地圖 | `maps/wilderness.lua` | `defineTile`, ASCII return, `startx`/`starty` |
| 地點標記地形 | `grids/wilderness.lua` | `change_level` + `change_zone` 欄位 |
| 地牢多層連接 | `grids/dungeon_forest.lua` | `change_level = 1`（相對）/ `change_zone`（絕對） |
| 子地圖返回大地圖 | `grids/town.lua` | `change_level=1, change_zone="wilderness"` |
| 遊戲起始 Zone | `class/Game.lua → newGame()` | `self:changeLevel(1, "wilderness")` |
| 動態解鎖地點 | `Game:unlockWorldLocation()` + `on_enter` pending | `map(x,y,Map.TERRAIN, new_grid)` |

**大地圖的本質**：大地圖和普通地圖的唯一區別，是 `all_remembered`、`all_lited` 和靜態地圖設計三件事的組合。整個 Zone 切換機制（`change_zone` + `change_level`）在大地圖和普通地圖上的工作方式完全一致，這也是 TE4 架構最優雅的地方之一。
