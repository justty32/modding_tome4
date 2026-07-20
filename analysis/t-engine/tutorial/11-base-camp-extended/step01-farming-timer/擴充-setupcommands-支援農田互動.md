### 擴充 `setupCommands` 支援農田互動

```lua
-- mod/class/Game.lua → setupCommands()（修改 CHANGE_LEVEL 鍵）

CHANGE_LEVEL = function()
    local Map = require "engine.Map"
    local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
    if not e or not self.player:enoughEnergy() then return end

    -- ① 標準樓層 / Zone 切換
    if e.change_level then
        self:changeLevel(
            e.change_zone and e.change_level
                          or self.level.level + e.change_level,
            e.change_zone)

    -- ② 農田互動（種植 / 查詢進度 / 收穫）
    elseif e.farm_interact then
        self:farmInteract(e, self.player.x, self.player.y)

    -- ③ 建造地塊（開啟建造管理員 chat 的替代方案：直接開選單）
    -- 注意：建造通常由建造管理員 NPC 的對話處理，此處留為備用
    elseif e.build_site then
        game.logPlayer(self.player,
            "這是建造地塊。到建造管理員（M）那裡選擇要建造的設施。")
    end
end,
```

---
