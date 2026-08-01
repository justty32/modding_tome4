TE4 的物品系統由四個核心概念組成：

```
ActorInventory（揹包介面）
  ├── 揹包槽位（INVEN）    ← 無限格數的主揹包
  └── 裝備槽位（WEAPON 等）← 已裝備的物品，穿上時生效

engine.Object（物品實體）
  ├── slot        ← 可裝備到哪個槽位（對應 defineInventory 的 short_name）
  ├── wielder     ← 裝備後給予 Actor 的臨時屬性加成
  ├── use_simple  ← 使用效果（消耗品）
  └── stacking    ← 是否可堆疊（true = 相同物品合併顯示）

Zone.object_list（物品資料庫）
  └── 從 data/zones/<zone>/objects.lua 載入

generator.object（地圖物品生成器）
  └── engine.generator.object.Random → 隨機散落物品到地板
```

**資料流向**：

```
load.lua
  → defineInventory（定義武器/裝備槽位）
  → Object:loadDefinition（載入物品原型）

zone.lua
  → object_class = "mod.class.Object"
  → generator.object.class = "engine.generator.object.Random"

Actor:init
  → body = { INVEN=20, WEAPON=1 }（初始化揹包）

Player 按鍵 g
  → Actor:pickupFloor()    ← 撿起地板物品
Player 按鍵 e / w
  → Actor:wearObject()     ← 裝備物品（自動呼叫 onWear → 套用 wielder）
Player 按鍵 d
  → Actor:dropFloor()      ← 丟棄物品
```

---
