#### Player.lua — 玩家角色

**繼承**：`mod.class.Actor + PlayerRest/Run/Hotkeys/Mouse/Slide + PlayerStats/DumpJSON/Explore/QuestPopup + PartyDeath`

| 欄位 | 說明 |
|------|------|
| `descriptor` | 出生描述符（種族/職業/世界）|
| `died_times` | 各死因死亡次數 |
| `puuid` | 角色 UUID（在線同步）|
| `damage_log`, `damage_intake_log` | 戰鬥統計 |

特有功能：
- 出生後 callback 系統（`registerOnBirth`）
- UUID 跨存檔追蹤
- JSON 角色卡匯出
- 新學技能自動分配快捷鍵
- 三頁快捷鍵列 + 教學系統

#### NPC.lua — AI 控制實體

**繼承**：`mod.class.Actor`

**關鍵特性**：

| 機制 | 說明 |
|------|------|
| `seen_by(who)` | 目標傳遞：含 FOV/距離/時間驗證，防止 chain aggro 濫用 |
| `checkAngered(src, set, value)` | 陣營反應修改（-200 到 200 範圍）|
| `reaction_actor` | 每個 Actor 的個別關係追蹤 |
| `summon_time` | 召喚物倒計時（歸零則消失）|
| `shove_pressure` | 推擠動量計數器 |
| `automaticTalents()` | 戰鬥狀態感知的自動技能系統 |
| `rank` | NPC 等級（2=普通、3=稀有、3.5+=Boss）|

NPC 死亡：rank 4+ 掉落 Rod of Recall；觸發成就；陣營反應降低

#### World.lua — 世界管理器

**繼承**：`engine.World + mod.class.interface.WorldAchievements`

- `unlocked_shimmers`：外觀解鎖（Shimmer 裝甲/武器顏色）
- `gainAchievement(id, src)`：依難度前綴（`EXPLORATION_`、`NORMAL_ROGUELIKE_`、`NIGHTMARE_`…）

#### Zone.lua — 地區生成器

**繼承**：`engine.Zone`

- `_object_special_ego_rules`：可堆疊 ego 屬性（`special_on_hit` 等）
- `onLoadZoneFile(basedir)`：載入地區特有事件（events.lua）
- `doQuake(rad, x, y, check)`：地震地形重排
- `adjustComputeRaritiesLevel()`：高等級物品生成機率縮放

#### Object.lua — 物品/裝備

**繼承**：`engine.Object + ObjectActivable + ObjectIdentify + ActorTalents`

- `moddable_tile` 系列欄位：外觀自訂（神器自動生成 tile 名）
- `getRequirementDesc()`：含反魔法相容性的需求描述
- 特殊 ego 觸發：`special_on_hit`、`talent_on_*`、`on_block` 等清單追加

#### Grid.lua — 地形

**繼承**：`engine.Grid`

| 欄位 | 說明 |
|------|------|
| `door_opened` | 開門後替換的 Grid |
| `door_player_check` | 開門前顯示的對話框 |
| `change_zone` | 傳送目標地區（樓梯）|
| `air_level`, `air_condition` | 呼吸需求 |

`block_move()` 處理：門的開啟對話框、穿透能力、空氣需求檢查、地形變更事件觸發

#### Party.lua — 隊伍管理

**繼承**：`engine.Entity + PartyIngredients + PartyLore`

- `members`：Actor → 成員定義映射
- `addMember(actor, def)`：通知所有成員（`callbackOnPartyAdd`）、轉換為 PartyMember 類別、建立 leash AI 狀態
- `switchParty(new_party)`：特殊地區的多隊伍切換

#### PartyMember.lua — 隨從

**繼承**：`mod.class.NPC + PartyDeath + PlayerHotkeys + PlayerQuestPopup`

- AI 切換為 `"party_member"`，備份原始 AI 型別
- `tactic_leash`/`tactic_leash_anchor`：限制隨從活動範圍

#### Store.lua — 商店

**繼承**：`engine.Store`

- 按補貨計數器（非玩家等級）提升基礎等級
- 材料等級每 10 玩家等級縮放一次（1-5 階）
- 寶石 40% 收購價，其他 5%
- `allowStockObject(e)`：過濾任務物品與 cost=0 物品

#### WildernessGrid.lua — 未探索地區入口指示器

**繼承**：`mod.class.Grid`

- `defineDisplayCallback()`：在未訪問地區入口附加 `entrance_glow` 粒子效果
