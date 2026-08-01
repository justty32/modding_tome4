```lua
-- 定義任務
local quest = Quest.new({
    name = "Kill the Dragon",
    desc = "...",
    on_grant = function(self, who) ... end,
    on_status_change = function(self, who, status, sub) ... end,
}, player)

-- 更新子目標
quest:setSubCompleted("find_lair")
quest:setCompleted()  -- 完成整個任務
```

**狀態機**：
- `PENDING (0)` → `COMPLETED (1)` → `DONE (100)`
- `PENDING (0)` → `FAILED (101)`

Hook 整合：`triggerHook{"Quest:init"}`, `triggerHook{"Quest:completed"}` 讓模組監聽任務事件。

---
