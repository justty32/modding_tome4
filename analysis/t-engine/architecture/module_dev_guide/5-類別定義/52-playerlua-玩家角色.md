### 5.2 Player.lua — 玩家角色

```lua
require "engine.class"
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerMouse"
require "engine.interface.PlayerHotkeys"

module(..., package.seeall, class.inherit(
    mod.class.Actor,
    engine.interface.PlayerRest,
    engine.interface.PlayerRun,
    engine.interface.PlayerMouse,
    engine.interface.PlayerHotkeys
))

function _M:init(t, no_default)
    t.player = true
    t.faction = t.faction or "players"
    mod.class.Actor.init(self, t, no_default)
    self.lite = t.lite or 0  -- 玩家照明範圍
end

function _M:act()
    if not mod.class.Actor.act(self) then return false end

    -- 處理自動行為（休息、奔跑）
    if self.resting then self:restStep() return false end
    if self.running then self:runStep() return false end

    -- 暫停遊戲等待玩家輸入
    game.paused = true
end

function _M:move(x, y, force)
    local moved = mod.class.Actor.move(self, x, y, force)
    if moved then
        -- 移動後更新地圖視口（以玩家為中心）
        game.level.map:moveViewSurround(self.x, self.y, 8, 8)
    end
    return moved
end

function _M:playerFOV()
    self:computeFOV(self.sight or 20, "block_sight", function(x, y)
        game.level.map:apply(x, y)   -- 標記格子為可見
        game.level.map.seens(x, y, true)  -- 記住已看見
    end, true, false, true)
end

function _M:die(src)
    -- 玩家死亡時顯示死亡對話框（而非直接移除）
    game:registerDialog(require("mod.dialogs.DeathDialog").new(self))
end
```

**關鍵差異**：
- 玩家 `act()` 設定 `game.paused = true` 等待輸入。
- 移動後呼叫 `moveViewSurround` 捲動地圖視口。
- 死亡不直接移除角色，而是顯示 DeathDialog。

