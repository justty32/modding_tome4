### 7.1 zone.lua — 區域設定

```lua
-- data/zones/dungeon/zone.lua
return {
    name = "Old Ruins",
    level_range = {1, 1},     -- NPC 等級範圍
    max_level = 10,            -- 最大樓層數
    decay = {300, 800},        -- 離開後多久可清除（遊戲時間 tick）
    width = 50, height = 50,   -- 地圖尺寸
    persistent = "zone",       -- 持久化策略: "zone" | "level" | false

    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 10,
            rooms = {"simple", "pilar"},  -- 對應 data/rooms/*.lua
            lite_room_chance = 100,
            ['.'] = "FLOOR",              -- 字元 → Grid define_as 映射
            ['#'] = "WALL",
            up = "UP",
            down = "DOWN",
            door = "DOOR",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {20, 30},            -- 每層生成 NPC 數量
        },
        object = {
            class = "engine.generator.object.Random",
            nb_object = {3, 5},
        },
        trap = {
            class = "engine.generator.trap.Random",
            nb_trap = {6, 9},
        },
    },

    -- 逐層覆蓋設定
    levels = {
        [10] = {
            -- 最終層特殊設定
            generator = {
                map = {
                    class = "engine.generator.map.Static",
                    map = "zones/dungeon/boss_room",
                },
            },
        },
    },
}
```

### 7.2 資料載入檔

Zone 自動載入同目錄下的 `grids.lua`、`npcs.lua`、`objects.lua`、`traps.lua`：

```lua
-- data/zones/dungeon/grids.lua
load("/data/general/grids/basic.lua")  -- 載入全域共用地形
-- 可追加區域特有地形：
-- newEntity{ define_as = "LAVA", ... }

-- data/zones/dungeon/npcs.lua
load("/data/general/npcs/kobold.lua")  -- 載入 kobold 系列 NPC
```

### 7.3 房間模板 (`data/rooms/*.lua`)

房間模板回傳一個工廠函數，在地圖生成時被呼叫：

```lua
-- data/rooms/pilar.lua
return function(gen, id)
    local w = rng.range(7, 12)
    local h = rng.range(7, 12)
    return { name="pilar"..w.."x"..h, w=w, h=h,
        generator = function(self, x, y, is_lit)
            -- 生成房間外框（牆壁）
            for i = 1, self.w do for j = 1, self.h do
                if i == 1 or i == self.w or j == 1 or j == self.h then
                    gen.map.room_map[i-1+x][j-1+y].can_open = true
                    gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
                else
                    gen.map.room_map[i-1+x][j-1+y].room = id
                    gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('.')])
                end
                if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
            end end

            -- 放置四根柱子
            local pilars = {{1,1},{self.w-2,1},{1,self.h-2},{self.w-2,self.h-2}}
            for _, p in ipairs(pilars) do
                gen.map(p[1]+x, p[2]+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
            end
        end
    }
end
```

---
