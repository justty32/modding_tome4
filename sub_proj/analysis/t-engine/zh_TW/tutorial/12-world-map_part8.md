---

## 步驟八：玩家返回位置的精確控制

TE4 的 `changeLevel` 預設行為：

```
從 wilderness → town_a：
  記錄 last_exit_x = player.x, last_exit_y = player.y 到 town_a Level 的 data
從 town_a → wilderness：
  讀取 wilderness Level 的 last_exit，玩家出現在上次離開 wilderness 的位置
```

若需要精確控制「從城鎮離開後回到大地圖的哪個位置」，可以在 `on_enter` 中設定：

```lua
-- wilderness/zone.lua → on_enter（精確控制返回位置）
on_enter = function(lev, old_lev)
    -- 從 town_a 返回，強制讓玩家出現在城鎮入口旁
    if game.zone.short_name == "wilderness" then
        local prev = game.__current_level_source  -- 前一個 Zone 名稱
        local spawn_positions = {
            town_a            = {x=11, y=21},  -- TOWN_A_ENTRANCE 旁
            town_b            = {x=42, y=21},  -- TOWN_B_ENTRANCE 旁
            camp              = {x= 2, y=15},  -- CAMP_ENTRANCE 旁
            dungeon_forest    = {x=14, y= 6},  -- DUNGEON_FOREST 旁
            dungeon_fortress  = {x=15, y= 9},  -- DUNGEON_FORTRESS 旁
        }
        local pos = prev and spawn_positions[prev]
        if pos then
            game.player:move(pos.x, pos.y, true)
        end
    end
end,
```

> **更常見的做法**是讓引擎的預設行為處理（返回上次離開位置），只在必要時覆蓋。對多數用途，預設行為已足夠。

---

## 步驟九：動態地點解鎖（進階）

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
