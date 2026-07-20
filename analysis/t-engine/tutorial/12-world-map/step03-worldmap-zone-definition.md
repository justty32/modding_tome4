### 檔案：`mod/data/zones/wilderness/zone.lua`

```lua
-- mod/data/zones/wilderness/zone.lua
-- 大地圖 Zone：整個世界的俯瞰地圖

local Zone = require "engine.Zone"

return Zone.new("wilderness", {
    name      = "世界地圖",
    level_range = {1, 1},
    max_level   = 1,

    -- 地圖尺寸必須與 wilderness.lua 的 ASCII 一致
    width  = 50,
    height = 30,

    -- ★ 大地圖通常設為持久化
    -- 若大地圖有動態地點解鎖（如摧毀敵營後地形改變），需要 persistent
    persistent = "zone",

    -- 整張地圖從一開始就全部可見
    all_remembered = true,
    all_lited      = true,

    -- 只載入大地圖地形（不需要 NPC / Object 列表）
    grid_list = require("mod.class.Grid"):loadList{
        "mod/data/grids/wilderness.lua",
    },
    npc_list    = {},   -- 大地圖上不放置 NPC（或可加入旅行商人）
    object_list = {},

    generator = {
        map = {
            class = "engine.generator.map.Static",
            map   = "wilderness",   -- 對應 data/maps/wilderness.lua
        },
        actor = {
            class = "engine.generator.actor.OnceAtCoord",
        },
    },

    -- 進入大地圖時的提示
    on_enter = function(lev, old_lev)
        if old_lev then  -- 從子地圖返回
            game.logPlayer(game.player,
                "你回到了世界地圖。")
        else             -- 首次進入（遊戲開始）
            game.logPlayer(game.player,
                "#LIGHT_GREEN#歡迎來到這個世界。按 [>] 進入地點，按 [方向鍵] 在地圖上移動。")
        end
    end,
})
```

---
