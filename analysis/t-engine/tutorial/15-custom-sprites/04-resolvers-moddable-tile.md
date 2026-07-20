普通（非獨特）裝備通常用 `resolvers.moddable_tile` 隨機選取圖層，根據物品品質等級（`material_level` 1–5）：

```lua
-- 在物品定義中
newEntity{
    name        = "Short Sword",
    type        = "weapon", subtype = "sword",
    slot        = "MAINHAND",
    moddable_tile = resolvers.moddable_tile("sword"),
    -- material_level 1 → "%s_hand_04_01"
    -- material_level 3 → "%s_hand_04_03"
    -- material_level 5 → "%s_hand_04_05"
}
```

`resolvers.moddable_tile` 支援的 slot 名稱列表（在 `mod/resolvers.lua` 中定義）：

```
"sword", "2hsword", "dagger", "axe", "2haxe", "mace", "2hmace",
"bow", "sling", "staff", "trident", "whip", "shield", "mindstar",
"massive", "heavy", "light", "robe",
"helm", "wizard_hat", "leather_cap",
"gauntlets", "gloves",
"leather_boots", "heavy_boots",
"cloak",
"quiver", "shotbag", "gembag"
```

---
