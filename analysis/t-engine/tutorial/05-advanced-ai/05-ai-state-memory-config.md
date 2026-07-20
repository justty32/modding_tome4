`ai_state` 是 NPC 的 AI 記憶體，分兩類：

### 靜態設定（在 NPC 定義中設定）

```lua
ai_state = {
    -- 基本
    ai_target  = "target_simple",  -- 目標 AI（可改為 "target_closest" 等）
    ai_move    = "move_simple",    -- 移動 AI（可改為 "move_dmap" 等）
    talent_in  = 4,                -- dumb AI 用：平均每 N 回合使用技能
    no_talents = false,            -- true = 不用技能

    -- 戰術 AI 用
    self_compassion   = 5,  -- 自傷技能的懲罰係數（預設 5）
    ally_compassion   = 1,  -- 友傷技能的懲罰係數（預設 1）
    tactical_random_range = 0.5,  -- 隨機化幅度（預設 0.5）

    -- 進階移動
    sense_radius = 10,  -- target_player_radius 用的感知半徑
}
```

### 動態狀態（由 AI 在運行時修改）

```lua
-- 由 AI 自動寫入，不需手動設定
self.ai_state.target_last_seen = {x=10, y=20, turn=1500}
self.ai_state.blocked_turns    = 5   -- 被卡住的回合數
self.ai_state._fight_data      = {actions=10, attacks=7}  -- 戰鬥統計
```

---
