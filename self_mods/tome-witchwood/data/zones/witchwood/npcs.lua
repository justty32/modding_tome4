-- 女巫森林的居民（Agent B 的地圖側）。
--
-- 這裡**不定義任何怪物**——三種原生怪都是 Agent A 的：
--   WITCHWOOD_HAG（林中老嫗，guardian）
--   WITCHWOOD_THORNLING（荊棘幼苗，雜兵）
--   WITCHWOOD_CAULDRON（遊走坩堝）
-- 只把 A 的定義檔拉進本 zone 的 npc_list（CONTRACT 硬性規定這行 load）。
--
-- load() 第二參數是 mod 函式（engine/Entity.lua:1247-1249），對 A 定義的
-- 每個 entity 補「沒設的」預設值：
--   * rarity   —— engine/Zone.lua:212-213：隨機生成**只撈有 rarity 的** entity，
--                 沒有就永遠不會自然生成（guardian 走 makeEntityByName 不受影響）。
--   * level_range —— engine/Zone.lua:223 沒 level_range 也不會進稀有度表。
-- 已設的值原樣保留，不覆寫 A 的決定。
load("/data-witchwood/npcs/witchwood.lua", function(e)
	if not e.rarity then
		if e.define_as == "WITCHWOOD_THORNLING" then e.rarity = 1
		elseif e.define_as == "WITCHWOOD_HAG" then e.rarity = 4
		elseif e.define_as == "WITCHWOOD_CAULDRON" then e.rarity = 6
		else e.rarity = 10 end
	end
	if not e.level_range then e.level_range = { 2, 30 } end
end)

-- ---------------------------------------------------------------------------
-- 任務 NPC（Agent C 的守根人葛薇）——本 session 代為接線。
-- ---------------------------------------------------------------------------
-- 平行開發時三個 agent 各守自己的檔案，接縫（誰載誰、誰放置誰）沒有人負責，
-- 這兩段就是補接縫。她的實際放置在 zone.lua 的 post_process。
--
-- 不給 rarity：她是任務 NPC，只能由 makeEntityByName 指名生成，
-- 不可以進隨機生成池（engine/Zone.lua:212-213 只撈有 rarity 的）。
load("/data-witchwood/npcs/witchwood-quest.lua")
