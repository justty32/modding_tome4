## 9. NPC 掉落物

於 NPC 定義中加入 `on_die` 回呼，教學 01 之科博德為例：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua

newEntity{
    define_as = "BASE_KOBOLD",
    type = "humanoid", subtype = "kobold",
    display = "k", color = colors.GREEN,
    body = { INVEN=10, WEAPON=1 },
    ai = "dumb_talented", ai_state = { talent_in=3 },
    energy = { mod=1 },
    autolevel = "warrior",
    stats = { str=8, dex=8, con=8 },
}

newEntity{ base = "BASE_KOBOLD",
    name = "科博德",
    level_range = {1, 5},
    exp_worth = 1,
    max_life = resolvers.rngrange(10, 20),
    life_rating = 8,
    combat = { dam=resolvers.rngrange(2, 5), atk=4, apr=1 },
    -- 最簡掉落：不依賴 ToME resolvers.drops
    on_die = function(self, who)
        if not rng.percent(50) then return end
        local o = game.zone:makeEntity(game.level, "object", nil, nil, true)
        if o then
            game.level.map:addObject(self.x, self.y, o)
            game.logSeen(self, "%s 掉落了 %s！",
                self:getName():capitalize(), o:getName{do_color=true})
        end
    end,
}

newEntity{ base = "BASE_KOBOLD",
    name = "科博德戰士",
    level_range = {3, 8},
    exp_worth = 2,
    max_life = resolvers.rngrange(20, 35),
    life_rating = 10,
    combat = { dam=resolvers.rngrange(5, 10), atk=6, apr=2 },
    on_die = function(self, who)
        if not rng.percent(80) then return end
        local o = game.zone:makeEntity(game.level, "object", nil, nil, true)
        if o then game.level.map:addObject(self.x, self.y, o) end
    end,
}
```

> 此處直接使用 `on_die` + `zone:makeEntity()` 而非 `resolvers.drops`，因後者依賴 ToME 專屬的篩選系統（`game.state:entityFilter`）。移植至 ToME Addon 時才需改用 `resolvers.drops`。

---

## 10. 玩家撿物與使用操作

### Player.lua

```lua
-- game/modules/hellodungeon/class/Player.lua

require "engine.class"
local Actor = require "mod.class.Actor"

module(..., package.seeall, class.inherit(Actor))

function _M:init(t, no_default)
    t.body = t.body or { INVEN = 20, WEAPON = 1 }
    Actor.init(self, t, no_default)
    self.player = true
end

function _M:act()
    if not Actor.act(self) then return end
    self:playerTurn()
end

function _M:playerTurn()
    game.paused = true
end

--- 撿起腳下物品
function _M:pickup()
    local objs = {}
    for i = Map.OBJECT, Map.OBJECT + 9 do
        local o = game.level.map:getObject(self.x, self.y, i)
        if o then objs[#objs+1] = {obj=o, idx=i - Map.OBJECT + 1} end
    end

    if #objs == 0 then
        game.logPlayer(self, "這裡什麼都沒有。")
        return
    elseif #objs == 1 then
        self:pickupFloor(1, true)
    else
        self:showPickupFloor("撿起什麼？", nil, function(o, item)
            self:pickupFloor(item, true)
        end)
    end
    self:useEnergy()
end

--- 裝備/背包視窗
function _M:showEquipment_player()
    self:showEquipInven("裝備與背包", nil,
        function(o, inven, item, button)
            if button == "left" then
                local inven_o = self:getInven(inven)
                if inven_o and inven_o.worn then
                    local ro = self:takeoffObject(inven, item)
                    if ro then
                        self:addObject(self.INVEN_INVEN, ro)
                        game.logPlayer(self, "卸下了 %s。", ro:getName{do_color=true})
                        self:useEnergy()
                    end
                else
                    local ro, rs = self:wearObject(o, true, true)
                    if ro then
                        if not self:addObject(self.INVEN_INVEN, ro) then
                            game.level.map:addObject(self.x, self.y, ro)
                        end
                        self:useEnergy()
                    end
                end
            elseif button == "right" then
                if o.use_simple then
                    local r = o.use_simple.use(o, self)
                    if r and r.used then
                        self:removeObject(inven, item, 1)
                        self:useEnergy()
                    end
                end
            end
        end
    )
end

--- 丟棄
function _M:dropItem()
    self:showEquipInven("丟棄什麼？", nil,
        function(o, inven, item, button)
            local ro = self:dropFloor(inven, item, true, true)
            if ro then self:useEnergy() end
        end
    )
end
```

### Game.lua 按鍵綁定

```lua
-- game/modules/hellodungeon/class/Game.lua 之 setupKeys()

function _M:setupKeys()
    -- ... 移動按鍵 ...

    self.key:addCommands{ [{"_g"}] = function()
        if game.player then game.player:pickup() end
    end}

    self.key:addCommands{ [{"_i"}] = function()
        if game.player then game.player:showEquipment_player() end
    end}

    self.key:addCommands{ [{"_d"}] = function()
        if game.player then game.player:dropItem() end
    end}

    self.key:addCommands{ [{"_a"}] = function()
        if game.player then
            game.player:showInventory("使用哪個物品？",
                game.player:getInven("INVEN"),
                function(o) return o.use_simple ~= nil end,
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
    end}
end
```

### 按鍵說明

| 按鍵 | 功能 |
|------|------|
| `g` | 撿起腳下物品 |
| `i` | 開啟裝備/背包（左鍵裝備/卸下，右鍵使用） |
| `d` | 丟棄 |
| `a` | 使用背包中消耗品 |
