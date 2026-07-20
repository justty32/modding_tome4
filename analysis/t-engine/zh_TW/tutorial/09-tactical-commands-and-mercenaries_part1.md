# 教學 09：戰術指令系統與僱傭兵招募

## 本章目標

實作兩個緊密相關的系統：

1. **戰術指令系統**：玩家可對隊友下達「攻擊目標」、「跟我來」、「待命」、「撤退」等指令，覆寫 NPC 的 AI 行為
2. **僱傭兵招募系統**：城鎮中有一個招募者 NPC，玩家透過對話花費金幣僱用傭兵，傭兵由模板動態生成並加入隊伍

兩個系統的連接點：所有招募來的傭兵都使用戰術指令 AI，可被玩家即時指揮。

---

## 系統設計概覽

```
玩家按下指令鍵
       ↓
CommandMenu Dialog（選擇隊友 + 選擇指令）
       ↓
設定 ally.ai_state.command = {type="...", target=...}
       ↓
每回合 ally:doAI() → 執行 "commanded_ally" AI
       ↓
commanded_ally 讀取 command，決定行為：
  - "attack" → setTarget + dumb_talented_simple
  - "follow" → 追蹤玩家座標
  - "standby" → 等待（consume energy）
  - "flee"   → target_simple + flee_simple
  - nil      → 預設自主戰鬥
```

```
玩家找到招募者 NPC
       ↓
Chat 腳本：選擇傭兵種類，條件判斷（有無足夠金幣）
       ↓
zone:makeEntityByName → 從模板產生 Actor 實例
       ↓
zone:addEntity → 放到地圖上
       ↓
game.party:addMember → 加入隊伍，可被指令系統控制
```

---

## 完整檔案結構

```
mygame/
  mod/
    ai/
      commanded_ally.lua        ← 自訂 AI（核心）
    class/
      interface/
        ActorCommand.lua        ← 玩家的指令介面 混入
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

