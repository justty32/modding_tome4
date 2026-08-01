### 10.1 等級 1：純近戰（無技能）

```lua
newEntity{
    name = "cave troll",
    type = "giant", subtype = "troll",
    display = "T", color = colors.GREEN,

    level_range = {5, 12}, exp_worth = 1,
    max_life = resolvers.rngavg(50, 70),
    rank = 2,

    -- 最簡單的 AI：找目標，直線衝
    ai = "simple",
    ai_state = { ai_move = "move_simple" },

    stats = {str=18, dex=8, con=16},
    combat = {dam=12, atk=8},
    combat_armor = 5,
}
```

### 10.2 等級 2：會技能的普通怪（dumb_talented_simple）

```lua
newEntity{
    name = "fire goblin shaman",
    type = "humanoid", subtype = "goblin",
    display = "g", color = colors.RED,

    level_range = {8, 15}, exp_worth = 1.2,
    max_life = resolvers.rngavg(30, 45),
    rank = 2,

    -- 每 4 回合隨機用一個技能
    ai = "dumb_talented_simple",
    ai_state = { talent_in = 4 },

    stats = {str=8, dex=12, con=10, mag=16},
    combat = {dam=4},

    -- 技能（dumb AI 不看 tactical，只要技能可用就隨機選）
    talents = {
        [T_FIREBALL]   = 2,
        [T_FIRE_SHIELD] = 1,
    },
    -- 技能冷卻從第 1 回合開始隨機化（避免所有怪同時開技能）
    talent_cd_reduction = {
        [T_FIREBALL] = resolvers.rngrange(0, 3),
    },
}
```

### 10.3 等級 3：智能戰術 AI（improved_tactical）

```lua
-- 技能定義（必須有 tactical table）
newTalent{
    name = "Soul Drain",
    type = {"necromancy/drain", 1},
    points = 5, cooldown = 5,
    range = 7,
    requires_target = true,

    action = function(self, t)
        local tg = {type="bolt", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        -- 造成傷害並恢復自己的生命
        local dam = 20 + self:getMag() * 2
        target:takeHit(dam, self)
        self:heal(dam * 0.5)
        return true
    end,

    -- ★ 關鍵：tactical table 讓 improved_tactical 知道怎麼用這個技能
    tactical = {
        attack = { DARKNESS = 2 },  -- 主要傷害
        heal   = 1,                 -- 附帶回血（自己）
    },

    info = function(self, t) return "汲取目標靈魂，造成黑暗傷害並恢復生命。" end,
}

-- NPC 定義
newEntity{
    name = "lich",
    type = "undead", subtype = "lich",
    display = "L", color = colors.WHITE,

    level_range = {30, 45}, exp_worth = 3,
    max_life = resolvers.rngavg(300, 400),
    rank = 3.5,  -- 3.5 = 稀有/菁英等級

    -- ★ 使用智能戰術 AI
    ai = "improved_tactical",
    ai_state = {
        ai_target = "target_simple",
        ai_move   = "move_complex",   -- 智能移動（A*/dmap/wander 複合）
        self_compassion = 5,           -- 標準自傷懲罰
        tactical_random_range = 0.3,   -- 稍微降低隨機性，更穩定
    },

    -- ★ 戰術偏好：法師風格（保持距離、使用控制）
    ai_tactic = {
        attack    = 2,
        disable   = 2,
        escape    = 1.5,
        safe_range = 5,   -- 嘗試保持 5 格距離
    },

    stats = {str=10, dex=12, con=16, mag=24, wil=18},
    combat = {dam=6, atk=15},
    combat_armor = 10,

    resists = {
        [DamageType.COLD]    = 100,  -- 冰抗
        [DamageType.DARKNESS]= 50,   -- 暗抗
    },

    -- ★ 所有技能都要有 tactical table
    talents = {
        [T_SOUL_DRAIN]       = 3,
        [T_BONE_SHIELD]      = 2,
        [T_RAISE_DEAD]       = 2,
        [T_PHASE_DOOR]       = 1,
    },
}
```

### 10.4 等級 4：Boss（高度客製化 AI）

```lua
-- 自訂 Boss AI：三個戰鬥階段
newAI("dragon_boss", function(self)
    if not self:runAI("target_simple") then return end

    local hp_pct = self.life / self.max_life

    if hp_pct > 0.6 then
        -- 第一階段（60%+ 血量）：普通攻擊模式
        self.ai_state.ai_move = "move_simple"
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end

    elseif hp_pct > 0.3 then
        -- 第二階段（30-60% 血量）：啟動狂暴
        if not self.ai_state._phase2_triggered then
            self.ai_state._phase2_triggered = true
            -- 觸發特殊效果
            game.log("#CRIMSON#The dragon RAGES!", self.name)
            self:setEffect(self.EFF_RAGE, 9999, {power=1.5})
        end
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end

    else
        -- 第三階段（低於 30% 血量）：拼死反擊
        self.ai_state.safe_range = nil     -- 取消安全距離
        self.ai_tactic.escape = 0          -- 不逃跑
        self.ai_tactic.attack = 5          -- 全力攻擊
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end
    end
end)

newEntity{
    name = "Ancient Dragon",
    unique = true,
    -- ...
    ai = "dragon_boss",
    ai_state = {
        ai_target = "target_simple",
        self_compassion = 3,  -- 稍低，更願意用自傷技能
    },
    ai_tactic = {
        attack     = 2,
        attackarea = 3,  -- 偏好 AOE
        safe_range = 4,
    },
}
```

---
