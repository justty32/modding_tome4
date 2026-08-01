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
