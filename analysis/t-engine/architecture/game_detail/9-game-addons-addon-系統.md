### 系統架構

每個 addon 使用三種整合機制：

| 機制 | 路徑 | 說明 |
|------|------|------|
| `hooks/` | `hooks/*.lua` | 在特定遊戲事件執行代碼（非侵入式）|
| `superload/` | `superload/mod/class/*.lua` | 覆蓋基礎模組類別（深度修改）|
| `overload/` | `overload/engine/*.lua` | 替換引擎代碼 |
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
