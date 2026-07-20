| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| 遊戲開始時黑畫面或進入錯誤 Zone | `newGame()` 的 `changeLevel(1, "wilderness")` 失敗 | 確認 `wilderness/zone.lua` 存在且路徑正確；確認 `mod/load.lua` 已載入所有 Zone |
| 大地圖字元全部顯示為空 | `defineTile` 的 Grid 找不到 | 確認 `grid_list` 載入了 `wilderness.lua`；確認 `define_as` 拼字一致 |
| 站在地點標記按 `>` 沒有反應 | `change_zone` 欄位錯誤，或 Zone 路徑找不到 | 確認 `change_zone` 的值與 `Zone.new("short_name", ...)` 的第一個參數一致 |
| 返回大地圖後玩家位置不對 | 引擎預設行為（無問題），或 `on_enter` 覆蓋有誤 | 移除 `on_enter` 中的手動 `move()`，先讓引擎預設處理 |
| 地牢最底層無法返回大地圖 | `change_level = -1` 在第 1 層計算為 0 層，引擎行為未定義 | 用 `on_enter` 動態把第 1 層的向上樓梯改為 `change_zone = "wilderness"` |
| 每次進入城鎮都重新生成（NPC 消失） | 城鎮 Zone 未設 `persistent = "zone"` | 在城鎮 Zone 加入 `persistent = "zone"` |
| 地圖寬高與 ASCII 不符造成崩潰 | Zone 的 `width`/`height` 與 ASCII 地圖實際行列數不一致 | 數 ASCII 地圖的列數（每行字元數）= `width`；行數 = `height` |
| 動態解鎖的地點重進大地圖後消失 | `pending_world_unlocks` 套用後未存檔，或 `persistent = "zone"` 未設定 | 確認大地圖 `persistent = "zone"`；確認 `pending_world_unlocks` 有在 `Game:save()` 的 `defaultSavedFields` 中宣告 |

---
