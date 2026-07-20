### 4.1 初始化（在 Game:load 中）

```lua
local FlyingText = require "engine.FlyingText"

function _M:load(...)
    ...
    -- 建立飄字系統
    self.flyers = FlyingText.new("/data/font/DroidSans.ttf", 14,
                                 "/data/font/DroidSans-Bold.ttf", 16)
    self.flyers:enableShadow(0.6)
    self:setFlyingText(self.flyers)
end
```

### 4.2 顯示飄字

```lua
-- 取得角色的螢幕像素座標
local function actorScreenPos(actor)
    local map = game.level.map
    local sx = map.display_x + (actor.x - map.mx) * map.tile_w
    local sy = map.display_y + (actor.y - map.my) * map.tile_h
    return sx, sy
end

-- 在受到傷害時顯示傷害數字
function _M:onTakeHit(value, src)
    local sx, sy = actorScreenPos(self)
    game.flyers:add(
        sx, sy,                          -- 螢幕位置
        30,                              -- 持續 30 幀
        (rng.range(0,2)-1) * 0.5,       -- 水平速度（-0.5 ~ 0.5）
        -3,                              -- 向上飄（負 y）
        tostring(math.ceil(value)),      -- 顯示文字
        {255, 80, 80},                   -- 紅色
        false                            -- 不使用大字
    )
    return value
end

-- 等級提升提示
local sx, sy = actorScreenPos(game.player)
game.flyers:add(sx, sy, 80, 0.5, -2, "LEVEL UP!", {0, 255, 255}, true)
```

`FlyingText:add` 參數：

| 參數 | 說明 |
|------|------|
| `x, y` | 螢幕像素座標 |
| `duration` | 持續幀數 |
| `xvel` | 水平速度（像素/幀） |
| `yvel` | 垂直速度（負值=向上） |
| `str` | 顯示文字 |
| `color` | `{r,g,b}` 表（0–255） |
| `bigfont` | `true` = 使用大號字 |

---
