獨特文物可以直接指定 `moddable_tile` 路徑：

```lua
newEntity{
    define_as = "DRAGON_SWORD",
    unique    = true,
    name      = "Dragon Sword",
    type      = "weapon", subtype = "sword",
    slot      = "MAINHAND",

    -- 庫存圖示（只需一張）
    image = "object/artifact/dragon_sword.png",

    -- 角色身上的圖層（每個種族性別組合都要有對應檔案！）
    moddable_tile = "special/%s_dragon_sword",
    --   主手：player/human_female/special/right_dragon_sword.png
    --   副手：player/human_female/special/left_dragon_sword.png
    --         player/human_male/special/right_dragon_sword.png
    --         player/dwarf_female/special/right_dragon_sword.png
    --         ...（每個種族）
}
```

> **注意**：`special/` 資料夾位於每個種族資料夾內，每個種族都要提供對應檔案，否則裝備在其他種族身上時圖層會消失。

引擎在物品初始化（`Object:init`）時會自動偵測是否存在 special 圖層：
```lua
-- 若 /data/gfx/shockbolt/player/human_female/special/right_dragon_sword.png 存在
-- 則自動設定 self.moddable_tile = "special/%s_dragon_sword"
```
因此，對於獨特文物，只要把 PNG 放到對的位置，引擎就會自動啟用。

---
