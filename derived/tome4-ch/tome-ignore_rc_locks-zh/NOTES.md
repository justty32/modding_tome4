# ignore_rc_locks 正體中文化筆記

## 覆蓋範圍摘要

`tome-ignore_rc_locks-zh` 共翻譯 **2 條**字串，兩者皆來自
`data/achievements/unlock.lua` 定義的成就 `IGNORE_RC_SELF_UNLOCK`
（「解鎖一個被鎖定的種族/職業時」觸發）：

- `name = 'Purely a Formality'`：由引擎
  `mod/class/interface/WorldAchievements.lua:48` 的
  `t.name = _t(t.name, "achievement name")` 在顯示成就時自動查表，
  tag 沿用官方翻譯檔對成就名稱的慣例 `"achievement name"`。
- `desc = _t[[Unlock a locked race or class while playing a character of that race/class.]]`：
  原始碼已用 `_t[[...]]`（無第二參數，預設 tag 為 `"_t"`）包裹，locale 可直接覆蓋。

## 掃描結果：其餘檔案無可覆蓋字串

逐檔確認過 `init.lua`（僅 addon 中介資料，不在翻譯範圍內，理由與其餘
3 個 addon 一致）、`hooks/load.lua`（純邏輯：載入成就定義、繞過職業/種族
的 evolution 鎖，無面向玩家的字串）、
`overload/mod/class/FakeBirther.lua`（僅 `print(...)` 除錯輸出，不在遊戲內顯示）、
`superload/mod/class/Game.lua`（僅 `print(...)` 除錯輸出）、
`superload/mod/dialogs/Birther.lua`、`superload/mod/dialogs/UberTalent.lua`
（純邏輯覆寫，無字串）——皆無其他玩家可見字串，故 locale 條目僅上述 2 筆。

`overload/data/gfx/achievements/*.png` 為成就圖示，非文字，不在翻譯範圍。

## 術語決策

- 成就名稱「Purely a Formality」譯為「純屬形式」，呼應此成就的反諷語氣
  （因為本 addon 已繞過鎖定，「解鎖」對玩家而言只是走個形式）。
- 「race/class」比照官方 zh_hant 常見譯法「種族／職業」。
