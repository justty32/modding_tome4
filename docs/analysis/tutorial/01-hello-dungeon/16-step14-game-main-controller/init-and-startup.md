`Game.lua` 是最複雜的部分，控制整個遊戲迴圈：

```lua
-- game/modules/hellodungeon/class/Game.lua

require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameTargeting"
require "engine.KeyBind"

local Savefile  = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone      = require "engine.Zone"
local Map       = require "engine.Map"
local Level     = require "engine.Level"
local Birther   = require "engine.Birther"

-- 你的自訂類別
local Grid      = require "mod.class.Grid"
local Actor     = require "mod.class.Actor"
local Player    = require "mod.class.Player"
local NPC       = require "mod.class.NPC"

-- UI 元件
local HotkeysDisplay  = require "engine.HotkeysDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay      = require "engine.LogDisplay"
local LogFlasher      = require "engine.LogFlasher"
local DebugConsole    = require "engine.DebugConsole"
local FlyingText      = require "engine.FlyingText"
local Tooltip         = require "engine.Tooltip"
local QuitDialog      = require "engine.dialogs.GameMenu"

-- 繼承回合制遊戲 + 瞄準系統
module(..., package.seeall, class.inherit(
    engine.GameTurnBased,
    engine.interface.GameTargeting
))

-- 初始化（首次載入）
function _M:init()
    -- 初始化回合制引擎
    -- 參數：KeyBind, 能量上限, 每回合獲得的能量
    engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)

    self.paused = true  -- 從暫停狀態開始
    self:loaded()       -- 執行載入後的初始化
end

-- 遊戲啟動
function _M:run()
    -- 建立 UI 元件
    -- LogFlasher：頂部閃光訊息
    self.flash = LogFlasher.new(0, 0, self.w, 20, nil, nil, nil, {255,255,255}, {0,0,0})
    -- LogDisplay：底部訊息日誌
    self.logdisplay = LogDisplay.new(
        0, self.h * 0.8,
        self.w * 0.5, self.h * 0.2,
        nil, nil, nil, {255,255,255}, {30,30,30}
    )
    -- HotkeysDisplay：快捷鍵列
    self.hotkeys_display = HotkeysDisplay.new(
        nil, self.w * 0.5, self.h * 0.8,
        self.w * 0.5, self.h * 0.2, {30,30,0}
    )
    -- ActorsSeenDisplay：視野內的 Actor 列表
    self.npcs_display = ActorsSeenDisplay.new(
        nil, self.w * 0.5, self.h * 0.8,
        self.w * 0.5, self.h * 0.2, {30,30,0}
    )
    self.tooltip = Tooltip.new(nil, nil, {255,255,255}, {30,30,30})
    self.flyers = FlyingText.new()
    self:setFlyingText(self.flyers)

    -- 建立便捷的 log 函數
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
        if e and self.level.map.seens(e.x, e.y) then self.log(style, ...) end
    end
    self.logPlayer = function(e, style, ...)
        if e == self.player then self.log(style, ...) end
    end

    self.log(self.flash.GOOD, "歡迎來到 #00FF00#Hello Dungeon！")

    -- 設定輸入
    self:setupCommands()
    self:setupMouse()

    -- 若無存檔，開始新遊戲
    if not self.player then self:newGame() end

    self.hotkeys_display.actor = self.player
    self.npcs_display.actor = self.player

    -- 啟動瞄準系統
    engine.interface.GameTargeting.init(self)

    -- 啟動遊戲引擎
    self:setCurrent()

    if self.level then self:setupDisplayMode() end
end

-- 新遊戲
function _M:newGame()
    self.player = Player.new{name=self.player_name, game_ender=true}
    Map:setViewerActor(self.player)
    self:setupDisplayMode()

    -- 開啟角色創建畫面
    self.creating_player = true
    local birth = Birther.new(nil, self.player, {"base", "role"}, function()
        -- 創建完成後：進入第 1 層
        self:changeLevel(1, "dungeon")
        self.player:resolve()       -- 解析所有 resolver（隨機屬性等）
        self.player:resolve(nil, true)
        self.player.energy.value = self.energy_to_act
        self.paused = true
        self.creating_player = false
    end)
    self:registerDialog(birth)
end

-- 從存檔載入後的初始化
function _M:loaded()
    engine.GameTurnBased.loaded(self)
    -- 告訴 Zone 使用哪些類別
    Zone:setup{
        npc_class  = "mod.class.NPC",
        grid_class = "mod.class.Grid",
    }
