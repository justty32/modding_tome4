# 教學 08：全新技能系統——連技體系（Technique System）

> **目標**：設計並實作一套與 TE4 現有技能樹（TalentType/Talent）**完全獨立**的技能系統——「連技體系」。玩家透過戰鬥、訓練師或掉落物獲得「連技」，裝填到最多 5 個槽位，按順序施展可累積連擊計數，並以終結技收割強化效果。系統擁有自己的橫條 HUD，不使用現有的技能樹 UI，但仍完整接入 TE4 的戰鬥屬性（`combat_dam`、`getStat()`、`project()`）。
>
> **設計哲學**：與現有技能樹的核心差異不在於「效果」，而在於**取得方式**、**排列組合**和**狀態機**。技能樹靠「加點」進化；連技靠「習得與熟練」，並透過連擊順序產生乘算效果。


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. 系統設計總覽](08-technique-system/01-system-design-overview.md)
- [2. 資料結構定義](08-technique-system/02-data-structure-definition.md)
- [3. ActorTechnique 混入](08-technique-system/03-actortechnique-mixin.md)
- [4. 連技定義檔格式](08-technique-system/04-combo-definition-format.md)
- [5. 五個範例連技](08-technique-system/05-five-example-combos.md)
- [6. 連技 HUD（橫條顯示器）](08-technique-system/06-combo-hud.md)
- [7. 整合到 Game.lua 與 Player.lua](08-technique-system/07-game-player-integration.md)
- [8. 連技的取得方式](08-technique-system/08-obtaining-combos.md)
- [9. 熟練度系統](08-technique-system/09-mastery-system.md)
- [10. 完整檔案結構](08-technique-system/10-file-structure.md)
- [11. 常見錯誤排查](08-technique-system/11-troubleshooting.md)
- [小結](08-technique-system/summary.md)
