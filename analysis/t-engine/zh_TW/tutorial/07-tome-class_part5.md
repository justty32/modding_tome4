## 8. 熟練度系統（Mastery）

熟練度影響技能的效果上限。`getTalentMastery()` 在技能公式中常見：

```lua
-- 技能內部用 getTalentMastery 來縮放效果：
local mastery = self:getTalentTypeMastery("blood/sanguination")
-- 返回值：0.3（初始值）到 1.0+（用點解鎖後）

-- 實際應用範例：
local dam = base_dam * mastery
```

**設定初始熟練度的方式**：

```lua
-- 方式 1：在 talents_types 中設定（推薦）
talents_types = {
    ["blood/sanguination"] = {true, 0.3},  -- 0.3 = 基礎熟練度加成
    -- 實際熟練度 = 1.0 + 0.3 = 1.3（因為引擎以 1.0 為基礎）
},

-- 方式 2：在 copy 中用 resolvers 設定（用於更精細控制）
copy = {
    resolvers.talents_types_mastery{
        ["blood/sanguination"] = 0.4,  -- 覆蓋 talents_types 中的值
    },
},
```

**讓玩家提升熟練度**：在技能 UI 中按 `+` 鍵投入「熟練度點數」（mastery point），需要在 Birther 中設定玩家有多少點可以分配。ToME 標準是每 10 級一個熟練度點。

---

## 9. 完整 Addon 實作

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

## 10. 測試與除錯技巧

### 10.1 在角色創建中快速測試

啟動遊戲進入角色創建，如果職業不出現：

1. 確認 `init.lua` 有 `hooks = true`
2. 確認 `hooks/load.lua` 的 掛鉤 名稱是 `"ToME:load"`（不是 `"ToME:run"`）
3. 確認 `Birther:loadDefinition` 的路徑正確（`/data/birth/classes/sanguinist.lua`，使用虛擬路徑）

### 10.2 技能不出現在技能 UI

```lua
-- 在遊戲中進入 debug 模式，呼叫以下查詢：
-- （在 Lua console 中，按 F12 或使用 ~ 鍵）
print(ActorTalents.talents_types_def["blood/sanguination"])
-- 應該顯示技能類型的定義表格
-- 如果是 nil，表示 loadDefinition 沒有成功執行
```

### 10.3 技能效果驗證

建立一個測試角色，在 debug 模式下手動設定技能等級：

```lua
-- 在 Lua console：
game.player:learnTalent(game.player.T_BLOOD_DRAIN, true, 5)
game.player:setTalentTypeMastery("blood/sanguination", 1.5)
```

### 10.4 require 問題

如果玩家無法加點（技能顯示「需求不足」），在技能的 `require` 中加入 print：

```lua
require = {
    stat = { mag = function(level)
        local v = 10 + level * 4
        print("[DEBUG] mag require for level", level, ":", v, "current:", game and game.player and game.player:getStat("mag"))
        return v
    end },
},
```

---

## 11. 常見錯誤排查

### 錯誤：`talent already exists with id T_BLOOD_MASTERY`

**原因**：`loadDefinition` 被呼叫了兩次（重複載入）。

**解法**：在 `hooks/load.lua` 中只呼叫一次。如果你有多個 掛鉤 可能重複觸發，用 guard：

```lua
hook{"ToME:load", function(info)
    if _G.__sanguinist_loaded then return end
    _G.__sanguinist_loaded = true
    ActorTalents:loadDefinition("/data/talents/blood.lua")
end}
```

---

### 錯誤：`blood/sanguination` 職業技能樹顯示為通用（generic）

**原因**：`newTalentType` 沒有設 `generic = false`（或省略），但 `talents_types` 中的設定與之矛盾。

**解法**：確認 `newTalentType` 中沒有 `generic = true`，且 `talents_types` 的第一個元素（`true`/`false`）是已解鎖狀態，不是 generic 標誌。

---

### 錯誤：`resolvers.equipbirth` 找不到物品

**原因**：指定的物品名稱（`name = "elm staff"`）在當前 Zone 的材料等級下找不到，或拼寫不符。

**解法**：
- 加入 `ignore_material_restriction = true`（equipbirth 預設已加入）
- 用 `defined = "ELM_STAFF"`（對應 `define_as`）精確指定，比名稱更可靠
- 在 Lua console 確認物品存在：`print(game.zone.object_list)` 或搜尋物品清單

---

### 錯誤：職業不顯示在特定種族的選項中

**原因**：種族的 `descriptor_choices.subclass` 沒有 allow 這個職業，或職業的 `descriptor_choices.race` 屏蔽了這個種族。

**解法**：
- 在 `sanguinist.lua` 的 `descriptor_choices.race` 中設 `__ALL__ = "allow"` 允許所有種族
- 確認目標種族（如 Human）的 `descriptor_choices.subclass` 沒有設 `__ALL__ = "disallow"` 且沒有特別排除 Sanguinist

---

### 錯誤：技能依賴鏈無法正常工作（`T_BLOOD_DRAIN` 為 nil）

**原因**：`ActorTalents.T_BLOOD_DRAIN` 在技能定義載入之前被引用。

**解法**：確認 `data/birth/classes/sanguinist.lua` 中的 `talents` 表格在 `data/talents/blood.lua` 載入**後**才執行。因為 `hooks/load.lua` 先載入技能再載入描述符，這通常不成問題。若仍報錯，把技能 ID 改為字串：

```lua
-- 用字串而不是常數（不依賴執行順序）
talents = {
    ["T_BLOOD_MASTERY"] = 1,
    ["T_BLOOD_DRAIN"]   = 1,
},
```

---

## 小結：製作新職業的完整檢查清單

- [ ] `init.lua`：設定 `hooks=true, data=true`
- [ ] `hooks/load.lua`：`ActorTalents:loadDefinition` + `Birther:loadDefinition`
- [ ] `data/talents/xxx.lua`：`newTalentType` + `newTalent`（全部技能）
- [ ] `data/birth/classes/xxx.lua`：`class` 大類別 + `subclass` 子職業
- [ ] subclass 的 `talents_types` 包含所有要解鎖的技能樹
- [ ] subclass 的 `talents` 包含起始技能
- [ ] subclass 的 `copy.equipment` 用 `resolvers.equipbirth`
- [ ] `descriptor_choices` 設定種族相容性（允許所有種族或限制特定種族）
- [ ] 在遊戲中測試角色創建 → 技能 UI → 每個技能效果
