load("/data/general/grids/basic.lua")

newEntity{
    define_as = "FFH_CITY_GROUND",
    type = "floor", subtype = "ash",
    name = "ashen city ground",
    image = "terrain/lava_floor.png",
    display = '.', color = colors.DARK_GREY, back_color = colors.DARK_RED,
}

newEntity{
    define_as = "FFH_CITY_ROAD",
    type = "floor", subtype = "road",
    name = "blackened street",
    image = "terrain/stone_road1.png",
    display = '_', color = colors.GREY, back_color = colors.DARK_GREY,
    special_minimap = colors.DARK_GREY,
}

newEntity{ base = "HARDWALL", define_as = "FFH_CITY_BUILDING", name = "sealed stone house" }
newEntity{ base = "HARDWALL", define_as = "FFH_CITY_PALACE", name = "Sheaim palace" }

newEntity{
    define_as = "FFH_CITY_FIRE",
    type = "floor", subtype = "fire",
    name = "ritual fire",
    image = "terrain/lava_floor.png", add_mos = { { image = "terrain/fire_floor.png" } },
    display = '*', color = colors.LIGHT_RED, back_color = colors.DARK_RED,
    special_minimap = colors.RED,
}

newEntity{
    define_as = "FFH_UP_WORLDMAP",
    type = "floor", subtype = "ash",
    name = "leave the city",
    image = "terrain/lava_floor.png", add_mos = { { image = "terrain/worldmap.png" } },
    display = '<', color_r = 255, color_g = 0, color_b = 255,
    always_remember = true,
    notice = true,
    change_level = 1,
    change_zone = "fall-from-heaven+worldmap",
}
