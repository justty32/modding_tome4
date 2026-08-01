```lua
DamageType:newDamageType{
    name = "FIRE",
    type = "fire",
    text_color = "#r#",
    projector = function(src, x, y, type, dam)
        -- 對 (x,y) 的 ACTOR 造成 dam 點火焰傷害
        local target = game.level.map(x, y, Map.ACTOR)
        if target then target:takeHit(dam, src) end
    end,
}
-- 自動生成 DamageType.FIRE 常數
```

- 每種傷害類型都有獨立的 projector 函數，由 `ActorProject:project()` 呼叫。
- 模組可自由定義新傷害類型（毒、神聖、冥界、…）。

---
