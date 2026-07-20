# 教學 04：任務系統與 NPC 對話

> **目標**：為 `hellodungeon` 加入完整任務流程：村長 NPC 委託、接受任務、擊殺地城頭目觸發完成、回城回報領獎。
>
> **前置**：完成教學 01–03（已有城鎮與地城兩個地區）。

---

## 1. 系統架構總覽

```
Quest 定義（.lua 檔）
  ├── name, desc, id
  ├── on_grant(self, who)          ← 發放任務時
  └── on_status_change(self, who, status, sub)  ← 狀態變更時

ActorQuest（混入）
  ├── grantQuest("quest-id")       ← 給予任務
  ├── hasQuest("quest-id")         ← 檢查任務（回傳 Quest 物件或 false）
  ├── setQuestStatus("id", COMPLETED, "sub-obj")  ← 設定任務/子目標狀態
  └── isQuestStatus("id", DONE)    ← 查詢狀態

Chat 腳本（data/chats/xxx.lua）
  ├── newChat{ id="xxx", text="...", answers={...} }
  ├── answers.cond(npc, player)    ← 選項顯示條件
  ├── answers.action(npc, player)  ← 選項執行動作
  └── return "welcome"             ← 指定首個對話節點

Chat 引擎
  ├── Chat.new("chat-name", npc, player)
  └── game:registerDialog(chat_dlg)  ← 顯示對話視窗
```

**任務狀態常數**（定義於 `engine/Quest.lua`）：

| 常數 | 值 | 意義 |
|------|----|------|
| `Quest.PENDING` | 0 | 進行中（預設） |
| `Quest.COMPLETED` | 1 | 達成目標，可回報 |
| `Quest.DONE` | 100 | 已完成（領取獎勵後） |
| `Quest.FAILED` | 101 | 已失敗 |

---

## 2. 第一步：Quest 定義檔

Quest 定義是 Lua 檔，由 `grantQuest("id")` 動態載入。引擎從 `/data/quests/<id>.lua` 讀取：

```lua
-- game/modules/hellodungeon/data/quests/slay-boss.lua

-- 任務 ID（須與檔名相同）
id = "slay-boss"

-- 任務日誌顯示的標題
name = "消滅科博德首領"

-- 任務描述函數（動態生成，依狀態顯示不同文字）
desc = function(self, who)
    local d = {}
    d[#d+1] = "村長請你消滅地城深處的科博德首領，以保護城鎮安全。"

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

-- 任務發放時呼叫（初始化任務狀態、顯示提示等）
on_grant = function(self, who)
    game.logPlayer(who, "#YELLOW#新任務：%s", self.name)
end

-- 任務/子目標狀態變更時呼叫
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

- `id` 須與 `grantQuest()` 字串一致，亦等於檔名（不含 .lua）
- `desc` 可為字串或函數；函數可在不同狀態下顯示不同內容
- 子目標（sub-objective）為任意字串，經 `setQuestStatus(id, status, sub)` 設定

---

## 3. 第二步：ActorQuest 混入

於 `Actor.lua` 加入 `ActorQuest`：

```lua
-- game/modules/hellodungeon/class/Actor.lua

require "engine.class"
local Actor = require "engine.Actor"
-- ... 其他 require ...
local ActorQuest = require "engine.interface.ActorQuest"   -- ← 新增

module(..., package.seeall, class.inherit(
    Actor,
    -- ... 其他混入 ...
    ActorQuest      -- ← 新增（無需個別 init，純方法集合）
))

function _M:init(t, no_default)
    -- ActorQuest 不需 init：self.quests 於 grantQuest 時惰性建立
    Actor.init(self, t, no_default)
    -- ... 其他 init ...
end
```

`ActorQuest` 提供的方法（不需手動 init）：

| 方法 | 說明 |
|------|------|
| `grantQuest("id")` | 從 `/data/quests/id.lua` 載入並給予任務 |
| `hasQuest("id")` | 回傳 Quest 物件或 `false` |
| `setQuestStatus("id", status, sub)` | 設定任務/子目標狀態 |
| `isQuestStatus("id", status, sub)` | 查詢是否為指定狀態 |
| `removeQuest("id")` | 移除任務（謹慎使用） |

---

## 4. 第三步：Chat 對話腳本格式

對話腳本是普通 Lua 檔，置於 `data/chats/`，以 `newChat{}` 宣告每個節點：

```lua
-- data/chats/elder.lua（範例結構）

-- 第一個對話節點
newChat{ id="welcome",
    -- @playername@ 會被替換為玩家角色名稱
    text = "你好，@playername@！我是村長。科博德首領盤踞地城，威脅我們的城鎮...",
    answers = {
        -- 每個 answer 是一個表格
        -- [1]      = 顯示文字
        -- cond     = 顯示條件（function(npc, player) return bool）
        -- action   = 選擇後執行動作（function(npc, player)）
        -- jump     = 跳至哪個 id 繼續（nil = 結束對話）

        -- 條件 1：玩家尚無任務 → 提供接受選項
        {
            "我願意替你消滅牠！",
            cond = function(npc, player)
                return not player:hasQuest("slay-boss")
            end,
            action = function(npc, player)
                player:grantQuest("slay-boss")
                game.logPlayer(player, "你接受了任務：消滅科博德首領。")
            end,
            jump = "accepted",
        },

        -- 條件 2：任務已完成頭目但未回報 → 顯示回報選項
        {
            "首領已被我消滅了！",
            cond = function(npc, player)
                return player:hasQuest("slay-boss")
                    and player:isQuestStatus("slay-boss", engine.Quest.COMPLETED, "killed_boss")
                    and not player:isQuestStatus("slay-boss", engine.Quest.COMPLETED, "reported")
            end,
            action = function(npc, player)
                player:setQuestStatus("slay-boss", engine.Quest.COMPLETED, "reported")
                -- 給予獎勵
                player.life = math.min(player.life + 50, player.max_life)
                game.logPlayer(player, "#LIGHT_GREEN#村長感謝你的英勇！你的生命值回復了 50 點。")
            end,
            jump = "reward",
        },

        -- 條件 3：任務已全部完成 → 感謝對話
        {
            "城鎮現在安全多了。",
            cond = function(npc, player)
                return player:hasQuest("slay-boss")
                    and player:isQuestStatus("slay-boss", engine.Quest.DONE)
            end,
            jump = "done",
        },

        -- 無條件選項：隨時可見
        {
            "我只是路過。",
            -- 無 action，無 jump → 結束對話
        },
    }
}

-- 接受任務後的節點
newChat{ id="accepted",
    text = "太好了！地城第三層深處有牠的巢穴。祝你好運，勇者！",
    answers = {
        { "我會的，再見！" },
    }
}

-- 回報完成後的節點
newChat{ id="reward",
    text = "你真是太厲害了！城鎮因你而得救。請收下這點薄禮。",
    answers = {
        { "謝謝你，村長。" },
    }
}

-- 任務已完成的節點
newChat{ id="done",
    text = "再次感謝你的幫助，英雄！城鎮的大門永遠為你敞開。",
    answers = {
        { "保重。" },
    }
}

-- 必須 return 第一個節點的 id
return "welcome"
```

**`text` 中的特殊標記**：

| 標記 | 替換內容 |
|------|----------|
| `@playername@` | 玩家名稱 |
| `@npcname@` | NPC 名稱 |
| `#RED#`...`#LAST#` | 顏色標記（`#LAST#` = 恢復前一顏色） |
