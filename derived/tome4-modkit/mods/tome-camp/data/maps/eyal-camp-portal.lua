-- 貼到原版 Eyal 大地圖上的 3x3 子地圖，正中央是營地入口。
-- '?' 未 defineTile → Static.lua:557 resolve 為 nil、:578 跳過，overlay 只複製有東西的格子
-- （engine/Map.lua:1063），所以周圍 8 格保留德斯城旁原本的地形，對其他 addon 是純加法。
-- CAMP_PORTAL 定義在 data/zones/wilderness-add/grids.lua，由 hooks 併進 wilderness grid_list。

defineTile('*', "CAMP_PORTAL")

return {
	[[???]],
	[[?*?]],
	[[???]],
}
