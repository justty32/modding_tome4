`init.lua` 是唯一必要的檔案。引擎讀取它來決定是否載入此 Addon。

```lua
-- game/addons/my-addon/init.lua

long_name  = "My First Addon"   -- 顯示名稱（主選單）
short_name = "my-addon"         -- 唯一識別碼（ASCII，不含空白）
for_module = "tome"             -- 目標模組，必須吻合才會載入

version    = {1, 0, 0}          -- 你的 Addon 版本
author     = { "你的名字", "email@example.com" }
homepage   = "https://example.com"
description = [[這個 Addon 新增一個強大的職業。]]

-- 宣告你需要哪些機制（設 true 才會被引擎掃描載入）
hooks     = true   -- 允許 hooks/load.lua
superload = true   -- 允許 superload/ 目錄
overload  = true   -- 允許 overload/ 目錄
data      = true   -- 允許 data/ 目錄

weight = 1         -- 數字越小越早載入（預設 1，DLC 通常 5+）

-- cheat_only = true  -- 僅在作弊模式啟用（如 tome-addon-dev）
-- dlc = 5            -- 標記為 DLC，需要線上驗證（如 tome-possessors）
```

### 關鍵欄位說明

| 欄位 | 說明 |
|------|------|
| `for_module` | 必須是 `"tome"` 才能用於 ToME；用於獨立模組時填自己的 `short_name` |
| `weight` | 決定 Addon 載入順序；多個 Addon 衝突時，weight 小的先載入 |
| `hooks` / `superload` / `overload` / `data` | 只宣告你實際使用的機制，未宣告的目錄不會被掃描 |

---
