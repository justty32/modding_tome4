-- 弗雷之族（Freyr's Ætt）索引
--
-- ⚠️ 不可用 require("data.talents.spells.futhark-freyr.type")。addon 的 data/ 掛在
-- /data-runewright/（engine/Module.lua:498-503），package.path 只有 /?.lua，
-- require 會去找模組自己的 /data/… 而拋 not found。
-- 這裡的 load() 是 engine/interface/ActorTalents.lua:40 由 loadDefinition 塞進 env 的那個
-- （吃絕對 VFS 路徑、沿用同一份 env），原版 data/talents.lua:300-311 就是這樣串檔的。
load("/data-runewright/talents/spells/futhark-freyr/type.lua")
load("/data-runewright/talents/spells/futhark-freyr/rw_fehu.lua")
load("/data-runewright/talents/spells/futhark-freyr/rw_thurisaz.lua")
load("/data-runewright/talents/spells/futhark-freyr/rw_kenaz.lua")
load("/data-runewright/talents/spells/futhark-freyr/rw_wunjo.lua")
