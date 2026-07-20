打包於 `game/engines/te4-1.7.6.teae`。

### 2.1 核心實體系統
| 類別 | 說明 |
|------|------|
| `Entity.lua` | 所有遊戲物件的基底類別，屬性、define/resolve 系統 |
| `Actor.lua` | 角色/怪物，繼承 Entity |
| `Grid.lua` | 地圖格（terrain tile） |
| `Object.lua` | 物品/裝備 |
| `Trap.lua` | 陷阱 |
| `Projectile.lua` | 投射物 |

### 2.2 世界結構
| 類別 | 說明 |
|------|------|
| `Zone.lua` | 區域（含多層 Level） |
| `Level.lua` | 單一樓層，持有 Map 與 Actor 列表 |
| `Map.lua` | 地圖資料與渲染 |
| `MapEffect.lua` | 地圖上的持續效果（毒霧、火焰…） |
| `World.lua` | 全局世界狀態（跨 Zone 持久資料） |

### 2.3 遊戲迴圈
| 類別 | 說明 |
|------|------|
| `Game.lua` | 基底遊戲類別，主迴圈介面 |
| `GameTurnBased.lua` | 回合制迴圈（energy 耗盡才輪到下一個） |
| `GameEnergyBased.lua` | Energy-based tick 系統（各 Actor 依速度累積 energy） |

### 2.4 介面混入 (Interface Mixins, `engine/interface/`)
Actor 相關：
- `ActorAI.lua` — AI 行為掛勾
- `ActorFOV.lua` — 視野計算
- `ActorInventory.lua` — 揹包管理
- `ActorLevel.lua` — 經驗值/等級
- `ActorLife.lua` — HP、死亡
- `ActorProject.lua` — 投射/施法
- `ActorQuest.lua` — 任務狀態
- `ActorResource.lua` — 資源（魔力、理智…）
- `ActorStats.lua` — 基礎屬性（力量、敏捷…）
- `ActorTalents.lua` — 技能系統（cooldown、使用、學習）
- `ActorTemporaryEffects.lua` — Buff/Debuff 系統

Player 專用：
- `PlayerExplore.lua` — 自動探索
- `PlayerRun.lua` — 自動移動
- `PlayerRest.lua` — 休息/等待
- `PlayerMouse.lua` — 滑鼠點擊移動
- `PlayerHotkeys.lua` — 快捷鍵
- `PlayerDumpJSON.lua` — 匯出角色資料（JSON）
- `PlayerSlide.lua` — 滑行移動

其他：
- `GameMusic.lua` — 音樂控制
- `GameSound.lua` — 音效控制
- `GameTargeting.lua` — 目標選擇系統
- `WorldAchievements.lua` — 成就系統
- `BloodyDeath.lua` — 死亡表現效果

### 2.5 AI 系統 (`engine/ai/`)
- `simple.lua` — 基礎 AI（追擊、攻擊）
- `talented.lua` — 技能使用 AI
- `special_movements.lua` — 特殊移動 AI（繞路、飛行）

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
| `MapScript.lua` | Script 驅動的程序地圖 |
| `GOL.lua` | Game of Life 細胞自動機 |
| `Hexacle.lua` | 六角形佈局 |
| `Octopus.lua` | 章魚形連通圖 |
| `TileSet.lua` | 圖磚集對應 |
| `WaveFunctionCollapse`（via C++ WFC） | 波函數塌縮生成 |

Tilemap（`engine/tilemaps/`）：
- `BSP.lua`, `Maze.lua`, `Heightmap.lua`, `Noise.lua`, `Rooms.lua`, `Static.lua`, `Tilemap.lua`, `WaveFunctionCollapse.lua`, `Proxy.lua`

Actor 生成器（`engine/generator/actor/`）：`Random.lua`, `OnSpots.lua`

演算法（`engine/algorithms/`）：`BSP.lua`（二元空間分割）、`MST.lua`（最小生成樹，用於房間連通）

### 2.7 UI 框架 (`engine/ui/`)
完整的 UI 元件庫（純 Lua 繪製於 OpenGL）：

`Base.lua`（基底）→ `Button`, `ButtonImage`, `Checkbox`, `Dropdown`, `Focusable`, `GenericContainer`, `Image`, `ImageList`, `List`, `ListColumns`, `NumberSlider`, `Numberbox`, `Separator`, `Slider`, `Tab`, `Tabs`, `Textbox`, `Textzone`, `TextzoneList`, `TreeList`, `UIContainer`, `UIGroup`, `VariableList`, `Waitbar`, `Waiter`, `WebView` ...

