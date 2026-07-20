# T-Engine 4 — 模組開發指南

> 本文件基於 `game/modules/example/` 範例模組分析，說明如何從零開始建立一個 TE4 遊戲模組。

---

## 1. 模組生命週期

```
1. 啟動引擎 (bootstrap/boot.lua)
   → 掛載 /game/engines/te4-1.7.6.teae 到 /engine/
   → 掛載 /game/modules/<模組名>/ 到 /mod/

2. 引擎初始化 (/engine/init.lua)
   → 載入 Addon 基礎設施
   → 掛載已啟用的 Addon (.teaa) 到 /mod/addons/<addon>/

3. 載入器 (game/loader/init.lua, pre-init.lua)
   → 設定自訂 Lua package.loaders（含 superload 攔截）
   → 註冊 RNG、table 序列化、基礎工具函數

4. 模組入口 (init.lua → starter → load.lua)
   → 載入鍵位定義、傷害類型、技能、效果、出生設定
   → 回傳 Game 類別

5. 遊戲啟動 (Game:newGame)
   → 角色創建 (Birther)
   → 載入第一個 Zone/Level
   → 進入主迴圈
```

---

## 2. 檔案結構

一個完整模組的目錄結構：

```
game/modules/mymod/
├── init.lua                    # 模組元資料
├── load.lua                    # 資料載入入口
│
├── class/                      # 類別定義
│   ├── Game.lua                # 遊戲主控制器（必要）
│   ├── Actor.lua               # 角色/怪物基底
│   ├── Player.lua              # 玩家角色
│   ├── NPC.lua                 # NPC（加入 AI）
│   ├── Grid.lua                # 地形格
│   ├── Object.lua              # 物品（若需要）
│   └── interface/
│       └── Combat.lua          # 自訂戰鬥介面
│
├── data/
│   ├── damage_types.lua        # 傷害類型定義
│   ├── talents.lua             # 技能定義
│   ├── timed_effects.lua       # Buff/Debuff 定義
│   ├── birth/
│   │   └── descriptors.lua     # 角色創建選項
│   ├── general/                # 全域共用實體
│   │   ├── grids/
│   │   │   └── basic.lua       # 基本地形（地板、牆、門…）
│   │   └── npcs/
│   │       └── kobold.lua      # NPC 模板
│   ├── zones/                  # 區域定義
│   │   └── dungeon/
│   │       ├── zone.lua        # 區域設定與生成器
│   │       ├── grids.lua       # 本區地形載入
│   │       ├── npcs.lua        # 本區 NPC 載入
│   │       ├── objects.lua     # 本區物品載入
│   │       └── traps.lua       # 本區陷阱載入
│   ├── rooms/                  # 房間模板（供地圖生成器使用）
│   │   ├── simple.lua
│   │   └── pilar.lua
│   └── gfx/particles/          # 粒子特效定義
│       └── acid.lua
│
├── dialogs/                    # UI 對話框
│   ├── DeathDialog.lua
│   └── Quit.lua
│
└── data/locales/               # 在地化翻譯
    └── ja_JP.lua
```

---

## 3. init.lua — 模組元資料

```lua
-- game/modules/mymod/init.lua
name = "My Roguelike"
long_name = "My First T-Engine4 Roguelike"
short_name = "mymod"
author = { "Author Name", "email@example.com" }
homepage = "https://example.com"
version = {1, 0, 0}
engine = {1, 7, 6, "te4"}       -- 所需引擎最低版本
starter = "mod.load"             -- 入口函數（對應 load.lua）
show_only_on_cheat = false       -- true = 在正常選單中隱藏
no_hierarchical_saves = true     -- true = 不使用階層式存檔
allow_hierarchical_saves = false
```

關鍵欄位：
- **`short_name`**：用作存檔資料夾名稱、虛擬路徑識別符。
- **`engine`**：`{major, minor, patch, "te4"}`，引擎會驗證相容性。
- **`starter`**：Lua 模組路徑，引擎呼叫此路徑對應的 `load.lua` 檔案。

---

## 4. load.lua — 資料載入入口

`load.lua` 負責在遊戲開始前載入所有定義（傷害、技能、效果等），最後回傳 Game 類別。

```lua
-- game/modules/mymod/load.lua

-- 引入引擎元件
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local Birther = require "engine.Birther"

-- 1. 載入鍵位綁定（引擎內建組合）
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- 2. 載入遊戲資料定義
DamageType:loadDefinition("/data/damage_types.lua")
ActorTalents:loadDefinition("/data/talents.lua")
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- 3. 定義角色資源（自訂的 MP、怒氣、能量…）
ActorResource:defineResource("Power", "power", nil, "power_regen",
    "Power is used to fuel special talents.")

-- 4. 定義角色屬性
ActorStats:defineStat("Strength",     "str", 10, 1, 100, "Physical power")
ActorStats:defineStat("Dexterity",    "dex", 10, 1, 100, "Agility")
ActorStats:defineStat("Constitution",  "con", 10, 1, 100, "Health")

-- 5. 載入 AI 行為定義（使用引擎內建 AI）
ActorAI:loadDefinition("/engine/ai/")

-- 6. 載入角色創建描述
Birther:loadDefinition("/data/birth/descriptors.lua")

-- 7. 若為即時制，啟用即時模式
-- core.game.setRealtime(20)  -- 每秒 20 tick

-- 8. 回傳 Game 類別（引擎會呼叫 Game.new()）
return { require "mod.class.Game" }
```
