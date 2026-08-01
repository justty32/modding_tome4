不使用 `moddable_tile` 系統的 NPC，可以直接在定義中設定 `add_mos` 做多層疊加：

```lua
newEntity{
    define_as = "BOSS_DRAGON",
    name      = "Dragon Boss",
    image     = "npc/dragon/dragon_base.png",
    add_mos   = {
        {image = "npc/dragon/dragon_wings.png",  auto_tall=1},
        {image = "npc/dragon/dragon_crown.png",  auto_tall=1},
    },
}
```

`auto_tall=1` 表示這個圖層使用 2 格高度的渲染（佔據上方格子），用於顯示高大的生物。

也可以在 `add_mos` 項目中加粒子：
```lua
add_mos = {
    {
        image         = "npc/demon/demon_body.png",
        particle      = "fire_aura",
        particle_args = {power=5},
        auto_tall     = 1,
    },
}
```

---
