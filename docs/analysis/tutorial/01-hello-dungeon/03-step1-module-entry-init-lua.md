這是引擎最先讀取的檔案，告訴引擎「這個模組是什麼」：

```lua
-- game/modules/hellodungeon/init.lua

name = "Hello Dungeon"
long_name = "Hello Dungeon - My First TE4 Game"
short_name = "hellodungeon"

author = { "你的名字", "your@email.com" }
version = {1, 0, 0}

-- 指定需要的引擎版本（必須與 te4-X.Y.Z.teae 一致）
engine = {1, 7, 6, "te4"}

description = [[
我的第一個 TE4 地城探索遊戲。
探索隨機地城，擊敗科博德！
]]

-- 遊戲啟動後要執行的 Lua 路徑（對應 load.lua）
starter = "mod.load"
```

**重點說明**：

| 欄位 | 說明 |
|------|------|
| `short_name` | 小寫字母，作為存檔目錄名稱、模組 ID |
| `engine` | 版本號必須與 `game/engines/te4-X.Y.Z.teae` 一致 |
| `starter` | `"mod.load"` 對應 `load.lua`（`mod.` 前綴表示模組根目錄）|
| `show_only_on_cheat` | 設為 `true` 可隱藏，開發時很有用 |

---
