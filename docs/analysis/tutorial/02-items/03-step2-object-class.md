物品需要自己的類別。最小版本只需繼承 `engine.Object` 即可：

```lua
-- game/modules/hellodungeon/class/Object.lua

require "engine.class"
local Object = require "engine.Object"

module(..., package.seeall, class.inherit(Object))

--- 物品顯示顏色
-- 這裡可以依 type 回傳不同顏色，目前統一用白色
function _M:getDisplayColor()
    if self.type == "weapon" then
        return {200, 200, 255}  -- 武器：淡藍
    elseif self.type == "potion" then
        return {100, 255, 100}  -- 藥水：綠
    end
    return {255, 255, 255}      -- 預設：白
end

--- 物品完整描述（按 '/' 或游標懸停時顯示）
function _M:getDesc()
    local str = self.name.."\n"
    if self.desc then
        str = str..self.desc.."\n"
    end
    -- 顯示裝備加成
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

**engine.Object 提供什麼？**

| 方法/欄位 | 說明 |
|-----------|------|
| `stackable()` / `canStack(o)` | 判斷是否可堆疊（需設 `stacking = true` 或字串） |
| `getNumber()` | 回傳堆疊數量 |
| `stack(o)` / `unstack(n)` | 合併/分離堆疊 |
| `wornInven()` | 依 `self.slot` 回傳對應的 `INVEN_*` ID |
| `getName(t)` | 帶數量的名稱（`{no_count=true}` 不顯示數量） |
| `resolve()` | 執行所有 resolver（物品生成時自動呼叫） |

---
