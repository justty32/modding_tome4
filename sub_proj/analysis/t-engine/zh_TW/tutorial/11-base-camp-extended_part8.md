
## 步驟五：`camp_state` 的初始化與存檔

### 初始化時機

`camp_state` 掛在 `game` 物件上，隨 `game:save()` 自動序列化。在 `newGame()` 時初始化，確保每個新存檔都有乾淨的起始狀態：

```lua
-- 已在步驟一的 Game.lua 中完整實作，這裡重申關鍵點：
game.camp_state = {
    buildings = {farm=false, chest=false, upgraded_fire=false},
    farms     = {},   -- 以 "x_y" 為 key 的農田狀態表
    workers   = {},   -- uid → 任務描述
}
```

### 存檔欄位宣告

```lua
-- mod/class/Game.lua → save()
function _M:save()
    return class.save(self, self:defaultSavedFields{
        camp_state = true,   -- ★ 必須宣告，否則存檔後據點進度消失
    }, true)
end
```

> **`farms` 使用 `"x_y"` 字串 key 的原因**：Lua table 的整數 key 與字串 key 行為略有不同，而座標組合 `x.."_"..y` 是安全的字串 key，不會因 Lua 的 hash table 特性造成序列化問題。也能輕鬆支援多格農田同時種植。

---

## 步驟六：完整流程展示

```
玩家第一次進入據點
│
├─ camp_state.buildings 全部 false
├─ 地圖上顯示 BUILD_SITE_* 格（?）
│
├─ 玩家到野外採集：木材×5
│
├─ 碰撞建造管理員 NPC（M）→ 建造農田
│   ├─ build() 消耗木材×5
│   ├─ camp_state.buildings.farm = true
│   └─ _applyBuildingToMap("farm")
│       → 掃描到 BUILD_SITE_FARM（build_tag="farm"）
│       → 替換為 FARM_EMPTY
│
├─ 玩家踩上農田（FARM_EMPTY），按 >
│   ├─ farmInteract() 消耗草藥種子×1
│   ├─ 地圖：FARM_EMPTY → FARM_GROWING
│   └─ camp_state.farms["x_y"] = {turn_planted=game.turn, ...}
│
├─ （可選）招募工人，指派到農田
│   └─ worker.ai_state.command = {type="work", task="farm"}
│       → 工人移動到農田旁
│       → 每 20 動作：farm.turn_planted -= 5 * ticks_per_act
│
├─ 每 10 game.turn（= 1 玩家動作）
│   └─ Game:onTurn() → updateCamp()
│       └─ turn - turn_planted >= 100 * 10 = 1000
│             → farm.ready = true
│             → 地圖：FARM_GROWING → FARM_READY
│             → 提示玩家
│
├─ 玩家踩上農田（FARM_READY），按 >
│   ├─ farmInteract() 把 yield 加入背包（HERB×3）
│   ├─ 地圖：FARM_READY → FARM_EMPTY
│   └─ camp_state.farms["x_y"] = nil
│
└─ 玩家離開據點（按 < 使用 EXIT_TO_WORLD）
    ├─ Zone:leaveLevel() → memory_levels[1] = level
    └─ Zone:save() 寫入 .teaz 磁碟檔
        → 地圖 Grid 替換狀態持久化（農田格保留）
        → camp_state 隨 game:save() 持久化（種植進度保留）
```

---

## 測試檢查清單

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