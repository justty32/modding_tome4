### 8.6 地區 (data/zones/)

共 89 個地區，依用途分組：

**新手地區（Tier 1，等級 1-7）**
- Abashed Expanse（太空蟲洞）、Deep Bellow、Blighted Ruins、Heart of the Gloom、Murgol Lair（水下）、Norgos Lair、Tutorial

**前期地城（等級 7-25）**
- Daikara（火山/一般）、Old Forest（晶質/一般）、The Maze、Paradox Plane（零重力）、Lake of Nur、Last Hope Graveyard、Ruined Halfling Complex

**中期地城（等級 25-45）**
- Ardhungol、Dark Crypt（任務關鍵）、Illusory Castle（TileSet）、Briagh's Lair、Ancient Elven Ruins

**後期地城（等級 35-80）**
- Gorbat/Grushnak/Rak'shor Pride（沙漠/地下/骨頭美術風格）、Orc Breeding Pits、High Peak（10 層）

**特殊/劇情地區**
- Charred Scar（550 回合計時任務）、Eidolon Plane（零重力死亡復活）、Demon Plane（熔岩惡魔）、Dreams/Dreamscape

**城鎮/樞紐**
- Derth、Last Hope（196×80 靜態地圖）、Angolwen、Zigur、Iron Council、Gates of Morning

**特殊玩法**
- The Arena（波次戰鬥/排行榜）、Infinite Dungeon（max_level=1,000,000,000）

**使用的地圖生成器**：Roomer（最常用）、Cavern、Forest、Static、TileSet、Maze、Octopus、MapScript、GOL、Empty

**特殊地區設定**：
- 替代佈局（多次遊玩變體）：火山/一般、崩塌/一般、晶質/一般
- `tier1=true`：控制初始任務進程
- `underwater=true`：水下環境
- `zero_gravity=true`：零重力移動

---

## 9. game/addons/ — Addon 系統

### 系統架構

每個 addon 使用三種整合機制：

| 機制 | 路徑 | 說明 |
|------|------|------|
| `hooks/` | `hooks/*.lua` | 在特定遊戲事件執行程式碼（非侵入式）|
| `superload/` | `superload/mod/class/*.lua` | 覆蓋基礎模組類別（深度修改）|
| `overload/` | `overload/engine/*.lua` | 替換引擎程式碼 |
| `data/` | `data/` | 新增內容檔案 |

**常用 Hook 點**：`ToME:run`、`ToME:load`、`ToME:runDone`、`Entity:loadList`、`MapGenerator*:subgenRegister`、`DonationDialog:features`、`DebugMain:*`

---

### tome-addon-dev（開發工具）

**版本**：1.7.4｜**類型**：開發工具

- FSHelper：檔案系統操作輔助
- Luafish 整合：偵錯/IDE 支援
- Hook：`ToME:run` 初始化 FSHelper

---

### tome-items-vault（道具保管庫）

**版本**：1.7.6｜**類型**：跨角色物品交易（贊助功能）

- Hook：`MapGeneratorStatic:subgenRegister`（地圖中加入保管庫房間）
- Hook：`DonationDialog:features`（在贊助對話框顯示功能）
- Hook：`ToME:PlayerDumpJSON`（JSON 匯出含保管庫資料）
- 核心類別：`mod.class.ItemsVaultDLC`

---

### tome-possessors（附身者 DLC 職業）

**版本**：1.7.4｜**類型**：付費 DLC（`dlc=5`）

- 新增「Possessor」職業：可附身敵人身體，繼承其能力/屬性同時保留玩家技能
- Hook：`ToME:load` → `PossessorsDLC.hookLoad`
- 核心類別：`mod.class.PossessorsDLC`
- 包含技能、物品、地圖覆蓋資料

---

### tome-remote-designer（遠端設計器）

**版本**：1.0.0｜**類型**：開發工具（`cheat_only=true`）

- 遊戲執行中透過網頁瀏覽器即時設計/修改實體
- Hook：`ToME:runDone` 啟動設計器（若設定啟用）
- Hook：`DebugMain:generate` 加入「Remote Designer」到除錯選單
- 核心類別：`mod.class.RemoteDesigner`

---

## 總結：game/ 目錄架構關係圖

```
game/
├── loader/           ← 引擎啟動（JIT、安全、Addon superload）
├── profile-thread/   ← 非同步在線服務（TCP、認證、聊天）
├── thirdparty/       ← 第三方庫（網路、解析、加密、動畫等）
├── engines/
│   └── te4-1.7.6/
│       ├── engine/   ← 引擎核心 Lua（→ 見 engine_detail.md）
│       └── data/     ← 引擎靜態資產（圖形、字型、著色器、音效）
├── modules/
│   ├── boot/         ← 主選單（即時制 + 全音訊）
│   ├── example/      ← 回合制模板（教學用）
│   ├── example_realtime/ ← 即時制模板（教學用）
│   └── tome-1.7.6/   ← Tales of Maj'Eyal（完整遊戲）
│       ├── mod/
│       │   ├── class/         ← 核心類別（Game/Actor/Player/NPC/Party…）
│       │   ├── class/interface/ ← ToME 專用混入（Combat/Archery/ActorAI…）
│       │   ├── ai/            ← 14 個 AI 腳本（戰術/護送/影子/沙蟲…）
│       │   ├── init.lua       ← 元資料 + 145 載入提示
│       │   ├── load.lua       ← 系統初始化 + 16 槽揹包定義
│       │   ├── settings.lua   ← 使用者設定預設值
│       │   └── resolvers.lua  ← 進階物品生成
│       └── data/
│           ├── birth/         ← 職業/種族/世界 + 難度設定
│           ├── talents/       ← 13 類 200+ 技能檔案
│           ├── zones/         ← 89 個地區定義
│           ├── general/       ← 通用實體（NPC/物品/地形/商店/陷阱）
│           ├── damage_types.lua ← 40+ 傷害類型
│           ├── resources.lua  ← 11 種資源池
│           └── factions.lua   ← 25+ 個陣營
└── addons/
    ├── tome-addon-dev      ← 開發工具（FSHelper）
    ├── tome-items-vault    ← 跨角色保管庫（贊助功能）
    ├── tome-possessors     ← 附身者職業（付費 DLC）
    └── tome-remote-designer ← 即時實體設計器（開發工具）
```
