### 2.1 AI 的狀態（ai_state 與 ai_target）

每個 NPC 都有兩個 AI 用的 table：

```lua
self.ai_state = {
    -- 靜態設定（在 NPC 定義中設定，存檔後保留）
    ai_target = "target_simple",   -- 目標選擇 AI 名稱
    ai_move   = "move_simple",     -- 移動 AI 名稱
    talent_in = 3,                 -- dumb_talented 的技能使用頻率（1/N 機率）
    no_talents = false,            -- 設為 true/1 則禁止使用技能
    -- 動態狀態（由 AI 在運行中修改）
    blocked_turns = nil,           -- move_complex 使用的卡住計數
    target_last_seen = {x, y, turn}, -- 最後一次看到目標的位置
}

self.ai_target = {
    actor = <Actor>,    -- 當前 AI 目標（弱引用，GC 不阻止）
}

self.ai_state_volatile = {
    -- 不存檔的揮發狀態（每次載入時重設）
    _want = {},     -- improved_tactical 的 WANT 表
    _avail = {},    -- improved_tactical 的 AVAIL 表
    _actions = {},  -- improved_tactical 的可行動列表
}
```

### 2.2 FOV（視野）

AI 執行前 NPC 必須先計算 FOV，才能知道能看到哪些 Actor：

```lua
-- NPC:act() 中（standard pattern）
self:computeFOV(self.sight or 20)  -- 計算視野半徑 20 格

-- 計算後可用
self.fov.actors_dist  -- 依距離排序的可見 Actor 列表
self.fov.actors[act]  -- actor → {sqdist=...} 的 table（sqdist = 距離平方）
```

### 2.3 目標追蹤：aiSeeTargetPos

AI 不總是能精確知道目標位置（目標可能在視線外）：

```lua
-- 取得 AI 認為目標在哪裡
local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
-- 目標在視線內 → 回傳精確座標
-- 目標在視線外 → 回傳帶誤差的估計位置（誤差隨時間增大）
```

這讓 NPC 的記憶系統更真實：失去視線 10 回合後，NPC 的目標位置估計誤差可達 10 格。

---
