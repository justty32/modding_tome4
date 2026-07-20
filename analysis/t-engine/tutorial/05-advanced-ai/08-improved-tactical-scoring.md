這是 ToME 最進階的 AI，用於稀有/Boss NPC。理解它的三步計算：

### 8.1 三步流程

```
第一步：計算 TACTIC WEIGHT（每個技能對各戰術的貢獻值）
          ↓
第二步：計算 WANT VALUE（AI 當前對每個戰術的需求程度）
          ↓
第三步：計算 FINAL TACTICAL SCORE（得分 = WEIGHT × WANT × 偏好）
          → 選擇得分最高的技能執行
```

### 8.2 第一步：TACTIC WEIGHT

每個技能的 `tactical` 表經過處理後，變成 **TACTIC WEIGHT**（技能貢獻值）：

```lua
-- 原始 tactical 表
tactical = { attack = {FIRE=2}, disable = {stun=1} }

-- 引擎分析後，考慮目標的火焰抗性（-50%）：
tacts = { attack = 1.0, disable = 1.0 }
-- attack 從 2 降到 1（目標火焰抗 50%）
-- disable 保持 1（不受抗性影響）
```

**影響 TACTIC WEIGHT 的因素**：
- 目標對該傷害類型的抗性
- 技能打到的目標數量（AOE）
- 是否打到友軍（懲罰）
- 是否打到自己（由 `self_compassion` 懲罰）

### 8.3 第二步：WANT VALUE

**WANT** 代表 AI 對每個戰術的「渴望程度」（-10 到 +10），由 AI 自動計算：

| 戰術 | WANT 計算邏輯 | 典型值 |
|------|-------------|--------|
| `attack` | 固定 2，眩暈/麻痺時減半 | 1-2 |
| `heal` | 血量越低越高（血剩 40% 時約 4）| 0-10 |
| `cure` | 負面效果越多越高 | 0-10 |
| `defend` | 附近敵人越多越高 | 0.1-10 |
| `escape` | 血量 + 距離觸發（血剩 25% 時 ≈ 2）| -5 到 10 |
| `closein` | 距離遠於理想攻擊範圍時升高 | -10 到 2.5 |
| `disable` | 戰鬥持久度估計（打長了越高）| 0-10 |
| `buff` | 依攻擊機會和戰鬥長度動態計算 | 0.1 以上 |

**WANT 是自動算的**——你不需要手動設定（ai_tactic 除外）。

### 8.4 第三步：FINAL TACTICAL SCORE

```
RAW SCORE = Σ( TACTIC_WEIGHT[t] × WANT[t] × ai_tactic[t] )

FINAL SCORE = RAW SCORE × level_adjustment × random_range / speed
```

其中：
- `level_adjustment = 1 + talent_level × 0.2`（高等級技能得分更高）
- `random_range = 1 + (0.5 的隨機值)`（預設增加最多 50% 隨機性）
- `speed = 技能速度`（即時技能不懲罰速度）

**只有 FINAL SCORE > 0.1 的技能才會被考慮。**

### 8.5 完整示例計算

```
情境：火焰法師 NPC，血量剩 40%，目標在旁邊
技能：Fireball（tactical = {attackarea={FIRE=2}, escape=1}）

Step 1 - TACTIC WEIGHT：
  目標火焰抗性 = 0%（不影響）
  打到 3 個敵人
  tacts = {attackarea = 2.0, escape = 1.0}

Step 2 - WANT VALUE：
  want.attackarea = 2.0（基礎）
  want.escape = 3.2（血量 40% → want.life ≈ 8 → escape = 8/2-1 = 3）

Step 3 - FINAL TACTICAL SCORE：
  RAW = 2.0×2.0 + 1.0×3.2 = 4.0+3.2 = 7.2
  level_adjustment = 1 + 3×0.2 = 1.6（技能等級 3）
  random_range = 1.3（隨機）
  speed = 1.0
  FINAL = 7.2 × 1.6 × 1.3 / 1.0 = 14.98 ✓（選擇此技能！）
```

### 8.6 啟用 improved_tactical

```lua
-- 在 NPC 定義中
newEntity{
    name = "elite fire mage",
    ai = "improved_tactical",   -- 使用進階戰術 AI
    ai_state = {
        ai_target = "target_simple",
        ai_move   = "move_simple",
        self_compassion = 5,     -- 自傷懲罰（預設 5）
        ally_compassion = 1,     -- 友傷懲罰（預設 1）
        tactical_random_range = 0.3,  -- 降低隨機性（預設 0.5）
    },
    -- 技能必須有 tactical 表才會被此 AI 使用
    talents = { [T_FIREBALL]=3, [T_MANA_SHIELD]=1 },
}
```

---
