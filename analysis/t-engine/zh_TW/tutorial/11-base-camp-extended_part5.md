
## 步驟三：建造系統

### 設計原則

1. 建造前：地圖上顯示 `BUILD_SITE_*` 格（`?`）
2. 玩家與建造管理員 NPC 對話，消耗資源
3. 建造後：呼叫 `_applyBuildingToMap(btype)` 掃描地圖，把對應 `build_tag` 的格子替換為設施 Grid
4. `camp_state.buildings[btype] = true` 標記完成
5. Zone 的 `persistent = "zone"` 確保替換後的 Grid 在下次進入時依然存在

### 更新靜態地圖 `mod/data/maps/camp.lua`

```lua
-- mod/data/maps/camp.lua（完整更新版）

defineTile('.', "CAMP_FLOOR")
defineTile('#', "CAMP_WALL")
defineTile('+', "CAMP_DOOR")
defineTile('*', "CAMPFIRE")
defineTile('<', "EXIT_TO_WORLD")
defineTile('t', "CAMP_TREE")
defineTile('~', "CAMP_WATER")
defineTile('f', "BUILD_SITE_FARM")                    -- 農田建造地塊
defineTile('B', "BUILD_SITE_CHEST")                   -- 儲物箱建造地塊
defineTile('F', "BUILD_SITE_FIRE")                    -- 強化篝火建造地塊
defineTile('w', "CAMP_FLOOR", nil, "WORKBENCH_NPC")   -- 合成工作臺 NPC
defineTile('M', "CAMP_FLOOR", nil, "BUILD_MANAGER_NPC") -- 建造管理員 NPC

startx = 12
starty = 17

return [[
#########################
#.......................#
#.t...................t.#
#.....##########.......#
#....#+........+#......#
#....#...F......#......#
#....#....*.....#......#
#....#.........M#......#
#....+..........+#.....#
#.....##########.......#
#....f................t#
#.t....w.......B.......#
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

### 新增 `BUILD_MANAGER_NPC` 到 `mod/data/npcs/camp_npcs.lua`

```lua
-- mod/data/npcs/camp_npcs.lua（追加）

-- ── 建造管理員（靜止 NPC） ───────────────────────────────────
newEntity{
    define_as = "BUILD_MANAGER_NPC",
    type = "humanoid", subtype = "human",
    name = "建造管理員",
    display = 'M', color_r=100, color_g=200, color_b=255,
    faction = "players",

    ai       = "none",
    ai_state = {},

    never_move = true,
    exp_worth  = 0,
    max_life   = 9999,
    rank       = 1,
    stats      = {str=15, dex=10, con=15, mag=0, wil=15, cun=15},

    -- 玩家碰撞時觸發建造對話
    on_bump = function(self, who)
        if who ~= game.player then return end
        local Chat = require "engine.Chat"
        Chat.new("mod.data.chats.build_manager", self, who):invoke()
    end,
}
```