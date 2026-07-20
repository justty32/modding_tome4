        HOTKEY_5  = function() self.player:activateHotkey(5) end,
        HOTKEY_6  = function() self.player:activateHotkey(6) end,
        HOTKEY_7  = function() self.player:activateHotkey(7) end,
        HOTKEY_8  = function() self.player:activateHotkey(8) end,
        HOTKEY_9  = function() self.player:activateHotkey(9) end,
        HOTKEY_10 = function() self.player:activateHotkey(10) end,
        HOTKEY_11 = function() self.player:activateHotkey(11) end,
        HOTKEY_12 = function() self.player:activateHotkey(12) end,

        -- 換層（站在樓梯上按 >/<）
        CHANGE_LEVEL = function()
            local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
            if self.player:enoughEnergy() and e.change_level then
                self:changeLevel(
                    e.change_zone and e.change_level or self.level.level + e.change_level,
                    e.change_zone)
            else
                self.log("這裡沒有出口。")
            end
        end,

        -- 休息（等待直到資源回滿）
        REST = function() self.player:restInit() end,

        -- 使用技能
        USE_TALENTS = function() self.player:useTalents() end,

        -- 存檔
        SAVE_GAME = function() self:saveGame() end,

        -- 離開（ESC）
        QUIT_GAME = function() self:onQuit() end,

        -- 截圖
        SCREENSHOT = function() self:saveScreenshot() end,

        -- 遊戲選單
        EXIT = function()
            local menu = require("engine.dialogs.GameMenu").new{
                "resume", "keybinds", "video", "save", "quit"
            }
            self:registerDialog(menu)
        end,

        -- Lua 除錯主控台（開發用）
        LUA_CONSOLE = function()
            self:registerDialog(DebugConsole.new())
        end,

        -- 切換 NPC 列表
        TOGGLE_NPC_LIST = function()
            self.show_npc_list = not self.show_npc_list
            self.player.changed = true
        end,
    }
    self.key:setCurrent()
end

-- 設定滑鼠輸入
function _M:setupMouse(reset)
    if reset then self.mouse:reset() end
    self.mouse:registerZone(
        Map.display_x, Map.display_y,
        Map.viewport.width, Map.viewport.height,
        function(button, mx, my, xrel, yrel, bx, by, event)
            if self:targetMouse(button, mx, my, xrel, yrel, event) then return end
            self.player:mouseHandleDefault(self.key, self.key == self.normal_key,
                button, mx, my, xrel, yrel, event)
        end)
    self.mouse:registerZone(
        self.logdisplay.display_x, self.logdisplay.display_y,
        self.w, self.h,
        function(button)
            if button == "wheelup"   then self.logdisplay:scrollUp(1) end
            if button == "wheeldown" then self.logdisplay:scrollUp(-1) end
        end, {button=true})
    self.mouse:setCurrent()
end

-- 離開遊戲確認
function _M:onQuit()
    self.player:restStop()
    if not self.quit_dialog then
        self.quit_dialog = require("engine.dialogs.GameMenu").new{
            "resume", "save", "quit"
        }
        self:registerDialog(self.quit_dialog)
    end
end

-- 存檔（將自身推入存檔管線）
function _M:saveGame()
    savefile_pipe:push(self.save_name, "game", self)
    self.log("儲存遊戲中...")
end
```

---
