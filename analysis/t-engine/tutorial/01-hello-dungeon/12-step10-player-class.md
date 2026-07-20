`Player` 繼承 `Actor`，加上玩家特有的輸入處理與介面：

```lua
-- game/modules/hellodungeon/class/Player.lua

require "engine.class"
require "mod.class.Actor"
require "engine.interface.PlayerRest"    -- 自動休息
require "engine.interface.PlayerRun"     -- 自動奔跑
require "engine.interface.PlayerMouse"   -- 滑鼠移動
require "engine.interface.PlayerHotkeys" -- 快捷鍵系統

local Map = require "engine.Map"
local DeathDialog = require "mod.dialogs.DeathDialog"

module(..., package.seeall, class.inherit(
    mod.class.Actor,
    engine.interface.PlayerRest,
    engine.interface.PlayerRun,
    engine.interface.PlayerMouse,
    engine.interface.PlayerHotkeys
))

function _M:init(t, no_default)
    -- 玩家固定顯示為 '@'，白色
    t.display = t.display or '@'
    t.color_r  = t.color_r  or 230
    t.color_g  = t.color_g  or 230
    t.color_b  = t.color_b  or 230

    t.player   = true        -- 標記為玩家
    t.type     = "humanoid"
    t.subtype  = "player"
    t.faction  = "players"   -- 陣營名稱
    t.lite     = t.lite or 0 -- 燈光範圍（載入時設定）

    mod.class.Actor.init(self, t, no_default)
    engine.interface.PlayerHotkeys.init(self, t)

    self.descriptor = {}  -- 角色創建的描述符記錄
end

-- 移動時讓視角跟著玩家
function _M:move(x, y, force)
    local moved = mod.class.Actor.move(self, x, y, force)
    if moved then
        game.level.map:moveViewSurround(self.x, self.y, 8, 8)
    end
    return moved
end

-- 玩家每回合行動
function _M:act()
    if not mod.class.Actor.act(self) then return end

    -- 清空閃光訊息
    game.flash:empty()

    -- 執行自動休息/奔跑，若都沒有則暫停等待輸入
    if not self:restStep() and not self:runStep() and self.player then
        game.paused = true
    end
end

-- 消耗能量時，解除暫停（讓其他 Actor 繼續行動）
function _M:useEnergy(val)
    mod.class.Actor.useEnergy(self, val)
    if self.player and self.energy.value < game.energy_to_act then
        game.paused = false
    end
end

-- 計算玩家視野（FOV）
local fovdist = {}
for i = 0, 30 * 30 do
    fovdist[i] = math.max((20 - math.sqrt(i)) / 14, 0.6)
end

function _M:playerFOV()
    game.level.map:cleanFOV()
    -- 正常視野（受地形阻擋）
    self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
        game.level.map:apply(x, y, fovdist[sqdist])
    end, true, false, true)
    -- 燈光範圍（無視黑暗但受牆壁阻擋）
    self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist)
        game.level.map:applyLite(x, y)
    end, true, true, true)
end

-- 受傷時停止休息/奔跑
function _M:onTakeHit(value, src)
    self:runStop(_t"受到傷害")
    self:restStop(_t"受到傷害")
    local ret = mod.class.Actor.onTakeHit(self, value, src)
    -- 血量低於 30% 時顯示警告飄字
    if self.life < self.max_life * 0.3 then
        local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
        game.flyers:add(sx, sy, 30, 0, 2, _t"血量危險！", {255, 0, 0}, true)
    end
    return ret
end

-- 玩家死亡
function _M:die(src)
    if self.game_ender then
        engine.interface.ActorLife.die(self, src)
        game.paused = true
        self.energy.value = game.energy_to_act
        game:registerDialog(DeathDialog.new(self))  -- 顯示死亡對話框
    else
        mod.class.Actor.die(self, src)
    end
end

-- 設定角色名稱（同時設定存檔名稱）
function _M:setName(name)
    self.name = name
    game.save_name = name
end

-- 升級飄字
function _M:levelup()
    mod.class.Actor.levelup(self)
    local x, y = game.level.map:getTileToScreen(self.x, self.y)
    game.flyers:add(x, y, 80, 0.5, -2, _t"升級了！", {0, 255, 255})
    game.log("#00ffff#歡迎來到第 %d 等級！", self.level)
end

-- 取得目標（委派給 Game 的瞄準系統）
function _M:getTarget(typ)
    return game:targetGetForPlayer(typ)
end

function _M:setTarget(target)
    return game:targetSetForPlayer(target)
end

-- 休息條件：無敵人且資源未滿
function _M:restCheck()
    -- 先檢查是否有敵人在視野內
    local seen = false
    core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20,
        function(_, x, y) return game.level.map:opaque(x, y) end,
        function(_, x, y)
            local actor = game.level.map(x, y, game.level.map.ACTOR)
            if actor and self:reactionToward(actor) < 0
               and self:canSee(actor) and game.level.map.seens(x, y) then
                seen = true
            end
        end, nil)
    if seen then return false, "發現敵人" end

    -- 檢查是否需要回復
    if self:getPower() < self:getMaxPower() and self.power_regen > 0 then return true end
    if self.life < self.max_life and self.life_regen > 0 then return true end

    return false, "所有資源已滿"
end

-- 奔跑條件：無敵人且無有趣地形
function _M:runCheck()
    local seen = false
    core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20,
        function(_, x, y) return game.level.map:opaque(x, y) end,
        function(_, x, y)
            local actor = game.level.map(x, y, game.level.map.ACTOR)
            if actor and self:reactionToward(actor) < 0
               and self:canSee(actor) and game.level.map.seens(x, y) then
                seen = true
            end
        end, nil)
    if seen then return false, "發現敵人" end

    local noticed = false
    self:runScan(function(x, y)
        local grid = game.level.map(x, y, Map.TERRAIN)
        if grid and grid.notice then noticed = "有趣地形" end
    end)
    if noticed then return false, noticed end

    self:playerFOV()
    return engine.interface.PlayerRun.runCheck(self)
end
```

---
