```lua
-- ── 3. 旋風斬（中繼）─────────────────────────────
newTechnique{
    name = "旋風斬", short_name = "SPIN_SLASH",
    type = "linker", ki_cost = 15, cooldown = 4,
    display = "✦", color = {100, 255, 180},
    action = function(self, t, combo)
        -- 中繼技：hit all adjacent
        local tg = {type="ball", radius=1, selffire=false}
        local dam = self:combatDamage() * (0.6 + combo * 0.1)
        self:project(tg, self.x, self.y, engine.DamageType.PHYSICAL, dam)
        game.logSeen(self, "%s 旋風斬！（連擊計數 %d，傷害倍率 %.1f×）",
            self:getName():capitalize(), combo,
            (0.6 + combo * 0.1))
        return true
    end,
    info = function(self, t)
        return ("對周圍所有敵人造成攻擊，需要先建立連擊。\n"..
               "傷害隨連擊計數增加（每層 +10%%）。")
    end,
}

-- ── 4. 穿甲刺（中繼）─────────────────────────────
newTechnique{
    name = "穿甲刺", short_name = "ARMOR_PIERCE",
    type = "linker", ki_cost = 18, cooldown = 5,
    display = "▶", color = {255, 120, 80},
    action = function(self, t, combo)
        local tg = {type="hit", range=1}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return false end

        -- 臨時降低目標護甲（持續 2 回合）
        local reduce = 5 + combo * 3
        local id = target:addTemporaryValue("combat_armor", -reduce)
        -- 計畫在 2 回合後移除（使用 setEffect 更優雅，這裡簡化）
        -- TODO: 完整版應使用 ActorTemporaryEffects

        local dam = self:combatDamage() * 0.9
        self:project(tg, x, y, engine.DamageType.PHYSICAL, dam)
        game.logSeen(self, "%s 穿甲刺！降低目標護甲 %d 點。",
            self:getName():capitalize(), reduce)
        return true
    end,
    info = function(self, t)
        return ("刺穿目標護甲，降低其護甲值。連擊越高降低越多。\n需要已有連擊計數。")
    end,
}

-- ── 5. 斬裂衝（終結）─────────────────────────────
newTechnique{
    name = "斬裂衝", short_name = "BURST_CLEAVE",
    type = "finisher", ki_cost = 25, cooldown = 8,
    display = "★", color = {255, 60, 60},
    action = function(self, t, combo)
        local tg = {type="hit", range=1}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return false end

        -- 終結技：連擊數越高，額外傷害乘數越大
        -- combo=1 → 1.5×, combo=2 → 2.0×, combo=5 → 3.5×
        local multiplier = 1.0 + combo * 0.5
        local dam        = self:combatDamage() * multiplier

        -- 視覺效果（若有粒子系統）
        -- game.level.map:particleEmitter(x, y, 1, "blood")

        self:project(tg, x, y, engine.DamageType.PHYSICAL, dam)
        game.logSeen(self, "#CRIMSON#%s 斬裂衝！%d 連擊，%.1f 倍傷害！#LAST#",
            self:getName():capitalize(), combo, multiplier)

        -- 終結技特效：回復一定氣值（獎勵完整連擊）
        if combo >= 3 then
            self:incResource("ki", combo * 3)
            game.logPlayer(self, "完整連擊！回復 %d 點氣。", combo * 3)
        end

        return true
    end,
    info = function(self, t)
        return ("連擊終結技。傷害 = 攻擊力 × (1.0 + 連擊數 × 0.5)。\n"..
               "3 連擊以上追加回復氣值。\n"..
               "需要先建立至少 1 個連擊計數。")
    end,
}
```
