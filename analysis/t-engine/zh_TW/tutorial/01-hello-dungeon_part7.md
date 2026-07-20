## 16. Game 主控制器（上）

`Game.lua` 控制整個遊戲迴圈，最複雜的部分：

```lua
-- game/modules/hellodungeon/class/Game.lua

require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameTargeting"
require "engine.KeyBind"

local Savefile   = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone       = require "engine.Zone"
local Map        = require "engine.Map"
local Level      = require "engine.Level"
local Birther    = require "engine.Birther"

local Grid   = require "mod.class.Grid"
local Actor  = require "mod.class.Actor"
local Player = require "mod.class.Player"
local NPC    = require "mod.class.NPC"

local HotkeysDisplay  = require "engine.HotkeysDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay      = require "engine.LogDisplay"
local LogFlasher      = require "engine.LogFlasher"
local DebugConsole    = require "engine.DebugConsole"
local FlyingText      = require "engine.FlyingText"
local Tooltip         = require "engine.Tooltip"
local QuitDialog      = require "engine.dialogs.GameMenu"

module(..., package.seeall, class.inherit(
    engine.GameTurnBased,
    engine.interface.GameTargeting
))

-- 初始化（首次載入）
function _M:init()
    -- 參數：KeyBind, 能量上限, 每回合能量
    engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
    self.paused = true
    self:loaded()
end

-- 遊戲啟動
function _M:run()
    -- UI 元件
    self.flash = LogFlasher.new(0, 0, self.w, 20,
        nil, nil, nil, {255,255,255}, {0,0,0})
    self.logdisplay = LogDisplay.new(
        0, self.h * 0.8, self.w * 0.5, self.h * 0.2,
        nil, nil, nil, {255,255,255}, {30,30,30})
    self.hotkeys_display = HotkeysDisplay.new(
        nil, self.w * 0.5, self.h * 0.8,
        self.w * 0.5, self.h * 0.2, {30,30,0})
    self.npcs_display = ActorsSeenDisplay.new(
        nil, self.w * 0.5, self.h * 0.8,
        self.w * 0.5, self.h * 0.2, {30,30,0})
    self.tooltip = Tooltip.new(nil, nil, {255,255,255}, {30,30,30})
    self.flyers = FlyingText.new()
    self:setFlyingText(self.flyers)

    -- 便捷 log 函數
    self.log = function(style, ...)
        if type(style) == "number" then
            self.logdisplay(...)
            self.flash(style, ...)
        else
            self.logdisplay(style, ...)
            self.flash(self.flash.NEUTRAL, style, ...)
        end
    end
    self.logSeen = function(e, style, ...)
        if e and self.level.map.seens(e.x, e.y) then
            self.log(style, ...)
        end
    end
    self.logPlayer = function(e, style, ...)
        if e == self.player then self.log(style, ...) end
    end

    self.log(self.flash.GOOD, "歡迎來到 #00FF00#Hello Dungeon！")

    self:setupCommands()
    self:setupMouse()

    if not self.player then self:newGame() end

    self.hotkeys_display.actor = self.player
    self.npcs_display.actor = self.player
    engine.interface.GameTargeting.init(self)
    self:setCurrent()

    if self.level then self:setupDisplayMode() end
end

-- 新遊戲
function _M:newGame()
    self.player = Player.new{name=self.player_name, game_ender=true}
    Map:setViewerActor(self.player)
    self:setupDisplayMode()

    self.creating_player = true
    local birth = Birther.new(nil, self.player, {"base", "role"}, function()
        self:changeLevel(1, "dungeon")
        self.player:resolve()
        self.player:resolve(nil, true)
        self.player.energy.value = self.energy_to_act
        self.paused = true
        self.creating_player = false
    end)
    self:registerDialog(birth)
end

-- 從存檔載入後初始化
function _M:loaded()
    engine.GameTurnBased.loaded(self)
    Zone:setup{
        npc_class  = "mod.class.NPC",
        grid_class = "mod.class.Grid",
    }
    Map:setViewerActor(self.player)
    -- 視口：x, y, 寬, 高, 磁磚寬, 磁磚高, 字型, 視野距離, 使用背景色
    Map:setViewPort(200, 20, self.w - 200,
        math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true)
    self.key = engine.KeyBind.new()
end

function _M:setupDisplayMode()
    Map:setViewPort(200, 20, self.w - 200,
        math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true)
    Map:resetTiles()
    Map.tiles.use_images = false  -- false = ASCII, true = 圖片模式

    if self.level then
        self.level.map:recreate()
        engine.interface.GameTargeting.init(self)
        self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
    end
end

function _M:save()
    return class.save(self, self:defaultSavedFields{}, true)
end

function _M:getSaveDescription()
    return {
        name = self.player.name,
        description = ("[Level %d of %s]"):format(self.level.level, self.zone.name),
    }
end

-- 離開關卡時保存玩家位置
function _M:leaveLevel(level, lev, old_lev)
    if level:hasEntity(self.player) then
        level.exited = level.exited or {}
        if lev > old_lev then
            level.exited.down = {x=self.player.x, y=self.player.y}
        else
            level.exited.up = {x=self.player.x, y=self.player.y}
        end
        level.last_turn = game.turn
        level:removeEntity(self.player)
    end
end

-- 換層/換地區
function _M:changeLevel(lev, zone)
    local old_lev = (self.level and not zone) and self.level.level or -1000
    if zone then
        if self.zone then self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave() end
        self.zone = Zone.new(zone)
    end
    self.zone:getLevel(self, lev, old_lev)

    if lev > old_lev then
        self.player:move(self.level.default_up.x, self.level.default_up.y, true)
    else
        self.player:move(self.level.default_down.x, self.level.default_down.y, true)
    end
    self.level:addEntity(self.player)
end

function _M:getPlayer() return self.player end
function _M:isLoadable() return not self:getPlayer(true).dead end

-- 核心迴圈
function _M:tick()
    if self.level then
        self:targetOnTick()
        engine.GameTurnBased.tick(self)
    end
    if self.paused and not savefile_pipe.saving then return true end
end

function _M:onTurn()
    if self.turn % 10 ~= 0 then return end
    self.level.map:processEffects()
end

-- 每幀渲染
function _M:display(nb_keyframe)
    if self.change_res_dialog then
        engine.GameTurnBased.display(self, nb_keyframe)
        return
    end

    if self.level and self.level.map and self.level.map.finished then
        if self.level.map.changed then self.player:playerFOV() end
        self.level.map:display(nil, nil, nb_keyframe)
        self.target:display()
        -- 小地圖（右上角）
        self.level.map:minimapDisplay(
            self.w - 200, 20,
            util.bound(self.player.x - 25, 0, self.level.map.w - 50),
            util.bound(self.player.y - 25, 0, self.level.map.h - 50),
            50, 50, 0.6)
    end

    self.flash:toScreen(nb_keyframe)
    self.logdisplay:toScreen()
    if self.show_npc_list then self.npcs_display:toScreen()
    else self.hotkeys_display:toScreen() end
    if self.player then self.player.changed = false end

    self:targetDisplayTooltip()
    engine.GameTurnBased.display(self, nb_keyframe)
end
```
