| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| TreeList 顯示空白 | `buildTree()` 沒有任何 known 分類 | 確認 actor 的 `talents_types_def` 已填充；確認有分類設定了 `known = true` |
| 學習後等級沒有更新 | `buildTree()` + `setList()` 沒有重建 | 確認 `doLearn()` 末尾有呼叫 `self.c_tree:setList(self.tree)` |
| `canLearnTalent` 始終返回 false | 玩家沒有 `unused_talents` 點數 | 在 `newGame()` 中給玩家初始點數：`player.unused_talents = 3` |
| 按鈕點擊沒有反應 | `game.mouse` 尚未初始化時呼叫 `_setupSkillButton` | 把 `_setupSkillButton` 移到 `Game:setupMouse()` 完成後，或在 UISet `activate()` 中延遲呼叫 |
| `toScreenFull` 參數數量錯誤 | TE4 glTexture 的 `toScreenFull` 參數需精確 | 呼叫格式：`tex:toScreenFull(x, y, w, h, tex_w, tex_h)` （基礎版，不帶顏色） |
| Dialog 的 `loadUI` 佈局錯亂 | `right=0` / `bottom=0` 相對的是 `iw`/`ih`（內容區），不是 `w`/`h` | 確認 `Dialog.init` 已呼叫；確認 `iw`/`ih` 在 `loadUI` 時已正確設定 |
| 舊 `UseTalents` 被覆蓋消失 | 誤刪了 `USE_TALENTS` 鍵綁定 | 在 `setupCommands` 中同時保留 `USE_TALENTS` 和 `SHOW_SKILL_TREE` 兩個綁定 |

---
