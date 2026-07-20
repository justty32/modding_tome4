T-Engine 4 在 Lua 5.1 上自行實作了一套物件導向系統，是整個引擎的地基。

### 類別建立

```lua
module(..., package.seeall, class.make)               -- 無繼承
module(..., package.seeall, class.inherit(A, B, C))   -- 多重繼承 mixin
```

| 方法 | 說明 |
|------|------|
| `class.make(c)` | 將 module table 升格為類別，注入 `new()`、`castAs()` |
| `class.inherit(...bases)` | 多重繼承：將所有 base 欄位**快取複製**到子類別（非 `__index` 鏈），左到右、後者覆蓋 |
| `getClassName()`, `getClass()`, `isClassName(name)` | 類別自省 |

### 物件實例化

```lua
local obj = MyClass.new(...)
-- 等同：obj.__CLASSNAME = "module.name"; setmetatable(obj, {__index=MyClass}); obj:init(...)
```

- `__CLASSNAME`：字串，存檔/讀檔時重建 metatable 用
- `__ATOMIC = true`：標記此 table 為物件，不做深拷貝

### Clone 機制

| 方法 | 說明 |
|------|------|
| `obj:clone(t)` | 淺拷貝，選擇性合併 `t` |
| `obj:cloneFull(post_copy)` | 遞迴深拷貝，cyclic safe，呼叫子物件 `:cloned()` |
| `obj:cloneCustom(alt_nodes, type_checker)` | 可自訂跳過/替換特定節點的深拷貝 |
| `obj:cloneForSave()` | 同 cloneFull 但不呼叫 `:cloned()`，用於序列化前 |
| `obj:cloneReloaded()` | 讀檔後重建 metatable 並呼叫所有 `:loaded()` |
| `obj:replaceWith(t)` | 就地替換物件內容（in-place），不改變引用 |

### Hook & Event 系統

```lua
class:bindHook("ActorAI:act", function(self, data) ... end)
self:triggerHook{"ActorAI:act", key=val, ...}
```

- `bindHook`：每次 bind 後動態重新生成一個 closure，把所有 handler 串成一個函數（避免 table 查找）
- `triggerHook`：任一 handler 回傳 `true` 則整體回傳 `true`
- `__persistent_hooks`：存入存檔的 hook，讀檔時自動重新 bind

### 存檔整合

- 存檔：序列化為 Lua 字串寫入 zip（每個物件一個檔案），由 `engine.Savefile` 管理
- 讀檔：反序列化字串，根據 `__CLASSNAME` 重設 metatable，呼叫 `:loaded()`
- `_no_save_fields`：排除在序列化之外的欄位列表

---
