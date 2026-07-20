這是玩家用來發出指令的 Dialog。設計上分兩步：
1. 選擇要指揮的隊友（若只有一個，跳過）
2. 選擇指令類型（若是攻擊，再選擇目標）

### 檔案：`mod/dialogs/CommandMenu.lua`

```lua
-- mod/dialogs/CommandMenu.lua
-- 戰術指令選單：讓玩家對隊友下達指令

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local List   = require "engine.ui.List"
local Map    = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(player)
    self.player = player
    self.allies = player:getCommandableAllies()

    Dialog.init(self, "戰術指令", 350, 400)

    if #self.allies == 0 then
        -- 沒有隊友，直接顯示提示並關閉
        self:simplePopup("無可用隊友", "你目前沒有可指揮的隊友。")
        return
    end

    if #self.allies == 1 then
        -- 只有一個隊友，直接進入指令選擇
        self:showCommandFor(self.allies[1])
    else
        -- 多個隊友，先選人
        self:showAllyList()
    end
end

--- 顯示隊友選擇列表
function _M:showAllyList()
    local items = {}
    for i, ally in ipairs(self.allies) do
        items[#items+1] = {
            name = ("%s（HP：%d/%d）"):format(ally.name, ally.life, ally.max_life),
            ally = ally,
        }
    end

    local list = List.new{
        width = self.iw,
        list = items,
        fct = function(item)
            self:showCommandFor(item.ally)
        end,
    }
    self:loadUI{{ui=list, x=0, y=0}}
    self:setupUI(true, true)
end

--- 顯示對指定隊友的指令選擇
-- @param ally 目標隊友 Actor
function _M:showCommandFor(ally)
    local cur_cmd = ally.ai_state.command
    local cur_desc = cur_cmd and cur_cmd.type or "自主"

    local commands = {
        {name = "攻擊（選擇目標）", cmd = "attack"},
        {name = "跟隨我",           cmd = "follow"},
        {name = "原地待命",         cmd = "standby"},
        {name = "撤退",             cmd = "flee"},
        {name = "恢復自主行動",     cmd = "auto"},
    }

    -- 在每個選項後面標注當前狀態
    local items = {}
    for i, c in ipairs(commands) do
        local suffix = (cur_desc == c.cmd) and " ◀ 當前" or ""
        items[#items+1] = {
            name = c.name .. suffix,
            cmd  = c.cmd,
            ally = ally,
        }
    end

    local title_label = ("指揮：%s"):format(ally.name)
    self:setTitle(title_label)

    local list = List.new{
        width = self.iw,
        list = items,
        fct = function(item)
            if item.cmd == "attack" then
                -- 攻擊需要額外選擇目標
                self:showTargetListFor(ally)
            else
                self.player:issueCommand(ally, item.cmd)
                self:unregister()
            end
        end,
    }
    self:loadUI{{ui=list, x=0, y=0}}
    self:setupUI(true, true)
    self:setKeyHandling()
end

--- 顯示可攻擊目標列表（FOV 範圍內的敵人）
-- @param ally 下達命令的隊友
function _M:showTargetListFor(ally)
    -- 從玩家 FOV 收集敵方目標
    local targets = {}
    local seen = self.player.fov and self.player.fov.actors_dist or {}
    for i, act in ipairs(seen) do
        if act and not act.dead and self.player:reactionToward(act) < 0 then
            local dist = core.fov.distance(self.player.x, self.player.y, act.x, act.y)
            targets[#targets+1] = {
                name = ("%s（距離 %d）"):format(act.name, dist),
                actor = act,
            }
        end
    end

    if #targets == 0 then
        self:simplePopup("無目標", "視野內沒有可攻擊的敵人。")
        return
    end

    self:setTitle("選擇攻擊目標")
    local list = List.new{
        width = self.iw,
        list = targets,
        fct = function(item)
            self.player:issueCommand(ally, "attack", item.actor)
            self:unregister()
        end,
    }
    self:loadUI{{ui=list, x=0, y=0}}
    self:setupUI(true, true)
    self:setKeyHandling()
end
```

> **`self:simplePopup(title, text)`** 是 `engine.ui.Dialog` 提供的便利函式，顯示一個只有「確定」按鈕的彈窗。

---
