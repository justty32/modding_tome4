### 目標選擇類

| AI 名稱 | 說明 |
|---------|------|
| `target_simple` | 找最近的敵人，90% 機率保持當前目標 |
| `target_closest` | 永遠鎖定最近的敵人（不保持當前目標）|
| `target_player` | 永遠以玩家為目標 |
| `target_player_radius` | 在 `ai_state.sense_radius` 格內攻擊玩家 |

**ToME 覆蓋版**（`mod/ai/target.lua`）的 `target_simple` 額外支援：
- 夜視（`infravision`）/ 增強感知（`heightened_senses`）
- 無敵目標跳過（`invulnerable`）
- 死亡召喚物轉攻擊召喚者

### 移動類

| AI 名稱 | 說明 | 特點 |
|---------|------|------|
| `move_simple` | 向目標最後已知位置直線移動 | 最快，但容易卡牆 |
| `move_dmap` | 使用 Dijkstra Map 找路 | 需要目標生成距離地圖 |
| `move_astar` | A* 尋路 | 最可靠，但計算量大 |
| `move_wander` | 隨機遊蕩 | 無目標時用 |
| `flee_simple` | 向相反方向逃跑 | 方向計算簡單 |
| `flee_dmap` | Dijkstra 逃跑 | 更可靠的逃跑 |
| `move_complex` | 智能複合移動 | A*/dmap/wander 按情況切換 |

### 技能使用類

| AI 名稱 | 說明 |
|---------|------|
| `dumb_talented` | 隨機使用一個可用技能（不智能）|
| `improved_talented` | 改良版：最多嘗試 5 次不同技能 |
| `dumb_talented_simple` | 目標選擇 + 1/N 機率用技能 + 移動（最常用基礎 AI）|
| `use_tactical` | 戰術評分系統（舊版）|
| `use_improved_tactical` | **戰術評分系統（新版，ToME 主要 NPC 使用）**|

### 複合頂層 AI

| AI 名稱 | 說明 |
|---------|------|
| `simple` | `target_simple` + `move_simple` |
| `dmap` | `target_simple` + `move_dmap` |
| `dumb_talented_simple` | target + 技能（1/N 機率）+ 移動 |
| `improved_tactical` | target + 技能（戰術評分）+ 移動（完整版）|

---
