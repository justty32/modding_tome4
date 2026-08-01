對話腳本是一個普通 Lua 檔案，放在 `data/chats/`，用 `newChat{}` 宣告每個對話節點：

```lua
-- data/chats/elder.lua（範例結構）

-- 第一個對話節點
newChat{ id="welcome",
    -- @playername@ 會被替換為玩家角色名稱
    text = "你好，@playername@！我是村長。科博德首領盤踞地城，威脅我們的城鎮...",
    answers = {
        -- 每個答案是一個表格
        -- [1]      = 顯示文字
        -- cond     = 顯示此選項的條件（function(npc, player) return bool）
        -- action   = 選擇後執行的動作（function(npc, player)）
        -- jump     = 跳到哪個 id 繼續（nil = 結束對話）

        -- 條件1：玩家還沒有任務 → 提供接受任務選項
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

        -- 條件2：任務已完成頭目但還沒回報 → 顯示回報選項
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

        -- 條件3：任務已全部完成 → 感謝對話
        {
            "城鎮現在安全多了。",
            cond = function(npc, player)
                return player:hasQuest("slay-boss")
                    and player:isQuestStatus("slay-boss", engine.Quest.DONE)
            end,
            jump = "done",
        },

        -- 沒有條件的選項：隨時可見
        {
            "我只是路過。",
            -- 沒有 action，沒有 jump → 結束對話
        },
    }
}

-- 接受任務後的節點
newChat{ id="accepted",
    text = "太好了！地城的第三層深處有牠的巢穴。祝你好運，勇者！",
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
| `#RED#`...`#LAST#` | 顏色標記（`#LAST#` = 恢復前一個顏色） |

---
