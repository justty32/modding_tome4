**用途**：遊戲啟動時顯示的主選單模組（`is_boot=true`）。

**繼承**：`engine.GameEnergyBased + GameMusic + GameSound`（完整音訊/即時引擎）

**初始化流程**：`init.lua` → `load.lua` → `class/Game` → 顯示 MainMenu 對話框

**特色**：
- 即時模式（8 tick/s）
- 載入背景材質、Web tooltip、Discord Presence、shader 支援
- Player 繼承自 NPC（非獨立），使用 demo AI（`ai="player_demo"`）
- FOV 距離預計算用不同係數（除以 17 vs 14）
- 約 117 個 Lua 檔（21 mod + 96 data）

---
