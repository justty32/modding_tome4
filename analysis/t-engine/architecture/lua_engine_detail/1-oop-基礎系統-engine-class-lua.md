TE4 在 Lua 5.1 上自行實作了一套物件導向系統，是整個引擎的地基。

### 1.1 類別建立

```lua
module(..., package.seeall, class.make)        -- 單繼承/無繼承
module(..., package.seeall, class.inherit(A, B, C))  -- 多重繼承 mixin
```

- **`class.make(c)`**：將 module table 升格為類別，注入 `new()`、`castAs()` 方法。
- **`class.inherit(...bases)`**：多重繼承，將所有 base 的欄位**快取複製**到子類別（而非 `__index` 鏈），避免查找開銷。繼承順序為左到右、後者覆蓋前者。

### 1.2 物件實例化

```lua
local obj = MyClass.new(...)
-- 等同於：
local obj = {}
obj.__CLASSNAME = "module.name"
obj.__ATOMIC = true
setmetatable(obj, {__index = MyClass})
obj:init(...)
```

- `__CLASSNAME`：字串，用於存檔/讀檔時重建 metatable。
- `__ATOMIC = true`：標記此 table 為物件，不做深拷貝。

### 1.3 Clone 機制

| 方法 | 說明 |
|------|------|
| `obj:clone(t)` | 淺拷貝，選擇性合併 `t` |
| `obj:cloneFull()` | 遞迴深拷貝，相同子物件只拷貝一次（cyclic safe），呼叫各子物件的 `:cloned()` |
| `obj:cloneCustom(alt_nodes, type_checker)` | 可自訂跳過/替換特定節點的深拷貝 |
| `obj:cloneForSave()` | 同 cloneFull 但不呼叫 `:cloned()`，僅用於序列化前準備 |
| `obj:cloneReloaded()` | 讀檔後重建 metatable 並呼叫所有 `:loaded()` |
| `obj:replaceWith(t)` | 就地替換物件內容（in-place），不改變引用 |

### 1.4 Hook & Event 系統

```lua
class:bindHook("ActorAI:act", function(self, data) ... end)
self:triggerHook{"ActorAI:act", key=val, ...}
```

- **`bindHook(hook, fct)`**：將 handler 加入指定 hook。每次 bind 後會動態重新生成一個 closure，把所有 handler 串成一個函數（避免 table 查找）。
- **`triggerHook(hook_table)`**：呼叫該 hook 的所有 handler，任一 handler 回傳 `true` 則整體回傳 `true`。
- `__persistent_hooks`：存入存檔的 hook，讀檔時自動重新 bind。

### 1.5 存檔整合

```lua
obj:save(filter, allow)
class.load(str, delayloading)
```

- 存檔：將物件序列化為 Lua 字串並寫入 zip（每個物件一個檔案），由 `engine.Savefile` 管理。
- 讀檔：反序列化字串，根據 `__CLASSNAME` 重設 metatable，呼叫 `:loaded()`。
- `loadNoDelay = true`：強制同步呼叫 `:loaded()`（不延遲），用於 Shader 等需立即初始化的物件。

---
