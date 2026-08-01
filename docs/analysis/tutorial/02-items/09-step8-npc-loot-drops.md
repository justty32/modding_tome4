讓怪物死亡後有機率掉落物品，需要在 NPC 定義中加入 `resolvers.drops`。

首先，確認你的模組有載入 ToME 的 resolver（或者用引擎基礎 resolver）。對於 hellodungeon，我們自己實作一個簡化版的 drops：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua
-- （在教學 01 的科博德定義中加入 drops）

newEntity{
    define_as = "BASE_KOBOLD",
    type = "humanoid", subtype = "kobold",
    display = "k", color = colors.GREEN,
    body = { INVEN=10, WEAPON=1 },
    -- 其他欄位與教學 01 相同...
    ai = "dumb_talented", ai_state = { talent_in=3 },
    energy = { mod=1 },
    autolevel = "warrior",
    stats = { str=8, dex=8, con=8 },
}

newEntity{ base = "BASE_KOBOLD",
    name = "科博德",
    level_range = {1, 5},
    exp_worth = 1,
    max_life = resolvers.rngrange(10, 20),
    life_rating = 8,
    combat = { dam=resolvers.rngrange(2, 5), atk=4, apr=1 },
    -- on_die：Actor 死亡時呼叫的回調函數
    -- 這是最直接的掉落物實作（不依賴 ToME 的 resolvers.drops）
    on_die = function(self, who)
        -- 50% 機率掉落一個物品
        if not rng.percent(50) then return end
        -- 從地區物品清單中隨機生成一個物品
        local o = game.zone:makeEntity(game.level, "object", nil, nil, true)
        if o then
            -- 放到怪物死亡的位置
            game.level.map:addObject(self.x, self.y, o)
            game.logSeen(self, "%s 掉落了 %s！",
                self:getName():capitalize(), o:getName{do_color=true})
        end
    end,
}

newEntity{ base = "BASE_KOBOLD",
    name = "科博德戰士",
    level_range = {3, 8},
    exp_worth = 2,
    max_life = resolvers.rngrange(20, 35),
    life_rating = 10,
    combat = { dam=resolvers.rngrange(5, 10), atk=6, apr=2 },
    on_die = function(self, who)
        -- 80% 機率掉落，更強的怪物掉落率更高
        if not rng.percent(80) then return end
        local o = game.zone:makeEntity(game.level, "object", nil, nil, true)
        if o then
            game.level.map:addObject(self.x, self.y, o)
        end
    end,
}
```

**為什麼不用 `resolvers.drops`？**

`resolvers.drops`（定義在 `mod/resolvers.lua`）是 ToME 模組專屬的 resolver，依賴 ToME 的物品篩選系統（`game.state:entityFilter` 等）。hellodungeon 是獨立模組，直接在 `on_die` 中呼叫 `zone:makeEntity()` 更簡單直接。若要移植到 ToME Addon，才需要改用 `resolvers.drops`。

---
