```lua
-- data/locales/ja_JP.lua
locale "ja_JP"

-- 指定來源檔案（用於管理翻譯完整性）
section "mod-example/class/Actor.lua"
t("You do not have enough power to activate %s.",
  "　%sを起動するリソースがない。",
  "logPlayer")

section "mod-example/data/damage_types.lua"
t("physical", "物理")
t("fire", "火焰")
```

啟用：在 `load.lua` 中呼叫 `I18N:loadLocale("/data/locales/ja_JP.lua")`，之後 `_t"physical"` 自動回傳翻譯。

---
