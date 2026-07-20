確保遊戲使用自訂的 UISet：

```lua
-- mod/load.lua（摘錄）

-- 載入自訂 UISet
local GameUI = require "mod.class.uiset.GameUI"

-- 在 Game.init 後設定 UISet（通常在 mod/class/Game.lua 的 init 中）
```

### 在 `mod/class/Game.lua → init()` 中設定 UISet

```lua
-- mod/class/Game.lua

function _M:init(zone, level, player)
    -- ... 原有初始化 ...

    -- ★ 設定自訂 UISet
    self.uiset = require("mod.class.uiset.GameUI").new()
    self.uiset:activate()
end
```

---
