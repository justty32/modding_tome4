# T-Engine 4 — game/ 目錄原始碼詳細分析

> 本文件涵蓋 `game/` 目錄下所有子系統，包含引擎啟動、模組（boot/example/ToME）、Addon 與第三方函式庫。

---

> **注意**：此文件已拆分為多個子檔案，可點擊下方連結查看各節內容。

## 目錄

- [1. game/loader/ — 引擎啟動器](./game_detail/1-game-loader-引擎啟動器.md)
- [2. game/profile-thread/ — 在線 Profile 執行緒](./game_detail/2-game-profile-thread-在線-profile-執行緒.md)
- [3. game/thirdparty/ — 第三方函式庫](./game_detail/3-game-thirdparty-第三方函式庫.md)
- [4. game/engines/te4-1.7.6/data/ — 引擎靜態資產](./game_detail/4-game-engines-te4-1-7-6-data-引擎靜態資產.md)
- [5. game/modules/boot — 啟動/主選單模組](./game_detail/5-game-modules-boot-啟動-主選單模組.md)
- [6. game/modules/example — 回合制範例模組](./game_detail/6-game-modules-example-回合制範例模組.md)
- [7. game/modules/example_realtime — 即時制範例模組](./game_detail/7-game-modules-example_realtime-即時制範例模組.md)
- [8. game/modules/tome-1.7.6 — Tales of Maj'Eyal](./game_detail/8-game-modules-tome-1-7-6-tales-of-maj-eyal.md)
- [9. game/addons/ — Addon 系統](./game_detail/9-game-addons-addon-系統.md)
- [總結：game/ 目錄架構關係圖](./game_detail/總結-game-目錄架構關係圖.md)

<details>
<summary>原始目錄 (供參考)</summary>

1. [game/loader/ — 引擎啟動器](#1-gameloader--引擎啟動器)
2. [game/profile-thread/ — 在線 Profile 執行緒](#2-gameprofile-thread--在線-profile-執行緒)
3. [game/thirdparty/ — 第三方函式庫](#3-gamethirdparty--第三方函式庫)
4. [game/engines/te4-1.7.6/data/ — 引擎靜態資產](#4-gameengineste4-176data--引擎靜態資產)
5. [game/modules/boot — 啟動/主選單模組](#5-gamemodulesboot--啟動主選單模組)
6. [game/modules/example — 回合制範例模組](#6-gamemodulesexample--回合制範例模組)
7. [game/modules/example_realtime — 即時制範例模組](#7-gamemodulesexample_realtime--即時制範例模組)
8. [game/modules/tome-1.7.6 — Tales of Maj'Eyal](#8-gamemodustome-176--tales-of-majeyal)
   - 8.1 [模組入口（init.lua / load.lua / settings.lua）](#81-模組入口)
   - 8.2 [核心類別（mod/class/）](#82-核心類別-modclass)
   - 8.3 [介面混入（mod/class/interface/）](#83-介面混入-modclassinterface)
   - 8.4 [AI 系統（mod/ai/）](#84-ai-系統-modai)
   - 8.5 [資料層（data/）](#85-資料層-data)
   - 8.6 [地區（data/zones/）](#86-地區-datazones)
9. [game/addons/ — Addon 系統](#9-gameaddons--addon-系統)

---

</details>
