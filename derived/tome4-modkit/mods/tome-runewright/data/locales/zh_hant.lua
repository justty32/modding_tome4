-- data = true 的 addon，locale 檔會被引擎自動載入（engine/Module.lua:505-508），
-- 不需要在 hooks/load.lua 手動呼叫——這是 data/ 底下唯一的例外。
--
-- tag 必須對得上，否則翻譯不生效（engine/I18N.lua:65-70 用 (原文, tag) 複合鍵）。
-- 職業／子職業顯示名的 tag 是 "birth descriptor name"（engine/Birther.lua:69）。

locale "zh_hant"

section "data-runewright/birth/classes/mage.lua"

t("Runewright", "盧恩術士", "birth descriptor name")
