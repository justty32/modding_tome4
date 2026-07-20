# 教學 05：進階 AI 系統

> **目標**：理解 TE4 的 AI 架構，從最簡單的移動 AI 到 ToME 的戰術評分系統（`improved_tactical`），並學會為你的 NPC 撰寫自訂 AI。
>
> **相關原始碼**：
> - `game/engines/engine/interface/ActorAI.lua` — AI 介面基礎（`doAI`、`runAI`、`newAI`）
> - `game/engines/engine/ai/simple.lua` — 引擎內建移動/目標 AI
> - `game/engines/engine/ai/talented.lua` — `dumb_talented`、`improved_talented`
> - `game/modules/tome-1.7.6/mod/ai/improved_tactical.lua` — ToME 戰術評分 AI（核心）
> - `game/modules/tome-1.7.6/mod/ai/target.lua` — ToME 目標選擇覆蓋


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. AI 系統全局架構](05-advanced-ai/01-ai-system-architecture.md)
- [2. AI 的基本組件](05-advanced-ai/02-ai-basic-components.md)
- [3. 引擎內建 AI 清單](05-advanced-ai/03-built-in-ai-list.md)
- [4. NPC 定義中的 AI 設定](05-advanced-ai/04-npc-ai-configuration.md)
- [5. ai_state：AI 的記憶與設定](05-advanced-ai/05-ai-state-memory-config.md)
- [6. 自訂簡單 AI](05-advanced-ai/06-custom-simple-ai.md)
- [7. 技能的戰術表（tactical table）](05-advanced-ai/07-tactical-table.md)
- [8. improved_tactical：三步評分系統](05-advanced-ai/08-improved-tactical-scoring.md)
- [9. ai_tactic：NPC 的戰術偏好](05-advanced-ai/09-ai-tactic-preferences.md)
- [10. 完整 NPC 範例：從簡單到進階](05-advanced-ai/10-complete-npc-examples.md)
- [11. 自訂新戰術（Tactic）](05-advanced-ai/11-custom-tactic.md)
- [12. AI 除錯技巧](05-advanced-ai/12-ai-debugging-tips.md)
- [13. 常見問題](05-advanced-ai/13-common-issues.md)
- [學完這篇教學後，你應該能：](05-advanced-ai/what-you-should-know.md)
