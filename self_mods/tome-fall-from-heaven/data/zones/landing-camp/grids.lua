load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")

newEntity{
    define_as = "FFH_CAMP_GROUND",
    type = "floor", subtype = "sand",
    name = "landing ground",
    image = "terrain/sand.png",
    display = '.', color = colors.UMBER, back_color = colors.DARK_UMBER,
}

newEntity{
    define_as = "FFH_CAMP_ROAD",
    type = "floor", subtype = "sand",
    name = "trampled path",
    image = "terrain/sand.png",
    display = '_', color = colors.WHITE, back_color = colors.UMBER,
    special_minimap = colors.UMBER,
}

newEntity{ base = "HARDWALL", define_as = "FFH_CAMP_TENT", name = "canvas tent", image = "terrain/stone_road1.png", display = 't', color = colors.WHITE, back_color = colors.UMBER }
newEntity{ base = "HARDWALL", define_as = "FFH_CAMP_SUPPLIES", name = "stacked supplies", image = "terrain/stone_road1.png", display = 's', color = colors.GOLD, back_color = colors.UMBER }

newEntity{
    define_as = "FFH_UP_WORLDMAP",
    type = "floor", subtype = "sand",
    name = "leave the landing camp",
    image = "terrain/sand.png", add_mos = { { image = "terrain/worldmap.png" } },
    display = '<', color_r = 255, color_g = 0, color_b = 255,
    always_remember = true,
    notice = true,
    change_level = 1,
    change_zone = "fall-from-heaven+worldmap",
}
