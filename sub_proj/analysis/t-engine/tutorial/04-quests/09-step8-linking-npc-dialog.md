玩家需要按下「互動鍵」（或碰觸 NPC）才能開始對話。最常見的做法：

**方法 A：碰觸 NPC 觸發（修改 Actor.lua 的移動函數）**

在 `Player.lua` 的移動邏輯中，如果目標格有 NPC，先嘗試對話而不是攻擊：

```lua
-- game/modules/hellodungeon/class/Player.lua

-- 修改或加入 bump 函數（碰觸非敵對 NPC 時觸發對話）
function _M:bump(x, y)
    local target = game.level.map(x, y, engine.Map.ACTOR)
    -- 如果目標有 chat 欄位，且不是敵對的 → 觸發對話
    if target and target.chat and target.faction ~= "enemies" then
        self:talkTo(target)
        self:useEnergy()
        return true
    end
    -- 否則走正常攻擊流程
    return false
end

-- 對話入口函數
function _M:talkTo(npc)
    local chat = require "engine.Chat"
    local d = chat.new(npc.chat, npc, self)
    game:registerDialog(d)
end
```

**方法 B：按 `t` 鍵對話（在 Game.lua 的 setupCommands 加入）**

```lua
-- game/modules/hellodungeon/class/Game.lua
-- 在 setupCommands 中加入：

[{"_t"}] = function()
    if not self.player then return end
    -- 查詢玩家四周一格內有沒有可對話的 NPC
    for _, dir in ipairs({"n","s","e","w","ne","nw","se","sw"}) do
        local dx, dy = util.dirToCoord(util.dirToPath(dir))
        local x, y = self.player.x + dx, self.player.y + dy
        local target = self.level.map(x, y, engine.Map.ACTOR)
        if target and target.chat then
            self.player:talkTo(target)
            self.player:useEnergy()
            return
        end
    end
    self.log("附近沒有可以對話的人。")
end,
```

---
