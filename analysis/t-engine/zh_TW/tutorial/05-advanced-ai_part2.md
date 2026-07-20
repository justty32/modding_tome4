---

## 5. ai_state：AI 記憶與設定

分兩類：

### 靜態設定（NPC 定義）

```lua
ai_state = {
    -- 基本
    ai_target  = "target_simple",
    ai_move    = "move_simple",
    talent_in  = 4,                -- dumb AI：每 N 回合用技能
    no_talents = false,            -- true = 禁用技能

    -- 戰術 AI
    self_compassion   = 5,         -- 自傷懲罰係數（預設 5）
    ally_compassion   = 1,         -- 友傷懲罰係數（預設 1）
    tactical_random_range = 0.5,   -- 隨機化幅度（預設 0.5）

    -- 進階移動
    sense_radius = 10,             -- target_player_radius 用的感知半徑
}
```

### 動態狀態（運行時由 AI 修改）

```lua
self.ai_state.target_last_seen = {x=10, y=20, turn=1500}
self.ai_state.blocked_turns    = 5
self.ai_state._fight_data      = {actions=10, attacks=7}
```

---

## 6. 自訂簡單 AI

### 6.1 第一個自訂 AI

放在 `mod/ai/custom.lua`：

```lua
-- game/modules/mygame/mod/ai/custom.lua

-- 巡邏 AI：無目標遊蕩，有目標追擊
newAI("patrol_then_chase", function(self)
    -- 步驟 1：尋找目標
    if not self:runAI(self.ai_state.ai_target or "target_simple") then
        self:runAI("move_wander")
        return
    end

    -- 步驟 2：有目標 → 追擊或技能
    if not self.energy.used then
        if rng.chance(5) then
            self:runAI("dumb_talented")
        end
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
ActorAI:loadDefinition("/mod/ai/")
-- 若也需要引擎 AI：ActorAI:loadDefinition("/engine/ai/")
```

### 6.3 帶狀態的 AI（計數器、記憶）

```lua
newAI("rage_mode", function(self)
    local hp_pct = self.life / self.max_life

    if hp_pct < 0.3 then
        -- 狂暴：每回合必用技能
        if self:runAI("target_simple") then
            self:runAI("dumb_talented")
            if not self.energy.used then
                self:runAI("move_simple")
            end
        end
    else
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
        self:runAI("flee_simple")
    elseif dist and dist <= 3 then
        self:runAI("flee_dmap")
    else
        if not self:runAI("dumb_talented") then
            self:useEnergy()  -- 無技能可用則等待
        end
    end
end)
```

---

## 7. 技能的戰術表（tactical table）

`tactical` 是讓**智能 AI**（`use_tactical`、`use_improved_tactical`）理解技能用途的關鍵。

### 7.1 基本格式

```lua
newTalent{
    name = "Fireball",
    tactical = {
        TACTIC_NAME = weight,
        -- 或細分傷害類型
        TACTIC_NAME = { DAMAGE_TYPE = weight },
    },
}
```

### 7.2 所有戰術分類

#### 傷害類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `attack` | 單目標傷害 | `{FIRE=2}` |
| `attackarea` | 多目標 AOE | `{COLD=3}` |
| `attackall` | 大範圍全傷 | `2` |

#### 生存類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `heal` | 恢復生命 | `2` |
| `cure` | 移除負面效果 | `2` |
| `defend` | 提升防禦/抗性 | `2` |
| `escape` | 增加與目標距離 | `2` |

#### 戰略類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `buff` | 增強己方 | `2` |
| `disable` | 控制/削弱目標 | `{stun=2}` |
| `closein` | 縮短距離 | `3` |
| `surrounded` | 被包圍時有用 | `3` |
| `protect` | 保護召喚者 | `3` |

#### 資源類

| Tactic | 說明 |
|--------|------|
| `stamina` | 恢復體力 |
| `mana` | 恢復魔力 |
| `ammo` | 補充彈藥 |
| `special` | 自訂（固定 want=1）|

### 7.3 戰術值的含義

數值代表技能在此戰術上的**效果強度**：

```lua
tactical = {
    attack = 2,      -- 標準（多數攻擊用 2）
    attack = 4,      -- 強力攻擊（對 AI 更有吸引力）
    attack = 0.5,    -- 弱攻擊（附帶傷害）
}
```

**細分傷害類型（影響抗性計算）**：

```lua
tactical = {
    attack = { FIRE = 2 },
    attack = { PHYSICAL = 3 },
    disable = { stun = 1, slow = 1 },
}
```

目標對火焰高抗時，AI 會降低此技能的吸引力。

### 7.4 函式形式

