## 3. 建立 Object 類別

繼承 `engine.Object` 即可。最小實作：

```lua
-- game/modules/hellodungeon/class/Object.lua

require "engine.class"
local Object = require "engine.Object"

module(..., package.seeall, class.inherit(Object))

--- 物品顯示顏色
function _M:getDisplayColor()
    if self.type == "weapon" then
        return {200, 200, 255}  -- 武器：淡藍
    elseif self.type == "potion" then
        return {100, 255, 100}  -- 藥水：綠
    end
    return {255, 255, 255}      -- 預設：白
end

--- 完整描述（懸停/按 / 時顯示）
function _M:getDesc()
    local str = self.name.."\n"
    if self.desc then str = str..self.desc.."\n" end
    if self.wielder then
        if self.wielder.combat_dam then
            str = str..("  傷害 +%d\n"):format(self.wielder.combat_dam)
        end
        if self.wielder.combat_apr then
            str = str..("  穿甲 +%d\n"):format(self.wielder.combat_apr)
        end
    end
    return str
end
```

### `engine.Object` 關鍵方法

| 方法/欄位 | 功能 |
|-----------|------|
| `stackable()` / `canStack(o)` | 判斷可堆疊（需設 `stacking = true`） |
| `getNumber()` | 回傳堆疊數量 |
| `stack(o)` / `unstack(n)` | 合併/分離堆疊 |
| `wornInven()` | 依 `self.slot` 回傳對應 `INVEN_*` ID |
| `getName(t)` | 含數量之名稱（`{no_count=true}` 隱藏數量） |
| `resolve()` | 執行所有 resolver（物品生成時自動呼叫） |

---

## 4. 更新 Actor：加入背包

`ActorInventory` 是 mixin，加入 `class.inherit()` 並在 `body` 宣告各槽位最大格數。

```lua
-- game/modules/hellodungeon/class/Actor.lua

require "engine.class"
local Actor = require "engine.Actor"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorFOV = require "engine.interface.ActorFOV"
local ActorInventory = require "engine.interface.ActorInventory"   -- 新增

module(..., package.seeall, class.inherit(
    Actor, ActorTalents, ActorStats, ActorResource,
    ActorTemporaryEffects, ActorAI, ActorFOV,
    ActorInventory      -- 新增
))

function _M:init(t, no_default)
    -- body 在 ActorInventory:init() 中被消耗（轉為 self.inven 表格後設為 nil）
    t.body = t.body or {
        INVEN  = 20,    -- 主背包 20 格
        WEAPON = 1,     -- 武器欄 1 格
    }

    Actor.init(self, t, no_default)
    ActorTalents.init(self, t)
    ActorStats.init(self, t)
    ActorResource.init(self, t)
    ActorTemporaryEffects.init(self, t)
    ActorInventory.init(self, t)   -- 新增，放最後
end

function _M:act()
    if not Actor.act(self) then return end
    self:timedEffects()
    self:useEnergy()
end

--- 基礎傷害（wielder 系統會自動累加武器 combat_dam 至 self.combat_dam）
function _M:combatDamage()
    return self.combat_dam or 5
end
```

> `body` 在 `ActorInventory:init()` 讀取後設為 nil——它是建構參數，非持久狀態。

---

## 5. 定義武器

`newEntity{...}` 語法與 NPC/地形相同。

```lua
-- game/modules/hellodungeon/data/general/objects/weapons.lua

-- 武器基底
-- define_as 可被其他 newEntity 以 base = "BASE_WEAPON" 繼承
-- slot 對應 defineInventory 之 short_name → 裝備到 WEAPON 欄
newEntity{
    define_as = "BASE_WEAPON",
    type = "weapon", subtype = "sword",
    slot = "WEAPON",
    display = "/",
    color = colors.SLATE,
    encumber = 2,
    rarity = 5,         -- 越大越罕見；無 rarity 永不隨機出現
    desc = "一把近戰武器。",
}

-- 木劍（初級）
newEntity{ base = "BASE_WEAPON",
    name = "木劍",
    level_range = {1, 5},
    rarity = 3,
    cost = 5,
    -- wielder：裝備後 addTemporaryValue 套用到 Actor
    -- onWear → self:addTemporaryValue(k, v)
    -- onTakeoff → self:removeTemporaryValue(k, id)
    wielder = {
        combat_dam = 3,
        combat_apr = 1,
    },
}

-- 鐵劍（中級）
newEntity{ base = "BASE_WEAPON",
    name = "鐵劍",
    level_range = {3, 10},
    rarity = 5, cost = 20,
    wielder = { combat_dam = 7, combat_apr = 2 },
}

-- 精鋼劍（高級）
newEntity{ base = "BASE_WEAPON",
    name = "精鋼劍",
    level_range = {8, 20},
    rarity = 8, cost = 60,
    wielder = { combat_dam = 14, combat_apr = 4 },
}
```

### `wielder` 運作原理

```
onWear(o, inven_id):
  o.wielded = {}
  o:check("on_wear", self, inven_id)
  for k, e in pairs(o.wielder) do
    o.wielded[k] = self:addTemporaryValue(k, e)
  end

addTemporaryValue("combat_dam", 7) → self.combat_dam += 7
removeTemporaryValue("combat_dam", id) → 精確移除
```

`addTemporaryValue` 支援數字（加減）、表格（深度合併）、函數（動態計算）。
