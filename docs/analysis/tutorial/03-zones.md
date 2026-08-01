# 教學 03：多地區與地區切換

> **目標**：為 `hellodungeon` 加入第二個地區（城鎮），並實作「進入地城 ↔ 返回城鎮」的雙向切換。理解 `Zone`、`changeLevel`、`change_level`/`change_zone` 地形欄位的完整工作原理。
>
> **前置條件**：完成教學 01 + 02。


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. 架構總覽](03-zones/01-architecture-overview.md)
- [2. 第一步：changeLevel 工作原理](03-zones/02-step1-changeLevel-mechanics.md)
- [3. 第二步：建立城鎮地區](03-zones/03-step2-town-zone.md)
- [4. 第四步：更新 Game.lua 支援多地區切換](03-zones/04-step4-game-lua-multi-zone.md)
- [5. 第五步：起始地區設為城鎮](03-zones/05-step5-starting-zone-town.md)
- [6. 第六步：地區切換時保留玩家位置](03-zones/06-step6-preserve-player-position.md)
- [7. 第七步：on_enter 與 on_leave 回調](03-zones/07-step7-on-enter-on-leave.md)
- [8. 完整檔案結構變更](03-zones/08-file-structure-changes.md)
- [9. 常見錯誤排查](03-zones/09-troubleshooting.md)
- [下一步](03-zones/next-steps.md)