戰術值可以是函式，依情況動態計算：

```lua
newTalent{
    name = "Chain Lightning",
    tactical = function(self, t, aitarget)
        local nb_foes = 0
        for _, act in ipairs(self.fov.actors_dist) do
            if self:reactionToward(act) < 0 then nb_foes = nb_foes + 1 end
        end
        return {
            attackarea = nb_foes >= 3 and 4 or 2,
        }
    end,
}
```

### 7.5 實際範例

```lua
-- 治療
newTalent{ name = "Minor Heal", tactical = { heal = 2 } }

-- 火球（AOE）
newTalent{ name = "Fireball", tactical = { attackarea = { FIRE = 2 } } }

-- 衝刺（靠近 + 攻擊）
newTalent{ name = "Rush", tactical = { closein = 3, attack = 1 } }

-- 屏障（純防禦）
newTalent{ name = "Stone Skin", mode = "sustained",
  tactical = { defend = 2, buff = 1 } }

-- 暈眩
newTalent{ name = "Stunning Blow",
  tactical = { attack = { PHYSICAL = 1 }, disable = { stun = 2 } } }

-- 傳送逃跑
newTalent{ name = "Phase Door", tactical = { escape = 2 } }
```

---

## 8. improved_tactical：三步評分系統

ToME 最進階的 AI，用於稀有/Boss NPC。

### 8.1 三步流程

```
Step 1: TACTIC WEIGHT（技能對各戰術的貢獻值）
          ↓
Step 2: WANT VALUE（AI 當下對各戰術的需求）
          ↓
Step 3: FINAL TACTICAL SCORE（SCORE = WEIGHT × WANT × 偏好）
          → 選最高分技能執行
```

### 8.2 Step 1：TACTIC WEIGHT

技能的 `tactical` 表轉換為加權後的分數：

```lua
-- 原始
tactical = { attack = {FIRE=2}, disable = {stun=1} }

-- 考慮目標火焰抗性（-50%）：
tacts = { attack = 1.0, disable = 1.0 }
-- attack 從 2 降到 1（目標火抗 50%）
-- disable 不變
```

**影響因子**：
- 目標對傷害類型的抗性
- AOE 打到的目標數
- 友軍傷害懲罰
- 自傷懲罰（`self_compassion`）

### 8.3 Step 2：WANT VALUE

WANT 代表對每個戰術的「渴望程度」（-10 ~ +10），自動計算：

| 戰術 | 計算邏輯 | 典型值 |
|------|---------|--------|
| `attack` | 固定 2，眩暈/麻痺時減半 | 1-2 |
| `heal` | 血量越低越高（40% 時約 4）| 0-10 |
| `cure` | 負面效果越多越高 | 0-10 |
| `defend` | 附近敵人越多越高 | 0.1-10 |
| `escape` | 血量 + 距離觸發（25% 時 ≈ 2）| -5~10 |
| `closein` | 距離遠於理想範圍時升高 | -10~2.5 |
| `disable` | 戰鬥越久越高 | 0-10 |
| `buff` | 依攻擊機會和戰鬥長度動態計算 | 0.1+ |

**WANT 自動計算**，不需手動設定（`ai_tactic` 除外）。

### 8.4 Step 3：FINAL TACTICAL SCORE

```
RAW SCORE = Σ( TACTIC_WEIGHT[t] × WANT[t] × ai_tactic[t] )

FINAL SCORE = RAW SCORE × level_adjustment × random_range / speed
```

其中：
- `level_adjustment = 1 + talent_level × 0.2`
- `random_range = 1 + (0~0.5 隨機)`（預設最多 +50%）
- `speed = 技能速度`（即時技能不懲罰）

**FINAL SCORE > 0.1 才會被考慮。**

### 8.5 完整計算範例

```
情境：火焰法師 NPC，血量 40%，目標在旁
技能：Fireball（tactical = {attackarea={FIRE=2}, escape=1}）

Step 1 - TACTIC WEIGHT：
  目標火焰抗性 = 0%
  打到 3 個敵人
  tacts = {attackarea = 2.0, escape = 1.0}

Step 2 - WANT VALUE：
  want.attackarea = 2.0
  want.escape = 3.2（血量 40% → want.life ≈ 8 → escape = 8/2-1 = 3）

Step 3 - FINAL SCORE：
  RAW = 2.0×2.0 + 1.0×3.2 = 7.2
  level_adjustment = 1 + 3×0.2 = 1.6（技能等級 3）
  random_range = 1.3
  speed = 1.0
  FINAL = 7.2 × 1.6 × 1.3 / 1.0 = 14.98 ✓
```

