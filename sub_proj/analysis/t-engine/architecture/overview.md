# T-Engine 4 架構總覽 (v1.7.6)

T-Engine 4 (TE4) 是一個以 **C + Lua** 雙層架構設計的 roguelike 遊戲引擎，底層用 C/SDL2/OpenGL 處理效能敏感的操作，上層用 Lua 實作遊戲邏輯，兩層透過 Lua C API 橋接。遊戲模組以 `.teae` / `.team` 壓縮包（zip 格式）發佈。

> **本地原始碼位置（2026-07-05 起）**：Lua 層原始碼解壓自 Steam 版封包，位於 `vendor/t-engine4/`：
> - 引擎 Lua 層 `engine/*.lua` → `vendor/t-engine4/engines/te4-1.7.6/engine/`
> - ToME 內容層 `mod/`、`data/` → `vendor/t-engine4/modules/tome/`
> - **C 層原始碼（`src/`）不在本地**——Steam 版只帶 Lua 層，本文 C 層章節僅供架構理解，要對照 C 碼需另從官方 git（te4.org）取得。

---

> **注意**：此文件已拆分為多個子檔案，可點擊下方連結查看各節內容。

## 目錄

- [整體分層架構](./overview/整體分層架構.md)
- [一、C 層模組 (`src/`)](./overview/一-c-層模組-src.md)
- [二、Lua 引擎層 (`engine/*.lua`)](./overview/二-lua-引擎層-engine-lua.md)
- [三、模組系統 (`game/modules/`)](./overview/三-模組系統-game-modules.md)
- [四、資料層 (`data/`)](./overview/四-資料層-data.md)
- [五、建構系統](./overview/五-建構系統.md)
- [六、關鍵設計決策](./overview/六-關鍵設計決策.md)
