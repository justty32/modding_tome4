```
game/modules/hellodungeon/
├── class/
│   └── Game.lua                  ← 修改：changeLevel、CHANGE_LEVEL、run 起始地區
│
└── data/zones/
    ├── dungeon/
    │   ├── grids.lua             ← 修改：加入 DUNGEON_EXIT 地形
    │   └── zone.lua              ← 修改：UP 指向 DUNGEON_EXIT（或靠 Game 判斷）
    └── town/                     ← 新增目錄
        ├── zone.lua              ← 新增：城鎮地區設定
        ├── grids.lua             ← 新增：城鎮地形（含 EXIT_TOWN）
        ├── npcs.lua              ← 新增：城鎮 NPC（可暫時空白）
        └── objects.lua           ← 新增：城鎮物品（可暫時空白）
```

**共新增 4 個檔案，修改 2 個檔案**。

---
