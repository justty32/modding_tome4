在 `example/class/Game.lua` 中已有完整的基礎實作：

```lua
function _M:changeLevel(lev, zone)
    local old_lev = (self.level and not zone) and self.level.level or -1000
    if zone then
        -- 離開舊地區
        if self.zone then
            self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave()
        end
        -- 建立新地區
        if type(zone) == "string" then
            self.zone = Zone.new(zone)
        else
            self.zone = zone
        end
    end
    -- 進入目標樓層
    self.zone:getLevel(self, lev, old_lev)

    -- 玩家出現在適當位置
    if lev > old_lev then
        self.player:move(self.level.default_up.x, self.level.default_up.y, true)
    else
        self.player:move(self.level.default_down.x, self.level.default_down.y, true)
    end
    self.level:addEntity(self.player)
end
```

**關鍵參數**：

| 情況 | `lev` | `zone` |
|------|-------|--------|
| 同地區下一層 | 當前層+1 | nil |
| 同地區上一層 | 當前層-1 | nil |
| 切換到新地區第1層 | 1 | `"zone_name"` |
| 切換到新地區特定層 | n | `"zone_name"` |

**地形觸發欄位**：

地形實體（Grid）上的兩個欄位控制切換行為：

```lua
change_level = 1,        -- 正數：往深處走（default_down 出現）
                          -- 負數：往上走（default_up 出現）
change_zone = "town",     -- 字串：切換到另一個地區（優先使用）
```

`Game:tick()` 或 `CHANGE_LEVEL` 按鍵動作讀取玩家腳下地形：

```lua
local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
if e.change_level then
    self:changeLevel(
        e.change_zone and e.change_level or self.level.level + e.change_level,
        e.change_zone
    )
end
```

注意：`e.change_zone` 存在時，`e.change_level` 是**目標地區的樓層號碼**（不是相對差值）。

---
