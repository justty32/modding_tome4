## 4. 連技定義檔格式

```lua
-- game/modules/hellodungeon/data/techniques/slash.lua

-- ═══════════════════════════════════════════════════
-- 全域定義函式（類似 newTalent 的 newTechnique）
-- ═══════════════════════════════════════════════════

-- 在 load.lua 中定義這個函式：
-- function newTechnique(t)
--     t.short_name = t.short_name or t.name:upper():gsub(" ", "_")
--     t.id = "T_TECH_" .. t.short_name
--     techniques_def[t.id] = t
-- end

newTechnique{
    name       = "迅斬",
    short_name = "SWIFT_SLASH",
    type       = "starter",
    ki_cost    = 8,
    cooldown   = 2,
    -- display：在 HUD 槽位中顯示的符號（若無圖檔）
    display    = "/",
    color      = {100, 200, 255},

    action = function(self, t, combo)
        -- 取得目標（相鄰格）
        local tg = {type="hit", range=1}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return false end  -- 取消使用

        -- 傷害 = 基礎攻擊 × (0.8 + 熟練度 × 0.4)
        local prof = self:getTechniqueProficiency(t.id)
        local dam  = self:combatDamage() * (0.8 + prof * 0.4)

        self:project(tg, x, y, engine.DamageType.PHYSICAL, dam)
        game.logSeen(self, "%s 迅斬！", self:getName():capitalize())
        return true
    end,

    info = function(self, t)
        local prof = self:getTechniqueProficiency(t.id)
        local dam  = self:combatDamage() * (0.8 + prof * 0.4)
        return ("快速斬擊，造成 %.0f 傷害，建立第一個連擊計數。\n"..
               "熟練度：%.0f%%（熟練後傷害最高可達攻擊力的 1.2 倍）"):format(
               dam, prof * 100)
    end,
}
```

---

## 5. 五個範例連技

```lua
-- game/modules/hellodungeon/data/techniques/combo.lua

-- ── 1. 迅斬（起手）────────────────────────────────
newTechnique{
    name = "迅斬", short_name = "SWIFT_SLASH",
    type = "starter", ki_cost = 8, cooldown = 2,
    display = "╱", color = {150, 200, 255},
    action = function(self, t, combo)
        local tg = {type="hit", range=1}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return false end
        local prof = self:getTechniqueProficiency(t.id)
        local dam  = self:combatDamage() * (0.8 + prof * 0.4)
        self:project(tg, x, y, engine.DamageType.PHYSICAL, dam)
        game.logSeen(self, "%s 迅斬！（連擊 +1）",
            self:getName():capitalize())
        return true
    end,
    info = function(self, t)
        return ("快速斬擊，建立連擊。傷害 = 攻擊力 × %.1f"):format(
               0.8 + self:getTechniqueProficiency(t.id) * 0.4)
    end,
}

-- ── 2. 踏步切（起手）─────────────────────────────
newTechnique{
    name = "踏步切", short_name = "STEP_CUT",
    type = "starter", ki_cost = 12, cooldown = 3,
    display = "→", color = {255, 220, 100},
    action = function(self, t, combo)
        local tg = {type="hit", range=2}  -- 更長射程
        local x, y, target = self:getTarget(tg)
        if not x or not target then return false end
        local dam = self:combatDamage() * 1.0
        self:project(tg, x, y, engine.DamageType.PHYSICAL, dam)
        -- 踏步：玩家移動到目標旁邊（teleport adjacent）
        local tx, ty = util.adjacentCoord(x, y, self.x, self.y)
        if tx and not game.level.map:checkEntity(tx, ty, engine.Map.TERRAIN, "block_move") then
            self:move(tx, ty, true)
        end
        game.logSeen(self, "%s 踏步切！", self:getName():capitalize())
        return true
    end,
    info = function(self, t)
        return "踏步衝刺後斬擊，射程 2 格，並移動到目標旁邊。\n建立連擊計數。"
    end,
}
```
