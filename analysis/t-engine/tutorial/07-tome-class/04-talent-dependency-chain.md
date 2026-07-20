這裡展示完整的「血術」技能樹（五個技能，一條清晰的依賴鏈）：

```lua
-- game/addons/sanguinist/data/talents/blood.lua

-- ═══════════════════════════════════════════════════
-- 技能樹定義
-- ═══════════════════════════════════════════════════
newTalentType{
    type        = "blood/sanguination",
    name        = "血術精通",
    description = "透過操控血液的力量汲取敵人的生命，或以血為盾、以血為刃。",
    allow_random = false,   -- 不讓隨機 Boss 用這些技能（保持職業特色）
}

-- ── 技能 1：血術精通（被動） ─────────────────────────────
newTalent{
    name   = "血術精通",
    type   = {"blood/sanguination", 1},  -- 樹中第一個
    mode   = "passive",
    points = 5,
    -- 無前置需求（樹的第一個技能）
    passives = function(self, t, p)
        -- 每點增加 3% 生命汲取效率
        self:talentTemporaryValue(p, "blood_drain_bonus",
            self:getTalentLevel(t) * 0.03)
    end,
    info = function(self, t)
        return ("深化你對血術的理解。\n"..
               "每點提升 3%% 生命汲取效果（當前：%.0f%%）。"):format(
               (self:getTalentLevel(t) * 3))
    end,
}

-- ── 技能 2：血液汲取（主動） ─────────────────────────────
newTalent{
    name     = "血液汲取",
    type     = {"blood/sanguination", 2},  -- 需要先學 1 個技能
    mode     = "activated",
    points   = 5,
    cooldown = function(self, t)
        return math.max(3, 8 - self:getTalentLevel(t))
    end,
    mana     = 15,
    range    = function(self, t)
        return math.floor(3 + self:getTalentLevel(t) * 0.8)
    end,
    require  = {
        stat  = { mag = function(level) return 10 + level * 4 end },
        -- 依賴技能1
        talent = { {ActorTalents.T_BLOOD_MASTERY, 1} },
    },
    action = function(self, t)
        local tg = {type="bolt", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return nil end

        local dam = self:combatSpellpower() * (0.5 + self:getTalentLevel(t) * 0.3)
        -- 汲取加成來自血術精通被動
        local bonus = 1 + (self.blood_drain_bonus or 0)
        dam = dam * bonus

        self:project(tg, x, y, DamageType.MIND, dam)

        -- 回復自身生命（50% 傷害轉化）
        if not target.dead then
            self:heal(dam * 0.5, target)
        end
        return true
    end,
    info = function(self, t)
        local dam = self:combatSpellpower() * (0.5 + self:getTalentLevel(t) * 0.3)
        return ("向目標射出血液汲取射線，造成 %.0f 精神傷害並回復 50%% 作為生命值。\n"..
               "冷卻：%d 回合 | 射程：%d格"):format(
               dam, self:getTalentCooldown(t), self:getTalentRange(t))
    end,
}

-- ── 技能 3：血盾屏護（持續） ─────────────────────────────
newTalent{
    name           = "血盾屏護",
    type           = {"blood/sanguination", 3},
    mode           = "sustained",
    points         = 5,
    sustain_mana   = 20,
    -- 每回合持續消耗（若使用 ActorResource）
    -- sustain_drain = {mana = 2},
    require = {
        stat  = { mag = function(level) return 18 + level * 5 end },
        talent = { {ActorTalents.T_BLOOD_DRAIN, 2} },  -- 需要血液汲取 2 點
    },
    activate = function(self, t)
        -- 啟動時給予護甲和生命回復
        local armor = math.floor(self:getTalentLevel(t) * 4)
        local regen = self:getTalentLevel(t) * 0.5
        local ret = {}
        ret.armor = self:addTemporaryValue("combat_armor", armor)
        ret.regen = self:addTemporaryValue("life_regen", regen)
        return ret
    end,
    deactivate = function(self, t, ret)
        self:removeTemporaryValue("combat_armor", ret.armor)
        self:removeTemporaryValue("life_regen", ret.regen)
        return true
    end,
    info = function(self, t)
        local armor = math.floor(self:getTalentLevel(t) * 4)
        local regen = self:getTalentLevel(t) * 0.5
        return ("以血液薄膜包裹自身，提供 %d 點護甲值和每回合 %.1f 點生命回復。"):format(
               armor, regen)
    end,
}

-- ── 技能 4：血液爆發（主動） ─────────────────────────────
newTalent{
    name     = "血液爆發",
    type     = {"blood/sanguination", 4},  -- 需要 3 個前置
    mode     = "activated",
    points   = 5,
    cooldown = 14,
    mana     = 40,
    radius   = function(self, t) return 2 + math.floor(self:getTalentLevel(t) / 2) end,
    require = {
        stat  = { mag = function(level) return 28 + level * 6 end },
        talent = { {ActorTalents.T_BLOOD_SHIELD, 2} },  -- 需要血盾 2 點
    },
    action = function(self, t)
        -- 以自身為中心的血液爆炸（消耗自己的生命）
        local cost = self.max_life * 0.1  -- 消耗 10% 最大生命值
        if self.life <= cost then
            game.logPlayer(self, "你的生命值不足以釋放血液爆發！")
            return nil
        end
        self:takeHit(cost, self)  -- 自我傷害

        local dam = self:combatSpellpower() * (1 + self:getTalentLevel(t) * 0.5)
        local tg = {type="ball", radius=self:getTalentRadius(t), selffire=false}
        self:project(tg, self.x, self.y, DamageType.MIND, dam)

        game.logSeen(self, "%s 引爆自身血液，對周圍造成 %.0f 傷害！",
            self:getName():capitalize(), dam)
        return true
    end,
    info = function(self, t)
        local dam = self:combatSpellpower() * (1 + self:getTalentLevel(t) * 0.5)
        return ("引爆自身血液，消耗 10%% 最大生命值，\n"..
               "對 %d 格範圍內的敵人造成 %.0f 精神傷害。"):format(
               self:getTalentRadius(t), dam)
    end,
}
```

---
