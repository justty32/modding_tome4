# 教學 03：多地區與地區切換

> **目標**：為 `hellodungeon` 新增第二地區（城鎮），實作地城↔城鎮雙向切換。理解 `Zone`、`changeLevel`、`change_level`/`change_zone` 的完整機制。
>
> **前置**：完成教學 01 + 02。

---

## 目錄

1. [架構總覽](#1-架構總覽)
2. [changeLevel 工作原理](#2-changelevel-工作原理)
3. [建立城鎮地區](#3-建立城鎮地區)
4. [更新 Game.lua 支援多地區切換](#4-更新-gamelua-支援多地區切換)
5. [起始地區設為城鎮](#5-起始地區設為城鎮)
6. [地區切換保留玩家位置](#6-地區切換保留玩家位置)
7. [on_enter / on_leave 回呼](#7-on_enter--on_leave-回呼)
8. [完整檔案結構](#8-完整檔案結構)
9. [常見錯誤排查](#9-常見錯誤排查)

---

## 1. 架構總覽

```
Game（全域）
 ├── game.zone   ← 當前 Zone 物件
 └── game.level  ← 當前 Level 物件（Zone 的一個樓層）
       └── game.level.map  ← 當前地圖

Zone（地區，如 "dungeon"、"town"）
 ├── short_name   ← changeLevel 識別字串
 ├── max_level    ← 最多樓層數
 └── [level 1], [level 2], ...  ← 每個樓層是一個 Level 物件

Level（樓層）
 ├── level        ← 樓層編號（1 = 第一層）
 ├── map          ← Map 物件（二維地形陣列）
 ├── default_up   ← {x, y}：從下方進入時的出現點
 └── default_down ← {x, y}：從上方進入時的出現點
```

**地區切換流程**：

```
踩上 change_level / change_zone 地形
  → Game:changeLevel(lev, zone_name)
       → zone:leaveLevel()         ← 儲存當前樓層狀態
       → Zone.new(zone_name)       ← 建立（或從快取讀取）新地區
       → zone:getLevel(lev)        ← 取得目標樓層（不存在則生成）
       → player:move(default_up/down)  ← 移動到預設出現點
       → level:addEntity(player)   ← 加入新樓層
```

---

## 2. changeLevel 工作原理

`example/class/Game.lua` 已有完整基礎實作：

```lua
function _M:changeLevel(lev, zone)
    local old_lev = (self.level and not zone) and self.level.level or -1000
    if zone then
        -- 離開舊地區
        if self.zone then
            self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave()
        end
        -- 建立新地區
        if type(zone) == "string" then
            self.zone = Zone.new(zone)
        else
            self.zone = zone
        end
    end
    -- 進入目標樓層
    self.zone:getLevel(self, lev, old_lev)

    -- 玩家出現在適當位置
    if lev > old_lev then
        self.player:move(self.level.default_up.x, self.level.default_up.y, true)
    else
        self.player:move(self.level.default_down.x, self.level.default_down.y, true)
    end
    self.level:addEntity(self.player)
end
```

**參數規則**：

| 情況 | `lev` | `zone` |
|------|-------|--------|
| 同地區下一層 | 當前層+1 | nil |
| 同地區上一層 | 當前層-1 | nil |
| 切換到新地區第1層 | 1 | `"zone_name"` |
| 切換到新地區特定層 | n | `"zone_name"` |

**地形觸發欄位**：

地形實體（Grid）的兩個欄位控制切換：

```lua
change_level = 1,        -- 正數：往深處走（default_down 出現）
                          -- 負數：往上走（default_up 出現）
change_zone = "town",     -- 字串：切換到另一地區（優先使用）
```

`Game:tick()` 或 `CHANGE_LEVEL` 按鍵動作讀取腳下地形：

```lua
local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
if e.change_level then
    self:changeLevel(
        e.change_zone and e.change_level or self.level.level + e.change_level,
        e.change_zone
    )
end
```

注意：`e.change_zone` 存在時，`e.change_level` 是**目標地區的樓層號碼**（非相對差值）。

---

## 3. 建立城鎮地區

城鎮是單層 Zone，用 `Roomer` 生成器即可。

### 3.1 town/zone.lua

```lua
-- game/modules/hellodungeon/data/zones/town/zone.lua

return {
    name = "賢者城鎮",
    short_name = "town",
    level_range = {1, 1},
    level_scheme = "player",
    max_level = 1,

    -- 城鎮永久保存（離開後地圖狀態不重置）
    persistent = "zone",

    -- 所有格子亮著
    all_lited = true,

    -- 城鎮 NPC 不重生
    decay = {300, 800, no_respawn=true},

    -- 指定使用的類別
    on_setup = function(self)
        self:setup{
            npc_class    = "mod.class.NPC",
            grid_class   = "mod.class.Grid",
            object_class = "mod.class.Object",
        }
    end,

    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 5,
            rooms = {"rect"},
            lite_room_chance = 100,
            floor = "FLOOR",
            wall  = "WALL",
            up    = "EXIT_TOWN",    -- 城鎮出口（進入地城）
            down  = "EXIT_TOWN",    -- 單層地區不需向下
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {3, 5},        -- 城鎮 NPC
        },
        object = {
            class = "engine.generator.object.Random",
            nb_object = {0, 2},
        },
    },
}
```

### 3.2 town/grids.lua

```lua
-- game/modules/hellodungeon/data/zones/town/grids.lua

-- 載入共用地形
load("/data/general/grids/basic.lua")

-- 城鎮出口（進入地城第 1 層）
newEntity{
    define_as = "EXIT_TOWN",
    name = "地城入口",
    display = '>', color_r=200, color_g=100, color_b=50,
    always_remember = true,
    notice = true,
    -- change_zone：進入 "dungeon" 地區
    -- change_level：目標地區層號（1 = 第一層）
    change_level = 1,
    change_zone = "dungeon",
}
```

### 3.3 town/npcs.lua 與 town/objects.lua

```lua
-- game/modules/hellodungeon/data/zones/town/npcs.lua
-- 暫時空白，或加入村民 NPC
```

```lua
-- game/modules/hellodungeon/data/zones/town/objects.lua
-- 暫時空白
```

### 3.4 更新地城地形：加入返回城鎮出口

在 `data/zones/dungeon/grids.lua` 加入出口：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/grids.lua

load("/data/general/grids/basic.lua")

-- 覆蓋 UP 地形：第一層上樓回到城鎮
newEntity{
    define_as = "UP",
    name = "返回城鎮",
    display = '<', color_r=255, color_g=200, color_b=50,
    always_remember = true,
    notice = true,
    -- 第一層 UP 指向城鎮，其他層指向上一層
    -- 邏輯在 CHANGE_LEVEL 事件處理（見第四步）
    change_level = -1,      -- 預設：上一層
}
```

更優雅的方式是使用專用地形 `DUNGEON_EXIT`：

```lua
newEntity{
    define_as = "DUNGEON_EXIT",
    name = "離開地城",
    display = '<', color_r=255, color_g=200, color_b=50,
    always_remember = true,
    notice = true,
    change_level = 1,       -- 城鎮只有 1 層
    change_zone = "town",   -- 回到城鎮
}
```

並在 `zone.lua` 生成器中把第 1 層的 `up` 改為 `"DUNGEON_EXIT"`（可在 `post_process` 動態替換）。
