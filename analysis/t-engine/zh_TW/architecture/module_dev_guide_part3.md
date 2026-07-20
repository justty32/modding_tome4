### 5.3 NPC.lua — AI 角色

```lua
require "engine.class"
require "mod.class.Actor"
require "engine.interface.ActorAI"

module(..., package.seeall, class.inherit(
    mod.class.Actor,
    engine.interface.ActorAI
))

function _M:init(t, no_default)
    mod.class.Actor.init(self, t, no_default)
    engine.interface.ActorAI.init(self, t, no_default)
end

function _M:act()
    if not mod.class.Actor.act(self) then return false end

    -- 計算視野
    self:computeFOV(self.sight or 20)
    -- 執行 AI 決策
    self:doAI()
end

-- 受傷時鎖定攻擊者為目標
function _M:onTakeHit(value, src)
    if src and src.player then
        self.ai_target.actor = src
    end
    return value
end
```

### 5.4 Grid.lua — 地形

```lua
require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
    engine.Grid.init(self, t, no_default)
end

-- 控制移動阻擋
function _M:block_move(x, y, e, act, couldpass)
    -- 門：碰到自動開啟
    if self.door_opened and act then
        game.level.map(x, y, engine.Map.TERRAIN,
            game.zone.grid_list[self.door_opened])
        return true  -- 消耗移動但通過
    end
    return self.does_block_move
end
```

### 5.5 Combat.lua — 戰鬥介面

```lua
-- game/modules/mymod/class/interface/Combat.lua
require "engine.class"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.make)

-- 碰撞邏輯：撞到敵人 = 攻擊
function _M:bumpInto(target)
    if target:reactionToward(self) < 0 then
        return self:attackTarget(target)
    end
end

-- 實際攻擊計算
function _M:attackTarget(target, mult)
    mult = mult or 1
    local dam = self.combat.dam * mult
    -- 傷害 = 攻擊力 + 力量加成 - 護甲
    dam = dam + self:getStr()
    dam = dam - (target.combat_armor or 0)
    if dam < 0 then dam = 0 end

    DamageType:get(DamageType.PHYSICAL).projector(
        self, target.x, target.y, DamageType.PHYSICAL, dam)
    self:useEnergy()
    return true
end
```

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
