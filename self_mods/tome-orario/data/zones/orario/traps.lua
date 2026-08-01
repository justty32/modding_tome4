-- 巴別塔市集（中央廣場頂排中間建築的門面）——三個商店入口。
-- 手法抄 town-derth/traps.lua：商店是「陷阱層」實體（defineTile 第 5 參，見
-- data/maps/orario.lua 的 '1'/'2'/'3'），玩家朝門面牆按方向鍵就開店
-- （mod/class/Player.lua:315-318 的 is_store 檢查 + resolvers.calc.store 的 block_move）。
load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "ORARIO_WEAPON_STORE",
	name = "巴別塔武具行",
	display = '1', color = colors.UMBER,
	resolvers.store("ORARIO_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_swordsmith.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ORARIO_SUPPLIES_STORE",
	name = "冒險者的雜貨",
	display = '2', color = colors.LIGHT_BLUE,
	resolvers.store("ORARIO_SUPPLIES", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_utility_store.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ORARIO_MATERIAL_STORE",
	name = "鍛造與附魔材料行",
	display = '3', color = colors.BLUE,
	resolvers.store("ORARIO_MATERIAL", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_alchemist.png"),
}
