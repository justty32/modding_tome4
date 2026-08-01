## 步驟一：大地圖地形定義

### 檔案：`mod/data/grids/wilderness.lua`

大地圖地形分兩類：
1. **背景地形**：草地、森林、山脈、水域、道路（可走 / 不可走）
2. **地點標記**：帶 `change_zone` 的特殊地形（城鎮入口、地牢入口）

```lua
-- mod/data/grids/wilderness.lua
-- 大地圖地形定義

-- ── 可通行地形 ──────────────────────────────────────────────────

newEntity{
    define_as = "GRASS",
    name = "草地",
    display = '.', color_r=80,  color_g=160, color_b=50,
    back_color = colors.DARK_GREEN,
    always_remember = true,
}

newEntity{
    define_as = "ROAD",
    name = "道路",
    display = '+', color_r=200, color_g=180, color_b=130,
    back_color = colors.DARK_UMBER,
    always_remember = true,
    -- 道路讓移動稍快（可選：設定 movement_speed_factor）
}

newEntity{
    define_as = "SHALLOW_WATER",
    name = "淺灘",
    display = '~', color_r=80,  color_g=150, color_b=220,
    back_color = colors.DARK_BLUE,
    always_remember = true,
    -- 淺灘可通行但速度減慢（簡化版：視為可通行）
}

-- ── 不可通行地形 ────────────────────────────────────────────────

newEntity{
    define_as = "DEEP_WATER",
    name = "深水",
    display = '~', color_r=0,   color_g=80,  color_b=200,
    back_color = colors.DARK_BLUE,
    always_remember = true,
    does_block_move = true,
}

newEntity{
    define_as = "MOUNTAIN",
    name = "山脈",
    display = '^', color_r=160, color_g=150, color_b=130,
    back_color = colors.DARK_GREY,
    always_remember = true,
    does_block_move = true,
    block_sight     = true,
}

newEntity{
    define_as = "FOREST",
    name = "森林",
    display = 'T', color_r=0,   color_g=120, color_b=30,
    back_color = colors.DARK_GREEN,
    always_remember = true,
    -- 森林可通行（不阻擋移動），但阻擋視線
    block_sight     = true,
}

-- ── 地點標記（帶 change_zone / change_level） ─────────────────
-- 玩家站上後按 > 進入對應 Zone

newEntity{
    define_as = "TOWN_A_ENTRANCE",
    name = "起點村莊",
    display = 'A', color_r=255, color_g=220, color_b=50,
    back_color = colors.DARK_UMBER,
    notice          = true,
    always_remember = true,
    change_level = 1,
    change_zone  = "town_a",
}

newEntity{
    define_as = "TOWN_B_ENTRANCE",
    name = "海邊港口",
    display = 'B', color_r=100, color_g=200, color_b=255,
    back_color = colors.DARK_BLUE,
    notice          = true,
    always_remember = true,
    change_level = 1,
    change_zone  = "town_b",
}

newEntity{
    define_as = "CAMP_ENTRANCE",
    name = "野外據點",
    display = 'C', color_r=0,   color_g=255, color_b=150,
    back_color = colors.DARK_GREEN,
    notice          = true,
    always_remember = true,
    change_level = 1,
    change_zone  = "camp",
}
```
