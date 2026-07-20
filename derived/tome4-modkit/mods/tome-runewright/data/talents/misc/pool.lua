-- 符文充能的持有天賦。
--
-- engine/interface/ActorResource.lua:87-94：資源的 getter 只在 knowTalent(talent) 為真時
-- 回傳實值，否則一律回 0。所以每個資源都需要一個「池天賦」，
-- 且子職業必須在 birth 的 talents 表裡學會它。
-- 形制照抄 modules/tome/data/talents/misc/misc.lua:127-134 的 Mana Pool。

newTalent {
    name = "Rune Charge Pool", -- → short_name 自動生成為 RUNE_CHARGE_POOL
    type = { "base/class", 1 },
    info = "讓你擁有符文充能。觸發任何銘文都會累積充能，供盧恩術士的高階技能消耗。",
    mode = "passive",
    hide = "always",
    no_unlearn_last = true,
}
