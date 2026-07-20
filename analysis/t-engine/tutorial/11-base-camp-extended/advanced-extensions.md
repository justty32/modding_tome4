### 1. 多格農田

`camp_state.farms` 已以 `"x_y"` 為 key 設計，天然支援多格農田同時種植，無需額外修改。只需在地圖上放置更多 `BUILD_SITE_FARM` 格即可。

### 2. 工人自動收穫並重新種植

```lua
-- 在 _cmd_work AI 中，若農田已 ready 自動收穫並重新種植
if farm.ready then
    game:farmInteract(
        game.level.map(tx, ty, Map.TERRAIN),  -- FARM_READY grid
        tx, ty
    )
    -- farmInteract 執行收穫後自動重置為 FARM_EMPTY
    -- 若工人背包有種子，可在此再次呼叫 farmInteract 種植
end
```

### 3. 升級樹（多層建造）

把建造系統擴展為多層升級（基礎農田 → 進階農田 → 溫室），在 chat 的 `cond` 中檢查前一層是否完成：

```lua
cond = function(npc, player)
    local bs = (game.camp_state or {}).buildings or {}
    return bs.farm == true           -- 基礎農田已建造
       and not bs.farm_lv2           -- 進階農田尚未建造
       and countItem(player, "IRON") >= 5
end,
action = function(npc, player)
    build(player, {IRON=5}, "farm_lv2")  -- build_tag = "farm_lv2"
end,
```

### 4. 儲物箱共享存儲

```lua
-- 在 Grid:on_move 的 camp_chest 分支中開啟存儲 Dialog
-- 使用 camp_state.chest_contents = {} 存放共享物品清單
if self.camp_chest and who == game.player then
    -- 開啟自訂 Dialog 讓玩家存放 / 取出物品
    local d = require("mod.dialogs.CampChest").new(game.camp_state)
    game:registerDialog(d)
end
```

---
