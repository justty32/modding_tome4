| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 自訂 Dialog | `dialogs/SkillLearnDialog.lua` | `Dialog.init` + `loadUI` + `setupUI` |
| TreeList 天賦樹 | `SkillLearnDialog:buildTree()` | `TreeList.new{tree=..., columns=...}` |
| 天賦資料讀取 | `actor.talents_types_def` | `getTalentLevelRaw`, `canLearnTalent`, `learnTalent` |
| 學習邏輯 | `SkillLearnDialog:doLearn()` | `actor:learnTalent(t.id)`, `actor.unused_talents` |
| HUD 圖示按鈕 | `uiset/GameUI.lua → displayUI()` | `glTexture:toScreenFull`, `game.mouse:registerZone` |
| 鍵盤快捷鍵 | `class/Game.lua → setupCommands()` | `self.key:addBinds{SHOW_SKILL_TREE=...}` |
| 舊界面保留 | `setupCommands()` 的 `USE_TALENTS` | 不刪除原有綁定，新舊同時存在 |
