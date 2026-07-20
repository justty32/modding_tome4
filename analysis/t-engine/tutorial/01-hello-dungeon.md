# 教學 01：製作一個最簡單的地城遊戲（Hello Dungeon）

> **目標**：從零開始，建立一個可以實際執行的 TE4 遊戲模組。玩家能在隨機生成的地城中移動、攻擊科博德、使用技能，並在死亡後看到死亡畫面。
>
> **參考**：本教學直接以 `game/modules/example/` 為範本說明。


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. TE4 模組是什麼？](01-hello-dungeon/01-te4-module.md)
- [2. 最終的檔案結構](01-hello-dungeon/02-final-file-structure.md)
- [3. 第一步：模組入口（init.lua）](01-hello-dungeon/03-step1-module-entry-init-lua.md)
- [4. 第二步：系統載入（load.lua）](01-hello-dungeon/04-step2-system-loading-load-lua.md)
- [5. 第三步：地形定義（grids/）](01-hello-dungeon/05-step3-terrain-definition-grids.md)
- [6. 第四步：地區設定（zone.lua）](01-hello-dungeon/06-step4-zone-setup-zone-lua.md)
- [7. 第五步：定義 NPC（npcs/）](01-hello-dungeon/07-step5-defining-npcs.md)
- [8. 第六步：定義技能（talents.lua）](01-hello-dungeon/08-step6-defining-talents.md)
- [9. 第七步：定義傷害類型（damage_types.lua）](01-hello-dungeon/09-step7-damage-types.md)
- [10. 第八步：定義角色創建（birth/descriptors.lua）](01-hello-dungeon/10-step8-birth-descriptors.md)
- [11. 第九步：Actor 基礎類別](01-hello-dungeon/11-step9-actor-base-class.md)
- [12. 第十步：Player 類別](01-hello-dungeon/12-step10-player-class.md)
- [13. 第十一步：NPC 類別](01-hello-dungeon/13-step11-npc-class.md)
- [14. 第十二步：Grid 類別](01-hello-dungeon/14-step12-grid-class.md)
- [15. 第十三步：戰鬥介面（Combat.lua）](01-hello-dungeon/15-step13-combat-interface.md)
- [16. 第十四步：Game 主控制器](01-hello-dungeon/16-step14-game-main-controller.md)
- [17. 第十五步：死亡對話框](01-hello-dungeon/17-step15-death-dialog.md)
- [18. 執行你的模組](01-hello-dungeon/18-running-your-module.md)
- [19. 常見錯誤與排解](01-hello-dungeon/19-troubleshooting.md)
- [下一步](01-hello-dungeon/next-steps.md)
