```lua
-- game/modules/hellodungeon/dialogs/DeathDialog.lua

require "engine.class"
local Dialog = require "engine.Dialog"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    Dialog.init(self, "你死了！", 400, 200)
    self.actor = actor

    self:addText(("你在第 %d 層倒下了。"):format(game.level.level), "red")
    self:addText(" ")
    self:addButton("重試（返回主選單）", function()
        self:unregisterDialog(self)
        -- 刪除存檔並返回主選單
        game:setPlayerDead()
    end)
end
```

**或者使用最簡單版本**（直接讓玩家重新開始）：

```lua
-- 最簡版死亡對話框
require "engine.class"
local Dialog = require "engine.Dialog"
module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    Dialog.init(self, _t"死亡", 400, 150)
    self:addText(_t"你已死亡，遊戲結束。")
    self:addButton(_t"確認", function()
        game:setPlayerDead()  -- 引擎的標準死亡處理
        self:unregisterDialog(self)
    end)
end
```

---
