```
game/modules/hellodungeon/
│
├── load.lua                    ← 修改：定義 newTechnique()、載入連技、定義 ki 資源
│
├── class/
│   ├── Actor.lua               ← 修改：繼承 ActorTechnique，initTechniques
│   ├── Game.lua                ← 修改：建立 technique_bar，數字鍵綁定，showTechniqueManagement
│   └── interface/
│       └── ActorTechnique.lua  ← 新增：連技混入（initTechniques/learnTechnique/useTechniqueInSlot 等）
│
├── class/ui/
│   └── TechniqueBar.lua        ← 新增：連技橫條 HUD
│
└── data/
    ├── techniques/             ← 新增目錄
    │   └── combo.lua           ← 新增：五個連技定義
    ├── general/
    │   └── objects/
    │       └── technique_scrolls.lua  ← 新增：連技捲軸物品
    ├── chats/
    │   └── trainer.lua         ← 新增：訓練師對話
    └── zones/
        └── town/
            └── npcs.lua        ← 修改：加入訓練師 NPC
```

在 `load.lua` 加入：

```lua
-- load.lua

-- 定義氣（Ki）資源
ActorResource:defineResource("Ki", "ki", "max_ki", "ki_regen",
    "氣是使用連技的能量，每回合自然回復。")

-- 定義全域連技表與 newTechnique 函數
_G.techniques_def = {}
function newTechnique(t)
    t.short_name = t.short_name or t.name:upper():gsub("[%s'%-]", "_")
    t.id = "T_TECH_" .. t.short_name
    assert(not techniques_def[t.id],
        "連技已存在：" .. t.id)
    techniques_def[t.id] = t
end

-- 載入所有連技定義
dofile("/data/techniques/combo.lua")
```

---
