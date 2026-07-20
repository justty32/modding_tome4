```lua
-- game/modules/hellodungeon/data/zones/town/npcs.lua

newEntity{
    define_as = "ELDER",
    type = "humanoid", subtype = "human",
    name = "村長 Aldric",
    display = "@", color = colors.YELLOW,
    -- 村長不移動、不攻擊
    ai = "simple",
    ai_state = { talent_in=9999 },
    body = { INVEN=10 },
    energy = { mod=1 },
    stats = { str=10, dex=10, con=10 },
    max_life = 100, life_rating = 10,
    rank = 1,
    exp_worth = 0,      -- 殺掉不給經驗（村長不應該被殺...）
    never_move = 1,     -- 不移動

    -- 對話腳本名稱（對應 data/chats/elder.lua）
    chat = "elder",

    -- 村長是固定生成的，不要被隨機生成器取走
    -- 通過在 zone.lua 的 post_process 中手動放置
    rarity = false,     -- 不參與隨機生成
}
```

村長不應該被 `generator.actor.Random` 隨機放置，而是在地圖生成完成後手動放在固定位置。在 `data/zones/town/zone.lua` 的 `post_process` 中：

```lua
-- data/zones/town/zone.lua 中的 post_process

post_process = function(level, zone)
    -- 在地圖中間位置放置村長
    local cx, cy = math.floor(level.map.w / 2), math.floor(level.map.h / 2)

    -- 找一個空的地板格
    for tries = 0, 50 do
        local x = cx + rng.range(-5, 5)
        local y = cy + rng.range(-5, 5)
        if not level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move")
            and not level.map(x, y, engine.Map.ACTOR) then
            -- 建立並放置村長
            local npc = zone.npc_class:loadList("/data/zones/town/npcs.lua")
            local elder = zone:makeEntityByName(level, npc, "ELDER")
            if elder then
                zone:addEntity(level, elder, "actor", x, y)
            end
            break
        end
    end
end,
```

---
