```
Quest 定義（.lua 檔）
  ├── name, desc, id
  ├── on_grant(self, who)          ← 任務給予時
  └── on_status_change(self, who, status, sub)  ← 狀態改變時

ActorQuest（混入）
  ├── grantQuest("quest-id")       ← 給予任務
  ├── hasQuest("quest-id")         ← 檢查是否有任務（回傳 Quest 物件或 false）
  ├── setQuestStatus("id", COMPLETED, "sub-obj")  ← 設定任務/子目標狀態
  └── isQuestStatus("id", DONE)    ← 查詢狀態

Chat 腳本（data/chats/xxx.lua）
  ├── newChat{ id="xxx", text="...", answers={...} }
  ├── answers.cond(npc, player)    ← 顯示選項的條件
  ├── answers.action(npc, player)  ← 選擇後執行的動作
  └── return "welcome"             ← 指定第一個對話節點

Chat 引擎
  ├── Chat.new("chat-name", npc, player)
  └── game:registerDialog(chat_dlg)  ← 顯示對話視窗
```

**任務狀態常數**（定義在 `engine/Quest.lua`）：

| 常數 | 值 | 意義 |
|------|----|------|
| `Quest.PENDING` | 0 | 進行中（預設） |
| `Quest.COMPLETED` | 1 | 達成目標，可回報 |
| `Quest.DONE` | 100 | 已完成（領取獎勵後） |
| `Quest.FAILED` | 101 | 已失敗 |

---
