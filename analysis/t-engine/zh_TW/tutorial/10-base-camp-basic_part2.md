## 步驟一：據點 Zone 定義

### 檔案：`mod/data/zones/camp/zone.lua`

```lua
-- mod/data/zones/camp/zone.lua
-- 據點 Zone：玩家的野外基地

local Zone = require "engine.Zone"

return Zone.new("camp", {
    name        = "野外據點",
    level_range = {1, 1},
    max_level   = 1,

    -- 地圖尺寸（必須與 data/maps/camp.lua 的 ASCII 地圖一致）
    width  = 25,
    height = 20,

    -- ★ 關鍵：整個 Zone 狀態持久化
    -- 離開時把 Level 物件存入 memory_levels，Zone 存檔時寫入磁碟
    persistent = "zone",

    -- 城鎮 / 據點：全部可見、全部有光
    all_remembered = true,
    all_lited      = true,

    -- 載入地形列表（通用地形 + 據點專用地形）
    grid_list = require("mod.class.Grid"):loadList{
        "mod/data/grids/general.lua",
        "mod/data/grids/camp.lua",
    },

    -- 載入 NPC 列表（據點工作人員）
    npc_list = require("mod.class.NPC"):loadList{
        "mod/data/npcs/camp_npcs.lua",
    },

    -- 載入物品列表（合成產品 + 據點材料）
    object_list = require("mod.class.Object"):loadList{
        "mod/data/objects/consumables.lua",  -- 藥水等消耗品（含合成產品）
        "mod/data/objects/materials.lua",    -- 材料（草藥、空瓶等）
    },

    generator = {
        -- 使用靜態地圖，不做隨機生成
        map = {
            class = "engine.generator.map.Static",
            map   = "camp",   -- 對應 data/maps/camp.lua
        },
        -- Static 產生器讀取地圖中的 actor defineTile 欄位自動放置 NPC
        -- 因此 actor 產生器設定為空
        actor = {
            class = "engine.generator.actor.OnceAtCoord",
        },
    },

    -- 進入 / 離開回呼（可選）
    on_enter = function(lev, old_lev)
        game.logPlayer(game.player, "#LIGHT_GREEN#你回到了你的野外據點。")
    end,
    on_leave = function(lev, old_lev)
        game.logPlayer(game.player, "你離開了據點。")
    end,
})
```

> **`all_remembered = true`**：讓地圖一開始就全部顯示在 minimap 上，不需要玩家親自走過每格。城鎮和據點通常開啟這個選項。

---

## 步驟二：靜態地圖

### 檔案：`mod/data/maps/camp.lua`

靜態地圖檔案在一個特殊環境中執行（由 `Static:getLoader()` 注入 `defineTile`、`addSpot` 等函式）。

```lua
-- mod/data/maps/camp.lua
-- 據點靜態地圖（25 寬 × 20 高）

-- ── 地形映射 ─────────────────────────────────────────────────
defineTile('.', "CAMP_FLOOR")                       -- 普通地板
defineTile('#', "CAMP_WALL")                        -- 木牆
defineTile('+', "CAMP_DOOR")                        -- 木門
defineTile('*', "CAMPFIRE")                         -- 篝火（踩上恢復 HP）
defineTile('<', "EXIT_TO_WORLD")                    -- 出口（返回大地圖）
defineTile('t', "CAMP_TREE")                        -- 裝飾樹木
defineTile('~', "CAMP_WATER")                       -- 裝飾水池

-- 第四參數 = actor define_as → 在 CAMP_FLOOR 上放置 NPC
defineTile('w', "CAMP_FLOOR", nil, "WORKBENCH_NPC") -- 合成工作台

-- ── 起點設定 ─────────────────────────────────────────────────
-- 玩家進入時出現的座標
startx = 12
starty = 17

-- ── ASCII 地圖（25 寬 × 20 高） ────────────────────────────
-- 索引從 0 開始：左上角 = (0,0)，右下角 = (24,19)
return [[
#########################
#.......................#
#.t...................t.#
#.....##########.......#
#....#+........+#......#
#....#..........#......#
#....#....*.....#......#
#....#..........#......#
#....+..........+#.....#
#.....##########.......#
#.....................t.#
#.t....w...............#
#......................#
#......................#
#......................#
#.....~.~..............#
#......................#
#......................#
#............<.........#
#########################
]]
```

> **地圖說明：**
> - 外圍 `#` 是圍牆；中央小屋內有 `*` 篝火
> - `w` 是工作台 NPC 的位置（地板上）
> - `<` 在底部，是返回大地圖的出口
> - `t`/`~` 是裝飾物件
