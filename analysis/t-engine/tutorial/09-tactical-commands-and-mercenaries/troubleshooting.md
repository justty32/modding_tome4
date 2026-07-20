| 錯誤現象 | 可能原因 | 解法 |
|---------|---------|------|
| `[runAI] UNDEFINED AI "commanded_ally"` | `mod/ai/` 未被載入 | 在 `Game:load()` 中呼叫 `self.player_class:loadDefinition("/mod/ai/")` |
| 傭兵招募後不移動 | `ai = "none"` 設在傭兵身上 | 確認傭兵模板的 `ai = "commanded_ally"` |
| `makeEntityByName` 回傳 nil | 傭兵模板未加入 zone.npc_list | 在 Zone 定義的 `npc_list` 中包含 `mercenaries.lua` |
| 傭兵攻擊玩家 | faction 設定錯誤 | 傭兵模板中設 `faction = "players"` |
| 指令對話框無法開啟 | `ActorCommand` mixin 未繼承 | 在 Player.lua 的 `class.inherit(...)` 中加入 `ActorCommand` |
| 切換樓層後傭兵消失 | `keep_between_levels` 未設為 true | 在 `addMember` 的 def 表格中設 `keep_between_levels = true` |
| 傭兵在 standby 時凍結（能量不消耗） | 沒有呼叫 `useEnergy()` | 在 `_cmd_standby` AI 中確認有 `self:useEnergy()` |
| 攻擊指令無效（目標死後繼續攻擊 nil） | 沒有清除 dead 目標 | `commanded_ally` AI 中 `if not cmd.target or cmd.target.dead then` 清除指令 |

---
