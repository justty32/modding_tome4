# TE4 模組開發教學系列 — 總覽

> 本系列教學以 T-Engine 4（版本 1.7.6）為基礎，帶你從零開始製作一個完整的 Roguelike 遊戲，或為 Tales of Maj'Eyal 製作 Addon。
>
> 建議按照編號順序閱讀。每個教學都會在上一個的基礎上繼續延伸。

---

## 本地原始碼位置

Lua 層原始碼（解壓自 Steam 版封包，2026-07-05）位於工作區 `projects/t-engine4/`：

| 教學中引用的路徑 | 本地實際位置 |
|------|------|
| `game/engines/te4-1.7.6/engine/` | `projects/t-engine4/engines/te4-1.7.6/engine/` |
| `game/modules/tome/`（`mod/` + `data/`） | `projects/t-engine4/modules/tome/` |
| C 層 `src/` | **不在本地**（Steam 版無 C 源，需另從 te4.org 官方 git 取得） |

實際執行環境可直接用 Steam 安裝版：`~/.local/share/Steam/steamapps/common/TalesMajEyal/`（模組放 `game/modules/`、addon 放 `game/addons/`）。

---

## 三種開發路線

- **獨立遊戲（全新模組）** → 教學 01 → 02 → 03 → 04 → 05
- **ToME Addon（擴充內容）** → 教學 01 → 06 → 07，之後依主題挑 08–17
- **引擎底層修改（C 層）** → 先讀 [`architecture/engine_detail.md`](../architecture/engine_detail.md)

---

## 教學清單（01–17 全數完成）

### 基礎：製作獨立遊戲

| 編號 | 標題 | 說明 |
|------|------|------|
| 01 | [製作一個最簡單的地城遊戲（Hello Dungeon）](./01-hello-dungeon.md) | 最小可執行模組：地城探索 + NPC + 技能 + 角色創建 |
| 02 | [加入物品系統](./02-items.md) | 揹包、裝備欄、消耗品、物品掉落 |
| 03 | [多地區與地區切換](./03-zones.md) | Zone 切換、WorldNPC、Wilderness |
| 04 | [任務系統與 NPC 對話](./04-quests.md) | Quest 定義、任務狀態追蹤、NPC 對話 |
| 05 | [進階 AI 系統](./05-advanced-ai.md) | `improved_tactical`、`ai_tactic` 權重表 |

### 進階：ToME Addon 開發

| 編號 | 標題 | 說明 |
|------|------|------|
| 06 | [製作第一個 ToME Addon](./06-addon-dev.md) | Addon 結構、hooks、superload、overload |
| 07 | [為 ToME 新增職業與技能樹](./07-tome-class.md) | `newTalentType`、`newTalent`、Birth 描述符整合 |
| 08 | [全新技能系統——連技體系](./08-technique-system.md) | Technique System：連技資源、連段設計 |
| 09 | [戰術指令系統與僱傭兵招募](./09-tactical-commands-and-mercenaries.md) | 隊友指令、僱傭兵生成與跟隨 |
| 10 | [據點系統基礎版](./10-base-camp-basic.md) | 玩家據點 Zone、設施互動 |
| 11 | [據點系統擴展版](./11-base-camp-extended.md) | 據點升級、NPC 進駐、資源產出 |
| 12 | [自訂大地圖（World Map）](./12-world-map.md) | Wilderness 地圖、據點入口、遭遇 |

### 專題：UI 與美術

| 編號 | 標題 | 說明 |
|------|------|------|
| 13 | [自訂技能學習界面](./13-skill-learn-dialog.md) | Dialog、TreeList、雙欄版面 |
| 14 | [技能視覺特效](./14-skill-effects.md) | 粒子系統 + 自訂貼圖 |
| 15 | [自訂武器、裝備與種族貼圖](./15-custom-sprites.md) | moddable tiles、貼圖分層 |
| 16 | [地塊貼圖與自訂 UI 風格](./16-custom-tiles-and-ui.md) | tileset、UI skin |
| 17 | [自訂動畫](./17-custom-animations.md) | 動畫幀、移動/攻擊動畫 |

---

## 前置知識

閱讀教學前，建議先了解以下背景：

- **Lua 基礎**：變數、函式、table、模組（`require`）
- **TE4 架構概覽**：閱讀 [`architecture/overview.md`](../architecture/overview.md)
- **引擎 Lua 層**：閱讀 [`architecture/lua_engine_detail.md`](../architecture/lua_engine_detail.md)（OOP 系統、Entity 生命週期）

---

## 開發環境設定

有兩種執行方式：

**A. 用 Steam 安裝版（推薦，本機可用）**

```bash
# 模組放進 Steam 版的 modules 目錄即可被偵測
cp -r <你的模組> ~/.local/share/Steam/steamapps/common/TalesMajEyal/game/modules/

# 直接啟動
~/.local/share/Steam/steamapps/common/TalesMajEyal/t-engine64
```

**B. 從原始碼編譯（需另取得含 C 層的完整原始碼）**

```bash
# 1. 生成 Makefile（Linux）
premake4 gmake

# 2. 編譯
make -C build

# 3. 執行（Debug 版，可看到 console 輸出）
./bin/Debug/t-engine
```

**推薦輔助工具**：
- `tome-addon-dev` addon：內建 `FSHelper` 與 Lua console（見 `architecture/game_detail.md` § 9）
- `LUA_CONSOLE` 按鍵（F1）：遊戲內執行任意 Lua 程式碼

---

## 快速參考：重要路徑

| 路徑 | 說明 |
|------|------|
| `game/engines/te4-1.7.6/engine/` | 引擎核心 Lua（不要直接修改）|
| `game/modules/<mod>/` | 你的模組根目錄 |
| `game/modules/<mod>/init.lua` | 模組元資料（必須）|
| `game/modules/<mod>/load.lua` | 系統初始化（必須）|
| `game/modules/<mod>/class/Game.lua` | 遊戲主控制器 |
| `game/modules/<mod>/data/zones/<name>/zone.lua` | 地區生成規則 |
| `game/addons/<addon>/` | Addon 根目錄（教學 06+）|

---

## 相關架構文件

| 文件 | 說明 |
|------|------|
| [`overview.md`](../architecture/overview.md) | 整體架構（C 層 + Lua 層 + 模組層）|
| [`lua_engine_detail.md`](../architecture/lua_engine_detail.md) | 引擎 Lua 詳細（OOP / Entity / Game Loop）|
| [`engine_detail.md`](../architecture/engine_detail.md) | C 子系統（SDL2 / OpenGL / PhysFS）|
| [`game_detail.md`](../architecture/game_detail.md) | game/ 目錄（loader / ToME 核心類別 / AI）|
| [`tome_content.md`](../architecture/tome_content.md) | ToME 內容層（NPC / 物品 / 任務 / 史料）|
| [`module_dev_guide.md`](../architecture/module_dev_guide.md) | 模組開發參考指南 |
