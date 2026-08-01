## 5. 第四步：建立村長 NPC

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
    exp_worth = 0,      -- 擊殺不給經驗（村長不應被殺...）
    never_move = 1,     -- 不移動

    -- 對話腳本名稱（對應 data/chats/elder.lua）
    chat = "elder",

    -- 村長固定生成，不由隨機生成器取走
    -- 透過 zone.lua 的 post_process 手動放置
    rarity = false,     -- 不參與隨機生成
}
```

村長不該被 `generator.actor.Random` 隨機放置，應在地圖生成完成後手動置於固定位置。於 `data/zones/town/zone.lua` 的 `post_process`：

```lua
-- data/zones/town/zone.lua 中的 post_process

post_process = function(level, zone)
    -- 在地圖中間位置放置村長
    local cx, cy = math.floor(level.map.w / 2), math.floor(level.map.h / 2)

    -- 找空地板格
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

## 6. 第五步：建立對話腳本

建立對話腳本檔（第三步已完整展示格式）：

```lua
-- game/modules/hellodungeon/data/chats/elder.lua
-- （完整程式碼見第三步）
```

確保 `data/chats/` 目錄存在。`engine.Chat` 會自動尋找 `/data/chats/<name>.lua` 路徑（虛擬路徑）。

---

## 7. 第六步：建立地城頭目

於地城的 NPC 定義中加入頭目，並在死亡時觸發任務進度：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua
-- （在現有定義後加入頭目）

newEntity{ base = "BASE_KOBOLD",
    define_as = "KOBOLD_BOSS",
    name = "科博德首領「鐵爪葛爾」",
    display = "K", color = colors.CRIMSON,
    level_range = {3, 3},   -- 僅出現在第三層
    rarity = false,         -- 不隨機生成，由地圖手動放置
    exp_worth = 5,
    rank = 3,               -- 精英怪（Boss 等級）
    max_life = resolvers.rngrange(60, 80),
    life_rating = 14,
    combat = { dam=resolvers.rngrange(10, 18), atk=12, apr=5 },
    body = { INVEN=10, WEAPON=1 },
    -- 死亡時觸發任務更新
    on_die = function(self, who)
        -- who = 擊殺者（通常為玩家）
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

於地城 zone.lua 的 `post_process` 中，生成第三層時放置頭目：

```lua
-- data/zones/dungeon/zone.lua

post_process = function(level, zone)
    -- 僅在第三層放置頭目
    if level.level ~= 3 then return end

    -- 找空地板格放置頭目
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

## 8. 第七步：回報完成對話

回報對話已於第三步的 `elder.lua` 中整合（條件 2：`killed_boss` 完成但 `reported` 未完成）。要將整個任務標記為 `DONE`，需在 Quest 定義的 `on_status_change` 中處理：

```lua
-- data/quests/slay-boss.lua（相關段落）

on_status_change = function(self, who, status, sub)
    -- 子目標進度提示
    if sub == "killed_boss" and status == self.COMPLETED then
        game.logPlayer(who, "#LIGHT_GREEN#首領已倒下！返回城鎮向村長回報。")
    end

    -- 回報完成 → 標記整個任務為 DONE
    if sub == "reported" and status == self.COMPLETED then
        who:setQuestStatus(self.id, engine.Quest.DONE)
    end
end
```
