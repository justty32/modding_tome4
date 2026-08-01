-- 巴別塔的掉落物。
-- 載入原版物品基底清單：object_list 非空，Random object 生成器才撈得到貨
-- （之前是空的 → 巴別塔完全不掉落物），隨機精英（randelite，機率 25%）加掛的
-- resolvers.equip 也不會再印 [resolveObject] **FAILED**（見 docs/knowledge/npc-and-chats.md §6）。
-- 抄 town-derth/objects.lua 的寫法。
load("/data/general/objects/objects-maj-eyal.lua")
