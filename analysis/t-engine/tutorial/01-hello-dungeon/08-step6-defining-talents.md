技能是玩家（和 NPC）可以使用的特殊能力：

```lua
-- game/modules/hellodungeon/data/talents.lua

-- 定義技能類型（用來分組顯示）
newTalentType{
    type = "role/combat",
    name = "combat",
    description = "戰鬥技巧"
}

-- 踢擊技能：將目標擊退
newTalent{
    name = "Kick",
    type = {"role/combat", 1},  -- 屬於 "role/combat" 組，第一個位置
    points = 1,                  -- 最多學習幾點
    cooldown = 6,                -- 冷卻時間（回合數）
    power = 2,                   -- 消耗的能量

    -- 目標選擇：近戰（range=1 的 hit 類型）
    -- 技能執行邏輯
    action = function(self, t)
        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        -- 必須在射程內
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        -- 擊退目標
        target:knockback(self.x, self.y, 2 + self:getDex())
        return true  -- 必須回傳 true 才會消耗能量和觸發冷卻
    end,

    -- 技能說明（顯示在 Tooltip 中）
    info = function(self, t)
        return ("踢開目標，將其擊退 %d 格。"):format(2 + self:getDex())
    end,
}

-- 酸液噴射技能：範圍傷害
newTalent{
    name = "Acid Spray",
    type = {"role/combat", 1},
    points = 1,
    cooldown = 6,
    power = 2,
    range = 6,

    action = function(self, t)
        -- ball 類型：以目標點為中心的圓形範圍
        local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        -- 對範圍內所有實體造成 ACID 傷害
        self:project(tg, x, y, DamageType.ACID, 1 + self:getDex(), {type="acid"})
        return true
    end,

    info = function(self, t)
        return ("向目標噴射酸液，造成 %d 點酸液傷害。"):format(1 + self:getDex())
    end,
}
```

**技能定義速查**：

| 欄位 | 說明 |
|------|------|
| `type` | `{技能組名, 需求等級}` |
| `mode` | `"activated"`（主動，預設）/ `"sustained"`（持續）/ `"passive"`（被動）|
| `cooldown` | 冷卻回合數 |
| `power` | 消耗的 Power 資源 |
| `range` | 使用距離 |
| `action(self, t)` | 技能執行（回傳 `true` = 成功消耗能量）|
| `info(self, t)` | 技能說明文字（支援動態計算）|

**投射形狀（`tg.type`）**：

| 形狀 | 說明 |
|------|------|
| `"hit"` | 單一目標（近戰/遠程）|
| `"ball"` | 圓形範圍（需要 `radius`）|
| `"beam"` | 直線穿透 |
| `"cone"` | 扇形（需要 `cone_angle`）|
| `"bolt"` | 直線彈道（不穿透）|

---
