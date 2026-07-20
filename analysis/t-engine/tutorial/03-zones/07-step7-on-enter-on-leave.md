Zone 支援進入/離開時的生命週期回調，放在 `zone.lua` 中：

```lua
-- data/zones/town/zone.lua

return {
    -- ... 其他欄位 ...

    -- 進入城鎮時觸發
    on_enter = function(self, lev, old_lev, zone)
        -- self = Zone 物件
        -- lev  = 要進入的樓層號
        -- zone = 來源地區（離開前的 Zone 物件，可能是 nil）
        game.log("#YELLOW#歡迎回到賢者城鎮！")
    end,

    -- 離開城鎮時觸發
    on_leave = function(self, lev, new_lev, new_zone)
        -- self = 即將離開的 Zone
        -- new_zone = 目標地區名稱（字串）
        if new_zone == "dungeon" then
            game.log("#RED#你進入了黑暗的地城…小心！")
        end
    end,
}
```

這兩個回調在 `Zone:getLevel()` 和 `Zone:leaveLevel()` 中被呼叫：

```lua
-- engine/Zone.lua（簡化版）
function _M:getLevel(game, lev, old_lev)
    -- ...生成或載入樓層...
    if self.on_enter then self:on_enter(lev, old_lev, old_zone) end
end

function _M:leaveLevel(no_close, lev, old_lev)
    if self.on_leave then self:on_leave(old_lev, lev, nil) end
    -- ...儲存樓層狀態...
end
```

---
