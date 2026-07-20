`improved_tactical` 支援擴充新的戰術分類：

```lua
-- 在你的 mod 中（例如透過 ToME:load hook 或直接在載入時執行）
local ActorAI = require "mod.class.interface.ActorAI"

-- 步驟 1：定義利益係數
-- +1 = 對自己有益（heal、defend 等）
-- -1 = 對敵人有害（attack、disable 等，預設值）
ActorAI.AI_TACTICS.taunt = 1   -- taunt 是對敵人的效果（-1 = 不改益損視角）

-- 步驟 2：定義 WANT 計算函式
ActorAI.AI_TACTICS_WANTS.taunt = function(self, want, actions, avail)
    -- 附近敵人越多，嘲諷需求越高
    local nb_foes = 0
    for _, act in ipairs(self.fov.actors_dist) do
        if self:reactionToward(act) < 0 then nb_foes = nb_foes + 1 end
    end
    -- 1 個敵人 want=1, 3 個 want=2, 6 個 want=3
    return math.min(10, nb_foes * 0.5)
end
```

之後在技能中使用：

```lua
newTalent{
    name = "Provoke",
    tactical = {
        taunt = 3,    -- AI 在多敵時使用
        defend = 1,   -- 也算防禦
    },
    -- ...
}
```

---
