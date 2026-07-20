### 8.4 AI 系統 (mod/ai/)

ToME 的 AI 比引擎基礎 AI 複雜得多，以下是所有 AI 腳本：

| 檔案 | AI 名稱 | 說明 |
|------|---------|------|
| `target.lua` | `target_simple`, `target_player_radius`, `target_closest` | 含 Lite/夜視的目標選取 |
| `improved_tactical.lua` | `improved_tactical` | 三步戰術評分系統（最先進 AI）|
| `improved_talented.lua` | `improved_talented_simple` | 技能使用 + 維護 + 移動 |
| `tactical.lua` | `use_tactical` | 傳統戰術決策系統 |
| `escort.lua` | `escort_quest`, `move_escort` | 護送任務 NPC（隨機停頓、逃跑）|
| `heal.lua` | `target_heal`, `dumb_heal`, `dumb_heal_simple` | 支援/治療 NPC |
| `maintenance.lua` | `maintenance` | 非戰鬥資源維護 |
| `party.lua` | `party_member`, `move_anchor` | 隊伍成員（含 leash 距離）|
| `quests.lua` | `move_quest_limmir` | 任務特定 NPC 行為 |
| `summon.lua` | `summoned`, `mirror_image` | 召喚物和鏡像複製體 |
| `shadow.lua` | `shadow` | 影子隨從（相位門、盲襲、防牆）|
| `sandworm_tunneler.lua` | `sandworm_tunneler`, `sandworm_tunneler_huge` | 沙蟲挖掘地形機制 |
| `worldnpcs.lua` | `world_patrol`, `world_hostile` | 世界地圖 NPC 巡邏/追擊 |
| `special_movements.lua` | `move_safe_grid`, `flee_dmap_keep_los` | 危險迴避移動 |

**戰術 AI 配置**（`improved_tactical`）：
- Actor 透過 `ai_tactic` table 設定各戰術的乘數
- `self_compassion`（預設 5）：自傷技能懲罰係數
- `ally_compassion`（預設 1）：友傷技能懲罰係數
- `AI_TACTICAL_RANDOM_RANGE`（預設 0.5）：隨機化範圍
- 技能需宣告 `tactical` table 指定涵蓋的戰術及其效果量

---

