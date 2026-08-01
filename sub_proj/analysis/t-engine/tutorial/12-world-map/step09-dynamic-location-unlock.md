有時需要根據遊戲進度解鎖新地點（例如完成任務後大地圖出現新城鎮）。

### 在 `camp_state`（或 `game.flags`）中記錄解鎖狀態

```lua
-- 在任務完成回呼中：
game.flags = game.flags or {}
game.flags.town_b_unlocked = true

-- 在大地圖地形的 on_move 中，解鎖地點標記
-- 注意：這需要動態替換地圖 Grid
```

### 動態在大地圖上添加新地點

```lua
-- 任務完成後呼叫（可在 Quest on_complete 中執行）
function _M:unlockWorldLocation(x, y, grid_id)
    -- 只在玩家當前在大地圖時立即生效；否則存為 pending，下次進入大地圖時套用
    if game.zone and game.zone.short_name == "wilderness" then
        local Map = require "engine.Map"
        local new_grid = game.zone.grid_list[grid_id]
        if new_grid then
            game.level.map(x, y, Map.TERRAIN, new_grid)
            game.level.map.changed = true
            game.logPlayer(game.player,
                "#LIGHT_BLUE#大地圖上出現了新的地點！")
        end
    else
        -- 存入 pending，下次進入 wilderness 時套用
        game.pending_world_unlocks = game.pending_world_unlocks or {}
        table.insert(game.pending_world_unlocks, {x=x, y=y, grid=grid_id})
    end
end
```

```lua
-- wilderness/zone.lua → on_enter（套用 pending 解鎖）
on_enter = function(lev, old_lev)
    if game.pending_world_unlocks then
        local Map = require "engine.Map"
        for _, unlock in ipairs(game.pending_world_unlocks) do
            local new_grid = game.zone.grid_list[unlock.grid]
            if new_grid then
                game.level.map(unlock.x, unlock.y, Map.TERRAIN, new_grid)
            end
        end
        game.level.map.changed = true
        game.pending_world_unlocks = nil   -- 清除 pending 列表
    end
end,
```

---
