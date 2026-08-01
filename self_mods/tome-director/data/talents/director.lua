-- 除錯用天賦：在遊戲裡按一下就跑 demo 演出。
--
-- 為什麼要有它：演出系統唯一有意義的驗證是「真的在遊戲裡跑一遍」，而 playtest.sh
-- 用 Lua console 觸發最省事。天賦是最好觸發的入口（no_energy + 無資源消耗 + 無冷卻）。
-- 正式的劇情 addon 不該用天賦觸發演出——那邊該由 zone 的 on_enter、對話的 action、
-- 或 NPC 的 on_die 觸發。

newTalentType{
	type = "misc/director",
	name = "演出（除錯）",
	description = "演出系統的除錯入口。",
	generic = true, hide = true,
}

newTalent{
	name = "Director Demo",
	short_name = "DIRECTOR_DEMO",
	type = { "misc/director", 1 },
	points = 1,
	mode = "activated",
	no_energy = true,          -- 不吃回合：演出自己會推進回合
	cooldown = 1,
	no_npc_use = true,
	hide = true,
	tactical = {},
	action = function(self, t)
		local D = rawget(_G, "__tome_director")
		if not D then
			game.logPlayer(self, "#LIGHT_RED#Director 函式庫沒載入。")
			return false
		end
		local ok, err = D:play("demo")
		if not ok then game.logPlayer(self, "#LIGHT_RED#演出無法開始：%s", tostring(err)) return false end
		return true
	end,
	info = function(self, t)
		return ([[開始「demo」演出範例（除錯用）。

			演出期間玩家無敵、無法操作，按 Enter 可跳過。]])
	end,
}
