### 9.1 目錄結構

```
game/addons/sanguinist/
├── init.lua
├── hooks/
│   └── load.lua              ← 載入技能定義和職業
└── data/
    ├── birth/
    │   └── classes/
    │       └── sanguinist.lua ← newBirthDescriptor（見第 5 節）
    └── talents/
        └── blood.lua          ← newTalentType + newTalent（見第 4 節）
```

### 9.2 init.lua

```lua
-- game/addons/sanguinist/init.lua

long_name   = "Sanguinist Class"
short_name  = "sanguinist"
for_module  = "tome"
version     = {1, 0, 0}
author      = {"你的名字", "your@email.com"}
description = [[
血術師職業 Addon：以血為代價，以血換力。
]]

hooks     = true   -- 使用 hooks/load.lua
data      = true   -- 有 data/ 目錄
```

### 9.3 hooks/load.lua

```lua
-- game/addons/sanguinist/hooks/load.lua

local ActorTalents = require "engine.interface.ActorTalents"

-- 在 ToME 的 load.lua 末尾執行後，載入我們的技能定義
hook{"ToME:load", function(info)
    -- 載入技能類型和技能定義
    ActorTalents:loadDefinition("/data/talents/blood.lua")

    -- 載入職業出生描述符
    local Birther = require "engine.Birther"
    Birther:loadDefinition("/data/birth/classes/sanguinist.lua")
end}
```

### 9.4 data/talents/blood.lua

（已在第 4 節展示完整程式碼）

### 9.5 data/birth/classes/sanguinist.lua

（已在第 5 節展示完整程式碼）

---
