# 教學 01：最簡地城遊戲 (Hello Dungeon)

> **目標**：從零建立可執行的 TE4 遊戲模組。玩家在隨機地城中移動、攻擊科博德、使用技能，死亡後顯示死亡畫面。
>
> **參考**：以 `game/modules/example/` 為範本說明。

---

## 1. TE4 模組是什麼？

TE4 (T-Engine 4) 是 **Lua 驅動的 Roguelike 引擎**。你的遊戲是「模組」(module)，置於：

```
game/modules/<模組名稱>/
```

引擎載入時掃描此目錄，找到 `init.lua` 後啟動遊戲。

**啟動流程**：
```
bootstrap/boot.lua
  → game/loader/init.lua             ← 引擎版本選擇 + Addon superload
    → game/modules/<mod>/init.lua    ← 模組元資料
      → game/modules/<mod>/load.lua  ← 遊戲系統定義
        → mod.class.Game:run()       ← 主迴圈開始
```

---

## 2. 最終檔案結構

模組名 `hellodungeon`：

```
game/modules/hellodungeon/
│
├── init.lua                          ← 模組元資料（名稱、版本、授權）
├── load.lua                          ← 載入所有遊戲系統
│
├── class/                            ← 核心類別
│   ├── Actor.lua                     ← 所有可動實體基底
│   ├── Player.lua                    ← 玩家（Actor 子類）
│   ├── NPC.lua                       ← AI 敵人（Actor 子類）
│   ├── Grid.lua                      ← 地形
│   ├── Game.lua                      ← 主控制器
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

共 **16 檔**。

---

## 3. 模組入口（init.lua）

引擎最先讀取的檔案，宣告模組身分：

```lua
-- game/modules/hellodungeon/init.lua

name = "Hello Dungeon"
long_name = "Hello Dungeon - My First TE4 Game"
short_name = "hellodungeon"

author = { "你的名字", "your@email.com" }
version = {1, 0, 0}

-- 引擎版本須與 te4-X.Y.Z.teae 一致
engine = {1, 7, 6, "te4"}

description = [[
我的第一個 TE4 地城探索遊戲。
探索隨機地城，擊敗科博德！
]]

-- 啟動後執行的 Lua 路徑（對應 load.lua）
starter = "mod.load"
```

| 欄位 | 說明 |
|------|------|
| `short_name` | 小寫，作存檔目錄名、模組 ID |
| `engine` | 版本須與 `game/engines/te4-X.Y.Z.teae` 一致 |
| `starter` | `"mod.load"` 對應 `load.lua`（`mod.` 前綴 = 模組根目錄）|
| `show_only_on_cheat` | 設 `true` 可隱藏模組，開發用 |

---

## 4. 系統載入（load.lua）

初始化所有遊戲系統，回傳 Game 類別：

```lua
-- game/modules/hellodungeon/load.lua

local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorAI = require "engine.interface.ActorAI"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"

-- 載入預設按鍵綁定
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- 載入傷害類型定義
DamageType:loadDefinition("/data/damage_types.lua")

-- 載入技能定義
ActorTalents:loadDefinition("/data/talents.lua")

-- 載入持續效果（Buff/Debuff）定義
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- 定義資源池：Power（能量）
-- 參數：顯示名稱, 內部名稱, 最大值欄位名, 回復速度欄位名, 說明
ActorResource:defineResource(
    "Power", "power",
    nil, "power_regen",
    "能量代表你使用特殊技能的能力。"
)

-- 定義基本屬性
-- 參數：名稱, 縮寫, 預設值, 最小值, 最大值, 說明
ActorStats:defineStat("Strength",    "str", 10, 1, 100,
    "力量：影響近戰傷害與攜帶重量。")
ActorStats:defineStat("Dexterity",   "dex", 10, 1, 100,
    "敏捷：影響命中率、閃避與輕武器傷害。")
ActorStats:defineStat("Constitution","con", 10, 1, 100,
    "體質：影響最大生命值。")

-- 載入引擎內建 AI 腳本
ActorAI:loadDefinition("/engine/ai/")

-- 載入角色創建描述符
Birther:loadDefinition("/data/birth/descriptors.lua")

-- 最後一行：回傳 Game 類別
return { require "mod.class.Game" }
```

**注意**：
- `"/data/..."` 是**虛擬路徑**，對應 `data/` 目錄
- `return { require "mod.class.Game" }` 為必須，告訴引擎使用哪個 Game 類別
