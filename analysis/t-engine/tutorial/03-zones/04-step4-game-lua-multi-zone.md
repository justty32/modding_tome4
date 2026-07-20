在 `Game.lua` 中把 `changeLevel` 和 `CHANGE_LEVEL` 按鍵綁定複製自 example 模組，加入必要修改：

```lua
-- game/modules/hellodungeon/class/Game.lua
-- （加入或修改以下函數）

function _M:changeLevel(lev, zone)
    local old_lev = (self.level and not zone) and self.level.level or -1000

    -- 離開舊地區前保存位置
    if self.level then
        local level = self.level
        if old_lev > lev then
            -- 往上走：記錄下行出現點
            level.exited = level.exited or {}
            level.exited.down = {x=self.player.x, y=self.player.y}
        else
            -- 往下走：記錄上行出現點
            level.exited = level.exited or {}
            level.exited.up = {x=self.player.x, y=self.player.y}
        end
        level:removeEntity(self.player)
    end

    if zone then
        if self.zone then
            self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave()
        end
        if type(zone) == "string" then
            self.zone = Zone.new(zone)
        else
            self.zone = zone
        end
    end

    self.zone:getLevel(self, lev, old_lev)

    -- 若舊地區有記錄返回位置，優先使用
    if lev > old_lev then
        local pos = self.level.exited and self.level.exited.up
        if pos then
            self.player:move(pos.x, pos.y, true)
        else
            self.player:move(self.level.default_up.x, self.level.default_up.y, true)
        end
    else
        local pos = self.level.exited and self.level.exited.down
        if pos then
            self.player:move(pos.x, pos.y, true)
        else
            self.player:move(self.level.default_down.x, self.level.default_down.y, true)
        end
    end

    self.level:addEntity(self.player)

    -- 重新計算玩家視野
    self.player:playerFOV()
end
```

在 `setupCommands()` 中加入 `CHANGE_LEVEL` 動作：

```lua
-- 在 Game:setupCommands() 的 key:addCommands 表格中加入：

CHANGE_LEVEL = function()
    local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
    if self.player:enoughEnergy() and e.change_level then
        -- change_zone 存在：切換到新地區，change_level 是目標層號
        -- change_zone 不存在：同地區，change_level 是相對差值
        self:changeLevel(
            e.change_zone and e.change_level or self.level.level + e.change_level,
            e.change_zone
        )
    else
        self.log("這裡沒有出口。")
    end
end,
```

確認 `load.lua` 載入了 `KeyBind:load("move,hotkeys,inventory,actions,interface,debug")`，其中 `actions` 包含 `CHANGE_LEVEL` 的預設按鍵（通常是 `<` 和 `>` 或 Enter）。

---
