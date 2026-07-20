在城鎮 Zone 的靜態地圖或 NPC 列表中加入招募者：

### 方法 A：在靜態地圖 Lua 中直接定義 NPC

```lua
-- mod/data/zones/town/map.lua（Static map）
-- 在特定座標放置招募者

-- 地圖格: R = 招募者 NPC
return {
    w = 20, h = 20,
    map = {
        -- ...（省略地形格）
    },
    -- 特殊格子上的 NPC 定義
    add_actor = {
        R = function(x, y)
            local npc = game.zone:makeEntityByName(game.level, "actor", "RECRUITER_BUTOK")
            if npc then
                game.zone:addEntity(game.level, npc, "actor", x, y)
            end
        end,
    },
}
```

### 方法 B：在 Zone 定義中加入固定 NPC 列表

```lua
-- mod/data/zones/town.lua
local Zone = require "engine.Zone"

return Zone.new("town", {
    name        = "洛克港鎮",
    level_range = {1, 1},
    level_scheme = "player",
    max_level   = 1,

    width = 40, height = 40,
    all_remembered   = true,   -- 城鎮全部可見
    all_lited        = true,
    persistent       = "zone", -- 城鎮狀態持久化

    generator = {
        map   = {class="engine.generator.map.Static", map="mod/maps/town"},
        actor = {class="engine.generator.actor.OnceAtCoord",
                 -- 在特定座標放置固定 NPC
                 actors = {
                     {defined="RECRUITER_BUTOK", x=10, y=8},
                 }},
    },

    -- 載入傭兵模板（讓 makeEntityByName 可以找到）
    npc_list  = require("mod.class.NPC"):loadList{
        "mod/data/npcs/town.lua",
        "mod/data/npcs/mercenaries.lua",  -- ← 必須包含
    },
})
```

### 招募者 NPC 定義

```lua
-- mod/data/npcs/town.lua（摘錄）
newEntity{
    define_as   = "RECRUITER_BUTOK",
    type        = "humanoid", subtype = "human",
    name        = "布托克",
    display     = "@", color = {r=255, g=200, b=100},
    faction     = "players",
    level_range = {1, 1},
    exp_worth   = 0,
    rank        = 1,
    
    -- 不自動移動
    ai = "none",
    ai_state = {},
    
    -- 對話腳本路徑
    chat = "mod.data.chats.recruiter",
    
    -- 點擊 / 互動觸發對話
    on_interact = function(self, who)
        local chat = require "engine.Chat"
        local c = chat.new(self.chat, self, who)
        c:invoke()
    end,
    
    stats = {str=12, dex=12, con=12, mag=5, wil=10, cun=10},
    max_life = resolvers.rngrange(50, 70),
}
```

> **`ai = "none"`**：定義在 `simple.lua` 中的一個空 AI（`newAI("none", function(self) end)`），讓 NPC 完全靜止，不尋找目標也不移動。城鎮 NPC 通常使用這個 AI。

---
