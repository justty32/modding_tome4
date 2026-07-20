-- lore 跟 quest 不一樣：它是**開機一次性批次載入**的，不是惰性載入。
-- 原版在 mod/load.lua:111 對 /data/lore/lore.lua 呼叫 PartyLore:loadDefinition。
-- addon 的 data/ 掛在私有的 /data-runeisles/，不會被自動掃到，
-- 所以 hooks/load.lua 必須自己再呼叫一次 loadDefinition。
load("/data-runeisles/lore/runeisles.lua")
