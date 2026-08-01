| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 自訂 AI | `mod/ai/commanded_ally.lua` | `newAI(name, fn)` / `self:runAI(name)` |
| AI 狀態儲存 | `self.ai_state.command` | Lua 表，自動序列化 |
| AI 組合 | `commanded_ally` 呼叫 `dumb_talented_simple`, `flee_simple` | `self:runAI(sub_ai)` |
| 下達指令的介面 | `ActorCommand` mixin | `ally.ai_state.command = {...}` |
| 指令 UI | `CommandMenu` Dialog | `Dialog`, `List`, `game:registerDialog` |
| 傭兵模板 | `mercenaries.lua` | `define_as`, `resolvers.equip` |
| 從模板生成 NPC | Chat action | `zone:makeEntityByName(level, "actor", name)` |
| 放置到地圖 | Chat action | `zone:addEntity(level, e, "actor", x, y)` |
| 加入隊伍 | Chat action | `party:addMember(actor, {control="no", keep_between_levels=true})` |
| 友敵判斷 | 傭兵模板 | `faction = "players"` |

兩個系統的核心思路相同：**用 `ai_state` 作為玩家與 AI 之間的通訊橋樑**。玩家寫入指令，AI 在每回合讀取並執行——這個模式可以延伸到任何需要玩家控制 NPC 行為的場景。
