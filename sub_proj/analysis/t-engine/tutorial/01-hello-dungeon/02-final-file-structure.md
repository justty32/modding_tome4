我們要建立的模組叫做 `hellodungeon`：

```
game/modules/hellodungeon/
│
├── init.lua                          ← 模組元資料（名稱、版本、授權）
├── load.lua                          ← 載入所有遊戲系統
│
├── class/                            ← 核心類別
│   ├── Actor.lua                     ← 所有可動實體的基底
│   ├── Player.lua                    ← 玩家（Actor 子類）
│   ├── NPC.lua                       ← AI 敵人（Actor 子類）
│   ├── Grid.lua                      ← 地形
│   ├── Game.lua                      ← 主遊戲控制器
│   └── interface/
│       └── Combat.lua                ← 戰鬥邏輯（混入）
│
├── data/                             ← 內容資料
│   ├── damage_types.lua              ← 傷害種類定義
│   ├── talents.lua                   ← 技能定義
│   ├── timed_effects.lua             ← 持續效果（狀態異常）
│   │
│   ├── birth/
│   │   └── descriptors.lua          ← 角色創建選項（職業/種族）
│   │
│   ├── general/
│   │   └── npcs/
│   │       └── kobold.lua            ← 科博德敵人
│   │
│   └── zones/
│       └── dungeon/
│           ├── zone.lua              ← 地區設定（地圖生成規則）
│           ├── grids.lua             ← 此地區使用的地形
│           └── npcs.lua              ← 此地區使用的 NPC
│
└── dialogs/
    └── DeathDialog.lua               ← 死亡畫面
```

**共 16 個檔案**。我們一個一個建立。

---
