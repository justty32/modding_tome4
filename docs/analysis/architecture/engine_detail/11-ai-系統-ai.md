AI 是命名行為的組合，以字串 key 組合：

```lua
npc.ai = "dumb_talented"     -- 主 AI
npc.ai_state = {talent_in=3} -- AI 狀態參數
```

### simple.lua — 基礎 AI 行為

| AI 名稱 | 說明 |
|---------|------|
| `move_simple` | 直線朝目標移動 |
| `move_dmap` | 目標可見用距離地圖；否則往最後目擊點 |
| `move_astar` / `move_astar_advanced` | A* 尋路（含 Actor 阻擋可選）|
| `move_blocked_astar` | 被阻擋多回合後切換 A* |
| `move_wander` | 隨機相鄰移動 |
| `move_complex` | 整合多策略（A*/距離地圖/漫遊） |
| `flee_simple` / `flee_dmap` | 反向移動 + 障礙迴避 |
| `target_simple` / `target_player` | 目標選取（最近敵人或玩家）|
| `simple` / `dmap` | 合成 AI（目標選取 + 移動）|
| `none` | 空 AI 佔位符 |

### talented.lua — 技能使用 AI

| AI 名稱 | 說明 |
|---------|------|
| `dumb_talented` | 隨機挑可用技能；無戰術評估 |
| `improved_talented` | 嘗試最多 5 個技能 + fallback |
| `dumb_talented_simple` | 目標選取 + N 分之一機率用技能 + 移動 |

`ai_state.talent_in`：使用技能的頻率；`ai_state.no_talents`：技能抑制旗標

### special_movements.lua — 特殊移動

| AI 名稱 | 說明 |
|---------|------|
| `move_ghoul` | 交替移動/暫停（`pause_chance`）|
| `move_snake` | 側滑接近；只在近距離時直線衝鋒 |

---
