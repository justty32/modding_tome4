`tactical` 是讓**智能 AI**（`use_tactical`、`use_improved_tactical`）理解技能用途的關鍵。

### 7.1 基本格式

```lua
newTalent{
    name = "Fireball",
    -- ...

    -- 戰術表：告訴 AI 這個技能做什麼
    tactical = {
        TACTIC_NAME = weight,
        -- 或分細的傷害類型
        TACTIC_NAME = { DAMAGE_TYPE = weight },
    },
}
```

### 7.2 所有可用的戰術分類（Tactics）

#### 傷害類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `attack` | 對一個目標傷害 | `{FIRE=2}` |
| `attackarea` | 對多個目標 AOE 傷害 | `{COLD=3}` |
| `attackall` | 傷害所有（大範圍）| `2` |

#### 生存類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `heal` | 恢復生命值 | `2` |
| `cure` | 移除負面效果 | `2` |
| `defend` | 提升防禦/抗性 | `2` |
| `escape` | 增加與目標的距離 | `2` |

#### 戰略類

| Tactic | 說明 | 典型值 |
|--------|------|--------|
| `buff` | 增強自己或友軍 | `2` |
| `disable` | 控制/削弱目標 | `{stun=2}` |
| `closein` | 縮短與目標的距離 | `3` |
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

戰術值代表技能在此戰術上的**效果強度**：

```lua
tactical = {
    attack = 2,      -- 標準攻擊強度（大多數攻擊用 2）
    attack = 4,      -- 強力攻擊（對 AI 更有吸引力）
    attack = 0.5,    -- 弱攻擊（附帶傷害）
}
```

**細分傷害類型（影響目標抗性計算）**：

```lua
tactical = {
    attack = { FIRE = 2 },        -- 火焰 AOE 攻擊
    attack = { PHYSICAL = 3 },    -- 物理重擊
    disable = { stun = 1, slow = 1 }, -- 暈眩+減速
}
```

當目標對火焰有高抗性時，AI 會降低這個技能的吸引力。

### 7.4 函式形式

戰術值也可以是函式，根據情況動態計算：

```lua
newTalent{
    name = "Chain Lightning",
    -- ...
    tactical = function(self, t, aitarget)
        -- 根據附近敵人數量決定戰術值
        local nb_foes = 0
        for _, act in ipairs(self.fov.actors_dist) do
            if self:reactionToward(act) < 0 then nb_foes = nb_foes + 1 end
        end
        return {
            attackarea = nb_foes >= 3 and 4 or 2,  -- 敵人多時更有吸引力
        }
    end,
}
```

### 7.5 實際範例

```lua
-- 治療技能
newTalent{
    name = "Minor Heal",
    tactical = { heal = 2 },          -- AI 在低血量時會使用
}

-- 火球（AOE）
newTalent{
    name = "Fireball",
    tactical = {
        attackarea = { FIRE = 2 },    -- 主要是 AOE 傷害
    },
}

-- 衝刺（靠近 + 攻擊）
newTalent{
    name = "Rush",
    tactical = {
        closein = 3,                   -- 主要用途：縮短距離
        attack = 1,                    -- 附帶傷害
    },
}

-- 屏障（純防禦）
newTalent{
    name = "Stone Skin",
    mode = "sustained",
    tactical = {
        defend = 2,                    -- 提升防禦
        buff = 1,                      -- 算作自身 buff
    },
}

-- 暈眩
newTalent{
    name = "Stunning Blow",
    tactical = {
        attack = { PHYSICAL = 1 },    -- 有傷害
        disable = { stun = 2 },       -- 主要用途：暈眩
    },
}

-- 傳送逃跑
newTalent{
    name = "Phase Door",
    tactical = {
        escape = 2,                   -- AI 在危急時使用
    },
}
```

---
