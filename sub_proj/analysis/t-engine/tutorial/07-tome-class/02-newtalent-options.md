```lua
newTalent{
    -- ── 必填 ──────────────────────────────────────────────────
    name    = "血液汲取",
    type    = {"blood/sanguination", 1},  -- {type, 在此樹中的位置（1~4）}
    -- 位置 1：樹中第一個技能，無前置需求
    -- 位置 2：需要先習得 1 個該樹技能才能學習
    -- 位置 3：需要 2 個，以此類推

    -- ── 模式（三選一）───────────────────────────────────────────
    mode    = "activated",    -- 主動技能：按鍵後觸發，消耗能量
    -- mode = "sustained",   -- 持續技能：開/關切換，啟動消耗資源，每回合持續消耗
    -- mode = "passive",     -- 被動技能：習得後永久生效，沒有使用動作

    -- ── 技能點需求 ────────────────────────────────────────────
    points  = 5,              -- 最大加點數（1~5，ToME 標準是 5）
    -- 不設預設為 1（只能加到 1 點，通常用於特殊技能）

    -- ── 冷卻與消耗 ────────────────────────────────────────────
    cooldown = 8,             -- 冷卻回合數（mode="activated" 才有意義）
    mana     = 20,            -- 施展時消耗的魔力（需要 ActorResource 定義 mana）
    -- 其他資源：vim、psi、positive、negative、hate、stamina...

    -- 持續技能的資源定義
    sustain_mana = 10,        -- 啟動時消耗（mode="sustained"）
    -- sustain_slots = 1,     -- 此技能最多同時持續幾個

    -- ── 前置需求（見第 3 節詳細說明）─────────────────────────
    require = { stat={mag=function(level) return 20 + level * 8 end} },

    -- ── 技能資訊（滑鼠懸停顯示）────────────────────────────────
    -- info 是函數，self=Actor、t=talent 定義表格
    -- 回傳字串（顯示在技能描述框）
    info    = function(self, t)
        local damage = self:getTalentLevel(t) * 15
        return ("汲取目標的血液，造成 %d 點傷害並回復等量生命。"):format(damage)
    end,

    -- ── 使用效果（activated 模式）────────────────────────────
    action  = function(self, t)
        -- 選擇目標
        local tg = {type="bolt", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not target then return nil end

        -- 計算傷害
        local dam = self:getTalentLevel(t) * 15

        -- 造成傷害（DamageType.project）
        self:project(tg, x, y, engine.DamageType.NATURE, dam)

        -- 回復玩家生命
        self:heal(dam * 0.5, target)

        game.logSeen(self, "%s 汲取了 %s 的生命力！",
            self:getName():capitalize(), target:getName():capitalize())

        return true  -- true = 使用成功，消耗能量和冷卻
    end,

    -- 持續技能的回調
    activate   = function(self, t)  -- 啟動時呼叫（mode="sustained"）
        -- 回傳一個 ret 表格，存在 self.sustain_talents[t.id] 中
        return { id = self:addTemporaryValue("combat_dam", 10) }
    end,
    deactivate = function(self, t, ret)  -- 關閉時呼叫
        self:removeTemporaryValue("combat_dam", ret.id)
        return true
    end,

    -- 被動技能的回調
    passives   = function(self, t, p)  -- mode="passive"，每次學習/升級時呼叫
        self:talentTemporaryValue(p, "combat_physcrit", self:getTalentLevel(t) * 2)
    end,

    -- ── 其他選項 ───────────────────────────────────────────────
    range   = function(self, t) return math.floor(self:getTalentLevel(t) * 1.5 + 3) end,
    radius  = function(self, t) return 2 end,   -- 法術範圍（球形/錐形）
    target  = function(self, t) return {type="bolt", range=self:getTalentRange(t)} end,

    -- no_energy = true：使用不消耗回合行動（瞬發）
    no_energy = true,

    -- on_pre_use：使用前的條件檢查（return false 阻止使用）
    on_pre_use = function(self, t, silent)
        if not self:hasEffect(self.EFF_BLEEDING) then
            if not silent then game.logPlayer(self, "你必須處於流血狀態才能使用此技能！") end
            return false
        end
        return true
    end,
}
```

---
