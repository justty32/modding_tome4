-- 「出土的」武器詞綴。由 hooks/load.lua 在 Entity:loadList 攔到原版
-- /data/general/objects/egos/weapon.lua 時 append 進同一個 res 清單。
-- ego 的結構與原版 egos/weapon.lua 一字不差：prefix/suffix + keywords + level_range + rarity。
-- instant_resolve=true 讓名稱在載入時就併好（原版慣例，egos/weapon.lua:31 等）。

local DamageType = require "engine.DamageType"

-- 前綴「出土的」：考古匠人的手筆，讓武器帶一點「揭示」的性質。
newEntity{
    power_source = { technique = true },
    name = "出土的", prefix = true, instant_resolve = true,
    keywords = { unearthed = true },
    level_range = { 1, 50 },
    rarity = 8,
    cost = 12,
    combat = {
        dam = resolvers.mbonus_material(8, 4),
        apr = resolvers.mbonus_material(4, 2),
    },
    wielder = {
        see_invisible = resolvers.mbonus_material(6, 2),
        infravision = resolvers.mbonus_material(3, 1),
    },
}
