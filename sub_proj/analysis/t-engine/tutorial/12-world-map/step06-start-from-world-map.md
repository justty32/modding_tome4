### 修改 `mod/class/Game.lua`

預設情況下，TE4 模組可能從地牢或其他 Zone 開始。要讓玩家**出生在大地圖的起點村莊旁**，修改 `newGame()`：

```lua
-- mod/class/Game.lua

function _M:newGame()
    -- 建立玩家角色（保留原有的 newGame 邏輯）
    self.player = self:createPlayer()
    self.player:resolve()

    -- 初始化 party
    self.party = require("mod.class.Party").new{}
    self.party:addMember(self.player, {
        control = "player",
        type    = "player",
        title   = "英雄",
    })

    -- 初始化據點狀態（Tutorial 10/11）
    self.camp_state = {
        buildings = {farm=false, chest=false, upgraded_fire=false},
        farms     = {},
        workers   = {},
    }

    -- ★ 起始於大地圖（wilderness Zone 的第 1 層）
    -- 玩家出現在 wilderness.lua 中設定的 startx, starty 位置
    self:changeLevel(1, "wilderness")
end
```

> **為什麼不在 `load()` 中設定？**  
> `newGame()` 只在「新遊戲」時呼叫一次；`load()` 在讀取存檔時呼叫。`changeLevel` 只需要在 `newGame()` 執行，存檔記錄了玩家當時所在的 Zone/Level，讀檔後自動恢復。

---
