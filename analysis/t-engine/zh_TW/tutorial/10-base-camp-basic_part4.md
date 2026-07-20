## 步驟四：Grid 類別的 `on_move` 擴充

### 為什麼在類別方法中分派？

TE4 的序列化系統使用 `__CLASSNAME` 重建物件的 class metatable，但**匿名函式無法序列化**。如果把 `on_move = function(...) end` 直接放在 `newEntity{}` 裡，存檔後重載時這個函式會遺失。

正確做法：把行為邏輯放在**有名稱的類別方法**中，實體只攜帶**旗標資料**。

### 修改 `mod/class/Grid.lua`

```lua
-- mod/class/Grid.lua
-- 繼承引擎 Grid，在 on_move 中加入旗標分派

require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
    engine.Grid.init(self, t, no_default)
end

-- block_move：處理開門、障礙物
function _M:block_move(x, y, e, act, couldpass)
    -- 玩家主動移動且格子是關閉的門 → 開門
    if self.door_opened and act then
        game.level.map(x, y, engine.Map.TERRAIN,
            game.zone.grid_list[self.door_opened])
        return true
    elseif self.door_opened and not couldpass then
        return true
    end
    -- 可通行特殊地形（water_pass 等）
    if e and self.can_pass and e.can_pass then
        for what, check in pairs(e.can_pass) do
            if self.can_pass[what] and self.can_pass[what] <= check then
                return false
            end
        end
    end
    return self.does_block_move
end

-- ── on_move 分派中心 ──────────────────────────────────────────
-- 每當 Actor 進入此格時被呼叫（forced = true 表示被強制傳送，不觸發）
function _M:on_move(x, y, who, forced)
    if forced then return end

    -- ① 移動投射傷害（原有功能）
    if who.move_project and next(who.move_project) then
        local DamageType = require "engine.DamageType"
        for typ, dam in pairs(who.move_project) do
            DamageType:get(typ).projector(who, x, y, typ, dam)
        end
    end

    -- ② 篝火治療（僅對玩家觸發）
    if self.camp_heal and who == game.player then
        self:_campfireHeal(x, y, who)
    end
end

-- ── 篝火治療邏輯 ──────────────────────────────────────────────
-- 使用 game.level.data 存放冷卻時間戳，跟隨 Level 一起序列化
function _M:_campfireHeal(x, y, who)
    local cd_key = "campfire_heal_cd_" .. x .. "_" .. y
    local last_heal = game.level.data[cd_key] or 0
    local cooldown  = self.camp_heal_cooldown or 10

    -- cooldown 單位是「玩家動作次數」
    -- 1 玩家動作 = energy_to_act / energy_per_tick 個 game.turn
    local ticks_per_act = game.energy_to_act / game.energy_per_tick
    if game.turn - last_heal < cooldown * ticks_per_act then
        return  -- 冷卻中，靜默不提示
    end

    -- 治療量 = camp_heal_pct * 最大 HP（預設 5%）
    local pct  = self.camp_heal_pct or 0.05
    local heal = math.floor(who.max_life * pct)

    if who.life >= who.max_life then
        game.logPlayer(who, "篝火溫暖了你，但生命值已滿。")
        return
    end

    who:heal(heal)
    game.level.data[cd_key] = game.turn
    game.logPlayer(who,
        "#LIGHT_GREEN#篝火的溫暖讓你恢復了 %d 點生命值（%.0f%%）。",
        heal, pct * 100)
end
```

> **`game.level.data[cd_key]`** 是 TE4 中非常常用的模式：把臨時狀態存在 `level.data` 表裡，它隨 Level 物件序列化，可以跨存檔保留（但不跨 Level）。這裡用它記錄上次治療的 `game.turn`，避免篝火每步都觸發。
