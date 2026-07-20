### 2.7 UI 框架 (`engine/ui/`)

純 Lua OpenGL 繪製的完整 UI 元件庫：

`Base.lua` (基底) → `Button`, `ButtonImage`, `Checkbox`, `Dropdown`, `Focusable`, `GenericContainer`, `Image`, `ImageList`, `List`, `ListColumns`, `NumberSlider`, `Numberbox`, `Separator`, `Slider`, `Tab`, `Tabs`, `Textbox`, `Textzone`, `TextzoneList`, `TreeList`, `UIContainer`, `UIGroup`, `VariableList`, `Waitbar`, `Waiter`, `WebView`…

另含 `Dialog.lua` (視窗基底), `SubDialog.lua`, `WithTitle.lua`, `Gestures.lua` (觸控), `EquipDoll.lua` (裝備展示), `EntityDisplay.lua`, `SurfaceZone.lua`。

### 2.8 預建對話框 (`engine/dialogs/`)
| 對話框 | 功能 |
|--------|------|
| `GameMenu.lua` | 主選單/暫停 |
| `ShowInventory.lua` / `ShowEquipment.lua` / `ShowEquipInven.lua` | 物品/裝備管理 |
| `ShowPickupFloor.lua` | 地板撿取 |
| `ShowStore.lua` | 商店介面 |
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
| `class.lua` | OOP 基底 (多重繼承 mixin) |
| `resolvers.lua` | 實體屬性解析器 (隨機、範圍、表格查詢) |
| `utils.lua` | 全域工具函數 |
| `colors.lua` | 顏色常數與解析 |
| `KeyBind.lua` / `Key.lua` / `KeyCommand.lua` | 鍵盤輸入與綁定 |
| `Mouse.lua` | 滑鼠事件 |
| `Savefile.lua` / `SavefilePipe.lua` | 存檔 (Lua serialization + zlib) |
| `Tiles.lua` | 圖磚載入、快取、動畫 |
| `Shader.lua` | Lua 端 shader 封裝 |
| `Particles.lua` / `ParticlesCallback.lua` | 粒子特效 |
| `FlyingText.lua` | 飄字效果 (傷害數字等) |
| `DamageType.lua` | 傷害類型定義與處理 |
| `Target.lua` | 目標選擇 (射程、形狀) |
| `Quest.lua` | 任務系統 |
| `Faction.lua` | 陣營/聲望 |
| `Store.lua` | 商店系統 |
| `Chat.lua` | NPC 對話腳本系統 |
| `HighScores.lua` | 本地高分榜 |
| `PlayerProfile.lua` | 在線 profile (te4.org) |
| `NameGenerator.lua` / `NameGenerator2.lua` | 程序名稱生成 (音節/文法) |
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
| `MicroTxn.lua` | 微交易 (Steam DLC) |
| `Module.lua` | 模組載入/管理 |
| `CharacterBallSave.lua` / `CharacterVaultSave.lua` | 角色存檔 (雲端) |
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

## 三、模組系統 (`game/modules/`)

每個模組為獨立遊戲，以 `.team` 壓縮包發佈：
- `tome-1.7.6.team` — Tales of Maj'Eyal (主遊戲)
- `boot-te4-1.7.6-nomusic.team` — 啟動/選單模組
- `example/`, `example_realtime/` — 範例模組

模組透過繼承 `engine.*` 類別並覆寫方法實作遊戲規則，引擎不強制任何具體規則。

## 四、資料層 (`data/`)
- `data/gfx/` — 圖像資源
- `data/font/` — 字型
- `data/sound/` — 音效
- `data/keybinds/` — 預設按鍵設定
- `data/locales/` — 在地化字串

## 五、建構系統

使用 **Premake4** (`premake4.lua`) 產生 Makefile/VS 專案：
- `build/te4core.lua` — 核心 C 程式建構規則
- `build/runner.lua` — Runner 工具
- `build/options.lua` — 編譯選項 (lua 版本、web 後端、steam、32bit 等)

支援平台：Linux、Windows (含交叉編譯)、macOS (`mac/`).

## 六、關鍵設計決策

1. **C/Lua 雙層**：效能瓶頸 (FOV、地圖繪製、粒子) 在 C，遊戲邏輯全在 Lua，方便模組擴充。
2. **Mixin 架構**：`engine/interface/` 功能以 mixin 混入，Actor 只需繼承所需介面，保持彈性。
3. **PhysFS 虛擬 FS**：所有資源透過虛擬路徑存取，引擎無需知道資源在磁碟還是 zip 內。
4. **Resolvers 系統**：實體屬性 define 時可用函數/表格描述，resolve 時才實際計算 (支援隨機化、條件判斷)。
5. **模組獨立性**：遊戲模組與引擎完全分離，可發佈多個不同遊戲共用同一引擎。
