### 1. 測試 AI 指令

```lua
-- 在 cheat console 測試（按 ` 或 F1 進入）
-- 取得第一個隊友
local ally = game.party.m_list[2]
if ally then
    -- 下達跟隨指令
    ally.ai_state.command = {type = "follow"}
    print("指令設定成功，隊友 AI:", ally.ai)
    
    -- 確認 AI 是否正確
    assert(ally.ai == "commanded_ally", "AI 未設定！")
    
    -- 下達攻擊指令（需要有敵人）
    local enemy = game.level.map(5, 5, require("engine.Map").ACTOR)
    if enemy and game.player:reactionToward(enemy) < 0 then
        ally.ai_state.command = {type = "attack", target = enemy}
    end
end
```

### 2. 測試招募流程

```lua
-- 在 cheat console 給玩家金幣
game.player.gold = 500
print("金幣設定完成:", game.player.gold)

-- 手動觸發招募
local merc = game.zone:makeEntityByName(game.level, "actor", "MERC_WARRIOR")
if merc then
    local x, y = util.findFreeGrid(game.player.x, game.player.y, 5, true,
        {[require("engine.Map").ACTOR]=true})
    game.zone:addEntity(game.level, merc, "actor", x, y)
    game.party:addMember(merc, {control="no", keep_between_levels=true})
    print("招募成功！隊伍人數:", #game.party.m_list)
else
    print("ERROR: 找不到 MERC_WARRIOR 模板！")
    print("確認 mercenaries.lua 已被載入到 zone.npc_list")
end
```

---
