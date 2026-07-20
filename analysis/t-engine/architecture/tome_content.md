# T-Engine 4 — ToME 1.7.6 內容層詳細分析

> 本文件是 `game_detail.md` 的補充，專注分析 `game/modules/tome-1.7.6/` 中尚未深入記錄的子系統：內容資料層、對話框系統、任務系統、史料系統、自訂生成器、UI 主題。

---

> **注意**：此文件已拆分為多個子檔案，可點擊下方連結查看各節內容。

## 目錄

- [1. data/general/ — 核心內容資料](./tome_content/1-data-general-核心內容資料.md)
- [2. mod/dialogs/ — 對話框系統](./tome_content/2-mod-dialogs-對話框系統.md)
- [3. data/quests/ — 任務系統](./tome_content/3-data-quests-任務系統.md)
- [4. data/lore/ — 史料系統](./tome_content/4-data-lore-史料系統.md)
- [5. mod/class/generator/ — 自訂生成器](./tome_content/5-mod-class-generator-自訂生成器.md)
- [6. mod/class/uiset/ — UI 主題系統](./tome_content/6-mod-class-uiset-ui-主題系統.md)
- [7. 系統間關係總覽](./tome_content/7-系統間關係總覽.md)

<details>
<summary>原始目錄 (供參考)</summary>

1. [data/general/ — 核心內容資料](#1-datageneral--核心內容資料)
   - 1.1 [NPC 定義（npcs/）](#11-npc-定義-npcs)
   - 1.2 [物品定義（objects/）](#12-物品定義-objects)
   - 1.3 [地形定義（grids/）](#13-地形定義-grids)
   - 1.4 [商店定義（stores/）](#14-商店定義-stores)
   - 1.5 [陷阱定義（traps/）](#15-陷阱定義-traps)
   - 1.6 [事件系統（events/）](#16-事件系統-events)
   - 1.7 [遭遇系統（encounters/）](#17-遭遇系統-encounters)
2. [mod/dialogs/ — 對話框系統](#2-moddialogs--對話框系統)
3. [data/quests/ — 任務系統](#3-dataquests--任務系統)
4. [data/lore/ — 史料系統](#4-datalore--史料系統)
5. [mod/class/generator/ — 自訂生成器](#5-modclassgenerator--自訂生成器)
6. [mod/class/uiset/ — UI 主題系統](#6-modclassuiset--ui-主題系統)
7. [系統間關係總覽](#7-系統間關係總覽)

---

</details>
