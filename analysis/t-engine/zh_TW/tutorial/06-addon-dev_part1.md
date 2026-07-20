# 教學 06：製作第一個 ToME Addon

> **目標**：從零製作 ToME Addon，掌握 hooks / superload / overload 三種機制，並以「新增職業」範例貫穿。
>
> **前置**：閱讀[教學 01](./01-hello-dungeon.md) 瞭解 TE4 基礎；熟悉 Lua `require`、閉包、metatables。

---

## 1. Addon 概述

不修改原始碼，可：

- 新增職業、種族、技能樹、天賦
- 替換或擴充現有 Lua 類別方法
- 注入回調至遊戲生命週期特定時刻
- 覆蓋資源檔案（圖、地圖、對話腳本）

開發時放 `game/addons/<short_name>/`，發布打包為 `.team` zip。引擎啟動後 `bootstrap/boot.lua` 自動掃描掛載。

---

## 2. 目錄結構

```
game/addons/my-addon/
├── init.lua          ← 必備；Addon 元資料
├── hooks/
│   └── load.lua      ← 事件 hook（最常用）
├── superload/
│   └── mod/class/Actor.lua   ← 攔截包裝現有 Lua 模組
├── overload/
│   └── mod/class/MyClass.lua ← 完全替換現有 Lua 模組
└── data/
    ├── birth/                ← 職業/種族描述符
    ├── talents/              ← 天賦定義
    └── ...
```

---

## 3. `init.lua`：Addon 元資料

唯一必要檔案。引擎據此判斷是否載入。

```lua
-- game/addons/my-addon/init.lua

long_name  = "My First Addon"   -- 顯示名稱（主選單）
short_name = "my-addon"         -- 唯一識別碼（ASCII，無空白）
for_module = "tome"             -- 目標模組

version    = {1, 0, 0}
author     = { "你的名字", "email@example.com" }
homepage   = "https://example.com"
description = [[此 Addon 新增一個強大職業。]]

-- 宣告所需機制（true 才會被掃描載入）
hooks     = true
superload = true
overload  = true
data      = true

weight = 1         -- 越小越早載入（預設 1，DLC 通常 5+）

-- cheat_only = true  -- 僅作弊模式啟用
-- dlc = 5            -- 標記為 DLC，需線上驗證
```

### 關鍵欄位

| 欄位 | 說明 |
|------|------|
| `for_module` | ToME 須為 `"tome"`；獨立模組填自己 `short_name` |
| `weight` | 載入順序；衝突時 weight 小者先載入 |
| `hooks` / `superload` / `overload` / `data` | 只宣告實際使用的目錄 |

---

## 4. 三種整合機制

### 4.1 Hooks（事件注入）

**最常用**。在生命週期特定時點執行程式碼，不影響原始流程。

```lua
-- hooks/load.lua

class:bindHook("ToME:run", function(self, data)
    -- 遊戲啟動時執行（主選單顯示前）
    print("My addon is active!")
end)
```

`bindHook` 第一參數為事件名稱，第二為回調。`self` 隨事件而異。

#### 常用 Hook

| Hook 名稱 | 觸發時機 | `self` 物件 |
|-----------|----------|-------------|
| `ToME:run` | 啟動、主選單顯示前 | `class` |
| `ToME:load` | `mod/load.lua` 最後執行時 | `class` |
| `ToME:runDone` | `run()` 完成後 | `class` |
| `ToME:birthDone` | 角色創建完成後 | `class` |
| `Entity:loadList` | 載入 Entity 列表（NPC、物品等） | Entity 原型 |
| `MapGeneratorStatic:subgenRegister` | 靜態地圖子產生器註冊 | 地圖產生器 |
| `Game:changeLevel` | 玩家切換樓層 | `game` 物件 |
| `Game:alterGameMenu` | 遊戲選單開啟 | `game` 物件 |
| `Actor:move` | Actor 移動後 | 移動的 Actor |
| `Actor:onWear` | Actor 裝備物品 | Actor |
| `Actor:preUseTalent` | 使用天賦前（可取消） | Actor |
| `Actor:tooltip` | 顯示 tooltip | Actor |
| `Actor:actBase:Effects` | 每回合 Effect 計算 | Actor |

#### 範例：`ToME:load` 載入天賦定義

```lua
-- hooks/load.lua

class:bindHook("ToME:load", function(self, data)
    local ActorTalents = require "engine.interface.ActorTalents"
    local Birther = require "engine.Birther"

    -- 載入天賦定義
    ActorTalents:loadDefinition("/data-my-addon/talents/my-class.lua")
    -- 載入職業描述符
    Birther:loadDefinition("/data-my-addon/birth/my-class.lua")
end)
```

> `data/` 目錄掛載後映射為 `/data-<short_name>/`（如 `my-addon` → `/data-my-addon/`）。

#### 範例：`Entity:loadList` 注入實體

```lua
class:bindHook("Entity:loadList", function(self, data)
    -- data.file 為載入中的檔案路徑，data.res 為已載入列表
    if data.file == "/data/general/npcs/undead.lua" then
        self:loadList("/data-my-addon/npcs/extra-undead.lua", nil, data.res)
    end
end)
```

---

### 4.2 Superload（方法包裝）

**修改現有類別方法**。在原始模組後執行，透過 `loadPrevious()` 取得原始模組並包裝。

```
原始模組 → superload 包裝層 → require 取得包裝後模組
```

**範例**：修改 `gainExp` 依條件阻止經驗獲取：

```lua
-- superload/mod/class/Actor.lua

-- loadPrevious() 觸發原始模組載入，返回 package.loaded["mod.class.Actor"]
local _M = loadPrevious(...)

local orig_gainExp = _M.gainExp

function _M:gainExp(value)
    if self.my_special_status then
        return  -- 阻止經驗獲取
    end
    return orig_gainExp(self, value)
end

return _M  -- 必須 return
```

#### Superload 規則

1. **路徑對應**：`superload/mod/class/Actor.lua` → 攔截 `require "mod.class.Actor"`
2. **`loadPrevious(...)`**：傳入 `...`（引擎依此識別模組名稱）
3. **必須 `return _M`**，否則模組變 `nil` 導致崩潰
4. **多 Addon**：按 `weight` 小→大串聯形成鏈，`loadPrevious` 指向前一層
5. **Engine 類別亦可**：`superload/engine/Actor.lua` → 攔截 `require "engine.Actor"`

#### 適用場景

- 修改現有方法行為（追加邏輯）
- 不破壞其他 Addon 前提下擴充

---

### 4.3 Overload（完全替換）

**直接替換整個 Lua 模組**，不呼叫原始版。謹慎使用，易衝突。

```lua
-- overload/mod/class/SomeClass.lua
-- 完全替換 mod/class/SomeClass.lua

local class = require "engine.class"
local Parent = require "engine.SomeParent"

module(..., package.seeall, class.inherit(Parent))

function _M:someMethod()
    -- 完全替換實作
end
```

#### 適用場景

- 添加全新類別（非修改現有）
- 替換整個 UI 對話框邏輯
- 添加新遊戲資源（圖、地圖等，放 `overload/data/`）

**覆蓋遊戲資源**：

```
overload/data/gfx/my_custom_tile.png
overload/data/maps/my-zone/mymap.lua
```
