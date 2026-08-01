# T-Engine 4 — Lua 引擎層詳細分析

> 所有原始碼位於 `game/engines/te4-1.7.6.teae`（zip 格式），解壓後為 `engine/` 目錄。

---

> **注意**：此文件已拆分為多個子檔案，可點擊下方連結查看各節內容。

## 目錄

- [1. OOP 基礎系統 (`engine/class.lua`)](./lua_engine_detail/1-oop-基礎系統-engine-class-lua.md)
- [2. 實體系統 (`engine/Entity.lua`)](./lua_engine_detail/2-實體系統-engine-entity-lua.md)
- [3. Resolver 系統 (`engine/resolvers.lua`)](./lua_engine_detail/3-resolver-系統-engine-resolvers-lua.md)
- [4. 世界結構](./lua_engine_detail/4-世界結構.md)
- [5. 遊戲迴圈](./lua_engine_detail/5-遊戲迴圈.md)
- [6. Actor 介面混入 (`engine/interface/`)](./lua_engine_detail/6-actor-介面混入-engine-interface.md)
- [7. 傷害類型系統 (`engine/DamageType.lua`)](./lua_engine_detail/7-傷害類型系統-engine-damagetype-lua.md)
- [8. 目標系統 (`engine/Target.lua`)](./lua_engine_detail/8-目標系統-engine-target-lua.md)
- [9. 地圖生成系統 (`engine/generator/`)](./lua_engine_detail/9-地圖生成系統-engine-generator.md)
- [10. 存檔系統 (`engine/Savefile.lua` + `engine/SavefilePipe.lua`)](./lua_engine_detail/10-存檔系統-engine-savefile-lua-engine-savefilepipe-lua.md)
- [11. UI 框架 (`engine/ui/`)](./lua_engine_detail/11-ui-框架-engine-ui.md)
- [12. 輸入系統](./lua_engine_detail/12-輸入系統.md)
- [13. 任務系統 (`engine/Quest.lua`)](./lua_engine_detail/13-任務系統-engine-quest-lua.md)
- [14. 玩家自動化功能](./lua_engine_detail/14-玩家自動化功能.md)
- [15. 渲染相關系統](./lua_engine_detail/15-渲染相關系統.md)
- [16. 在線與 Profile 系統](./lua_engine_detail/16-在線與-profile-系統.md)
- [17. 在地化系統 (`engine/I18N.lua`)](./lua_engine_detail/17-在地化系統-engine-i18n-lua.md)
- [18. 關鍵設計模式總結](./lua_engine_detail/18-關鍵設計模式總結.md)
