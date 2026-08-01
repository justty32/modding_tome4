```
mygame/
  mod/
    ai/
      commanded_ally.lua        ← 自訂 AI（核心）
    class/
      interface/
        ActorCommand.lua        ← 玩家的指令介面 mixin
    dialogs/
      CommandMenu.lua           ← 指令選單 UI
    data/
      npcs/
        mercenaries.lua         ← 傭兵模板定義
      chats/
        recruiter.lua           ← 招募者對話腳本
      zones/
        town.lua                ← 城鎮 Zone（含招募者 NPC）
    class/
      Player.lua                ← 綁定指令鍵
      Game.lua                  ← 載入自訂 AI
```

---
