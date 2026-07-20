# TE4 模組開發教學系列 — 總覽

> 基於 T-Engine 4（v1.7.6），目標：從零產出完整 Roguelike 遊戲，或為 ToME 製作 Addon。

---

## 原始碼位置

Lua 層（Steam 封包解壓，2026-07-05）位於工作區 `projects/t-engine4/`：

| 教學路徑 | 本地路徑 |
|----------|----------|
| `game/engines/te4-1.7.6/engine/` | `projects/t-engine4/engines/te4-1.7.6/engine/` |
| `game/modules/tome/`（`mod/` + `data/`） | `projects/t-engine4/modules/tome/` |
| C 層 `src/` | **不在本地**（Steam 版無 C 源，需自 te4.org git 取得） |

執行環境：`~/.local/share/Steam/steamapps/common/TalesMajEyal/`（模組放 `game/modules/`，addon 放 `game/addons/`）。

---

## 開發路線

- **獨立遊戲** → 01 → 02 → 03 → 04 → 05
- **ToME Addon** → 01 → 06 → 07，依主題續接 08–17
- **引擎修改（C 層）** → 先讀 [`architecture/engine_detail.md`](../architecture/engine_detail.md)

---

## 教學一覽（01–17）

### 基礎：獨立遊戲

| # | 標題 | 主題 |
|---|------|------|
| 01 | [Hello Dungeon](./01-hello-dungeon.md) | 最小模組：地城 + NPC + 技能 + 角色創建 |
| 02 | [物品系統](./02-items.md) | 揹包、裝備、消耗品、掉落 |
| 03 | [多地區切換](./03-zones.md) | Zone 切換、WorldNPC、Wilderness |
| 04 | [任務與對話](./04-quests.md) | Quest 定義、狀態追蹤、Chat 腳本 |
| 05 | [進階 AI](./05-advanced-ai.md) | `improved_tactical`、`ai_tactic` 權重 |

### 進階：ToME Addon

| # | 標題 | 主題 |
|---|------|------|
| 06 | [首個 Addon](./06-addon-dev.md) | 結構、hooks、superload、overload |
| 07–12 | 職業/技能樹/戰術/據點/大地圖 | 漸進擴充 |
| 13–17 | UI/美術專題 | Dialog、粒子、貼圖、動畫 |

---

## 前置知識

- Lua 基礎（變數、函式、table、`require`）
- [`architecture/overview.md`](../architecture/overview.md) — TE4 整體架構
- [`architecture/lua_engine_detail.md`](../architecture/lua_engine_detail.md) — OOP、Entity 生命週期

---

## 執行方式

```bash
# A) Steam 版（推薦）
cp -r <module> ~/.local/share/Steam/steamapps/common/TalesMajEyal/game/modules/
~/.local/share/Steam/steamapps/common/TalesMajEyal/t-engine64

# B) 原始碼編譯（需 C 層原始碼）
premake4 gmake && make -C build && ./bin/Debug/t-engine
```

輔助工具：`tome-addon-dev`（FSHelper + Lua Console）、`LUA_CONSOLE` 鍵（F1）。

---

## 關鍵路徑

| 路徑 | 用途 |
|------|------|
| `game/engines/te4-1.7.6/engine/` | 引擎核心 Lua（勿改） |
| `game/modules/<mod>/` | 模組根目錄 |
| `game/modules/<mod>/init.lua` | 模組元資料 |
| `game/modules/<mod>/load.lua` | 系統初始化 |
| `game/modules/<mod>/class/Game.lua` | 遊戲主控制器 |
| `game/modules/<mod>/data/zones/<name>/zone.lua` | 地區生成規則 |
| `game/addons/<addon>/` | Addon 根目錄（06+） |

---

## 相關架構文件

| 文件 | 內容 |
|------|------|
| [`overview.md`](../architecture/overview.md) | C 層 + Lua 層 + 模組層 |
| [`lua_engine_detail.md`](../architecture/lua_engine_detail.md) | OOP / Entity / Game Loop |
| [`engine_detail.md`](../architecture/engine_detail.md) | SDL2 / OpenGL / PhysFS |
| [`game_detail.md`](../architecture/game_detail.md) | Loader / ToME 核心 / AI |
| [`tome_content.md`](../architecture/tome_content.md) | NPC / 物品 / 任務 / 史料 |
| [`module_dev_guide.md`](../architecture/module_dev_guide.md) | 模組開發參考 |
