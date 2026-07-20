# T-Engine 4 — engine/ 原始碼詳細分析

> 原始碼位於 `game/engines/te4-1.7.6/engine/`（解壓自 `te4-1.7.6.teae`）。

---

> **注意**：此文件已拆分為多個子檔案，可點擊下方連結查看各節內容。

## 目錄

- [1. OOP 基礎系統 (class.lua)](./engine_detail/1-oop-基礎系統-class-lua.md)
- [2. 實體系統](./engine_detail/2-實體系統.md)
- [3. 世界結構](./engine_detail/3-世界結構.md)
- [4. 遊戲迴圈](./engine_detail/4-遊戲迴圈.md)
- [5. Resolver 延遲計算系統 (resolvers.lua)](./engine_detail/5-resolver-延遲計算系統-resolvers-lua.md)
- [6. Actor 介面混入 (interface/)](./engine_detail/6-actor-介面混入-interface.md)
- [7. 玩家介面混入](./engine_detail/7-玩家介面混入.md)
- [8. 傷害類型系統 (DamageType.lua)](./engine_detail/8-傷害類型系統-damagetype-lua.md)
- [9. 目標系統 (Target.lua)](./engine_detail/9-目標系統-target-lua.md)
- [10. 程序地圖生成系統 (generator/)](./engine_detail/10-程序地圖生成系統-generator.md)
- [11. AI 系統 (ai/)](./engine_detail/11-ai-系統-ai.md)
- [12. 演算法 (algorithms/)](./engine_detail/12-演算法-algorithms.md)
- [13. Tilemap 中間表示 (tilemaps/)](./engine_detail/13-tilemap-中間表示-tilemaps.md)
- [14. 存檔系統 (Savefile.lua)](./engine_detail/14-存檔系統-savefile-lua.md)
- [15. 渲染支援系統](./engine_detail/15-渲染支援系統.md)
- [16. UI 框架 (ui/)](./engine_detail/16-ui-框架-ui.md)
- [17. 輸入系統](./engine_detail/17-輸入系統.md)
- [18. 支援系統](./engine_detail/18-支援系統.md)
- [19. 關鍵設計模式總結](./engine_detail/19-關鍵設計模式總結.md)

<details>
<summary>原始目錄 (供參考)</summary>

1. [OOP 基礎系統 (class.lua)](#1-oop-基礎系統-classlua)
2. [實體系統](#2-實體系統)
   - Entity、Actor、Grid、Object、Trap、Projectile
3. [世界結構](#3-世界結構)
   - World、Zone、Level、Map、MapEffect
4. [遊戲迴圈](#4-遊戲迴圈)
   - Game、GameEnergyBased、GameTurnBased
5. [Resolver 延遲計算系統 (resolvers.lua)](#5-resolver-延遲計算系統-resolverslua)
6. [Actor 介面混入 (interface/)](#6-actor-介面混入-interface)
7. [玩家介面混入](#7-玩家介面混入)
8. [傷害類型系統 (DamageType.lua)](#8-傷害類型系統-damagetypelua)
9. [目標系統 (Target.lua)](#9-目標系統-targetlua)
10. [程序地圖生成系統 (generator/)](#10-程序地圖生成系統-generator)
11. [AI 系統 (ai/)](#11-ai-系統-ai)
12. [演算法 (algorithms/)](#12-演算法-algorithms)
13. [Tilemap 中間表示 (tilemaps/)](#13-tilemap-中間表示-tilemaps)
14. [存檔系統 (Savefile.lua)](#14-存檔系統-savefilelua)
15. [渲染支援系統](#15-渲染支援系統)
16. [UI 框架 (ui/)](#16-ui-框架-ui)
17. [輸入系統](#17-輸入系統)
18. [支援系統](#18-支援系統)
19. [關鍵設計模式總結](#19-關鍵設計模式總結)

---

</details>
