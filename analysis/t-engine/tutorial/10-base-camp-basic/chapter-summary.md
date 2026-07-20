| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| Zone 持久化 | Zone 定義 `persistent = "zone"` | `leaveLevel()` 寫 `memory_levels`；`Zone:save()` 寫磁碟 |
| 靜態地圖 | `data/maps/camp.lua` | `defineTile`, `startx`/`starty`, ASCII return |
| 地形行為（旗標模式） | `data/grids/camp.lua` + `class/Grid.lua` | 實體定義旗標；Grid class `on_move` 分派 |
| 臨時狀態存儲 | `game.level.data[key]` | 跟隨 Level 序列化，持久且安全 |
| 合成工作台 | `npcs/camp_npcs.lua` + `chats/workbench.lua` | `on_bump` 觸發 Chat；local 輔助函式操作物品 |
| 區域切換 | `grids/camp.lua` + `grids/wilderness.lua` | `change_level` + `change_zone`；`CHANGE_LEVEL` 鍵觸發 |
