## 16. Game 主控制器（下）-- 輸入設定

### 鍵盤輸入

```lua
function _M:setupCommands()
    self.normal_key = self.key
    self:targetSetupKey()
    self.key:unicodeInput(true)

    self.key:addBinds{
        -- 移動（方向鍵 / 小鍵盤）
        MOVE_LEFT       = function() self.player:moveDir(4) end,
        MOVE_RIGHT      = function() self.player:moveDir(6) end,
        MOVE_UP         = function() self.player:moveDir(8) end,
        MOVE_DOWN       = function() self.player:moveDir(2) end,
        MOVE_LEFT_UP    = function() self.player:moveDir(7) end,
        MOVE_LEFT_DOWN  = function() self.player:moveDir(1) end,
        MOVE_RIGHT_UP   = function() self.player:moveDir(9) end,
        MOVE_RIGHT_DOWN = function() self.player:moveDir(3) end,
        MOVE_STAY       = function() self.player:useEnergy() end,

        -- 奔跑（Shift + 方向）
        RUN_LEFT  = function() self.player:runInit(4) end,
        RUN_RIGHT = function() self.player:runInit(6) end,
        RUN_UP    = function() self.player:runInit(8) end,
        RUN_DOWN  = function() self.player:runInit(2) end,

        -- 快捷鍵 1~12
        HOTKEY_1  = function() self.player:activateHotkey(1) end,
        HOTKEY_2  = function() self.player:activateHotkey(2) end,
        HOTKEY_3  = function() self.player:activateHotkey(3) end,
        HOTKEY_4  = function() self.player:activateHotkey(4) end,
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
                    e.change_zone and e.change_level
                        or self.level.level + e.change_level,
                    e.change_zone)
            else self.log("這裡沒有出口。") end
        end,

        REST = function() self.player:restInit() end,
        USE_TALENTS = function() self.player:useTalents() end,
        SAVE_GAME = function() self:saveGame() end,
        QUIT_GAME = function() self:onQuit() end,
        SCREENSHOT = function() self:saveScreenshot() end,

        EXIT = function()
            local menu = require("engine.dialogs.GameMenu").new{
                "resume", "keybinds", "video", "save", "quit"
            }
            self:registerDialog(menu)
        end,

        -- Lua 除錯主控臺（開發用）
        LUA_CONSOLE = function()
            self:registerDialog(DebugConsole.new())
        end,

        TOGGLE_NPC_LIST = function()
            self.show_npc_list = not self.show_npc_list
            self.player.changed = true
        end,
    }
    self.key:setCurrent()
end

-- 滑鼠輸入
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

-- 離開遊戲
function _M:onQuit()
    self.player:restStop()
    if not self.quit_dialog then
        self.quit_dialog = require("engine.dialogs.GameMenu").new{
            "resume", "save", "quit"
        }
        self:registerDialog(self.quit_dialog)
    end
end

function _M:saveGame()
    savefile_pipe:push(self.save_name, "game", self)
    self.log("儲存遊戲中...")
end
```

---

## 17. 死亡對話框

```lua
-- game/modules/hellodungeon/dialogs/DeathDialog.lua

require "engine.class"
local Dialog = require "engine.Dialog"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    Dialog.init(self, "你死了！", 400, 200)
    self.actor = actor

    self:addText(("你在第 %d 層倒下了。"):format(game.level.level), "red")
    self:addText(" ")
    self:addButton("重試（返回主選單）", function()
        self:unregisterDialog(self)
        game:setPlayerDead()  -- 刪除存檔返回主選單
    end)
end
```

**最簡版本**：

```lua
require "engine.class"
local Dialog = require "engine.Dialog"
module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
    Dialog.init(self, _t"死亡", 400, 150)
    self:addText(_t"你已死亡，遊戲結束。")
    self:addButton(_t"確認", function()
        game:setPlayerDead()
        self:unregisterDialog(self)
    end)
end
```

---

## 18. 執行模組

**放置**：
```
game/modules/hellodungeon/
```

**方式 A：Steam 安裝版（免編譯）**
```bash
cp -r hellodungeon ~/.local/share/Steam/.../TalesMajEyal/game/modules/
~/.local/share/Steam/.../TalesMajEyal/t-engine64
```

**方式 B：原始碼編譯**（需含 C 層完整原始碼）
```bash
premake4 gmake
make -C build
./bin/Debug/t-engine
```

**顯示在清單**：`init.lua` 若無 `show_only_on_cheat = true` 則直接顯示。若有則需在設定開啟 Cheat 模式。

---

## 19. 常見錯誤

| 錯誤 | 解法 |
|------|------|
| 模組不出現在清單 | 檢查 `init.lua` 的 `engine` 版本與 `game/engines/te4-X.Y.Z.teae` 一致；`short_name` 僅小寫字母數字 |
| `attempt to index a nil value` in load.lua | 確認所有 `require` 路徑正確；`loadDefinition` 使用虛擬路徑 `"/data/..."` |
| 地圖看不到 NPC | 確認 `zone.lua` 的 `generator.actor.class` 已設定；`npcs.lua` 有 `load(...)`；NPC `level_range` 與 zone 重疊 |
| 技能無法使用 | 確認 `load.lua` 有 `ActorTalents:loadDefinition("/data/talents.lua")`；技能在 `newTalentType` 宣告類型；常數名 `T_` + 大寫名稱 |
| 無法換層 | Grid 有 `change_level`；`Game.lua` 有 `CHANGE_LEVEL` 綁定；zone 生成器設定了 `up`/`down` |

---

## 下一步

- **教學 02**：物品系統（背包、裝備、消耗品）
- **教學 03**：多個地區（世界地圖）
- **教學 04**：任務系統
- **教學 05**：進階 AI（戰術評分）
- **教學 06**：ToME Addon 製作
