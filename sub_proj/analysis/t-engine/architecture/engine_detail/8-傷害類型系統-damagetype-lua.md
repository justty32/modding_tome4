```lua
DamageType:newDamageType{
    name = "FIRE", type = "fire", text_color = "#r#",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then target:takeHit(dam, src) end
    end,
}
-- 自動生成 DamageType.FIRE 常數
```

- 每種傷害類型有獨立 projector 函數，由 `ActorProject:project()` 呼叫
- `setDefaultProjector(fct)` — 未自訂 projector 的傷害類型使用預設
- `projectingFor(src, v)` / `getProjectingFor(src)` — 委派投射（一個角色代另一個投射）

---