還有 `Dialog.lua`（視窗基底）、`SubDialog.lua`、`WithTitle.lua`、`Gestures.lua`（觸控）、`EquipDoll.lua`（裝備展示）、`EntityDisplay.lua`、`SurfaceZone.lua`。

### 2.8 預建對話框 (`engine/dialogs/`)
| 對話框 | 功能 |
|--------|------|
| `GameMenu.lua` | 主選單/暫停選單 |
| `ShowInventory.lua` / `ShowEquipment.lua` / `ShowEquipInven.lua` | 物品/裝備管理 |
| `ShowPickupFloor.lua` | 地板撿取 |
| `ShowStore.lua` | 商店界面 |
| `ShowQuests.lua` | 任務列表 |
| `ShowLog.lua` | 訊息記錄 |
| `ShowAchievements.lua` | 成就 |
| `ViewHighScores.lua` | 排行榜 |
| `UseTalents.lua` | 技能使用 |
| `KeyBinder.lua` | 按鍵設定 |
| `VideoOptions.lua` / `AudioOptions.lua` | 影音設定 |
| `DisplayResolution.lua` | 解析度設定 |
| `LanguageSelect.lua` | 語言選擇 |
| `Downloader.lua` | 更新/下載器 |
| `Chat.lua` / `ChatChannels.lua` / `ChatFilter.lua` / `ChatIgnores.lua` | 在線聊天 |
| `GetText.lua` / `GetQuantity.lua` / `Talkbox.lua` | 輸入對話 |
| `UserInfo.lua` | 用戶資料 |

### 2.9 其他核心系統
| 模組 | 說明 |
|------|------|
| `class.lua` | 物件導向基礎（OOP，多重繼承 mixin） |
| `resolvers.lua` | 實體屬性解析器（隨機、範圍、表格查詢） |
| `utils.lua` | 全局工具函數 |
| `colors.lua` | 顏色常數與解析 |
| `KeyBind.lua` / `Key.lua` / `KeyCommand.lua` | 鍵盤輸入與綁定系統 |
| `Mouse.lua` | 滑鼠事件 |
| `Savefile.lua` / `SavefilePipe.lua` | 存檔（Lua serialization + zlib） |
| `Tiles.lua` | 圖磚載入、快取、動畫 |
| `Shader.lua` | Lua 端 shader 封裝 |
| `Particles.lua` / `ParticlesCallback.lua` | 粒子特效系統 |
| `FlyingText.lua` | 飄字效果（傷害數字等） |
| `DamageType.lua` | 傷害類型定義與處理 |
| `Target.lua` | 目標選擇（射程、形狀） |
| `Quest.lua` | 任務系統 |
| `Faction.lua` | 陣營/聲望系統 |
| `Store.lua` | 商店系統 |
| `Chat.lua` | NPC 對話腳本系統 |
| `HighScores.lua` | 本地高分榜 |
| `PlayerProfile.lua` | 在線玩家 profile（te4.org） |
| `NameGenerator.lua` / `NameGenerator2.lua` | 程序名稱生成（音節/文法） |
| `Birther.lua` | 角色創建嚮導 |
| `Autolevel.lua` | NPC 自動升級 |
| `Calendar.lua` | 遊戲內日曆/時間 |
| `Emote.lua` | 角色表情 |
| `Generator.lua` | 生成器基底類別 |
| `I18N.lua` | 國際化/在地化 |
| `Quadratic.lua` | 二次曲線工具 |
| `Heightmap.lua` | 高度圖工具 |
| `Astar.lua` | A* 路徑尋路 |
| `DirectPath.lua` | 直線路徑 |
| `MicroTxn.lua` | 微交易（Steam DLC） |
| `Module.lua` | 模組載入/管理 |
| `CharacterBallSave.lua` / `CharacterVaultSave.lua` | 角色存檔（雲端） |
| `LogDisplay.lua` / `LogFlasher.lua` | 訊息日誌顯示 |
| `HotkeysDisplay.lua` / `HotkeysIconsDisplay.lua` | 快捷鍵 HUD |
| `ActorsSeenDisplay.lua` | 視野內敵人顯示 |
| `Tooltip.lua` | 提示框 |
| `UserChat.lua` | 在線聊天後端 |
| `DebugConsole.lua` | 開發者除錯控制台 |
| `FontPackage.lua` | 字型打包管理 |
| `BootErrorHandler.lua` | 啟動錯誤處理 |
| `webcore.lua` | WebView 本地請求解析 |
| `version.lua` | 版本資訊 |

---
