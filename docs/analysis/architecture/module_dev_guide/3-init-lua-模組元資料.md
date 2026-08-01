```lua
-- game/modules/mymod/init.lua
name = "My Roguelike"
long_name = "My First T-Engine4 Roguelike"
short_name = "mymod"
author = { "Author Name", "email@example.com" }
homepage = "https://example.com"
version = {1, 0, 0}
engine = {1, 7, 6, "te4"}       -- 所需引擎最低版本
starter = "mod.load"             -- 入口函數（對應 load.lua）
show_only_on_cheat = false       -- true = 在正常選單中隱藏
no_hierarchical_saves = true     -- true = 不使用階層式存檔
allow_hierarchical_saves = false
```

關鍵欄位：
- **`short_name`**：用作存檔資料夾名稱、虛擬路徑識別符。
- **`engine`**：`{major, minor, patch, "te4"}`，引擎會驗證相容性。
- **`starter`**：Lua 模組路徑，引擎呼叫此路徑對應的 `load.lua` 檔案。

---
