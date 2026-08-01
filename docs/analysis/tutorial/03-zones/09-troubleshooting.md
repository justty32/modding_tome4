### 錯誤：`Zone.new: no such zone 'town'`

**原因**：Zone 是從 `data/zones/<short_name>/zone.lua` 載入的，路徑錯誤或拼寫不符。

**解法**：
- 確認目錄名稱為 `data/zones/town/`（與 `change_zone = "town"` 一致）
- 確認 `zone.lua` 中有 `short_name = "town"`

---

### 錯誤：玩家進入新地區後出現在 (0,0)

**原因**：Zone 生成時找不到 `default_up`/`default_down` 位置，預設落在 (0,0)。

**解法**：
- 地圖生成器必須設定 `up` 和 `down` 欄位，對應 `grids.lua` 中定義的地形 define_as
- `engine.generator.map.Roomer` 會自動找地形 `notice=true` 的格子作為起點/終點

---

### 錯誤：切換地區後地圖沒有更新（仍顯示舊地圖）

**原因**：`game.level.map.changed` 沒有被設為 `true`，或 FOV 沒有重新計算。

**解法**：在 `changeLevel` 末尾加入：

```lua
self.player:playerFOV()
self.level.map.changed = true
```

---

### 錯誤：`self.level.exited` 在重新生成地區後消失

**原因**：`level.exited` 需要在 `persistent = "zone"` 的設定下才會持久化。

**解法**：如果城鎮設了 `persistent = "zone"`，`level.exited` 就會在存檔時保留。地城若沒有設 persistent，每次重新進入都會重新生成樓層，`exited` 自然消失（符合 roguelike 風格）。

---
