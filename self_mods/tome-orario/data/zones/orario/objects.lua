-- 中央廣場不放隨機掉落物，但要載入原版物品基底清單，
-- 否則 zone 的 object_list 為空、酒館冒險者的 resolvers.equip 找不到武具而空手
-- （實測坑：town zone 沒 load 這行，NPC 的 equip 靜默失敗）。抄 town-derth/objects.lua。
load("/data/general/objects/objects-maj-eyal.lua")
