```lua
-- game/modules/hellodungeon/data/damage_types.lua

-- 物理傷害（預設就有，但需要在這裡定義才能使用）
newDamageType{
    name = "physical", type = "PHYSICAL",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            -- 直接造成物理傷害
            target:takeHit(dam, src)
            game.logSeen(target, "%s takes %d physical damage!", target.name:capitalize(), dam)
        end
    end,
}

-- 酸液傷害
newDamageType{
    name = "acid", type = "ACID",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:takeHit(dam, src)
            game.logSeen(target, "%s is burned by acid for %d damage!", target.name:capitalize(), dam)
            -- 施加持續效果（燃燒）
            if not target:attr("acid_immune") then
                target:setEffect(target.EFF_ACIDBURN, 3, {power=dam/3, src=src})
            end
        end
    end,
}
```

---
