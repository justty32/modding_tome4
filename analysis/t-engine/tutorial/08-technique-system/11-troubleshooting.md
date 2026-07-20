### 錯誤：`attempt to call nil value (global 'newTechnique')`

**原因**：`newTechnique` 尚未定義就執行了 `dofile`。

**解法**：確認 `load.lua` 中定義 `newTechnique` 的程式碼**在** `dofile` 之前執行。

---

### 錯誤：HUD 不顯示（畫面上看不到橫條）

**原因**：`Game:display()` 中沒有呼叫 `technique_bar:toScreen()`，或 `self.technique_bar` 是 nil。

**解法**：
1. 確認 `Game:run()` 有建立 `self.technique_bar`
2. 確認 `Game:display()` 的呼叫位置在地圖繪製**之後**（否則會被蓋住）
3. 檢查座標：`bar_y = self.h - 80` 是否在可見範圍內

---

### 錯誤：`linker`/`finisher` 技能顯示「需要先建立連擊」但連擊計數不是 0

**原因**：`combo_state.active` 沒有被設為 `true`，或 Actor 的 `act()` 忘記呼叫 `techniqueTurn()`（導致計時器沒有倒數、狀態沒有更新）。

**解法**：確認 `Actor:act()` 有呼叫 `self:techniqueTurn()`。

---

### 錯誤：`incResource("ki", ...)` 報錯

**原因**：`ActorResource` 的 `incResource` 需要資源名稱與 `defineResource` 的第二個參數（內部名稱）一致。

**解法**：確認 `defineResource("Ki", "ki", ...)` 和 `incResource("ki", ...)` 用的是同一個小寫名稱。

---

### 效能問題：HUD 每幀都重繪

**原因**：`actor.changed` 沒有在連技狀態改變後設為 `true`，導致 `display()` 的提早退出條件失效，反而每幀都進入繪製。

**解法**：確認在 `useTechniqueInSlot`、`updateComboState`、`techniqueTurn` 的末尾都有設定 `self.changed = true`，且在 `Game:display()` 的最後把 `self.player.changed = false` 重置。

---
