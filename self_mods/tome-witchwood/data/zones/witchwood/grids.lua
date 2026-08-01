-- 女巫森林的地形（Agent B）。
--
-- 地面／樹／階梯都基於原版森林地磚（/data/general/grids/forest.lua），
-- 只覆寫 define_as、名稱與貼圖——沿用原版地磚的移動/視線/挖掘語意
-- （GRASS 可走、TREE 擋路擋視線、GRASS_UP_WILDERNESS 帶 change_zone="wilderness"）。
--
-- 貼圖優先用自己的美術（overload/data/gfx/terrain/witchwood_*.png，64x64），
-- 檔名一律加 witchwood_ 前綴（CONTRACT 美術規則：prepend 撞名會靜默覆蓋全遊戲）。
-- 生圖失敗或沒圖時這些檔不會存在，引擎缺圖只會顯示 fallback 方塊、不會崩潰。
load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")

-- 地面：濕冷陰鬱的林地。GRASS 有 grow="TREE"（forest.lua:24-31），
-- 這裡改長女巫森林自己的樹。
newEntity{
	base = "GRASS",
	define_as = "WITCHWOOD_FLOOR",
	name = "女巫森林的地面",
	image = "terrain/witchwood_floor.png",
	grow = "WITCHWOOD_TREE",
	nice_tiler = false,
}

newEntity{
	base = "GRASS",
	define_as = "WITCHWOOD_FLOOR2",
	name = "長滿苔蘚的地面",
	image = "terrain/witchwood_floor2.png",
	grow = "WITCHWOOD_TREE",
	nice_tiler = false,
}

-- 門：可走的林間空地（Roomer 的 door 需要一格可走地磚）。
newEntity{
	base = "GRASS",
	define_as = "WITCHWOOD_DOOR",
	name = "林間空地",
	image = "terrain/witchwood_floor.png",
	grow = "WITCHWOOD_TREE",
	nice_tiler = false,
}

-- 樹：扭曲的老樹，當牆用。dig 回地面（TREE 同款語意，forest.lua:62-73）。
newEntity{
	base = "TREE",
	define_as = "WITCHWOOD_TREE",
	name = "扭曲的老樹",
	image = "terrain/witchwood_tree.png",
	dig = "WITCHWOOD_FLOOR",
	nice_tiler = false,
}

newEntity{
	base = "TREE",
	define_as = "WITCHWOOD_TREE2",
	name = "枯死的老樹",
	image = "terrain/witchwood_tree2.png",
	dig = "WITCHWOOD_FLOOR",
	nice_tiler = false,
}

-- 第一層出口：離開女巫森林，回到瑞文谷一帶的大地圖。
-- base 的 change_zone="wilderness" 與 change_level=1 原樣繼承
-- （/data/general/grids/forest.lua:151-160 GRASS_UP_WILDERNESS）。
newEntity{
	base = "GRASS_UP_WILDERNESS",
	define_as = "WITCHWOOD_UP_WILDERNESS",
	name = "離開女巫森林，回到瑞文谷",
	image = "terrain/witchwood_floor.png",
}

-- 層間階梯：往上一層／往下一層（GRASS_UP2 / GRASS_DOWN2 同款，forest.lua:173-181 / :224-232）。
newEntity{
	base = "GRASS_UP2",
	define_as = "WITCHWOOD_UP2",
	name = "往上一層",
	image = "terrain/witchwood_floor.png",
}

newEntity{
	base = "GRASS_DOWN2",
	define_as = "WITCHWOOD_DOWN",
	name = "往下一層",
	image = "terrain/witchwood_floor.png",
}
