這是核心模組，管理所有連技狀態：

```lua
-- game/modules/hellodungeon/class/interface/ActorTechnique.lua

require "engine.class"

module(..., package.seeall, class.make)

-- ═══════════════════════════════════════════════════
-- 初始化
-- ═══════════════════════════════════════════════════

function _M:initTechniques(t)
    self.techniques = t.techniques or {
        slots = {nil, nil, nil, nil, nil},
        known = {},
        cooldowns = {},
    }
    self.combo_state = {
        count  = 0,
        timer  = 0,
        active = false,
    }
end

-- ═══════════════════════════════════════════════════
-- 連技習得
-- ═══════════════════════════════════════════════════

--- 習得一個連技
function _M:learnTechnique(id)
    if not techniques_def[id] then
        error("[Technique] 未知連技 ID: "..tostring(id))
        return false
    end
    if self.techniques.known[id] then
        game.logPlayer(self, "你已經知道「%s」了。", techniques_def[id].name)
        return false
    end
    self.techniques.known[id] = { proficiency = 0, uses = 0 }
    game.logPlayer(self, "#YELLOW#你習得了新連技：「%s」！", techniques_def[id].name)
    return true
end

--- 是否已習得
function _M:knowsTechnique(id)
    return self.techniques.known[id] ~= nil
end

-- ═══════════════════════════════════════════════════
-- 槽位管理
-- ═══════════════════════════════════════════════════

--- 將連技裝填到指定槽位
function _M:setTechniqueSlot(slot, id)
    assert(slot >= 1 and slot <= 5, "槽位必須是 1~5")
    if id and not self:knowsTechnique(id) then
        game.logPlayer(self, "你還不知道這個連技。")
        return false
    end
    self.techniques.slots[slot] = id
    self.changed = true
    return true
end

--- 取得指定槽位的連技定義
function _M:getTechniqueInSlot(slot)
    local id = self.techniques.slots[slot]
    return id and techniques_def[id]
end

-- ═══════════════════════════════════════════════════
-- 使用連技
-- ═══════════════════════════════════════════════════

--- 檢查是否可以使用這個連技
function _M:canUseTechnique(t)
    if not t then return false, "連技不存在" end
    -- 冷卻中
    if self.techniques.cooldowns[t.id] and self.techniques.cooldowns[t.id] > 0 then
        return false, ("冷卻中：%d 回合"):format(self.techniques.cooldowns[t.id])
    end
    -- 氣值不足
    local ki = self:getResource("ki") or 0
    if ki < t.ki_cost then
        return false, ("氣值不足（需要 %d，現有 %d）"):format(t.ki_cost, ki)
    end
    -- 狀態限制
    if t.type == "linker" or t.type == "finisher" then
        if not self.combo_state.active then
            return false, "需要先建立連擊（使用起手技）"
        end
    end
    return true
end

--- 使用槽位中的連技
function _M:useTechniqueInSlot(slot)
    local t = self:getTechniqueInSlot(slot)
    if not t then
        game.logPlayer(self, "槽位 %d 沒有連技。", slot)
        return false
    end
    local ok, reason = self:canUseTechnique(t)
    if not ok then
        game.logPlayer(self, "#RED#無法使用「%s」：%s", t.name, reason)
        return false
    end

    -- 消耗資源
    self:incResource("ki", -t.ki_cost)

    -- 設定冷卻
    self.techniques.cooldowns[t.id] = t.cooldown or 0

    -- 執行效果
    local combo_before = self.combo_state.count
    local result = t.action(self, t, self.combo_state.count)

    -- 更新連擊狀態
    if result ~= false then
        self:updateComboState(t)
    end

    -- 熟練度提升
    self:gainTechniqueProficiency(t.id, 1)

    -- 消耗一個行動
    self:useEnergy()
    return true
end

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
    -- （需要在 load.lua 中 ActorResource:defineResource("Ki", "ki", ...)）
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
