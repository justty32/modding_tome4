### 新增 `BUILD_MANAGER_NPC` 到 `mod/data/npcs/camp_npcs.lua`

```lua
-- mod/data/npcs/camp_npcs.lua（追加）

-- ── 建造管理員（靜止 NPC） ───────────────────────────────────
newEntity{
    define_as = "BUILD_MANAGER_NPC",
    type = "humanoid", subtype = "human",
    name = "建造管理員",
    display = 'M', color_r=100, color_g=200, color_b=255,
    faction = "players",

    ai       = "none",
    ai_state = {},

    never_move = true,
    exp_worth  = 0,
    max_life   = 9999,
    rank       = 1,
    stats      = {str=15, dex=10, con=15, mag=0, wil=15, cun=15},

    -- 玩家碰撞時觸發建造對話
    on_bump = function(self, who)
        if who ~= game.player then return end
        local Chat = require "engine.Chat"
        Chat.new("mod.data.chats.build_manager", self, who):invoke()
    end,
}
```

