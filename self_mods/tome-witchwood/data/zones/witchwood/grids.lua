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
--
-- ── 兩張樹貼圖的來歷（2026-08-01 換過一次，別再走回頭路）──────────────────────
-- 初版是 AI 生圖後自己 key 掉背景的，實機一看滿佈亮洋紅色斑點——使用者的原話是
-- 「樹沒有去背」。病因是 `magick -fuzz N% -transparent` 這條路產出的是 **1-bit alpha**：
-- 邊緣只有全透明／全不透明兩種，鋸齒之外還留下一圈沒被 key 到的洋紅殘邊；
-- fuzz 開大一點又會把跟背景同色的樹幹一起鑿穿（tree2 的樹幹整片變蜂窩）。
-- **alpha 資訊已經毀了，重新 key 救不回來。**
--
-- 現在改成從原版美術資產衍生——那些檔案本來就有乾淨的 8-bit alpha 與抗鋸齒：
--   witchwood_tree.png  ← shockbolt/terrain/swamptree2.png       （垂枝、露根，最有女巫味）
--   witchwood_tree2.png ← shockbolt/terrain/tree_dark_alpha3.png （圓冠，做變化）
-- 兩張都套同一組色調位移做成詛咒紫：
--   magick <src> -modulate 95,140,212 -define png:color-type=6 <dst>
-- （`-modulate B,S,H`，H=100 不變、每 +1% 約 +1.8 度。212 → 約 +200 度，
--   綠葉轉紫。實測 189 會變藍、236 會變洋紅，212 是要的那個。）
--
-- ⚠️ `-define png:color-type=6` 不能省：省了會存成索引色（PaletteAlpha），
--    引擎會噴 truecolor 警告。
-- ⚠️ 要換造型就換 src 檔名重跑同一條指令，**不要**再回去生圖 + fuzz key。
--    原版 terrain/ 底下有 485 張樹可挑（tree_dark_alpha1-5 / swamptree1-3 / redtree* …）。
--
-- ── ★ 為什麼 image 是地面、樹在 add_mos ────────────────────────────────────────
-- **一格只畫一個 TERRAIN 實體，引擎不會自動幫你在底下鋪地面。**
-- 把樹直接寫在 `image` 的話，樹的透明處露出來的是黑底，不是林地——
-- 2026-08-01 實機回報「樹應該和地面 tile 重疊，目前似乎只 render tree」就是這個。
--
-- 原版所有「地面上的東西」都是同一個寫法：`image` 放**地面**，特徵疊在 `add_mos`。
--   /data/general/grids/forest.lua:153  image="terrain/grass.png", add_mos={{image="terrain/worldmap.png"}}
--   同檔 :76                            makeNewTrees({... image="terrain/grass.png"}, treesdef)
-- （`add_mos` 的元素是 `{image=, display_x=, display_y=, display_w=, display_h=}`，
--   合成在同一個 map object 上，見 M/mod/class/Grid.lua:248-290 的 makeNewTrees。）
--
-- 這也解釋了為什麼本檔下面那三個階梯只覆寫 `image` 就沒問題：
-- 它們的 base（GRASS_UP2 / GRASS_DOWN2 / GRASS_UP_WILDERNESS）把箭頭放在 `add_mos` 裡，
-- 我們換掉 `image` 只是換掉腳下的地面，箭頭原樣繼承。
newEntity{
	base = "TREE",
	define_as = "WITCHWOOD_TREE",
	name = "扭曲的老樹",
	image = "terrain/witchwood_floor.png",
	add_mos = {{ image = "terrain/witchwood_tree.png" }},
	dig = "WITCHWOOD_FLOOR",
	nice_tiler = false,
}

newEntity{
	base = "TREE",
	define_as = "WITCHWOOD_TREE2",
	name = "枯死的老樹",
	image = "terrain/witchwood_floor.png",
	add_mos = {{ image = "terrain/witchwood_tree2.png" }},
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
