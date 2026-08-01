```lua
local I18N = require "engine.I18N"
I18N:loadLocale("/data/locales/engine/zh.lua")
I18N:setLocale("zh")

-- 使用
_t"Hello World"   -- 翻譯字串
_t("Hello %s", name)  -- 帶參數
```

- 翻譯資料以 Lua table 形式儲存（`{["Hello World"] = "你好世界"}`）。
- 技能名稱、效果描述等在 `newTalent/newEffect` 時自動呼叫 `_t()`。

---
