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
defineTile('w', "CAMP_FLOOR", nil, "WORKBENCH_NPC")   -- 合成工作台 NPC
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

