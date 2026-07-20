## 11. 戰鬥整合

武器 `wielder.combat_dam` 經 `addTemporaryValue` 自動累加至 `Actor.combat_dam`，Combat.lua 僅需讀取 `self.combat_dam`：

```lua
-- game/modules/hellodungeon/class/interface/Combat.lua

function _M:attackTarget(target)
    local hit = self:checkHit(self:combatAttack(), target:combatDefense())

    if hit then
        -- wielder.combat_dam 已透過 addTemporaryValue 累加至 combat_dam
        local dam = math.max(1, (self.combat_dam or 5) + rng.range(-2, 2))

        target:takeHit(dam, self)
        game.logSeen(self, "%s 攻擊 %s，造成 %d 點傷害！",
            self:getName():capitalize(),
            target:getName():capitalize(), dam)
        return true
    else
        game.logSeen(self, "%s 攻擊 %s，但未命中！",
            self:getName():capitalize(),
            target:getName():capitalize())
        return false
    end
end
```

累加原理：

```
基礎 combat_dam = 5
裝備木劍（combat_dam=3）：
  addTemporaryValue("combat_dam", 3) → self.combat_dam = 8
卸下木劍：
  removeTemporaryValue("combat_dam", id) → self.combat_dam = 5
```

---

## 12. 完整檔案結構變更

相較教學 01，**新增**或**修改**之檔案：

```
game/modules/hellodungeon/
│
├── load.lua                          ← 修改：加入 ActorInventory + defineInventory
│
├── class/
│   ├── Actor.lua                     ← 修改：繼承 ActorInventory，body，init
│   ├── Object.lua                    ← 新增：物品類別
│   ├── Player.lua                    ← 修改：pickup/showEquipment_player/dropItem
│   └── Game.lua                      ← 修改：setupKeys 加入 g/i/d/a
│
├── class/interface/
│   └── Combat.lua                    ← 修改：傷害改讀 self.combat_dam
│
└── data/
    ├── general/
    │   └── objects/                  ← 新增目錄
    │       ├── weapons.lua           ← 新增：武器定義
    │       └── potions.lua           ← 新增：藥水定義
    └── zones/
        └── dungeon/
            ├── zone.lua              ← 修改：object_class + generator.object
            └── objects.lua           ← 新增：地區物品清單
```

**共新增 3 檔案，修改 5 檔案**。

---

## 13. 常見錯誤排查

### `attempt to index a nil value (self.inven)`

**原因**：Actor 未繼承 `ActorInventory` 或未呼叫 `ActorInventory.init()`。

**解法**：
1. `class.inherit(...)` 須包含 `ActorInventory`
2. `Actor.init()` 中呼叫 `ActorInventory.init(self, t)`
3. `t.body` 須在 `init` 之前設定

---

### `inventory slot undefined: WEAPON`

**原因**：`Actor.body` 宣告 `WEAPON=1` 但 `defineInventory("WEAPON",...)` 尚未執行。

**解法**：確認 `load.lua` 中 `ActorInventory:defineInventory("WEAPON",...)` 在任何 Actor 建立前執行。

---

### 物品未出現在地圖

- `zone.lua` 缺少 `generator.object` 區塊
- 所有物品定義皆無 `rarity`（無 rarity 不會隨機生成）
- `objects.lua` 之 `load()` 路徑錯誤（須為虛擬路徑 `/data/...`）

---

### `wearObject` 回傳 false

- 物品 `slot` 與 `defineInventory` 之 `short_name` 不符（須大寫 `"WEAPON"`）
- Actor 之 `body` 未包含 `WEAPON=1`

---

### 喝藥水後物品未消失

**原因**：`use_simple.use()` 回傳值結構不正確，或 Player 未呼叫 `removeObject`。

**解法**：確認回傳 `{used=true}`，且 Player 程式碼於 `r.used` 為真時呼叫：
```lua
self:removeObject(inven, item, 1)
```

---

### 裝備武器但傷害未增加

**原因**：`Combat.lua` 未讀取 `self.combat_dam`，或讀取固定值。

**診斷**：
```lua
print("目前 combat_dam:", self.combat_dam)
```
裝備後 `combat_dam` 應增加 `wielder.combat_dam`。若未增加，檢查 `defineInventory` 之第三參數 `is_worn = true`。

---

## 附錄：力量藥水 timed_effects 補充

於 `data/timed_effects.lua` 加入：

```lua
newEffect{
    name = "STRENGTH_BOOST",
    desc = "力量提升",
    type = "physical",
    subtype = { },
    status = "beneficial",
    parameters = { id=nil },
    deactivate = function(self, eff)
        if eff.id then
            self:removeTemporaryValue("combat_dam", eff.id)
        end
    end,
}
```

---

## 下一步

完成本教學後，hellodungeon 具備完整物品系統：武器、消耗品、撿物、裝備、丟棄。

**教學 03：多地區與世界地圖**將涵蓋：
- 第二地區（城鎮）
- 世界地圖（Wilderness）
- 地區切換（`game:changeLevel()`）
- 傳送點地形
