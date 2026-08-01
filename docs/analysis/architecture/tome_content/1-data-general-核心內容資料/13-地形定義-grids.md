### 1.3 地形定義 (grids/)

共 **30 個地形定義檔案**，依環境主題組織。

#### 檔案分類

**自然環境**

| 檔案 | 環境 |
|------|------|
| `forest.lua` | 森林（樹木、草地、荊棘）|
| `jungle.lua` | 叢林（熱帶植被）|
| `ice.lua` | 冰雪（冰原、凍土）|
| `underground.lua` | 地下（岩石、洞窟）|
| `cave.lua` | 山洞 |
| `lava.lua` | 熔岩（岩漿地形、傷害地板）|
| `sand.lua` / `sanddunes.lua` | 沙漠（沙地、沙丘）|
| `mountain.lua` | 山地 |
| `water.lua` | 水域（淺水、深水、沼澤）|
| `autumn_forest.lua` | 秋天森林 |
| `snowy_forest.lua` | 積雪森林 |
| `elven_forest.lua` | 精靈森林 |

**地城主題**

| 檔案 | 主題 |
|------|------|
| `gothic.lua` | 哥特式（石磚牆、拱頂）|
| `fortress.lua` | 要塞（城堡磚牆）|
| `bone.lua` | 骨頭（獸人城市美術風格）|
| `malrok_walls.lua` | Malrok 牆壁（特殊地城）|
| `slimy_walls.lua` | 黏液牆壁 |
| `crystal.lua` | 水晶地形 |
| `void.lua` | 虛空（宇宙背景）|
| `psicave.lua` | 心靈山洞 |
| `slime.lua` | 黏液地形 |
| `burntland.lua` | 燒焦大地 |

**特殊環境**

| 檔案 | 說明 |
|------|------|
| `icecave.lua` | 冰窟 |
| `underground_dreamy.lua` | 夢境地下 |
| `underground_gloomy.lua` | 陰鬱地下 |
| `underground_slimy.lua` | 黏液地下 |
| `jungle_hut.lua` | 叢林小屋 |

**核心定義**

`basic.lua`（25KB）：最主要的地形定義，包含：
- FLOOR（地板）/ WALL（牆壁）基礎類型
- DOOR / DOOR_LOCKED / DOOR_BLOCKED（各類門）
- STAIRS_UP / STAIRS_DOWN（樓梯）
- 特殊互動地形

#### 地形屬性

```lua
newEntity{
    define_as = "FLOOR",
    type = "floor",
    name = _t"floor",
    display = '.', color = colors.GREY,
    -- 通行性
    block_move = false,
    block_sight = false,
    -- 地圖顯示
    special_minimap = colors.WHITE,
    -- 互動回呼
    on_stand = function(self, x, y, who) ... end,
    on_dig = function(self, x, y, who) ... end,
}
```

**特殊 Grid 屬性**（`mod/class/Grid.lua` 擴展）：

| 屬性 | 說明 |
|------|------|
| `door_opened` | 開門後替換的 Grid |
| `door_player_check` | 開門前顯示的確認對話框 |
| `change_zone` | 傳送目標（樓梯用）|
| `air_level` / `air_condition` | 空氣供應量/類型（水下地形）|
| `translate_into_region` | 傳送至地區內部坐標 |

---

