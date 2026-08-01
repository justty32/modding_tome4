### 8.2 核心類別 (mod/class/)

#### Game.lua — 主遊戲控制器

**繼承**：`engine.GameTurnBased + GameMusic + GameSound + GameTargeting`

| 欄位 | 說明 |
|------|------|
| `visited_zones` | 已探索地區 |
| `calendar` | 遊戲內日曆（122 天/年、167 天/月）|
| `tooltip`, `tooltip2` | 提示框管理 |
| `flyers` | 飄字傷害顯示 |
| `bignews` | 成就/事件通知 |
| `nicer_tiles` | 增強圖磚渲染 |

ToME 特有：Hook 系統（`"ToME:run"`, `"ToME:runDone"`）、動態視窗標題、Shader gamma 校正

#### GameState.lua — 遊戲會話狀態

**繼承**：`engine.Entity + mod.class.interface.WorldAchievements`

跨關卡/地區的持久狀態管理：

| 欄位 | 說明 |
|------|------|
| `world_artifacts_pool` | 尚未生成的任務神器 |
| `unique_death` | 已擊殺的唯一怪 |
| `boss_killed` | Boss 擊殺計數 |
| `stores_restock` | 商店補貨計數器 |
| `birth` | 角色出生描述符資料 |

關鍵方法：`generateRandart(data)`（隨機神器生成）、`createRandomBossNew(base, data)`（隨機精英 Boss 生成）、`entityFilter()`/`entityFilterPost()`（戰利品過濾）、`dayNightCycle()`（日夜循環）

#### Actor.lua — 所有活體實體基底（318KB）

**繼承**（15+ 介面混入）：
```
engine.Actor
engine.interface.ActorInventory
engine.interface.ActorTemporaryEffects
mod.class.interface.ActorLife
engine.interface.ActorProject
engine.interface.ActorLevel
engine.interface.ActorStats
engine.interface.ActorTalents
engine.interface.ActorResource
engine.interface.BloodyDeath
engine.interface.ActorFOV
mod.class.interface.ActorAI
mod.class.interface.ActorPartyQuest
mod.class.interface.ActorInscriptions
mod.class.interface.ActorObjectUse
mod.class.interface.Combat
mod.class.interface.Archery
```

**11 種資源池**（部分）：

| 資源 | 說明 |
|------|------|
| mana | 魔法施法 |
| stamina | 體力（物理技能）|
| vim | 惡魔/Reaver |
| equilibrium | 自然平衡（反轉值）|
| paradox | 時間悖論（反轉值）|
| positive/negative | 善/惡能量 |
| hate | 狂暴者怒氣 |
| psi | 心靈能量 |
| soul | 靈魂（上限 10，不自動回復）|
| air | 呼吸空氣 |

**三層戰鬥系統**：

| 層級 | 屬性 |
|------|------|
| 物理 | `combat_atk`, `combat_dam`, `combat_physcrit`, `combat_physspeed` |
| 法術 | `combat_spellcrit`, `combat_spellspeed` |
| 心靈 | `combat_mindcrit`, `combat_mindspeed` |

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

---

