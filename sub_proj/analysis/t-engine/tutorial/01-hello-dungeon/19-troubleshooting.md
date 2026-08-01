### 錯誤：模組不出現在清單中

- 檢查 `init.lua` 的 `engine` 版本是否與 `game/engines/te4-X.Y.Z.teae` 一致
- 確認 `short_name` 只包含小寫字母和數字（無空格）

### 錯誤：`attempt to index a nil value` in load.lua

- 確認所有 `require` 的路徑正確
- `DamageType:loadDefinition("/data/damage_types.lua")` — 路徑需要是虛擬路徑（`/data/...`）

### 錯誤：地圖生成後看不到 NPC

- 確認 `zone.lua` 的 `generator.actor` 已設定 `class`
- 確認 `data/zones/dungeon/npcs.lua` 有 `load(...)` 引用 NPC 定義
- 確認 NPC 的 `level_range` 與 zone 的 `level_range` 有重疊

### 錯誤：技能無法使用

- 確認 `load.lua` 有 `ActorTalents:loadDefinition("/data/talents.lua")`
- 確認技能在 `newTalentType` 中宣告了類型
- 確認 `descriptors.lua` 的 `[ActorTalents.T_KICK]` 常數名稱與技能 `name` 轉換後一致（`T_` + 大寫名稱，空格換成 `_`）

### 錯誤：玩家無法換層

- 確認 Grid 有設定 `change_level = 1` 或 `-1`
- 確認 `Game.lua` 的 `CHANGE_LEVEL` 按鍵綁定存在
- 確認 `zone.lua` 的生成器設定了 `up` 和 `down` 鍵對應

---
