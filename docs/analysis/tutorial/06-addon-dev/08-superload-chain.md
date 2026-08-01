當多個 Addon 都 superload 同一個模組時，引擎按 `weight` 從小到大串聯：

```
原始 Actor.lua
  └─ addon-A (weight=1) 的 superload → 呼叫 loadPrevious() 得到原始
      └─ addon-B (weight=2) 的 superload → 呼叫 loadPrevious() 得到 addon-A 的版本
          └─ require "mod.class.Actor" 返回最外層（addon-B 的版本）
```

這意味著：
- **每個 superload 必須呼叫 `loadPrevious()`**，否則斷鏈，前面的 Addon 失效
- **方法替換時必須儲存原始方法再呼叫**（如範例中的 `orig_gainExp`）
- 越後載入（weight 越大）的 Addon，包裝在最外層，優先執行

---
