### 6.1 撰寫第一個自訂 AI

將 AI 定義放在你的模組的 AI 載入目錄中：

```lua
-- game/modules/mygame/mod/ai/custom.lua

-- 巡邏 AI：無目標時遊蕩，有目標時追擊
newAI("patrol_then_chase", function(self)
    -- 步驟 1：尋找目標
    if not self:runAI(self.ai_state.ai_target or "target_simple") then
        -- 沒有目標：隨機遊蕩
        self:runAI("move_wander")
        return
    end

    -- 步驟 2：有目標 → 追擊或使用技能
    if not self.energy.used then
        -- 先嘗試使用技能（1/5 機率）
        if rng.chance(5) then
            self:runAI("dumb_talented")
        end
        -- 若未行動，則移動接近目標
        if not self.energy.used then
            self:runAI(self.ai_state.ai_move or "move_simple")
        end
    end
end)
```

### 6.2 在 load.lua 中載入

```lua
-- game/modules/mygame/load.lua
local ActorAI = require "engine.interface.ActorAI"

-- 載入自訂 AI 定義
ActorAI:loadDefinition("/mod/ai/")
-- 如果也要引擎 AI，先載入引擎的
ActorAI:loadDefinition("/engine/ai/")
```

### 6.3 帶狀態的 AI（計數器、記憶）

```lua
newAI("rage_mode", function(self)
    -- 血量低於 30% 時切換到狂暴模式
    local hp_pct = self.life / self.max_life

    if hp_pct < 0.3 then
        -- 狂暴：永遠追擊，每回合必定使用技能
        if self:runAI("target_simple") then
            self:runAI("dumb_talented")   -- 嘗試用技能
            if not self.energy.used then
                self:runAI("move_simple") -- 沒用成功就移動
            end
        end
    else
        -- 普通模式
        self:runAI("dumb_talented_simple")
    end
end)
```

### 6.4 組合 AI：逃跑 + 技能

```lua
-- 玻璃砲 AI：受傷就跑，安全時狙擊
newAI("glass_cannon", function(self)
    if not self:runAI("target_simple") then return end

    local hp_pct = self.life / self.max_life
    local target = self.ai_target.actor
    local dist = target and core.fov.distance(self.x, self.y, target.x, target.y)

    if hp_pct < 0.5 then
        -- 血量低：逃跑
        self:runAI("flee_simple")
    elseif dist and dist <= 3 then
        -- 目標太近：先跑開
        self:runAI("flee_dmap")
    else
        -- 安全距離：使用遠程技能
        if not self:runAI("dumb_talented") then
            -- 沒有可用技能就等待（消耗 energy）
            self:useEnergy()
        end
    end
end)
```

---
