-- 巴別塔市集的商店定義。
--
-- 商店實體定義（含 store 欄位）登錄進 mod.class.Store 的 stores_def 全域清單，
-- 由 hooks/load.lua 在 ToME:load 時用 Store:loadStores 載入——原版同款機制：
-- mod/load.lua:242 對 /data/general/stores/basic.lua 做的事。addon 的 data/ 是私有
-- 掛載點不會被自動掃到，必須自己補一次。
--
-- 三個店種：
--   ORARIO_WEAPON    武具行——巴別塔冒險者各系武器（含彈藥）
--   ORARIO_SUPPLIES  雜貨——藥水/符文銘刻、光源、掘地工具
--   ORARIO_MATERIAL  鍛造與附魔材料——寶石（ToME 的附魔/鍛造材料，見 crafting-and-imbue.md）
--
-- 進貨清單全部是「冒險者用得到」的原版物種（filter 語法照抄 basic.lua 的
-- tome_drops="store" 慣例），player_material_level=true 讓貨品材料等級隨玩家成長。

newEntity{
	define_as = "ORARIO_WEAPON",
	name = "巴別塔武具行",
	display = '3', color = colors.UMBER,
	store = {
		purse = 50,
		empty_before_restock = false,
		nb_fill = 4,
		player_material_level = true,
		filters = {
			{type="weapon", subtype="longsword", id=true, tome_drops="store"},
			{type="weapon", subtype="greatsword", id=true, tome_drops="store"},
			{type="weapon", subtype="dagger", id=true, tome_drops="store"},
			{type="weapon", subtype="mace", id=true, tome_drops="store"},
			{type="weapon", subtype="waraxe", id=true, tome_drops="store"},
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="weapon", subtype="mindstar", id=true, tome_drops="store"},
			{type="weapon", subtype="longbow", id=true, tome_drops="store"},
			{type="weapon", subtype="sling", id=true, tome_drops="store"},
			{type="ammo", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ORARIO_SUPPLIES",
	name = "冒險者的雜貨",
	display = '4', color = colors.LIGHT_BLUE,
	store = {
		purse = 20,
		empty_before_restock = false,
		nb_fill = 4,
		player_material_level = true,
		filters = {
			{type="scroll", subtype="infusion", id=true, ego_chance=1000},
			{type="scroll", subtype="rune", id=true, ego_chance=1000},
			{type="lite", id=true, tome_drops="store"},
			{type="tool", subtype="digger", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ORARIO_MATERIAL",
	name = "鍛造與附魔材料行",
	display = '9', color = colors.BLUE,
	store = {
		purse = 30,
		empty_before_restock = false,
		nb_fill = 4,
		player_material_level = true,
		filters = {
			{type="gem", id=true},
		},
	},
}
