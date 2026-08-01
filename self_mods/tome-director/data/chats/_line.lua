-- 單句台詞的對話框。由 director 的 `say` step 動態呼叫，不是給人手寫的。
--
-- 台詞從 `Chat.new(name, npc, player, data)` 的第四個參數進來：`data` 會成為
-- 這個檔案執行環境的 `__index`（E/Chat.lua:51 與 :61-68），所以直接寫變數名就讀得到。
--
-- 答案刻意**不給 action 也不給 jump**——`E/dialogs/Chat.lua:118-124` 在兩者皆無時
-- 會自己 `unregisterDialog`，而 director 覆寫了該 dialog 的 unload 來接回演出。
-- 換句話說：玩家怎麼關掉這個框（選答案／Escape／滑鼠）都能正確續演。

newChat{
	id = "line",
	text = __director_text or "",
	answers = {
		{ __director_answer or "（繼續）" },
	},
}

return "line"
