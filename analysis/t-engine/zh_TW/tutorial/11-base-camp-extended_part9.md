
## 常見錯誤排查

| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| `camp_state` 存檔後消失 | `save()` 未宣告 `camp_state = true` | 在 `defaultSavedFields{}` 加入 `camp_state = true` |
| 建造後地圖沒有變化 | `build_tag` 不一致或 `grid_list` 找不到目標 Grid | 確認 `BUILD_SITE_FARM.build_tag == "farm"` 且 `FARM_EMPTY` 已在 `grid_list` |
| 農田成熟後 Grid 沒有更新為 FARM_READY | `updateCamp` 中座標解析失敗 | 確認 key 格式 `"x_y"` 與 `farmInteract` 中一致 |
| `updateCamp` 不被呼叫 | `onTurn` 條件判斷失誤或 Zone 名稱不符 | 確認 `game.zone.short_name == "camp"` 正確；確認 `_M:onTurn()` 有呼叫 `self:updateCamp()` |
| 工人不移動到農田 | 農田格不是 `FARM_GROWING`（未種植） | 先種植，地形換為 `FARM_GROWING` 後工人才會找到目標 |
| 建造後重進據點 BUILD_SITE 復原 | `persistent = "zone"` 未設定 | 在 Zone 定義加入，讓 Grid 替換狀態持久化 |
| `commanded_ally` AI 無 work 分支 | `mod/ai/commanded_ally.lua` 未更新 | 確認 `newAI("commanded_ally", ...)` 已加入 `work` 分支和 `_cmd_work` AI |
| 招募的工人不執行工作指令 | `ai_state.command` 未正確設定 | 呼叫 `assignWorkerToFarm(worker)` 後確認 `worker.ai_state.command.type == "work"` |
| 農作進度不保留跨存檔 | `camp_state.farms` 未隨存檔保存 | 同 camp_state 存檔問題；確認 `farms` 字段在 `camp_state` 內 |
| Chat 輔助函式找不到 `_M` | 舊版 chat 使用 `_M.func` | 改用 `local function` 定義輔助函式（Chat 環境沒有 `_M`） |

---

## 進階擴展方向

### 1. 多格農田

`camp_state.farms` 已以 `"x_y"` 為 key 設計，天然支援多格農田同時種植，無需額外修改。只需在地圖上放置更多 `BUILD_SITE_FARM` 格即可。

### 2. 工人自動收穫並重新種植

```lua
-- 在 _cmd_work AI 中，若農田已 ready 自動收穫並重新種植
if farm.ready then
    game:farmInteract(
        game.level.map(tx, ty, Map.TERRAIN),  -- FARM_READY grid
        tx, ty
    )
    -- farmInteract 執行收穫後自動重置為 FARM_EMPTY
    -- 若工人背包有種子，可在此再次呼叫 farmInteract 種植
end
```

### 3. 升級樹（多層建造）

把建造系統擴展為多層升級（基礎農田 → 進階農田 → 溫室），在 chat 的 `cond` 中檢查前一層是否完成：

```lua
cond = function(npc, player)
    local bs = (game.camp_state or {}).buildings or {}
    return bs.farm == true           -- 基礎農田已建造
       and not bs.farm_lv2           -- 進階農田尚未建造
       and countItem(player, "IRON") >= 5
end,
action = function(npc, player)
    build(player, {IRON=5}, "farm_lv2")  -- build_tag = "farm_lv2"
end,
```

### 4. 儲物箱共享存儲

```lua
-- 在 Grid:on_move 的 camp_chest 分支中開啟存儲 Dialog
-- 使用 camp_state.chest_contents = {} 存放共享物品清單
if self.camp_chest and who == game.player then
    -- 開啟自訂 Dialog 讓玩家存放 / 取出物品
    local d = require("mod.dialogs.CampChest").new(game.camp_state)
    game:registerDialog(d)
end
```

---

## 本章小結

| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 農作計時器 | `Game:onTurn()` + `camp_state.farms` | `game.turn` 差值；`energy_to_act / energy_per_tick` 轉換 |
| 農田地形三態 | `data/grids/camp.lua` | `farm_interact` 旗標；Grid `on_move` 提示分派 |
| 農田互動（種植/查詢/收穫） | `Game:farmInteract()` + `setupCommands CHANGE_LEVEL` | `map(x,y,Map.TERRAIN, new_grid)` 替換 Grid |
| 建造系統 | `chats/build_manager.lua` + `_applyBuildingToMap()` | `build_tag` 掃描；Grid 替換；`map.changed = true` |
| 建造狀態持久化 | `game.camp_state` + `Game:save()` | `defaultSavedFields{camp_state=true}` |
| 工人 AI | `ai/commanded_ally.lua` + `_cmd_work` | `ai_state.command = {type="work", task="farm"}` |
| 工人加速農作 | `_cmd_work` AI | `farm.turn_planted -= speed_up`（把種植時間往前移） |
| 建造管理員 NPC | `npcs/camp_npcs.lua` + `on_bump` | 與合成工作臺相同的 `on_bump` + Chat 模式 |

**三份教學（Tutorial 09 + 10 + 11）的核心主題是狀態管理的三個層次：**

| 層次 | 存放位置 | 生命週期 |
|------|---------|---------|
| 臨時地圖狀態（篝火冷卻） | `game.level.data[key]` | 跟隨 Level，可跨存檔 |
| 跨樓層 / 跨 Zone 進度（建造、農田） | `game.camp_state`（`game:save()` 宣告） | 跟隨整個存檔，永久保留 |
| 地圖 Grid 替換狀態（農田格、設施格） | Zone 的 `persistent = "zone"` + `.teaz` 磁碟檔 | 跟隨 Zone 持久化 |
