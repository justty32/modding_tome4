### 4.1 Hooks（事件注入）

**最常用**。在遊戲生命週期的特定時間點執行你的程式碼，不影響原始程式流程。

```lua
-- hooks/load.lua

class:bindHook("ToME:run", function(self, data)
    -- 遊戲啟動時執行（在主選單顯示之前）
    print("My addon is active!")
end)
```

`bindHook` 的第一個參數是事件名稱，第二個是回調函式。`self` 是觸發 hook 的物件（因事件而異）。

#### 常用 Hook 列表

| Hook 名稱 | 觸發時機 | `self` 物件 |
|-----------|----------|-------------|
| `ToME:run` | 遊戲啟動、主選單顯示前 | `class`（類別表） |
| `ToME:load` | `mod/load.lua` 最後執行時 | `class` |
| `ToME:runDone` | `run()` 完成後 | `class` |
| `ToME:birthDone` | 角色創建完成後 | `class` |
| `Entity:loadList` | 每次載入 Entity 列表（NPC、物品等）| 載入的 Entity 原型物件 |
| `MapGeneratorStatic:subgenRegister` | 靜態地圖子產生器註冊時 | 地圖產生器 |
| `Game:changeLevel` | 玩家切換樓層時 | `game` 物件 |
| `Game:alterGameMenu` | 遊戲選單開啟時 | `game` 物件 |
| `Actor:move` | Actor 移動後 | 移動的 Actor |
| `Actor:onWear` | Actor 裝備物品時 | Actor |
| `Actor:preUseTalent` | 使用天賦前（可取消）| Actor |
| `Actor:tooltip` | 顯示 Actor tooltip 時 | Actor |
| `Actor:actBase:Effects` | 每回合 Effect 計算時 | Actor |

#### 範例：用 `ToME:load` 載入新天賦定義

```lua
-- hooks/load.lua

class:bindHook("ToME:load", function(self, data)
    local ActorTalents = require "engine.interface.ActorTalents"
    local Birther = require "engine.Birther"

    -- 載入天賦定義檔
    ActorTalents:loadDefinition("/data-my-addon/talents/my-class.lua")

    -- 載入職業描述符
    Birther:loadDefinition("/data-my-addon/birth/my-class.lua")
end)
```

> **注意**：`data/` 目錄在 Addon 內被映射到 `/data-<short_name>/`（例如 `my-addon` → `/data-my-addon/`）。

#### 範例：用 `Entity:loadList` 注入額外實體

```lua
class:bindHook("Entity:loadList", function(self, data)
    -- data.file 是正在載入的檔案路徑
    -- data.res  是已載入的實體列表（table）
    if data.file == "/data/general/npcs/undead.lua" then
        -- 把自己的 NPC 加進同一個列表
        self:loadList("/data-my-addon/npcs/extra-undead.lua", nil, data.res)
    end
end)
```

---

### 4.2 Superload（方法包裝）

**用來修改現有類別的方法**。Superload 在原始模組之後執行，可以透過 `loadPrevious()` 取得原始模組，然後包裝它的方法。

```
原始模組 → superload 包裝層 → require 的呼叫者取得包裝後的模組
```

**範例**：修改 Actor 的 `gainExp` 讓某些狀態下阻止經驗獲取：

```lua
-- superload/mod/class/Actor.lua

-- loadPrevious() 觸發原始 mod/class/Actor.lua 的載入，
-- 並返回 package.loaded["mod.class.Actor"]
local _M = loadPrevious(...)

-- 儲存原始方法的引用
local orig_gainExp = _M.gainExp

-- 用新函式替換，保留對原始的呼叫
function _M:gainExp(value)
    -- 自訂前置邏輯
    if self.my_special_status then
        return  -- 阻止獲取經驗
    end
    -- 呼叫原始方法
    return orig_gainExp(self, value)
end

return _M  -- 必須 return _M
```

#### Superload 規則

1. **路徑對應**：`superload/mod/class/Actor.lua` → 攔截 `require "mod.class.Actor"`
2. **`loadPrevious(...)`**：呼叫時必須傳入 `...`（讓引擎知道模組名稱）
3. **必須 `return _M`**：否則模組變成 `nil`，遊戲崩潰
4. **多個 Addon**：載入順序由 `weight` 決定，每個 Superload 的 `loadPrevious` 指向前一層的版本（形成鏈）
5. **Engine 類別也可以 superload**：`superload/engine/Actor.lua` 可攔截 `require "engine.Actor"`

#### 什麼時候用 Superload？

- 修改現有方法的行為（加入額外邏輯）
- 在不破壞其他 Addon 的前提下擴充方法

---

### 4.3 Overload（完全替換）

**直接替換整個 Lua 模組檔案**，不呼叫原始版本。謹慎使用，容易與其他 Addon 衝突。

```lua
-- overload/mod/class/SomeClass.lua
-- 這個檔案完全替換 mod/class/SomeClass.lua

local class = require "engine.class"
local Parent = require "engine.SomeParent"

module(..., package.seeall, class.inherit(Parent))

function _M:someMethod()
    -- 完全替換的實作
end
```

#### 什麼時候用 Overload？

- 你需要添加完全新的類別（而不是修改現有的）
- 你需要替換整個 UI 對話框邏輯
- 添加新的遊戲資源（圖片、地圖等，放在 `overload/data/` 中）

**覆蓋遊戲資源**（圖片、地圖等）：

```
overload/data/gfx/my_custom_tile.png
overload/data/maps/my-zone/mymap.lua
```

---
