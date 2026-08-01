## 7. 整合到 Game.lua 與 Player.lua

### 7.1 在 Game.lua 中建立 HUD 並渲染

```lua
-- game/modules/hellodungeon/class/Game.lua

function _M:run()
    -- ... 原有初始化 ...

    -- 建立連技橫條（放在螢幕底部中央）
    local TechniqueBar = require "mod.class.ui.TechniqueBar"
    local bar_w = (80 + 4) * 5 + 120  -- 與 TechniqueBar 的常數一致
    local bar_x = (self.w - bar_w) / 2
    local bar_y = self.h - 80         -- 距離底部 80 像素
    self.technique_bar = TechniqueBar.new(self.player, bar_x, bar_y)

    -- ... 繼續其他初始化 ...
end

function _M:display(nb_keyframe)
    -- ... 其他繪製 ...

    -- 繪製連技橫條（放在地圖和其他 HUD 之後）
    if self.technique_bar then
        self.technique_bar:toScreen()
    end

    -- ... 其他繪製 ...
end

-- 在滑鼠事件處理中轉發點擊
function _M:mouseEvent(button, mx, my, xrel, yrel)
    if self.technique_bar and self.technique_bar:mouseEvent(button, mx, my) then
        return  -- 橫條消化了這個點擊
    end
    -- ... 其他滑鼠事件處理 ...
end
```

### 7.2 在 Player.lua 加入數字鍵 1~5 直接使用槽位

```lua
-- game/modules/hellodungeon/class/Game.lua（setupCommands 中）

-- 數字鍵 1~5：使用對應槽位的連技
for slot = 1, 5 do
    local s = slot  -- 閉包捕獲
    self.key:addCommands{
        [{"_"..tostring(s), shift=false}] = function()
            if self.player then
                self.player:useTechniqueInSlot(s)
            end
        end,
    }
end

-- T 鍵：開啟連技管理介面（槽位裝填）
self.key:addCommands{
    [{"_t"}] = function()
        if self.player then
            self:showTechniqueManagement()
        end
    end,
}
```

### 7.3 連技管理介面（槽位裝填）

```lua
-- game/modules/hellodungeon/class/Game.lua

function _M:showTechniqueManagement()
    local Dialog = require "engine.ui.Dialog"
    local List = require "engine.ui.List"
    local Textzone = require "engine.ui.Textzone"

    local p = self.player
    local d = Dialog.new("連技管理", 600, 400)

    -- 左側：已習得的連技清單
    local known_list = {}
    for id, entry in pairs(p.techniques.known) do
        local t = techniques_def[id]
        if t then
            known_list[#known_list+1] = {
                id   = id,
                name = ("%s [%s] 熟練:%.0f%%"):format(
                    t.name, t.type, entry.proficiency),
                def  = t,
            }
        end
    end
    table.sort(known_list, function(a, b) return a.name < b.name end)

    -- 右側：目前槽位狀態
    local slot_list = {}
    for i = 1, 5 do
        local t = p:getTechniqueInSlot(i)
        slot_list[#slot_list+1] = {
            slot = i,
            name = ("槽位 %d：%s"):format(i, t and t.name or "（空白）"),
        }
    end

    local selected_technique = nil

    local c_known = List.new{width=260, height=d.ih-40,
        list = known_list,
        fct = function(item) selected_technique = item end,
    }
    local c_slots = List.new{width=260, height=d.ih-40,
        list = slot_list,
        fct = function(item)
            if selected_technique then
                -- 將選中的連技放入此槽位
                p:setTechniqueSlot(item.slot, selected_technique.id)
                -- 更新槽位清單文字
                item.name = ("槽位 %d：%s"):format(
                    item.slot, selected_technique.def.name)
                c_slots:regenList()
                selected_technique = nil
            end
        end,
    }

    d:loadUI{
        {left=0,  top=0, ui=c_known},
        {right=0, top=0, ui=c_slots},
    }
    d:setupUI()

    -- 提示文字
    d.key:addCommands{
        _DELETE = function()
            -- 在槽位清單選中時，按 Delete 清空
            local sel = c_slots.sel
            if sel then
                p:setTechniqueSlot(slot_list[sel].slot, nil)
                slot_list[sel].name = ("槽位 %d：（空白）"):format(slot_list[sel].slot)
                c_slots:regenList()
            end
        end,
    }
    game:registerDialog(d)
end
```
