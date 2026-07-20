這個 mixin 掛載到玩家身上，提供下達指令的方法。

### 檔案：`mod/class/interface/ActorCommand.lua`

```lua
-- mod/class/interface/ActorCommand.lua
-- 玩家側介面：發出戰術指令給隊友

require "engine.class"
local Map = require "engine.Map"

module(..., package.seeall, class.make)

--- 向指定隊友下達指令
-- @param ally   目標隊友 Actor
-- @param cmd_type  "attack"|"follow"|"standby"|"flee"|"auto"
-- @param target    （僅 attack 模式）攻擊目標 Actor
function _M:issueCommand(ally, cmd_type, target)
    if not game.party or not game.party.members[ally] then
        game.logPlayer(self, "無法對非隊友下達指令。")
        return false
    end
    if ally == self then
        game.logPlayer(self, "無法對自己下達指令。")
        return false
    end

    if cmd_type == "auto" then
        -- 清除指令，回到自主 AI
        ally.ai_state.command = nil
        game.logPlayer(self, "命令 %s 恢復自主行動。", ally.name)
    elseif cmd_type == "attack" then
        if not target or target.dead then
            game.logPlayer(self, "無效的攻擊目標。")
            return false
        end
        ally.ai_state.command = {type = "attack", target = target}
        game.logPlayer(self, "命令 %s 攻擊 %s！", ally.name, target.name)
    elseif cmd_type == "follow" then
        ally.ai_state.command = {type = "follow"}
        game.logPlayer(self, "命令 %s 跟隨你。", ally.name)
    elseif cmd_type == "standby" then
        ally.ai_state.command = {type = "standby"}
        game.logPlayer(self, "命令 %s 原地待命。", ally.name)
    elseif cmd_type == "flee" then
        ally.ai_state.command = {type = "flee"}
        game.logPlayer(self, "命令 %s 撤退！", ally.name)
    end

    return true
end

--- 取得所有可指揮的隊友列表
-- @return table  隊友 Actor 的陣列
function _M:getCommandableAllies()
    if not game.party then return {} end
    local list = {}
    for i, actor in ipairs(game.party.m_list) do
        if actor ~= self and not actor.dead then
            list[#list+1] = actor
        end
    end
    return list
end
```

---
