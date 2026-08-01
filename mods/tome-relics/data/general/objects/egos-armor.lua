-- 「挖掘者的」防具詞綴。由 hooks/load.lua 在 Entity:loadList 攔到原版
-- /data/general/objects/egos/armor.lua 時 append 進同一個 res 清單。

local Stats = require "engine.interface.ActorStats"

-- 前綴「挖掘者的」：長年扛重物、鑽坑道練出來的耐操與夜視。
newEntity{
    power_source = { technique = true },
    name = "挖掘者的", prefix = true, instant_resolve = true,
    keywords = { excavators = true },
    level_range = { 1, 50 },
    rarity = 9,
    cost = 12,
    wielder = {
        combat_armor = resolvers.mbonus_material(4, 2),
        max_encumber = resolvers.mbonus_material(30, 10),
        infravision = resolvers.mbonus_material(4, 1),
        fatigue = resolvers.mbonus_material(4, 2, function(e, v) return 0, -v end),
    },
}
