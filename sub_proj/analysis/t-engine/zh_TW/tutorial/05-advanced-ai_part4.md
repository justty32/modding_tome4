---

## 11. 自訂新戰術（Tactic）

`improved_tactical` 支援擴充新戰術分類：

```lua
-- 在 mod 中（ToME:load hook 或載入時執行）
local ActorAI = require "mod.class.interface.ActorAI"

-- 步驟 1：定義利益係數（+1 有益己方，-1 有害敵方）
ActorAI.AI_TACTICS.taunt = 1

-- 步驟 2：定義 WANT 計算函式
ActorAI.AI_TACTICS_WANTS.taunt = function(self, want, actions, avail)
    local nb_foes = 0
    for _, act in ipairs(self.fov.actors_dist) do
        if self:reactionToward(act) < 0 then nb_foes = nb_foes + 1 end
    end
    return math.min(10, nb_foes * 0.5)
end
```

技能中使用：

```lua
newTalent{
    name = "Provoke",
    tactical = { taunt = 3, defend = 1 },
}
```

---

## 12. AI 除錯技巧

### 12.1 開啟詳細日誌

```lua
-- Lua console（F1）
config.settings.log_detail_ai = 2
-- 0=關閉, 1=基本, 2=詳細, 3=非常詳細, 4=超詳細
```

輸出範例：

```
[use_tactical AI]==##== RUNNING turn 1523 42 fire goblin ...
[use_tactical AI] COMPUTED TACTIC WEIGHTs for: T_FIREBALL
---	attack: 1.5
---	attackarea: 2.0
[use_tactical AI] T_FIREBALL USEFUL TACTIC: attack 1.5
```

### 12.2 檢查 AI 狀態

```lua
local npc = game.level.map(10, 10, engine.Map.ACTOR)
print("AI:", npc.ai)
print("Target:", npc.ai_target.actor and npc.ai_target.actor.name)
table.print(npc.ai_state, "ai_state: ")
table.print(npc.ai_tactic, "ai_tactic: ")

-- improved_tactical 計算結果
table.print(npc.ai_state_volatile._want, "WANT: ")
table.print(npc.ai_state_volatile._avail, "AVAIL: ")
```

### 12.3 手動觸發 AI

```lua
local npc = game.level.map(10, 10, engine.Map.ACTOR)
npc:computeFOV(20)
npc:doAI()
```

### 12.4 常見 AI 失效原因

| 問題 | 原因 | 解決 |
|------|------|------|
| `improved_tactical` 不用某技能 | 無 `tactical` 表 | 加上 `tactical = {...}` |
| `improved_tactical` 不用某技能 | `no_npc_use = true` | 移除此旗標 |
| 技能偶爾用但 AI 不用 | `no_dumb_use = true` | 僅 dumb AI 受影響 |
| NPC 原地不動 | 未消耗能量 | 確認有 `self:useEnergy()` |
| NPC 不攻擊玩家 | 陣營錯誤 | 確認 `faction` |
| `target_simple` 找不到玩家 | FOV 未更新 | 確認有 `self:computeFOV()` |

---

## 13. 常見問題

### Q：`dumb_talented` 還是 `improved_tactical`？

| 情境 | 建議 |
|------|------|
| 普通雜兵（rank 2）| `dumb_talented_simple`（快速低開銷）|
| 稀有/菁英（rank 3）| `improved_talented`（較聰明但隨機）|
| Boss/特殊（rank 4+）| `improved_tactical`（完整評分）|

### Q：`self_compassion` 和 `ally_compassion`？

控制 AI 對自傷/友傷的容忍度：

- `self_compassion = 5`（預設）：AOE 自傷懲罰 ×5
- `ally_compassion = 1`（預設）：友傷懲罰 ×1

設 `false` 則不在乎：

```lua
ai_state = { self_compassion = false }
```

### Q：如何讓 NPC 保持距離？

```lua
ai_tactic = { escape = 2, safe_range = 5 }
```

距離 < `safe_range` 時 `want.escape` 大幅提升。

### Q：`tactical_random_range` 調整？

```lua
tactical_random_range = 0.0  -- 完全決定論
tactical_random_range = 0.5  -- 預設（最多 +50% 隨機）
tactical_random_range = 1.0  -- 高隨機性
```

### Q：NPC 只在特定條件用技能？

用 `on_pre_use_ai` 回呼：

```lua
newTalent{
    name = "Desperate Strike",
    on_pre_use_ai = function(self, t, silent, fake)
        return self.life / self.max_life < 0.3
    end,
    tactical = { attack = 4 },
}
```

---

## 學完本篇後應能：

- 理解 TE4 AI 的組合式架構
- 設定不同難度 NPC 的 AI（`simple` → `dumb_talented` → `improved_tactical`）
- 為技能正確撰寫 `tactical` 表
- 用 `ai_tactic` 調整 NPC 的戰術個性
- 撰寫自訂 AI 函式處理特殊行為
- 擴充新戰術分類
- 使用日誌系統除錯 AI
