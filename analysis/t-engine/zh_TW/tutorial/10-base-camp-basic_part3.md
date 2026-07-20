## 步驟三：地形實體定義

### 檔案：`mod/data/grids/camp.lua`

```lua
-- mod/data/grids/camp.lua
-- 據點專用地形定義

-- ── 基礎地形 ──────────────────────────────────────────────────
newEntity{
    define_as = "CAMP_FLOOR",
    name = "地板",
    display = '.', color_r=200, color_g=180, color_b=140,
    back_color = colors.DARK_GREY,
}

newEntity{
    define_as = "CAMP_WALL",
    name = "木牆",
    display = '#', color_r=139, color_g=90, color_b=43,
    back_color = colors.DARK_UMBER,
    always_remember   = true,
    does_block_move   = true,
    block_sight       = true,
    dig               = "CAMP_FLOOR",
}

newEntity{
    define_as = "CAMP_DOOR",
    name = "木門",
    display = '+', color_r=180, color_g=120, color_b=60,
    back_color = colors.DARK_UMBER,
    notice          = true,
    always_remember = true,
    block_sight     = true,
    door_opened     = "CAMP_DOOR_OPEN",
}

newEntity{
    define_as = "CAMP_DOOR_OPEN",
    name = "木門（開）",
    display = "'", color_r=180, color_g=120, color_b=60,
    back_color = colors.DARK_GREY,
    always_remember = true,
    door_closed     = "CAMP_DOOR",
}

newEntity{
    define_as = "CAMP_TREE",
    name = "樹",
    display = 't', color_r=0, color_g=150, color_b=0,
    back_color = colors.DARK_GREY,
    always_remember = true,
    does_block_move = true,
    block_sight     = true,
}

newEntity{
    define_as = "CAMP_WATER",
    name = "水池",
    display = '~', color_r=0, color_g=100, color_b=200,
    back_color = colors.DARK_BLUE,
    always_remember = true,
    does_block_move = true,
}

-- ── 篝火（帶 camp_heal 旗標） ──────────────────────────────────
-- 不在這裡放 on_move 函式（函式無法序列化）
-- 行為邏輯統一在 mod/class/Grid.lua 的 on_move 中根據旗標分派
newEntity{
    define_as = "CAMPFIRE",
    name = "篝火",
    display = '*', color_r=255, color_g=150, color_b=0,
    back_color = colors.DARK_RED,
    notice          = true,
    always_remember = true,

    camp_heal          = true,   -- 旗標：觸發治療
    camp_heal_pct      = 0.05,   -- 每次治療 5% 最大 HP
    camp_heal_cooldown = 10,     -- 冷卻：10 個玩家動作才能再次觸發
}

-- ── 出口（返回大地圖） ─────────────────────────────────────────
-- change_level + change_zone 欄位由 Game:setupCommands 的 CHANGE_LEVEL 鍵讀取
newEntity{
    define_as = "EXIT_TO_WORLD",
    name = "據點出口",
    display = '<', color_r=255, color_g=255, color_b=0,
    back_color = colors.DARK_GREY,
    notice          = true,
    always_remember = true,

    change_level = 1,            -- 目標層
    change_zone  = "wilderness", -- 目標 Zone short_name
}
```
