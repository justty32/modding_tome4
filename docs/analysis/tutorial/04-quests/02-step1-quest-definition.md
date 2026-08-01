Quest 定義是一個 Lua 檔案，由 `grantQuest("id")` 動態載入。引擎會從 `/data/quests/<id>.lua` 讀取：

```lua
-- game/modules/hellodungeon/data/quests/slay-boss.lua

-- 任務 ID（與檔案名稱相同）
id = "slay-boss"

-- 顯示在任務日誌的標題
name = "消滅科博德首領"

-- 任務描述函數（動態生成，可依狀態顯示不同文字）
desc = function(self, who)
    local d = {}
    d[#d+1] = "村長請你消滅地城深處的科博德首領，以保護城鎮的安全。"

    -- 依子目標狀態顯示進度
    if self:isCompleted("killed_boss") then
        d[#d+1] = "\n#LIGHT_GREEN#✔ 已擊殺科博德首領。#LAST#"
    else
        d[#d+1] = "\n#YELLOW#○ 目標：擊殺地城第三層的科博德首領。#LAST#"
    end

    if self:isStatus(self.DONE) then
        d[#d+1] = "\n#LIGHT_GREEN#✔ 已向村長回報，任務完成。#LAST#"
    elseif self:isCompleted("killed_boss") then
        d[#d+1] = "\n#YELLOW#○ 回到城鎮向村長回報。#LAST#"
    end

    return table.concat(d, "\n")
end

-- 任務給予時呼叫（可在這裡初始化任務狀態、顯示歡迎訊息等）
on_grant = function(self, who)
    game.logPlayer(who, "#YELLOW#新任務：%s", self.name)
end

-- 任務/子目標狀態改變時呼叫
on_status_change = function(self, who, status, sub)
    if sub == "killed_boss" and status == self.COMPLETED then
        game.logPlayer(who, "#LIGHT_GREEN#任務進度：科博德首領已被消滅！返回城鎮回報。")
    end
    -- 所有子目標完成 → 標記整個任務完成
    if self:isCompleted("killed_boss") and self:isCompleted("reported") then
        who:setQuestStatus(self.id, engine.Quest.DONE)
    end
end
```

**設計要點**：

- `id` 必須與傳入 `grantQuest()` 的字串一致，也等於檔案名稱（不含 .lua）
- `desc` 可以是字串或函數；函數可在不同狀態下顯示不同內容
- 子目標（sub-objective）是任意字串，用 `setQuestStatus(id, status, sub)` 設定

---
