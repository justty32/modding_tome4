回報對話已在第三步的 `elder.lua` 中整合（條件2：`killed_boss` 完成但 `reported` 未完成）。要讓整個任務標記為 `DONE`，需在 Quest 定義的 `on_status_change` 中處理：

```lua
-- data/quests/slay-boss.lua（相關段落）

on_status_change = function(self, who, status, sub)
    -- 子目標進度提示
    if sub == "killed_boss" and status == self.COMPLETED then
        game.logPlayer(who, "#LIGHT_GREEN#首領已倒下！返回城鎮向村長回報。")
    end

    -- 回報完成 → 標記整個任務為 DONE
    if sub == "reported" and status == self.COMPLETED then
        who:setQuestStatus(self.id, engine.Quest.DONE)
    end
end
```

---
