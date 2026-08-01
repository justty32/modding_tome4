| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 農作計時器 | `Game:onTurn()` + `camp_state.farms` | `game.turn` 差值；`energy_to_act / energy_per_tick` 轉換 |
| 農田地形三態 | `data/grids/camp.lua` | `farm_interact` 旗標；Grid `on_move` 提示分派 |
| 農田互動（種植/查詢/收穫） | `Game:farmInteract()` + `setupCommands CHANGE_LEVEL` | `map(x,y,Map.TERRAIN, new_grid)` 替換 Grid |
| 建造系統 | `chats/build_manager.lua` + `_applyBuildingToMap()` | `build_tag` 掃描；Grid 替換；`map.changed = true` |
| 建造狀態持久化 | `game.camp_state` + `Game:save()` | `defaultSavedFields{camp_state=true}` |
| 工人 AI | `ai/commanded_ally.lua` + `_cmd_work` | `ai_state.command = {type="work", task="farm"}` |
| 工人加速農作 | `_cmd_work` AI | `farm.turn_planted -= speed_up`（把種植時間往前移） |
| 建造管理員 NPC | `npcs/camp_npcs.lua` + `on_bump` | 與合成工作台相同的 `on_bump` + Chat 模式 |

**三份教學（Tutorial 09 + 10 + 11）的核心主題是狀態管理的三個層次：**

| 層次 | 存放位置 | 生命週期 |
|------|---------|---------|
| 臨時地圖狀態（篝火冷卻） | `game.level.data[key]` | 跟隨 Level，可跨存檔 |
| 跨樓層 / 跨 Zone 進度（建造、農田） | `game.camp_state`（`game:save()` 宣告） | 跟隨整個存檔，永久保留 |
| 地圖 Grid 替換狀態（農田格、設施格） | Zone 的 `persistent = "zone"` + `.teaz` 磁碟檔 | 跟隨 Zone 持久化 |
