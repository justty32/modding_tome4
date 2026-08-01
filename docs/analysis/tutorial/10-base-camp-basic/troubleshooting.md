| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| 每次進入據點都重新生成 | 未設 `persistent = "zone"` | 在 Zone 定義加入 `persistent = "zone"` |
| 靜態地圖字元顯示為空或問號 | `defineTile` 的 `define_as` 找不到 | 確認 `grid_list` 已載入 `camp.lua`；確認 `define_as` 拼字正確 |
| 篝火不觸發治療 | `on_move` 未被呼叫或未分派 | 確認 `mod/class/Grid.lua` 已繼承並 override `on_move`；確認地形有 `camp_heal = true` |
| 篝火每步都觸發 | 冷卻邏輯錯誤 | 確認 `game.level.data[cd_key]` 正確讀寫；`ticks_per_act` = 1000/100 = 10 |
| 工作台 NPC 不出現 | `defineTile` 的 actor 找不到 | 確認 `npc_list` 已載入 `camp_npcs.lua`；確認 `WORKBENCH_NPC` 拼字正確 |
| 碰撞工作台沒有反應 | `on_bump` 未觸發 | 確認 NPC 的 `faction = "players"`；確認 Game 的碰撞邏輯呼叫 `npc:bumpInto(player)` |
| 合成時找不到產品 | 產品不在 `object_list` | 在 Zone 的 `object_list` 中包含含有該物品的清單 |
| 地圖尺寸不符崩潰 | ASCII 行數/列數與 Zone 的 `width`/`height` 不一致 | 數 ASCII 地圖的行列數，更新 Zone 定義的 `width`/`height` |

---
