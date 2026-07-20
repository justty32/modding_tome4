若要使用力量藥水的範例，在 `data/timed_effects.lua` 中加入：

```lua
-- 在現有的效果定義後面加入
newEffect{
    name = "STRENGTH_BOOST",
    desc = "力量提升",
    type = "physical",
    subtype = { },
    status = "beneficial",
    parameters = { id=nil },
    -- 效果結束時：移除 addTemporaryValue 加的 combat_dam 加成
    deactivate = function(self, eff)
        if eff.id then
            self:removeTemporaryValue("combat_dam", eff.id)
        end
    end,
}
```

---
