## 2. mod/dialogs/ — 對話框系統

共 **44+ 對話框檔案**，實現所有玩家互動介面。

### 2.1 核心遊戲對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `Birther.lua` | 72KB | 角色創建畫面（出生選擇流程）|
| `CharacterSheet.lua` | 97KB | 角色資訊/裝備全覽頁面 |
| `LevelupDialog.lua` | 48KB | 升級技能選擇 |
| `GameOptions.lua` | 48KB | 遊戲設定選單 |
| `DeathDialog.lua` | 14KB | 死亡畫面與重生選項 |

### 2.2 物品管理對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `ShowEquipInven.lua` | 13KB | 裝備 + 背包合併檢視 |
| `ShowEquipment.lua` | 3.4KB | 純裝備欄位 |
| `ShowInventory.lua` | 4.4KB | 純背包內容 |
| `ShowPickupFloor.lua` | 2.4KB | 地板物品拾取 |
| `ShowStore.lua` | 10KB | 商店買賣介面 |
| `UseItemDialog.lua` | 9.5KB | 使用物品確認 |
| `SwiftHands.lua` | 5.6KB | 快速換裝介面 |
| `SwiftHandsUse.lua` | 4.3KB | 快速使用消耗品 |
| `SentientWeapon.lua` | 9.4KB | 有靈性武器互動 |

### 2.3 技能相關對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `UseTalents.lua` | 18KB | 技能使用選單 |
| `UberTalent.lua` | 11KB | 偉業技能特殊互動 |

**talents/ 子目錄**（具時間魔法技能的特殊 UI）：
- `Contingency.lua`、`Empower.lua`、`Extension.lua`、`Matrix.lua`、`Quicken.lua`
- `MagicalCombatArcaneCombat.lua`

### 2.4 資訊顯示對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `ShowMap.lua` | 3.9KB | 世界地圖 |
| `ShowLore.lua` | 4.3KB | 史料書/圖鑑 |
| `ShowIngredients.lua` | 2.9KB | 工藝材料庫存 |
| `ShowChatLog.lua` | 11KB | 訊息歷史記錄 |
| `ShowAchievements.lua` | 3.4KB | 成就列表 |
| `LorePopup.lua` | 4KB | 新史料彈出提示 |
| `QuestPopup.lua` | 4.5KB | 任務通知 |

### 2.5 隊伍管理對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `PartyOrder.lua` | 3.3KB | 隊伍命令（攻擊/防守等）|
| `PartySelect.lua` | 2.1KB | 選擇隊伍成員 |
| `PartySendItem.lua` | 3.1KB | 物品傳給隊友 |
| `PartyRewardSelector.lua` | 1.9KB | 戰利品分配選擇 |

### 2.6 特殊系統對話框

| 檔案 | 大小 | 功能 |
|------|------|------|
| `Chat.lua` | 7.7KB | NPC 對話系統（選項樹狀）|
| `MapMenu.lua` | 11KB | 地圖互動選單（右鍵）|
| `GraphicMode.lua` | 5.7KB | 圖形設定頁 |
| `OptionTree.lua` | 6.4KB | 階層式選項選單 |
| `ArenaFinish.lua` | 2.2KB | 競技場結算 |
| `Donation.lua` | 5.2KB | 永久死亡角色捐贈 |
| `UnlockDialog.lua` | 1.7KB | 解鎖成就通知 |
| `WandererSeed.lua` | 6.9KB | 流浪者模式種子設定 |

### 2.7 外觀系統（shimmer/ 子目錄）

Shimmer 是 ToME 的外觀自訂系統（贊助功能）：

| 檔案 | 說明 |
|------|------|
| `Shimmer.lua` | 外觀系統基礎 |
| `ShimmerOutfits.lua` | 服裝/外觀配色選擇 |
| `ShimmerOther.lua` | 其他外觀選項 |
| `ShimmerRemoveSustains.lua` | 移除持續效果（外觀相關）|
| `ShimmerDemo.lua` | 外觀預覽功能 |
| `CommonData.lua` | 共用外觀資料 |

### 2.8 隨從命令（orders/ 子目錄）

| 檔案 | 說明 |
|------|------|
| `Behavior.lua` | 設定隨從 AI 行為策略 |
| `Talents.lua` | 設定隨從使用哪些技能 |

### 2.9 UI 元件（elements/ 子目錄）

| 檔案 | 說明 |
|------|------|
| `ChatPortrait.lua` | NPC 對話肖像顯示 |
| `StatusBox.lua` | 狀態指示器小部件 |
| `TalentGrid.lua` | 技能格子顯示（升級/選擇）|
| `TalentTrees.lua` | 技能樹排版系統 |

### 2.10 除錯工具（dialogs/debug/ 子目錄）

共 **14 個除錯工具**，`cheat_only=true` 限制：

| 檔案 | 大小 | 功能 |
|------|------|------|
| `AdvanceActor.lua` | 15KB | 測試 Actor 升級 |
| `AdvanceZones.lua` | 11KB | 跳過地區進度 |
| `RandomActor.lua` | 14KB | 生成隨機 NPC |
| `RandomObject.lua` | 29KB（最大）| 生成隨機物品 |
| `CreateItem.lua` | 14KB | 指定生成物品 |
| `Endgamify.lua` | 10KB | 模擬終局內容 |
| `DebugMain.lua` | 7.5KB | 除錯主選單 |
| `PlotTalent.lua` | 5.6KB | 技能測試 |
| `SummonCreature.lua` | 6KB | 召喚生物 |
| `AlterFaction.lua` | 3KB | 調整陣營關係 |
| `ChangeZone.lua` | 3KB | 傳送至指定地區 |
| `CreateTrap.lua` | 3.4KB | 放置陷阱 |
| `GrantQuest.lua` | 3KB | 啟動任務 |
| `SpawnEvent.lua` | 3KB | 觸發世界事件 |
| `ReloadZone.lua` | 1.4KB | 重新載入地區 |
