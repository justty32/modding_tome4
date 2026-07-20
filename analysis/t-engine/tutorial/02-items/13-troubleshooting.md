### 錯誤：`attempt to index a nil value (self.inven)`

**原因**：Actor 沒有繼承 `ActorInventory` 或沒有呼叫 `ActorInventory.init(self, t)`。

**解法**：
1. 確認 `class.inherit(...)` 列表包含 `ActorInventory`
2. 確認 `Actor.init()` 中呼叫了 `ActorInventory.init(self, t)`
3. 確認 `t.body` 已在呼叫 `init` **之前**設定好

---

### 錯誤：`inventory slot undefined: WEAPON`

**原因**：`Actor.body` 宣告了 `WEAPON=1`，但 `defineInventory("WEAPON", ...)` 還沒被呼叫。

**解法**：確認 `load.lua` 中的 `ActorInventory:defineInventory("WEAPON", ...)` 在任何 Actor 被創建之前就執行到。`load.lua` 是在遊戲開始前載入，只要放在 `load.lua` 裡面就夠早。

---

### 錯誤：物品不出現在地圖上

**可能原因一**：`zone.lua` 沒有加 `generator.object` 區塊。  
**可能原因二**：所有物品定義都沒有 `rarity` 欄位（沒有 rarity 的物品不會被隨機生成）。  
**可能原因三**：`objects.lua` 的 `load()` 路徑錯誤（注意路徑是虛擬路徑 `/data/...`，不是磁碟路徑）。

---

### 錯誤：`wearObject` 返回 `false`，武器裝備失敗

**原因**：物品的 `slot` 欄位與 `defineInventory` 的 `short_name` 不符合，或 Actor 沒有對應的揹包欄位。

**解法**：
- 確認物品定義有 `slot = "WEAPON"`（大寫）
- 確認 `defineInventory("WEAPON", ...)` 已呼叫
- 確認 Actor 的 `body` 包含 `WEAPON=1`

---

### 錯誤：喝藥水後物品沒有消失

**原因**：`use_simple.use()` 回傳的表格結構不對，或 Player 的處理邏輯中沒有呼叫 `removeObject`。

**解法**：確認 `use_simple.use()` 回傳 `{used=true}`，且你的 Player 程式碼在 `r.used` 為真時有呼叫：

```lua
self:removeObject(inven, item, 1)  -- 從揹包移除 1 個（堆疊時只消耗一個）
```

---

### 進階排查：武器裝備了但傷害沒增加

**原因**：`Combat.lua` 沒有讀取 `self.combat_dam`，或讀取的是舊的固定值。

**診斷方式**：

```lua
-- 在 Player 身上臨時加入除錯輸出
function _M:pickup()
    -- ... 撿物邏輯 ...
    print("目前 combat_dam:", self.combat_dam)
end
```

裝備武器後，`combat_dam` 應該增加對應的 `wielder.combat_dam` 數值。若沒有增加，檢查 `onWear` 是否被呼叫（確認 `defineInventory` 的第三個參數 `is_worn = true`）。

---
