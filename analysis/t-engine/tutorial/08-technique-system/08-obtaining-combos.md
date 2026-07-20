### 8.1 作為掉落物（Object）

連技捲軸是一種消耗品，使用後習得連技：

```lua
-- data/general/objects/technique_scrolls.lua

newEntity{
    define_as = "BASE_TECHNIQUE_SCROLL",
    type = "scroll", subtype = "technique",
    display = "?", color = colors.CYAN,
    stacking = false,   -- 每個捲軸都是唯一的
    rarity = 8,
    desc = "記載著某種連技的羊皮紙卷。",
    use_simple = {
        name = "研讀連技捲軸",
        use = function(self, who)
            if not self.technique_id then return {used=false} end
            if who:knowsTechnique(self.technique_id) then
                game.logPlayer(who, "你已經知道這個連技了。")
                return {used=false}
            end
            who:learnTechnique(self.technique_id)
            return {used=true, id=true}
        end,
    },
}

newEntity{ base = "BASE_TECHNIQUE_SCROLL",
    name = "迅斬秘笈",
    technique_id = "T_TECH_SWIFT_SLASH",
    level_range = {1, 5},
    rarity = 5,
    color = colors.LIGHT_BLUE,
    desc = "記載「迅斬」連技的入門秘笈。",
}

newEntity{ base = "BASE_TECHNIQUE_SCROLL",
    name = "斬裂衝真傳",
    technique_id = "T_TECH_BURST_CLEAVE",
    level_range = {6, 20},
    rarity = 15,
    color = colors.CRIMSON,
    desc = "記載終極連技「斬裂衝」的稀有典籍。",
}
```

### 8.2 訓練師 NPC

在城鎮加入一個訓練師 NPC，提供付費學習：

```lua
-- data/zones/town/npcs.lua

newEntity{
    define_as = "TRAINER",
    name = "連技訓練師 Wu",
    display = "T", color = colors.LIGHT_GREEN,
    ai = "simple", never_move = 1,
    chat = "trainer",  -- data/chats/trainer.lua
    rarity = false,
}
```

```lua
-- data/chats/trainer.lua

newChat{ id="welcome",
    text = "我可以傳授你連技。你想學什麼？",
    answers = {
        {
            "教我「迅斬」（費用：50 金）",
            cond = function(npc, player)
                return not player:knowsTechnique("T_TECH_SWIFT_SLASH")
            end,
            action = function(npc, player)
                if (player.money or 0) < 50 then
                    game.logPlayer(player, "金幣不足。")
                    return
                end
                player.money = player.money - 50
                player:learnTechnique("T_TECH_SWIFT_SLASH")
            end,
        },
        { "再見。" },
    }
}

return "welcome"
```

### 8.3 戰鬥中頓悟（事件觸發）

在 Actor 的 `attackTarget` 中，有機率在擊殺後習得連技：

```lua
-- class/interface/Combat.lua

function _M:attackTarget(target)
    local hit, dam = -- ... 原有攻擊邏輯 ...

    if target.dead and rng.percent(5) then  -- 5% 機率頓悟
        -- 隨機選一個未習得的連技
        local candidates = {}
        for id, t in pairs(techniques_def) do
            if not self:knowsTechnique(id) then
                candidates[#candidates+1] = id
            end
        end
        if #candidates > 0 then
            local id = rng.table(candidates)
            game.logPlayer(self, "#GOLD#在激戰中，你頓悟了「%s」！",
                techniques_def[id].name)
            self:learnTechnique(id)
        end
    end
end
```

---
