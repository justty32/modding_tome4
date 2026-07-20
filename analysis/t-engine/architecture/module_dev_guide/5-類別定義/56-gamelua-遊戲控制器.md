### 5.6 Game.lua — 遊戲控制器

Game 是模組中最複雜的類別，負責整個遊戲生命週期：

```lua
require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameTargeting"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Zone = require "engine.Zone"
local Birther = require "engine.Birther"

module(..., package.seeall, class.inherit(
    engine.GameTurnBased,
    engine.interface.GameTargeting
))

function _M:init()
    engine.GameTurnBased.init(self,
        engine.KeyBind.new(),   -- 鍵盤
        engine.Mouse.new(),     -- 滑鼠
        "mymod",                -- 存檔目錄名
        12, 14                  -- energy_to_act, energy_per_tick
    )
    self.paused = true  -- 回合制從暫停開始
end

function _M:run()
    -- 建立 UI 元件
    self.log = engine.LogDisplay.new(0, self.h * 0.80, self.w * 0.5, self.h * 0.20, nil, nil, nil, {255,255,255}, {30,30,30})
    self.logSeen = function(e, style, ...) if e and self.level.map.seens(e.x, e.y) then self.log(style, ...) end end
    self.hotkeys_display = engine.HotkeysDisplay.new(nil, self.w * 0.5, self.h * 0.80, self.w * 0.5, self.h * 0.20, {30,30,30})
    self.tooltip = engine.Tooltip.new(nil, nil, {255,255,255}, {30,30,30})
    self.flyers = engine.FlyingText.new()

    -- 設定操作
    self:setupCommands()
    self:setupMouse()

    -- 若是新遊戲，啟動角色創建
    if not self.player then self:newGame() end
end

function _M:newGame()
    -- Birther 系統處理角色創建
    self.player = require("mod.class.Player").new{
        name = "Player", faction = "players",
    }
    self:setupPlayer(self.player)
    -- 或使用 Birther 對話框：
    -- self:registerDialog(Birther.new(self.player, ...))
end

-- 切換關卡
function _M:changeLevel(lev, zone)
    -- 離開當前關卡
    if self.level then
        self:leaveLevel(self.level, lev)
    end

    -- 載入/生成新關卡
    if zone then
        self.zone = Zone.new(zone)
    end
    self.level = self.zone:getLevel(self, lev)

    -- 放置玩家到入口
    local spot = self.level:pickSpot{type="up"}
    if spot then
        self.player:move(spot.x, spot.y, true)
    end

    -- 將玩家加入關卡
    self.level:addEntity(self.player)

    -- 初始化地圖顯示
    self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
end

function _M:leaveLevel(level, lev)
    -- 儲存玩家在此關卡的位置
    self.player.x_old, self.player.y_old = self.player.x, self.player.y
    level:removeEntity(self.player)
end

function _M:tick()
    if self.paused then return true end
    engine.GameTurnBased.tick(self)
    -- 玩家行動後自動暫停
    if self.player and not self.player:enoughEnergy() then
        self.paused = true
    end
    return true
end

function _M:display(nb_keyframe)
    -- 繪製地圖
    if self.level and self.level.map then
        self.level.map:display()
    end
    -- 繪製 UI 元件
    self.log:display()
    self.hotkeys_display:display()
end

function _M:setupCommands()
    -- 綁定鍵位到動作
    self.key:addBinds{
        MOVE_LEFT  = function() self.player:move(self.player.x-1, self.player.y) end,
        MOVE_RIGHT = function() self.player:move(self.player.x+1, self.player.y) end,
        MOVE_UP    = function() self.player:move(self.player.x, self.player.y-1) end,
        MOVE_DOWN  = function() self.player:move(self.player.x, self.player.y+1) end,

        REST = function() self.player:restInit(100, "resting", "rested") end,
        RUN  = function() self.player:runInit() end,

        USE_TALENT = function()
            self:registerDialog(require("engine.dialogs.UseTalents").new(self.player))
        end,

        CHANGE_LEVEL = function()
            local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
            if e.change_level then
                self:changeLevel(
                    self.level.level + e.change_level,
                    e.change_zone
                )
            end
        end,
    }
end
```

---
