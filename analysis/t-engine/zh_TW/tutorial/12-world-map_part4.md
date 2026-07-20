---

## 步驟三：大地圖 Zone 定義

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

## 步驟四：起點村莊 Zone

### 檔案：`mod/data/zones/town_a/zone.lua`

城鎮使用靜態地圖（手工設計），並設定持久化。

```lua
-- mod/data/zones/town_a/zone.lua
-- 起點村莊

local Zone = require "engine.Zone"

return Zone.new("town_a", {
    name        = "起點村莊",
    level_range = {1, 1},
    max_level   = 1,

    width  = 30,
    height = 25,

    persistent    = "zone",
    all_remembered = true,
    all_lited      = true,

    grid_list = require("mod.class.Grid"):loadList{
        "mod/data/grids/general.lua",
        "mod/data/grids/town.lua",    -- 城鎮專用地形
    },
    npc_list = require("mod.class.NPC"):loadList{
        "mod/data/npcs/town_a_npcs.lua",  -- 村莊居民、商人
    },
    object_list = require("mod.class.Object"):loadList{
        "mod/data/objects/consumables.lua",
        "mod/data/objects/equipment.lua",
    },

    generator = {
        map   = {class = "engine.generator.map.Static", map = "town_a"},
        actor = {class = "engine.generator.actor.OnceAtCoord"},
    },

    on_enter = function(lev, old_lev)
        game.logPlayer(game.player, "#YELLOW#你進入了起點村莊。")
    end,
})
```

### 城鎮出口地形（`mod/data/grids/town.lua` 摘錄）

每個城鎮都需要一個「出口」地形，讓玩家返回大地圖：

```lua
-- mod/data/grids/town.lua（摘錄）

-- 城鎮通用地板 / 牆壁
newEntity{define_as="TOWN_FLOOR", name="石板地",
    display='.', color_r=180, color_g=180, color_b=160,
    back_color=colors.DARK_GREY}

newEntity{define_as="TOWN_WALL", name="石牆",
    display='#', color_r=150, color_g=150, color_b=150,
    back_color=colors.DARK_GREY,
    always_remember=true, does_block_move=true, block_sight=true}

-- ★ 關鍵：城鎮出口 → 返回大地圖
newEntity{
    define_as = "TOWN_EXIT",
    name = "城鎮出口",
    display = '<', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice          = true,
    always_remember = true,

    -- 返回 wilderness Zone 的第 1 層
    change_level = 1,
    change_zone  = "wilderness",
}
```
