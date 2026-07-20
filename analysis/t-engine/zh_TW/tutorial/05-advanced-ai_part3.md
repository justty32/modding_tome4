### 8.6 啟用 improved_tactical

```lua
newEntity{
    name = "elite fire mage",
    ai = "improved_tactical",
    ai_state = {
        ai_target = "target_simple",
        ai_move   = "move_simple",
        self_compassion = 5,
        ally_compassion = 1,
        tactical_random_range = 0.3,
    },
    talents = { [T_FIREBALL]=3, [T_MANA_SHIELD]=1 },
}
```

---

## 9. ai_tactic：NPC 的戰術偏好

`ai_tactic` 是 NPC 的**個性設定**，乘以 WANT 值：

```lua
newEntity{
    name = "aggressive berserker",
    ai_tactic = {
        attack   = 3,   -- 攻擊慾望 3 倍
        escape   = 0,   -- 永不逃跑
        defend   = 0.5,
        disable  = 2,
        safe_range = 4, -- 保持 4 格外
    },
}
```

### 常見風格模板

```lua
-- 近戰侵略
ai_tactic = { attack = 3, closein = 2, escape = 0, defend = 0.5 }
-- 遠程狙擊
ai_tactic = { attack = 2, escape = 2, closein = 0.5, safe_range = 5 }
-- 支援治療
ai_tactic = { heal = 3, defend = 2, attack = 0.5, escape = 2 }
-- 控制削弱
ai_tactic = { disable = 3, attack = 1.5, buff = 1 }
-- Boss 型
ai_tactic = { attack=2, disable=2, buff=2, heal=2, escape=1, safe_range=3 }
```

---

## 10. 完整 NPC 範例

### 10.1 Lv1：純近戰（無技能）

```lua
newEntity{
    name = "cave troll",
    type = "giant", subtype = "troll",
    display = "T", color = colors.GREEN,
    level_range = {5, 12}, exp_worth = 1,
    max_life = resolvers.rngavg(50, 70), rank = 2,
    ai = "simple",
    ai_state = { ai_move = "move_simple" },
    stats = {str=18, dex=8, con=16},
    combat = {dam=12, atk=8}, combat_armor = 5,
}
```

### 10.2 Lv2：會技能的普通怪（dumb_talented_simple）

```lua
newEntity{
    name = "fire goblin shaman",
    type = "humanoid", subtype = "goblin",
    display = "g", color = colors.RED,
    level_range = {8, 15}, exp_worth = 1.2,
    max_life = resolvers.rngavg(30, 45), rank = 2,
    ai = "dumb_talented_simple",
    ai_state = { talent_in = 4 },
    stats = {str=8, dex=12, con=10, mag=16},
    combat = {dam=4},
    talents = { [T_FIREBALL]=2, [T_FIRE_SHIELD]=1 },
    talent_cd_reduction = {
        [T_FIREBALL] = resolvers.rngrange(0, 3),
    },
}
```

### 10.3 Lv3：智能戰術 AI（improved_tactical）

```lua
-- 技能定義（必須有 tactical table）
newTalent{
    name = "Soul Drain",
    type = {"necromancy/drain", 1},
    points = 5, cooldown = 5, range = 7,
    requires_target = true,
    action = function(self, t)
        local tg = {type="bolt", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        local dam = 20 + self:getMag() * 2
        target:takeHit(dam, self)
        self:heal(dam * 0.5)
        return true
    end,
    -- ★ tactical table 讓 improved_tactical 知道怎麼用
    tactical = { attack = { DARKNESS = 2 }, heal = 1 },
    info = function(self, t) return "汲取目標靈魂，造成暗傷並回血。" end,
}

-- NPC 定義
newEntity{
    name = "lich",
    type = "undead", subtype = "lich",
    display = "L", color = colors.WHITE,
    level_range = {30, 45}, exp_worth = 3,
    max_life = resolvers.rngavg(300, 400), rank = 3.5,
    ai = "improved_tactical",
    ai_state = {
        ai_target = "target_simple",
        ai_move   = "move_complex",
        self_compassion = 5,
        tactical_random_range = 0.3,
    },
    ai_tactic = { attack=2, disable=2, escape=1.5, safe_range=5 },
    stats = {str=10, dex=12, con=16, mag=24, wil=18},
    combat = {dam=6, atk=15}, combat_armor = 10,
    resists = { [DamageType.COLD]=100, [DamageType.DARKNESS]=50 },
    talents = {
        [T_SOUL_DRAIN]=3, [T_BONE_SHIELD]=2,
        [T_RAISE_DEAD]=2, [T_PHASE_DOOR]=1,
    },
}
```

### 10.4 Lv4：Boss（高度自訂 AI）

```lua
-- 自訂 Boss AI：三階段
newAI("dragon_boss", function(self)
    if not self:runAI("target_simple") then return end
    local hp_pct = self.life / self.max_life

    if hp_pct > 0.6 then
        -- 第一階段：普通攻擊
        self.ai_state.ai_move = "move_simple"
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end

    elseif hp_pct > 0.3 then
        -- 第二階段：狂暴
        if not self.ai_state._phase2_triggered then
            self.ai_state._phase2_triggered = true
            game.log("#CRIMSON#The dragon RAGES!", self.name)
            self:setEffect(self.EFF_RAGE, 9999, {power=1.5})
        end
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end

    else
        -- 第三階段：拼死反擊
        self.ai_state.safe_range = nil
        self.ai_tactic.escape = 0
        self.ai_tactic.attack = 5
        self:runAI("use_improved_tactical")
        if not self.energy.used then self:runAI("move_simple") end
    end
end)

newEntity{
    name = "Ancient Dragon",
    unique = true,
    ai = "dragon_boss",
    ai_state = { ai_target = "target_simple", self_compassion = 3 },
    ai_tactic = { attack = 2, attackarea = 3, safe_range = 4 },
}
```
