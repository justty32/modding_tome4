在 `Actor.lua` 中加入 `ActorQuest`：

```lua
-- game/modules/hellodungeon/class/Actor.lua

require "engine.class"
local Actor = require "engine.Actor"
-- ... 其他 require ...
local ActorQuest = require "engine.interface.ActorQuest"   -- ← 新增

module(..., package.seeall, class.inherit(
    Actor,
    -- ... 其他混入 ...
    ActorQuest      -- ← 新增（不需要單獨 init，它是純方法集合）
))

function _M:init(t, no_default)
    -- ActorQuest 不需要 init：self.quests 是在 grantQuest 時惰性建立的
    Actor.init(self, t, no_default)
    -- ... 其他 init ...
end
```

`ActorQuest` 提供的方法（不需要手動 init）：

| 方法 | 說明 |
|------|------|
| `grantQuest("id")` | 從 `/data/quests/id.lua` 載入並給予任務 |
| `hasQuest("id")` | 回傳 Quest 物件或 `false` |
| `setQuestStatus("id", status, sub)` | 設定任務/子目標狀態 |
| `isQuestStatus("id", status, sub)` | 查詢是否為指定狀態 |
| `removeQuest("id")` | 移除任務（謹慎使用）|

---
