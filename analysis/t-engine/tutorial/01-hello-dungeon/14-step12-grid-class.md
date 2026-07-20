Grid 通常不需要大幅修改，繼承引擎 Grid 就足夠了：

```lua
-- game/modules/hellodungeon/class/Grid.lua

require "engine.class"
require "engine.Grid"

module(..., package.seeall, class.inherit(engine.Grid))

-- 可以在這裡覆寫 block_move 等行為
-- 例如讓門可以被玩家開啟（引擎 Grid 已內建此邏輯）
```

---
