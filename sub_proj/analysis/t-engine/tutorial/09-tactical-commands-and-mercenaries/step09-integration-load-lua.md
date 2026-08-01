```lua
-- mod/load.lua（摘錄）

-- 確保 Party 系統已初始化
dofile("/mod/class/Party.lua")

-- 載入 NPC 模板（包含傭兵）
-- （通常在 Zone 的 npc_list 中已指定，這裡是確保全域可用）

-- 初始化 game.party（如果你的模組使用 Party 系統）
game.party = require("mod.class.Party").new()
game.party:addMember(game.player, {
    main    = true,
    control = "full",
    title   = "主角",
    keep_between_levels = true,
})
```

---
