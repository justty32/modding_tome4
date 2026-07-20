**用途**：最小化 RPG 模板，展示回合制地城探索 + 玩家 vs NPC 戰鬥。

**繼承**：`engine.GameTurnBased + engine.interface.GameTargeting`

**核心流程**：

```
tick() → engine.GameTurnBased.tick()
Player.act(): cooldowns → regen → timedEffects → 消耗 energy
  → game.paused = true（等待輸入）
```

**類別結構**：

```
Game (439行) ← GameTurnBased + GameTargeting
  Player ← Actor + PlayerRest/Run/Hotkeys/Mouse
  NPC    ← Actor + ActorAI
  Actor  ← Entity + ActorStats/Talents/Life/FOV/Resource...
  Grid
  interface/Combat.lua
```

**資料層**：30+ Lua 檔（talents、damage_types、birth、zones、grids、NPCs）

**顯示**：32×32 ASCII 圖磚，底部 80% 為 log，右側 20% 為快捷鍵/NPC 列表

**Birth 流程**：選擇 "base" + "role" 描述符，合併屬性、技能、裝備到角色

---
