```
game/modules/hellodungeon/
├── class/
│   ├── Actor.lua                 ← 修改：繼承 ActorQuest
│   ├── Player.lua                ← 修改：加入 bump、talkTo 函數
│   └── Game.lua                  ← 修改：加入 t 鍵對話、j 鍵任務日誌

├── data/
│   ├── quests/                   ← 新增目錄
│   │   └── slay-boss.lua         ← 新增：討伐首領任務定義
│   │
│   ├── chats/                    ← 新增目錄
│   │   └── elder.lua             ← 新增：村長對話腳本
│   │
│   ├── general/
│   │   └── npcs/
│   │       └── kobold.lua        ← 修改：加入 KOBOLD_BOSS（含 on_die）
│   │
│   └── zones/
│       ├── town/
│       │   ├── zone.lua          ← 修改：加入 post_process 放置村長
│       │   └── npcs.lua          ← 修改：加入 ELDER 定義
│       └── dungeon/
│           └── zone.lua          ← 修改：加入 post_process 放置首領
```

**共新增 3 個檔案（目錄），修改 5 個檔案**。

---
