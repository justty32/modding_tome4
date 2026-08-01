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
- FLOOR / WALL 基礎類型
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
    block_move = false, block_sight = false,
    special_minimap = colors.WHITE,
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

### 1.4 商店定義 (stores/)

**`basic.lua`**（22KB）：完整商店/供應商系統。

#### 商店類型

| 商店名稱 | 商品類型 |
|---------|---------|
| Heavy Armor Smith | 重甲、板甲 |
| Light Armor Tanner | 輕甲、布甲 |
| Weapon Smith | 各類武器 |
| Potion Alchemist | 藥水、消耗品 |
| Scroll Vendor | 卷軸、魔棒 |
| Jewelry Vendor | 戒指、項鍊 |
| Gem Vendor | 寶石（材料）|
| General Loot | 混合物品 |
| Faction Merchant | 陣營限定物品 |

#### 商店配置

```lua
newEntity{
    name = _t"heavy armor store",
    store_filter = "tome_store",
    purse = 200,
    nb_fill = 10,
    filters = {
        {type="armor", subtype="massive"},
        {type="armor", subtype="heavy"},
        {type="armor", subtype="shield"},
    },
    empty_before_restock = true,
    restock_on_zone_change = true,
}
```

**定價規則**：
- 基礎買入價 = 物品原價 × 1.0
- 賣出價：寶石 40%，其他物品 5%
- 陣營友好度加成（Angolwen 等特殊商人有折扣）

---

### 1.5 陷阱定義 (traps/)

共 **9 個陷阱類型檔案**。

#### 陷阱類型

| 檔案 | 陷阱類別 |
|------|---------|
| `alarm.lua` | 警報陷阱（召喚敵人）|
| `annoy.lua` | 騷擾陷阱（弱效果）|
| `complex.lua` | 複雜陷阱（多效果組合）|
| `elemental.lua` | 元素陷阱（火/冰/閃電/酸）|
| `natural_forest.lua` | 自然森林陷阱（荊棘/植物）|
| `teleport.lua` | 傳送陷阱（隨機/陷阱房間）|
| `temporal.lua` | 時間陷阱（減速/時間歸零）|
| `water.lua` | 水中陷阱 |
| `store.lua` | 商店陷阱（有代價的獎勵）|

#### 陷阱定義結構

```lua
newEntity{
    type = "trap", subtype = "elemental",
    name = _t"fire trap",
    display = '^', color = colors.RED,
    detect_power = 10, disarm_power = 12,
    triggered = function(self, x, y, who)
        game.level.map:particleEmitter(x, y, 1, "fire")
        who:takeHit(rng.avg(10, 25), self, {type="fire"})
        game.logSeen(who, "A fire trap activates!")
    end,
    rarity = 10, level_range = {1, 30},
    disarmed = {define_as = "DISARMED_FIRE_TRAP"},
}
```

---

### 1.6 事件系統 (events/)

共 **34 個程序性世界事件**，隨機修改已生成的地圖。

#### 事件類型

**環境修改類**

| 事件檔 | 說明 |
|--------|------|
| `antimagic-bush.lua` | 反魔法荊棘（傷害魔法使用者）|
| `blighted-soil.lua` | 枯萎土地（腐化效果）|
| `pyroclast.lua` | 火山噴發（熔岩地形）|
| `meteor.lua` | 隕石（坑洞地形）|
| `thunderstorm.lua` | 雷暴（閃電環境效果）|
| `snowstorm.lua` | 雪暴（寒冷環境效果）|
| `drake-cave.lua` | 龍巢穴（特殊地形）|
| `damp-cave.lua` | 潮濕山洞 |

**稀有特殊事件**

| 事件檔 | 大小 | 說明 |
|--------|------|------|
| `cultists.lua` | 11KB | 邪教徒 NPC 群出現 |
| `fearscape-portal.lua` | 9.4KB | 恐懼界入口傳送門 |
| `naga-portal.lua` | 7.6KB | 奈迦界傳送門 |
| `rat-lich.lua` | 7KB | 鼠妖（特殊 Boss 遭遇）|
| `sub-vault.lua` | 6.2KB | 程序性寶庫變體 |
| `old-battle-field.lua` | 7.7KB | 古戰場殘跡（戰利品/危機）|
| `glowing-chest.lua` | 4KB | 發光寶箱（特殊獎勵）|
| `weird-pedestals.lua` | 5.7KB | 古代台座（謎題）|

#### 事件執行流程

```lua
newEvent{
    name = "meteor",
    rarity = 10,
    filter = function(self, zone, level, spot)
        return zone.short_name ~= "underwater"
    end,
    generate = function(self, zone, level, spot)
        local x, y = spot.x, spot.y
        local gx, gy = game.state:findEventGrid(level, x, y, 8)
        if not gx then return end
        level.map(gx, gy, Map.TERRAIN, terrains.CRATER)
        level.map:particleEmitter(gx, gy, 2, "smoke_cloud")
        level.map(gx, gy, Map.TERRAIN).on_stand = function(self, x, y, who)
            who:takeHit(rng.avg(5, 10), nil, {type="physical"})
        end
    end,
}
```

#### 事件分組 (events/groups/)

每個地區類型使用一個事件組定義可能出現的事件：

| 分組檔 | 用途 |
|--------|------|
| `majeyal-generic.lua` | Maj'Eyal 地下城通用事件 |
| `fareast-generic.lua` | 遠東地下城通用事件 |
| `outdoor-majeyal-generic.lua` | Maj'Eyal 戶外通用事件 |
| `outdoor-majeyal-gloomy.lua` | Maj'Eyal 陰鬱戶外事件 |
| `outdoor-fareast-generic.lua` | 遠東戶外事件 |

分組中的事件有個別出現機率（如 weird-pedestals 10%）。

---

### 1.7 遭遇系統 (encounters/)

共 **4 個遭遇定義檔案**，用於世界地圖上的特殊 NPC 遭遇。

#### 遭遇檔案

| 檔案 | 大小 | 說明 |
|------|------|------|
| `maj-eyal.lua` | 10KB | 主大陸遭遇事件 |
| `fareast.lua` | 3.5KB | 遠東地區遭遇事件 |
| `maj-eyal-npcs.lua` | 4.2KB | 遭遇中使用的 NPC 定義 |
| `fareast-npcs.lua` | 2.5KB | 遠東遭遇 NPC |

#### 遭遇機制

```lua
newEntity{
    define_as = "ENCOUNTER_MERCHANT",
    type = "encounter",
    name = _t"lost merchant",
    level_range = {5, 25}, rarity = 15,
    min_lore = 0, immediate = true,
    on_encounter = function(self, who, x, y)
        local npc = game.zone:makeEntityByName(game.level, "worldnpc", "LOST_MERCHANT")
        game.zone:addEntity(game.level, npc, "worldnpc", x, y)
        npc:talkTo(who)
    end,
    special_filter = function(self, who)
        return not who:hasQuest("lost-merchant")
    end,
}
```

**遭遇觸發鏈**：世界地圖行走 → 觸發遭遇 → 生成 WorldNPC → 啟動對話/任務 → 更新任務狀態
