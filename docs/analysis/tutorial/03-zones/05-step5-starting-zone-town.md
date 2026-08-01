在 `Game:run()` 中將初始 `changeLevel` 改為從城鎮開始：

```lua
-- game/modules/hellodungeon/class/Game.lua

function _M:run()
    -- ... （初始化程式碼，與教學 01 相同）...

    -- 從城鎮開始，而不是直接進入地城
    self:changeLevel(1, "town")

    -- ... （其他初始化）...
end
```

---
