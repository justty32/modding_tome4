```lua
-- ═══════════════════════════════════════════════════
-- 連擊狀態管理
-- ═══════════════════════════════════════════════════

--- 使用連技後更新連擊狀態
function _M:updateComboState(t)
    if t.type == "starter" then
        self.combo_state.active = true
        self.combo_state.count  = self.combo_state.count + 1
        self.combo_state.timer  = 3  -- 3 回合內不行動就清空
    elseif t.type == "linker" then
        self.combo_state.count = self.combo_state.count + 1
        self.combo_state.timer = 3
    elseif t.type == "finisher" then
        -- 終結技清空連擊
        self.combo_state.active = false
        self.combo_state.count  = 0
        self.combo_state.timer  = 0
    elseif t.type == "free" then
        -- 不影響連擊狀態
        if self.combo_state.active then
            self.combo_state.timer = 3  -- 重置計時
        end
    end
    self.changed = true
end

--- 每回合呼叫（倒數連擊計時器）
function _M:techniqueTurn()
    -- 更新冷卻
    for id, cd in pairs(self.techniques.cooldowns) do
        if cd > 0 then
            self.techniques.cooldowns[id] = cd - 1
        end
    end
    -- 連擊超時
    if self.combo_state.active then
        self.combo_state.timer = self.combo_state.timer - 1
        if self.combo_state.timer <= 0 then
            self.combo_state.active = false
            self.combo_state.count  = 0
            game.logPlayer(self, "#GREY#連擊中斷。")
        end
    end
    self.changed = true
end

-- ═══════════════════════════════════════════════════
-- 熟練度
-- ═══════════════════════════════════════════════════

--- 使用連技後增加熟練度
-- proficiency 範圍：0~100（100 = 完全熟練）
function _M:gainTechniqueProficiency(id, amount)
    local entry = self.techniques.known[id]
    if not entry then return end
    entry.uses = (entry.uses or 0) + 1
    -- 越熟練漲得越慢（邊際遞減）
    local gain = amount * (1 - entry.proficiency / 120)
    entry.proficiency = math.min(100, (entry.proficiency or 0) + gain)
end

--- 取得熟練度（0.0~1.0）
function _M:getTechniqueProficiency(id)
    local entry = self.techniques.known[id]
    if not entry then return 0 end
    return (entry.proficiency or 0) / 100
end
```

在 `Actor.lua` 中整合：

```lua
-- class/Actor.lua

local ActorTechnique = require "mod.class.interface.ActorTechnique"

module(..., package.seeall, class.inherit(
    Actor,
    -- ... 其他混入 ...
    ActorTechnique      -- ← 加入
))

function _M:init(t, no_default)
    -- ... 其他 init ...
    ActorTechnique.initTechniques(self, t)

    -- 加入氣（Ki）資源
    -- （需要在 load.lua 中 ActorResource:defineResource("Ki", "ki", ...）
    self.max_ki = t.max_ki or 60
    self.ki     = t.ki or self.max_ki
    self.ki_regen = t.ki_regen or 3  -- 每回合回復 3 點
end

function _M:act()
    if not Actor.act(self) then return end
    self:techniqueTurn()  -- ← 每回合更新連技冷卻和連擊計時
    -- 氣值回復
    self:incResource("ki", self.ki_regen or 3)
    self:timedEffects()
    self:useEnergy()
end
```

---
