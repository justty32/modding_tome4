**問題**：玩家進入地城後打了 5 層，回到城鎮，再進入地城，會從第幾層開始？

**引擎行為**：`Zone:getLevel(game, lev, old_lev)` 如果對應樓層已存在（`zone.memory_levels[lev]`），就直接讀取快取，不重新生成。所以玩家會回到第 1 層（城鎮出口指定 `change_level=1`）。

**如果想讓玩家回到「最後一次離開地城的那一層」**，需要追蹤這個狀態：

```lua
-- 在 Game.lua 中加入輔助功能：
function _M:changeLevel(lev, zone)
    -- ... 原本的程式碼 ...

    -- 特殊處理：記住玩家離開地城時在哪一層
    if zone and zone ~= (self.zone and self.zone.short_name) then
        if self.zone and self.zone.short_name == "dungeon" then
            -- 離開地城時記錄層數
            self.player.last_dungeon_level = self.level and self.level.level
        end
    end
end
```

---
