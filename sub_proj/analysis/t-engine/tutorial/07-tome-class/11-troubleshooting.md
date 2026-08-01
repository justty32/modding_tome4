### 錯誤：`talent already exists with id T_BLOOD_MASTERY`

**原因**：`loadDefinition` 被呼叫了兩次（重複載入）。

**解法**：在 `hooks/load.lua` 中只呼叫一次。如果你有多個 hook 可能重複觸發，用 guard：

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
