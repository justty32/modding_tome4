Zone 在載入時會自動讀取對應目錄下的 `objects.lua`：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/objects.lua

-- load() 是引擎提供的特殊函數，用於在 Entity:loadList() 中載入子檔案
-- 功能等同於在當前上下文中執行那個 lua 檔案，並把 newEntity 定義加進清單

load("/data/general/objects/weapons.lua")
load("/data/general/objects/potions.lua")
```

**為什麼要有這個中間層？**

`Zone:loadBaseLists()` 呼叫 `object_class:loadList("...objects.lua")`，這個函數會執行該檔案，並收集所有 `newEntity{}` 呼叫的結果到一個清單。用 `load()` 轉發到子檔案，讓你可以把物品按類別分開管理，不必塞在同一個大檔案裡。

---
