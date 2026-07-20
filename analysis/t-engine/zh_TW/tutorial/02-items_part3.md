## 6. 定義藥水（消耗品）

```lua
-- game/modules/hellodungeon/data/general/objects/potions.lua

-- 藥水基底
-- stacking = true：相同藥水自動堆疊
-- use_simple：按 a 使用物品時觸發
newEntity{
    define_as = "BASE_POTION",
    type = "potion", subtype = "potion",
    display = "!", color = colors.VIOLET,
    encumber = 0.2,
    stacking = true,    -- 多瓶合為一格顯示數量
    rarity = 4,
    desc = "神祕的魔法藥水。",
}

-- 治癒藥水
newEntity{ base = "BASE_POTION",
    name = "治癒藥水",
    color = colors.RED,
    level_range = {1, 50},
    rarity = 3, cost = 10,
    use_simple = {
        name = "喝下治癒藥水",
        use = function(self, who)
            local heal = 20 + rng.range(1, 10)
            who:heal(heal, who)
            game.logSeen(who, "%s 喝下治癒藥水，恢復了 %d 點生命！",
                who:getName():capitalize(), heal)
            -- {used=true} = 使用成功，物品消耗
            return {used=true, id=true}
        end
    },
}

-- 力量藥水（需 EFF_STRENGTH_BOOST，見附錄）
newEntity{ base = "BASE_POTION",
    name = "力量藥水",
    color = colors.ORANGE,
    level_range = {3, 50},
    rarity = 6, cost = 25,
    use_simple = {
        name = "喝下力量藥水",
        use = function(self, who)
            game.logSeen(who, "%s 喝下力量藥水，力量暫時提升！",
                who:getName():capitalize())
            local id = who:addTemporaryValue("combat_dam", 5)
            who:setEffect(who.EFF_STRENGTH_BOOST, 20, {id=id})
            return {used=true, id=true}
        end
    },
}
```

### `use_simple` vs `use`

| 欄位 | 說明 |
|------|------|
| `use_simple.name` | 動作選單顯示文字 |
| `use_simple.use(self, who)` | `self`=物品，`who`=使用者；回傳 `{used=true}` 消耗物品 |
| `use` | 完整版（可自訂對話框、目標選擇），進階用法 |

> 力量藥水範例依賴 `EFF_STRENGTH_BOOST`。若 `timed_effects.lua` 未定義，執行會報錯。可先僅保留治癒藥水測試，或補充定義（見附錄）。

---

## 7. 地區物品清單

Zone 載入時自動讀取 `objects.lua`：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/objects.lua

-- load() 執行指定檔案，收集 newEntity{} 至清單
load("/data/general/objects/weapons.lua")
load("/data/general/objects/potions.lua")
```

> `load()` 路徑為虛擬路徑 `/data/...`，非磁碟路徑。此中繼層讓物品可按類別分檔管理。

---

## 8. 設定物品生成器

更新 `zone.lua`：加入 `object_class`、`generator.object`、`on_setup` 中的 `object_class`。

```lua
-- game/modules/hellodungeon/data/zones/dungeon/zone.lua

return {
    name = "地下城",
    short_name = "dungeon",
    level_range = {1, 10},
    level_scheme = "player",
    max_level = 3,
    decay = {300, 800},
    persistent = "zone",

    object_class = "mod.class.Object",       -- 新增

    on_setup = function(self)
        self:setup{
            npc_class    = "mod.class.NPC",
            grid_class   = "mod.class.Grid",
            object_class = "mod.class.Object",   -- 新增
        }
    end,

    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 8,
            rooms = {"rect"},
            lite_room_chance = 80,
            floor = "FLOOR", wall = "WALL",
            up = "UP", down = "DOWN",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {5, 10},
        },
        object = {                              -- 新增
            class = "engine.generator.object.Random",
            nb_object = {3, 7},                 -- 每層 3~7 個物品
        },
    },
}
```

### `engine.generator.object.Random` 流程

1. `zone:makeEntity(level, "object", filter)` — 依 `rarity` 隨機選取
2. 找空地板格
3. `zone:addEntity(level, o, "object", x, y)` — 放到地圖
