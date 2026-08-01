## 9. 熟練度系統

熟練度（0%~100%）影響連技效果，透過使用累積：

### 9.1 熟練度影響效果的標準公式

```lua
-- 在每個 action 函式中使用：
local prof = self:getTechniqueProficiency(t.id)  -- 0.0~1.0
local dam = base_dam * (1 + prof)
-- prof=0（剛學）：1.0× 傷害
-- prof=1（完全熟練）：2.0× 傷害
```

### 9.2 熟練度進度顯示

在 `showTechniqueManagement` 或工具提示中顯示進度條：

```lua
-- 以文字模擬進度條（10 格）
local function profBar(prof)
    local filled = math.floor(prof * 10)
    return ("[%s%s]"):format(
        string.rep("█", filled),
        string.rep("░", 10 - filled)
    )
end
-- 使用：("熟練 %s %.0f%%"):format(profBar(prof), prof*100)
```

### 9.3 熟練度里程碑

可在 `gainTechniqueProficiency` 中加入里程碑提示：

```lua
function _M:gainTechniqueProficiency(id, amount)
    local entry = self.techniques.known[id]
    if not entry then return end

    local before = math.floor(entry.proficiency / 25)  -- 0~3
    local gain = amount * (1 - entry.proficiency / 120)
    entry.proficiency = math.min(100, entry.proficiency + gain)
    local after = math.floor(entry.proficiency / 25)

    -- 每 25% 一個里程碑
    if after > before then
        local milestones = {
            [1] = "入門", [2] = "熟練", [3] = "精通", [4] = "完美"
        }
        local t = techniques_def[id]
        game.logPlayer(self, "#YELLOW#「%s」熟練度提升：%s！",
            t.name, milestones[after] or "完美")
    end
end
```

---

## 10. 完整檔案結構

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

-- 定義全域連技表格與 newTechnique 函式
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
