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

