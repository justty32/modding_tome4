加入 `j` 鍵顯示任務日誌（用 TE4 內建 UI）：

```lua
-- game/modules/hellodungeon/class/Game.lua
-- 在 setupCommands 加入：

[{"_j"}] = function()
    if not self.player then return end
    -- 如果沒有任何任務
    if not self.player.quests or not next(self.player.quests) then
        game.log("你目前沒有任何進行中的任務。")
        return
    end

    -- 建立簡單的任務清單對話框
    local d = require("engine.ui.Dialog").new("任務日誌", 500, 400)
    local text = ""
    for id, q in pairs(self.player.quests) do
        local status = engine.Quest.status_text[q.status] or "未知"
        text = text..string.format("#YELLOW#%s#LAST# [%s]\n", q.name, status)
        if type(q.desc) == "function" then
            text = text..q:desc(self.player).."\n\n"
        elseif q.desc then
            text = text..q.desc.."\n\n"
        end
    end

    local Textzone = require "engine.ui.Textzone"
    local tz = Textzone.new{
        width = d.iw,
        height = d.ih,
        scrollbar = true,
        text = text,
    }
    d:loadUI{{left=0, top=0, ui=tz}}
    d:setupUI()
    game:registerDialog(d)
end,
```

---
