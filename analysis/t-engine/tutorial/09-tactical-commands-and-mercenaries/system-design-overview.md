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
