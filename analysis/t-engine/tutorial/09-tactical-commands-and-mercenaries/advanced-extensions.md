### 1. 指令優先序與指令佇列

目前設計是「最後一個指令覆蓋前一個」。若要支援佇列：

```lua
-- ai_state.command_queue 是一個陣列
ally.ai_state.command_queue = ally.ai_state.command_queue or {}
table.insert(ally.ai_state.command_queue, {type="attack", target=enemy})
-- AI 每次執行完一個指令後 table.remove(queue, 1)
```

### 2. 傭兵等級隨玩家提升

在 `Party:addMember` 後立即同步等級：

```lua
-- 強制傭兵達到玩家等級
if merc.forceLevelup then
    merc:forceLevelup(game.player.level)
end
```

### 3. 傭兵死亡後的處理

在傭兵身上加入 `on_die` 回呼：

```lua
on_die = function(self, who)
    if game.party and game.party.members[self] then
        game.party:removeMember(self)
        game.logPlayer(game.player, "#RED#%s 陣亡了！", self.name)
    end
end,
```

### 4. 多人傭兵的群體指令

```lua
-- 對所有隊友同時下達指令
function Player:issueCommandToAll(cmd_type, target)
    local allies = self:getCommandableAllies()
    for _, ally in ipairs(allies) do
        self:issueCommand(ally, cmd_type, target)
    end
end
```

---
