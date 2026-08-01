在 `Player.lua` 中加入按鍵處理函數：

```lua
-- game/modules/hellodungeon/class/Player.lua

require "engine.class"
local Actor = require "mod.class.Actor"

module(..., package.seeall, class.inherit(Actor))

function _M:init(t, no_default)
    t.body = t.body or {
        INVEN  = 20,
        WEAPON = 1,
    }
    Actor.init(self, t, no_default)
    self.player = true
end

--- 玩家行動入口（由 Game:tick() 呼叫）
function _M:act()
    if not Actor.act(self) then return end
    self:playerTurn()
end

--- 等待玩家輸入（暫停遊戲回合）
function _M:playerTurn()
    -- 暫停：讓遊戲迴圈等待玩家按鍵
    -- Game:key:on(...) 設定的事件處理器負責呼叫實際動作
    game.paused = true
end

--- 撿起腳下物品
function _M:pickup()
    -- 如果地板上只有一個物品，直接撿
    -- 如果有多個，顯示選擇對話框
    local objs = {}
    for i = Map.OBJECT, Map.OBJECT + 9 do
        local o = game.level.map:getObject(self.x, self.y, i)
        if o then objs[#objs+1] = {obj=o, idx=i - Map.OBJECT + 1} end
    end

    if #objs == 0 then
        game.logPlayer(self, "這裡什麼都沒有。")
        return
    elseif #objs == 1 then
        local o, num = self:pickupFloor(1, true)
        -- pickupFloor 自動顯示撿起訊息（vocal=true）
    else
        -- 多物品：顯示選擇視窗
        self:showPickupFloor("撿起什麼？", nil, function(o, item)
            self:pickupFloor(item, true)
        end)
    end
    self:useEnergy()
end

--- 顯示揹包
function _M:showEquipment_player()
    self:showEquipInven("裝備與揹包",
        nil,  -- filter：nil 表示顯示所有物品
        function(o, inven, item, button)
            if button == "left" then
                -- 左鍵：嘗試裝備（若是裝備欄的物品則卸下）
                local inven_o = self:getInven(inven)
                if inven_o and inven_o.worn then
                    -- 物品已裝備 → 卸下
                    local ro = self:takeoffObject(inven, item)
                    if ro then
                        self:addObject(self.INVEN_INVEN, ro)
                        game.logPlayer(self, "卸下了 %s。", ro:getName{do_color=true})
                        self:useEnergy()
                    end
                else
                    -- 未裝備 → 嘗試裝備
                    local ro, rs = self:wearObject(o, true, true)
                    if ro then
                        -- wearObject 回傳被替換的物品，放回揹包
                        if not self:addObject(self.INVEN_INVEN, ro) then
                            -- 揹包滿了，直接放地板
                            game.level.map:addObject(self.x, self.y, ro)
                        end
                        self:useEnergy()
                    end
                end
            elseif button == "right" then
                -- 右鍵：使用物品（藥水等）
                if o.use_simple then
                    local r = o.use_simple.use(o, self)
                    if r and r.used then
                        -- 從揹包移除一個
                        self:removeObject(inven, item, 1)
                        self:useEnergy()
                    end
                end
            end
        end
    )
end

--- 丟棄選中的物品
function _M:dropItem()
    self:showEquipInven("丟棄什麼？",
        nil,
        function(o, inven, item, button)
            local ro = self:dropFloor(inven, item, true, true)
            if ro then
                self:useEnergy()
            end
        end
    )
end
```

接著在 `Game.lua` 的 `setupKeys()` 中將這些函數綁定到按鍵：

```lua
-- game/modules/hellodungeon/class/Game.lua
-- 在 setupKeys() 函數中加入（或修改）以下按鍵綁定

function _M:setupKeys()
    -- ... 移動按鍵（與教學 01 相同）...

    -- g：撿起腳下的物品
    self.key:addCommands{
        [{"_g"}] = function()
            if game.player then game.player:pickup() end
        end,
    }

    -- i：開啟揹包/裝備介面
    self.key:addCommands{
        [{"_i"}] = function()
            if game.player then game.player:showEquipment_player() end
        end,
    }

    -- d：丟棄物品
    self.key:addCommands{
        [{"_d"}] = function()
            if game.player then game.player:dropItem() end
        end,
    }

    -- a：使用揹包中的物品（快速使用）
    self.key:addCommands{
        [{"_a"}] = function()
            if game.player then
                game.player:showInventory("使用哪個物品？",
                    game.player:getInven("INVEN"),
                    function(o) return o.use_simple ~= nil end,  -- 只顯示可使用物品
                    function(o, item)
                        if o.use_simple then
                            local r = o.use_simple.use(o, game.player)
                            if r and r.used then
                                game.player:removeObject(game.player.INVEN_INVEN, item, 1)
                                game.player:useEnergy()
                            end
                        end
                    end
                )
            end
        end,
    }
end
```

**按鍵說明**：

| 按鍵 | 功能 |
|------|------|
| `g` | 撿起腳下物品 |
| `i` | 開啟裝備/揹包視窗（左鍵裝備/卸下，右鍵使用） |
| `d` | 開啟丟棄視窗 |
| `a` | 使用揹包中的消耗品 |

---
