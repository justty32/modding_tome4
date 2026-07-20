Zone 定義了「一個地城區域」的生成規則：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/zone.lua

return {
    name = _t"古老遺跡",       -- 地區名稱（_t 包裝支援多語言）
    level_range = {1, 1},      -- 怪物等級範圍（Resolver 使用）
    max_level = 10,            -- 最多幾層
    decay = {300, 800},        -- 關卡在快取中存活的回合數範圍
    width = 50, height = 50,   -- 地圖尺寸（格）

    -- 是否在記憶體中持久保存此 zone（不是 level）
    persistent = "zone",

    -- 地圖生成設定
    generator = {
        map = {
            class = "engine.generator.map.Roomer",  -- 使用房間生成器
            nb_rooms = 10,                          -- 生成約 10 間房
            rooms = {"simple", "pilar"},            -- 使用的房間模板
            lite_room_chance = 100,                 -- 100% 房間有燈光

            -- 字元 → Grid define_as 對應
            ['.'] = "FLOOR",
            ['#'] = "WALL",
            up    = "UP",     -- 向上樓梯使用的 Grid
            down  = "DOWN",   -- 向下樓梯使用的 Grid
            door  = "DOOR",
        },
        actor = {
            class = "engine.generator.actor.Random",  -- 隨機生成 NPC
            nb_npc = {20, 30},                        -- 每層生成 20~30 個
        },
    },

    -- 逐層覆蓋設定（可選，若需要讓特定層有不同規則）
    levels = {
        -- [5] = { name = "Boss Floor" },  -- 第 5 層使用不同名稱
    },
}
```

**地圖生成器選項**（`Roomer` 的主要參數）：

| 參數 | 說明 |
|------|------|
| `nb_rooms` | 房間數量 |
| `rooms` | 使用的房間模板（`"simple"` = 矩形，`"pilar"` = 柱廊）|
| `lite_room_chance` | 房間預先點亮的機率（0~100）|
| `['.']` / `['#']` | 字元到 Grid 定義的映射 |

---
