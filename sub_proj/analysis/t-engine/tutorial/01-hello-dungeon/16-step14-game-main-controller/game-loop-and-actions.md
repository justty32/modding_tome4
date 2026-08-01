    Map:setViewerActor(self.player)
    -- 設定視口（地圖顯示區域）
    -- 參數：x, y, 寬, 高, 磁磚寬, 磁磚高, 字型, 視野距離, 使用背景色
    Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true)
    self.key = engine.KeyBind.new()
end

-- 設定顯示模式
function _M:setupDisplayMode()
    Map:setViewPort(200, 20, self.w - 200, math.floor(self.h * 0.80) - 20, 32, 32, nil, 22, true)
    Map:resetTiles()
    Map.tiles.use_images = false  -- false = ASCII 模式，true = 圖片模式

    if self.level then
        self.level.map:recreate()
        engine.interface.GameTargeting.init(self)
        self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
    end
end

-- 儲存遊戲
function _M:save()
    return class.save(self, self:defaultSavedFields{}, true)
end

-- 存檔描述（顯示在存檔選擇畫面）
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
        if self.zone then
            self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave()
        end
        self.zone = Zone.new(zone)  -- 載入地區（對應 data/zones/<zone>/zone.lua）
    end
    self.zone:getLevel(self, lev, old_lev)

    -- 根據移動方向放置玩家在對應的樓梯旁
    if lev > old_lev then
        self.player:move(self.level.default_up.x, self.level.default_up.y, true)
    else
        self.player:move(self.level.default_down.x, self.level.default_down.y, true)
    end
    self.level:addEntity(self.player)
end

function _M:getPlayer() return self.player end

function _M:isLoadable()
    return not self:getPlayer(true).dead
end

-- 遊戲 tick（核心迴圈）
function _M:tick()
    if self.level then
        self:targetOnTick()
        engine.GameTurnBased.tick(self)
    end
    -- 暫停時回傳 true（等待玩家輸入）
    if self.paused and not savefile_pipe.saving then return true end
end

-- 每回合回呼
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
        -- 重計 FOV
        if self.level.map.changed then
            self.player:playerFOV()
        end

        -- 繪製地圖
        self.level.map:display(nil, nil, nb_keyframe)

        -- 繪製瞄準游標
        self.target:display()

        -- 繪製小地圖（右上角）
        self.level.map:minimapDisplay(
            self.w - 200, 20,
            util.bound(self.player.x - 25, 0, self.level.map.w - 50),
            util.bound(self.player.y - 25, 0, self.level.map.h - 50),
            50, 50, 0.6)
    end

    -- 繪製 UI
    self.flash:toScreen(nb_keyframe)
    self.logdisplay:toScreen()
    if self.show_npc_list then
        self.npcs_display:toScreen()
    else
        self.hotkeys_display:toScreen()
    end
    if self.player then self.player.changed = false end

    self:targetDisplayTooltip()
    engine.GameTurnBased.display(self, nb_keyframe)
end

-- 設定鍵盤輸入
function _M:setupCommands()
    self.normal_key = self.key
    self:targetSetupKey()
    self.key:unicodeInput(true)

    self.key:addBinds{
        -- 移動（方向鍵 / 小鍵盤）
        MOVE_LEFT      = function() self.player:moveDir(4) end,
        MOVE_RIGHT     = function() self.player:moveDir(6) end,
        MOVE_UP        = function() self.player:moveDir(8) end,
        MOVE_DOWN      = function() self.player:moveDir(2) end,
        MOVE_LEFT_UP   = function() self.player:moveDir(7) end,
        MOVE_LEFT_DOWN = function() self.player:moveDir(1) end,
        MOVE_RIGHT_UP  = function() self.player:moveDir(9) end,
        MOVE_RIGHT_DOWN= function() self.player:moveDir(3) end,
        MOVE_STAY      = function() self.player:useEnergy() end,  -- 等待一回合

        -- 奔跑（Shift + 方向）
        RUN_LEFT       = function() self.player:runInit(4) end,
        RUN_RIGHT      = function() self.player:runInit(6) end,
        RUN_UP         = function() self.player:runInit(8) end,
        RUN_DOWN       = function() self.player:runInit(2) end,

        -- 快捷鍵（1~12）
        HOTKEY_1  = function() self.player:activateHotkey(1) end,
        HOTKEY_2  = function() self.player:activateHotkey(2) end,
        HOTKEY_3  = function() self.player:activateHotkey(3) end,
        HOTKEY_4  = function() self.player:activateHotkey(4) end,
