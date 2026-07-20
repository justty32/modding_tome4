在地城的 NPC 定義中加入首領，並在死亡時觸發任務進度：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua
-- （在現有定義後加入首領）

newEntity{ base = "BASE_KOBOLD",
    define_as = "KOBOLD_BOSS",
    name = "科博德首領「鐵爪葛爾」",
    display = "K", color = colors.CRIMSON,
    level_range = {3, 3},   -- 只出現在第三層
    rarity = false,         -- 不隨機生成，由地圖手動放置
    exp_worth = 5,
    rank = 3,               -- 精英怪（Boss 等級）
    max_life = resolvers.rngrange(60, 80),
    life_rating = 14,
    combat = { dam=resolvers.rngrange(10, 18), atk=12, apr=5 },
    body = { INVEN=10, WEAPON=1 },
    -- 死亡時觸發任務更新
    on_die = function(self, who)
        -- who = 殺死此 NPC 的 Actor（通常是玩家）
        if who == game.player then
            game.player:setQuestStatus(
                "slay-boss",
                engine.Quest.COMPLETED,
                "killed_boss"       -- 子目標 ID
            )
        end
        -- 掉落豐厚戰利品
        for i = 1, 3 do
            local o = game.zone:makeEntity(game.level, "object", nil, nil, true)
            if o then
                game.level.map:addObject(self.x, self.y, o)
            end
        end
    end,
}
```

在地城 zone.lua 的 `post_process` 中，當生成第三層時放置首領：

```lua
-- data/zones/dungeon/zone.lua

post_process = function(level, zone)
    -- 只在第三層放置首領
    if level.level ~= 3 then return end

    -- 找一個空的地板格放置首領
    for tries = 0, 100 do
        local x = rng.range(5, level.map.w - 5)
        local y = rng.range(5, level.map.h - 5)
        if not level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move")
            and not level.map(x, y, engine.Map.ACTOR) then
            local boss = zone:makeEntityByName(level, "actor", "KOBOLD_BOSS")
            if boss then
                zone:addEntity(level, boss, "actor", x, y)
                game.log("#RED#你感覺到深處有股邪惡的氣息…")
            end
            break
        end
    end
end,
```

---
