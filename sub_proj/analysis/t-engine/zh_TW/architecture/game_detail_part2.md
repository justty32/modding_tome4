## 8. game/modules/tome-1.7.6 — Tales of Maj'Eyal

ToME 是引擎上最完整的遊戲實現，作者 Nicolas Casalini（DarkGod），GPL v3 授權。

### 8.1 模組入口

#### init.lua

- 模組元資料：名稱 "Tales of Maj'Eyal"、版本 {1,7,6}、引擎 {1,7,6,"te4"}
- 145+ 載入提示（lore 與玩法提示）
- 40+ 載入背景圖
- 字型套件選擇系統
- Profile 統計欄位：artifacts、characters、deaths、uniques、scores、lore、escorts

#### load.lua

- 載入 `/mod/settings.lua` 設定
- ASCII 模式支援（低端渲染）
- 地圖設定（平滑捲動、陣營危險等級）
- **揹包系統定義**（16 個 slot）：
  - MAINHAND、OFFHAND、PSIONIC_FOCUS
  - BODY、CLOAK、HEAD、HANDS、FEET
  - FINGER（×2）、NECK、LITE、BELT、TOOL、QUIVER
  - GEM、QS_MAINHAND、QS_OFFHAND（快速換組）
- 裝備娃娃定義（視覺裝備預覽）
- 鍵位、Resolver、存檔 MD5 設定

#### settings.lua

| 設定 | 說明 |
|------|------|
| `autosave` | 自動存檔開關 |
| `smooth_move` | 平滑移動等級（0-3）|
| `twitch_move` | 瞬間移動模式 |
| `tile_size` | 圖磚尺寸（48/64 像素）|
| `weather_effects` | 天氣效果 |
| `day_night` | 日夜循環 |
| `smooth_fov` | FOV 平滑 |
| `log_lines` | 訊息列數（5）|

#### resolvers.lua

- `resolveObject(e, filter, do_wear, tries)` — 進階物品生成：
  - 支援預生成物品（`_use_object`）、指定唯一品（`defined`）、自訂清單（`base_list`）
  - 反魔法相容性檢查
  - 最多 5 次重試
  - `autoreq`：強制升級/學技能以符合需求
  - `alter`：生成後修改函數

---

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
