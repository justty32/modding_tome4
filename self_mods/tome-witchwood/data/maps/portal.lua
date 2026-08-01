-- 貼到原版 Eyal 大地圖上的 3x3 子地圖，正中央是通往女巫森林的入口。
-- 位置：瑞文谷（Derth，(25,17)）西北方 (23,15)。
--
-- '?' 沒有被 defineTile，engine/generator/map/Static.lua:557 的 resolve 會回 nil，
-- :578 的 `if g then` 就整格跳過；engine/Map.lua:1063 的 overlay 也只複製有東西的格子。
-- 所以周圍 8 格保留原本的平原，不會踩到其他 addon。
--
-- WITCHWOOD_PORTAL 定義在 data/zones/witchwood/wilderness-add.lua，
-- 由 hooks/load.lua 的 Entity:loadList hook 併進 wilderness 的 grid_list。

defineTile('*', "WITCHWOOD_PORTAL")

return {
	[[???]],
	[[?*?]],
	[[???]],
}
