## 二、Lua 引擎層 (`engine/*.lua`)

打包於 `game/engines/te4-1.7.6.teae`。

### 2.1 核心實體系統
| 類別 | 說明 |
|------|------|
| `Entity.lua` | 所有遊戲物件的基底類別，屬性 define/resolve 系統 |
| `Actor.lua` | 角色/怪物，繼承 Entity |
| `Grid.lua` | 地圖格 (terrain tile) |
| `Object.lua` | 物品/裝備 |
| `Trap.lua` | 陷阱 |
| `Projectile.lua` | 投射物 |

### 2.2 世界結構
| 類別 | 說明 |
|------|------|
| `Zone.lua` | 區域 (含多層 Level) |
| `Level.lua` | 單一樓層，持有 Map 與 Actor 列表 |
| `Map.lua` | 地圖資料與渲染 |
| `MapEffect.lua` | 地圖持續效果 (毒霧、火焰…) |
| `World.lua` | 全局世界狀態 (跨 Zone 持久資料) |

### 2.3 遊戲迴圈
| 類別 | 說明 |
|------|------|
| `Game.lua` | 基底遊戲類別，主迴圈介面 |
| `GameTurnBased.lua` | 回合制迴圈 (energy 耗盡才輪換) |
| `GameEnergyBased.lua` | Energy-based tick 系統 (各 Actor 依速度累積 energy) |

### 2.4 介面混入 (Interface Mixins, `engine/interface/`)

**Actor 相關：**
- `ActorAI.lua` — AI 行為掛勾
- `ActorFOV.lua` — 視野計算
- `ActorInventory.lua` — 揹包管理
- `ActorLevel.lua` — 經驗值/等級
- `ActorLife.lua` — HP、死亡
- `ActorProject.lua` — 投射/施法
- `ActorQuest.lua` — 任務狀態
- `ActorResource.lua` — 資源 (魔力、理智…)
- `ActorStats.lua` — 基礎屬性 (力量、敏捷…)
- `ActorTalents.lua` — 技能系統 (cooldown、使用、學習)
- `ActorTemporaryEffects.lua` — Buff/Debuff 系統

**Player 專用：**
- `PlayerExplore.lua` — 自動探索
- `PlayerRun.lua` — 自動移動
- `PlayerRest.lua` — 休息/等待
- `PlayerMouse.lua` — 滑鼠點擊移動
- `PlayerHotkeys.lua` — 快捷鍵
- `PlayerDumpJSON.lua` — 匯出角色資料 (JSON)
- `PlayerSlide.lua` — 滑行移動

**其他：**
- `GameMusic.lua` — 音樂控制
- `GameSound.lua` — 音效控制
- `GameTargeting.lua` — 目標選擇系統
- `WorldAchievements.lua` — 成就系統
- `BloodyDeath.lua` — 死亡表現效果

### 2.5 AI 系統 (`engine/ai/`)
- `simple.lua` — 基礎 AI (追擊、攻擊)
- `talented.lua` — 技能使用 AI
- `special_movements.lua` — 特殊移動 AI (繞路、飛行)

### 2.6 程序地圖生成 (`engine/generator/map/`)
| 生成器 | 說明 |
|--------|------|
| `Roomer.lua` / `Rooms.lua` / `RoomsLoader.lua` | 房間式地牢 |
| `Cavern.lua` / `CavernousTunnel.lua` | 洞窟 |
| `Maze.lua` | 迷宮 |
| `Forest.lua` | 森林 |
| `Heightmap.lua` | 高度圖地形 |
| `Building.lua` | 建築 |
| `Town.lua` | 城鎮 |
| `Static.lua` | 手工靜態地圖 |
| `MapScript.lua` | Script 驅動程序地圖 |
| `GOL.lua` | Game of Life 細胞自動機 |
| `Hexacle.lua` | 六角形佈局 |
| `Octopus.lua` | 章魚形連通圖 |
| `TileSet.lua` | 圖磚集對應 |
| `WaveFunctionCollapse` (via C++ WFC) | 波函數塌縮生成 |

Tilemap (`engine/tilemaps/`)：
- `BSP.lua`, `Maze.lua`, `Heightmap.lua`, `Noise.lua`, `Rooms.lua`, `Static.lua`, `Tilemap.lua`, `WaveFunctionCollapse.lua`, `Proxy.lua`

Actor 生成器 (`engine/generator/actor/`)：`Random.lua`, `OnSpots.lua`

演算法 (`engine/algorithms/`)：`BSP.lua` (二元空間分割)、`MST.lua` (最小生成樹，房間連通用)
