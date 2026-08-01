-- 演出系統的測試對話。只有一個選項，按 Enter 就關掉。
--
-- ⚠️ 對話檔必須 return 起始 chat id（E/Chat.lua:70），漏了一開口就 nil index 崩潰。
-- 見 docs/knowledge/npc-and-chats.md §2。

newChat{ id = "welcome",
	text = [[（演出系統的測試對話。按 Enter 關閉，演出應該接著跑下去。）]],
	answers = {
		{ "（離開）" },
	},
}

return "welcome"
