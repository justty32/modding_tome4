`descriptor_choices` 控制「選擇 A 後，B 的選項如何被過濾」。最常見的是種族-職業相容性：

```lua
-- 在 subclass 定義中設定哪些種族可以選擇此職業：
descriptor_choices = {
    -- 過濾 "race" 類型的描述符
    race = {
        -- 允許所有種族（不設限制）
        __ALL__ = "allow",
    },
    -- 或者只允許特定種族：
    -- race = {
    --     __ALL__  = "disallow",
    --     ["Human"] = "allow",
    --     ["Elf"]   = "allow",
    -- },
}

-- 在 race 定義中也可以設定哪些職業兼容：
-- （位於 data/birth/races/xxx.lua）
newBirthDescriptor{
    type = "race",
    name = "Human",
    descriptor_choices = {
        subclass = {
            -- 允許玩家選擇血術師
            ["Sanguinist"] = "allow",
            -- 其他職業的 allow/disallow 由各職業的 subclass 定義控制
        },
    },
    -- ...
}
```

**相容性邏輯**：種族和職業的 `descriptor_choices` 取**交集**。只有兩邊都 `"allow"` 的組合才能被玩家選擇。

---
