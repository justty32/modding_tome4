在 `mod/class/Player.lua` 中繼承 `ActorCommand` mixin，並綁定按鍵：

```lua
-- mod/class/Player.lua（摘錄）
require "engine.class"
local ActorCommand = require "mod.class.interface.ActorCommand"

module(..., package.seeall, class.inherit(
    engine.Player,
    ActorCommand          -- ← 加入指令介面
))

function _M:init(t, no_default)
    engine.Player.init(self, t, no_default)
end

--- 按鍵處理：在 keyboardHandler 或 act() 中加入
function _M:setupKeys()
    -- 按 'c'（或你偏好的鍵）開啟戰術指令選單
    self.key:addCommand(self.key._c, function()
        local menu = require("mod.dialogs.CommandMenu").new(self)
        game:registerDialog(menu)
    end)
end
```

然後在 `Game:run()` 或玩家初始化後呼叫 `player:setupKeys()`。

---
