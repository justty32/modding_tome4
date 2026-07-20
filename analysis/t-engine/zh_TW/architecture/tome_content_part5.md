## 5. mod/class/generator/ — 自訂生成器

ToME 在引擎標準生成器之上，實作了許多特化生成器。

### 5.1 Actor 生成器 (generator/actor/)

| 檔案 | 大小 | 說明 |
|------|------|------|
| `Arena.lua` | 25KB | 競技場 NPC 生成（波次系統）|
| `Random.lua` | 2.6KB | 隨機 Actor 覆蓋（ToME 特定規則）|
| `OnSpots.lua` | 2.6KB | 在指定位置生成 NPC |
| `RandomStairGuard.lua` | 1.9KB | 在樓梯旁生成守衛 |
| `CharredScar.lua` | 1.8KB | 焦土峽谷特有 NPC |
| `Sandworm.lua` | 2KB | 沙蟲遭遇生成 |
| `ValleyMoon.lua` | 3.5KB | 月之谷遭遇 |
| `HighPeakFinal.lua` | 1.9KB | High Peak 最終 Boss 生成 |

**Arena.lua — 波次系統核心**：
- 按波次（Wave）定義不同難度的 NPC 組合
- 支援隨機選擇池（weighted random）
- 每波清除後自動生成下一波
- 記錄最高波次到排行榜

### 5.2 Map 生成器 (generator/map/)

| 檔案 | 大小 | 說明 |
|------|------|------|
| `StaticPredrawn.lua` | 25KB | 預繪製地圖載入器（最大）|
| `VaultLevel.lua` | 5KB | 寶庫關卡生成 |
| `GenericTunnel.lua` | 2.4KB | 通用隧道生成 |
| `SlimeTunnels.lua` | 2.6KB | 黏液隧道（視覺特化）|
| `CharredScar.lua` | 2KB | 焦土峽谷地圖 |
| `Caldera.lua` | 3.7KB | 火山口地圖生成 |

**StaticPredrawn.lua — 預繪製地圖系統**：

```lua
-- zone 定義中使用
generator = {
    map = {
        class = "mod.class.generator.map.StaticPredrawn",
        maps = {
            "city/last-hope-1",
            "city/last-hope-2",
        },
    },
}
```

功能：
- 載入 `.lua` 靜態地圖文件（字元碼 → 實體）
- 支援 `subgen` 子生成器（在靜態地圖特定位置嵌入程序生成內容）
- 解析地圖標記（`@` = 玩家起始、`<` = 向上樓梯等）
- 支援多地圖替代版本（replayability）

---

## 6. mod/class/uiset/ — UI 主題系統

ToME 支援可切換的 UI 佈局主題（UISet）。

### 6.1 檔案結構

| 檔案 | 大小 | 說明 |
|------|------|------|
| `UISet.lua` | 1.7KB | UISet 基礎類別 |
| `Classic.lua` | 22KB | 傳統 UI 佈局 |
| `ClassicPlayerDisplay.lua` | 22KB | 傳統玩家資訊面板 |
| `Minimalist.lua` | 105KB（最大）| 極簡 UI 主題 |

### 6.2 UISet 架構

**UISet.lua** — 基礎介面：
- `UISet:init()` — 初始化 UI 元素
- `UISet:display()` — 每幀繪製回呼
- `UISet:resize(w, h)` — 視窗大小改變時重排
- `UISet:getTargetDisplay(actor)` — 取得目標資訊顯示格式

### 6.3 Classic UI（傳統佈局）

**Classic.lua** — 主佈局：
- 底部：訊息 log（1-5 行，可設定）
- 右側：玩家屬性面板
- 右上：小地圖
- 整合快捷鍵列（3 頁 x 12 格）

**ClassicPlayerDisplay.lua** — 玩家資訊面板：
- 生命/魔力/體力等資源條（顏色編碼）
- 當前效果圖示
- 裝備欄縮略圖
- 屬性數值（根據是否有效果而閃爍）

### 6.4 Minimalist UI（極簡佈局）

**Minimalist.lua**（105KB）— 最複雜的 UI 主題：

主要設計理念：
- **地圖最大化**：移除固定面板，只在需要時顯示 HUD
- **條件式顯示**：資源條只在資源不滿或最近變化時顯示
- **通知氣泡**：事件用飄動文字取代靜態 log
- **智慧縮放**：根據視窗大小自動調整所有元素

顯著功能：
- 自訂圖示庫（技能/效果圖示）
- 動畫資源條（血量下降時紅色脈衝）
- 拖曳式快捷鍵列
- 可收合的多個資訊浮動面板

---

## 7. 系統間關係總覽

```
角色創建流程：
  Birther.lua
    ├── data/birth/ (職業/種族描述符)
    ├── data/quests/start-*.lua (起始任務)
    └── Player:registerOnBirth() (後置 callback)

世界遭遇流程：
  世界地圖移動
    ├── data/general/encounters/ (遭遇定義)
    │   └── on_encounter() → WorldNPC + Chat.lua
    └── data/quests/lost-merchant.lua 等 (任務更新)

地城生成流程：
  Zone:generate()
    ├── mod/class/generator/map/ (地圖生成)
    │   └── StaticPredrawn / VaultLevel / etc
    ├── data/general/events/ (隨機事件疊加)
    ├── mod/class/generator/actor/ (NPC 生成)
    │   └── data/general/npcs/ (NPC 定義庫)
    └── data/general/objects/ (物品生成)

物品生成流程：
  Zone:makeEntityByName("object", id)
    ├── data/general/objects/*.lua (物品定義)
    ├── egos/ (詞綴疊加)
    └── random-artifacts.lua (隨機神器)

任務完成流程：
  NPC 對話 / 地形互動 / 擊殺事件
    ├── who:setQuestStatus(quest, status)
    ├── on_status_change() (獎勵/下一步)
    ├── data/lore/ (解鎖史料)
    └── mod/class/interface/WorldAchievements.lua (成就)

UI 渲染流程：
  Game:display()
    ├── mod/class/uiset/Classic.lua 或 Minimalist.lua
    │   └── ClassicPlayerDisplay.lua (玩家資訊)
    └── mod/dialogs/ (開啟時疊加)
```

---

> **相關文件**：
> - `game_detail.md` — 引擎啟動、profile thread、引擎核心 Lua、ToME 核心類別、AI 系統
> - `engine_detail.md` — 引擎 Lua 層詳細分析（`engine/` 目錄）
> - `lua_engine_detail.md` — Lua 引擎核心設計（OOP/Entity/Game Loop 等）
> - `overview.md` — 整體架構概覽
