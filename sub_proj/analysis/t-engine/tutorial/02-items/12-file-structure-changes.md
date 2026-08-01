相對於教學 01，需要**新增**或**修改**的檔案：

```
game/modules/hellodungeon/
│
├── load.lua                          ← 修改：加入 ActorInventory + defineInventory
│
├── class/
│   ├── Actor.lua                     ← 修改：繼承 ActorInventory，加入 body，呼叫 ActorInventory.init
│   ├── Object.lua                    ← 新增：物品類別
│   ├── Player.lua                    ← 修改：加入 pickup/showEquipment_player/dropItem
│   └── Game.lua                      ← 修改：setupKeys 加入 g/i/d/a 鍵
│
├── class/interface/
│   └── Combat.lua                    ← 修改：傷害計算改讀 self.combat_dam
│
└── data/
    ├── general/
    │   └── objects/                  ← 新增目錄
    │       ├── weapons.lua           ← 新增：武器定義
    │       └── potions.lua           ← 新增：藥水定義
    └── zones/
        └── dungeon/
            ├── zone.lua              ← 修改：加入 object_class + generator.object
            └── objects.lua           ← 新增：地區物品清單（load weapons + potions）
```

**共新增 3 個檔案，修改 5 個檔案**。

---
