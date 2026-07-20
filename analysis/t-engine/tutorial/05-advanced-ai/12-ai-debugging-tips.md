### 12.1 開啟 AI 詳細日誌

在遊戲設定或 Lua console 中設定：

```lua
-- Lua console 中輸入（F1 開啟 console）
config.settings.log_detail_ai = 2
-- 0 = 關閉, 1 = 基本, 2 = 詳細, 3 = 非常詳細, 4 = 超詳細
```

日誌會顯示到 console：

```
[use_tactical AI]==##== RUNNING turn 1523 42 fire goblin ...
[use_tactical AI] COMPUTED TACTIC WEIGHTs for: T_FIREBALL
---	attack: 1.5
---	attackarea: 2.0
[use_tactical AI] T_FIREBALL USEFUL TACTIC: attack 1.5
```

### 12.2 在 Lua Console 檢查 AI 狀態

```lua
-- 選中一個 NPC，檢查它的 AI 狀態
local npc = game.level.map(10, 10, engine.Map.ACTOR)
print("AI:", npc.ai)
print("Target:", npc.ai_target.actor and npc.ai_target.actor.name)
table.print(npc.ai_state, "ai_state: ")
table.print(npc.ai_tactic, "ai_tactic: ")

-- 查看 improved_tactical 的計算結果
table.print(npc.ai_state_volatile._want, "WANT: ")
table.print(npc.ai_state_volatile._avail, "AVAIL: ")
```

### 12.3 手動觸發 AI

```lua
-- 強制一個 NPC 執行 AI（在 console 中）
local npc = game.level.map(10, 10, engine.Map.ACTOR)
npc:computeFOV(20)
npc:doAI()
```

### 12.4 常見 AI 失效原因

| 問題 | 原因 | 排解 |
|------|------|------|
| 技能從不被 `improved_tactical` 使用 | 技能沒有 `tactical` 表 | 加上 `tactical = {...}` |
| 技能從不被 `improved_tactical` 使用 | 技能設了 `no_npc_use = true` | 移除此旗標 |
| 技能偶爾用，但 `improved_tactical` 不用 | 技能設了 `no_dumb_use = true` | 只有 dumb AI 受此影響 |
| NPC 停在原地不動 | AI 沒有正確消耗能量 | 確認 AI 函式有呼叫 `self:useEnergy()` |
| NPC 不攻擊玩家 | 陣營設定錯誤 | 確認 `faction` 欄位正確 |
| `target_simple` 找不到玩家 | FOV 問題 | 確認有先呼叫 `self:computeFOV()` |

---
