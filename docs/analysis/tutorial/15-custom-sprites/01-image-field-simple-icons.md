任何實體（Entity）都可以設定 `image` 欄位，這是它在地圖上和庫存畫面的圖示：

```lua
newEntity{
    name    = "Iron Sword",
    type    = "weapon", subtype = "sword",
    slot    = "MAINHAND",
    image   = "object/sword/iron_sword.png",  -- 相對於 /data/gfx/
}
```

若設定 `auto_image = true`，引擎會根據名稱自動產生路徑：
```lua
auto_image = true  -- 名稱 "Iron Sword" → image = "object/ironsword.png"
```
對獨特文物（unique）則會查找 `"object/artifact/ironsword.png"`。

**NPC 和非玩家 Actor** 的地圖圖示也用 `image` 欄位，不需要 `moddable_tile` 系統。

---
