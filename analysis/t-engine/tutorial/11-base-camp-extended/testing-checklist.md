```lua
-- 按 ` 或 F1 開啟 Cheat Console

-- 1. 給自己測試材料
local inven = game.player:getInven("INVEN")
for _, id in ipairs{"WOOD","STONE","HERB_SEED"} do
    for i = 1, 5 do
        local obj = game.zone:makeEntityByName(game.level, "object", id)
        if obj then game.player:addObject(inven, obj) end
    end
end

-- 2. 碰撞建造管理員對話（手動觸發）
game.camp_state.buildings.farm = true
-- 然後手動呼叫 _applyBuildingToMap
local Map = require "engine.Map"
for y=0,game.level.map.h-1 do
    for x=0,game.level.map.w-1 do
        local t = game.level.map(x,y,Map.TERRAIN)
        if t and t.build_tag == "farm" then
            game.level.map(x,y,Map.TERRAIN, game.zone.grid_list["FARM_EMPTY"])
            print("替換農田 at", x, y)
        end
    end
end

-- 3. 確認農田格存在
-- 走到地圖上的 f 字元位置（約 x=5, y=10），確認顯示為空農田

-- 4. 測試農作計時器（作弊加速）
-- 假設已種植在 (5,10)
game.camp_state.farms = game.camp_state.farms or {}
game.camp_state.farms["5_10"] = {
    turn_planted  = 0,      -- 設為 0 使其立即成熟
    turns_to_grow = 100,
    yield         = {HERB=3},
    ready         = false,
}
game:updateCamp()   -- 應觸發成熟提示並替換 Grid

-- 5. 確認 camp_state 存檔
-- 手動存檔後重載，確認 camp_state 仍存在
print("farm 建造狀態：", game.camp_state.buildings.farm)
```

---
