load("/data/general/grids/basic.lua")

newEntity{
    define_as = "FFH_SKIRMISH_ASH",
    type = "floor", subtype = "ash",
    name = "ashen field",
    image = "terrain/lava_floor.png",
    display = '.', color = colors.DARK_GREY, back_color = colors.DARK_RED,
}

newEntity{
    define_as = "FFH_SKIRMISH_RUIN",
    type = "wall", subtype = "ruin",
    name = "broken basalt wall",
    image = "terrain/granite_wall1.png",
    display = '#', color = colors.SLATE,
    always_remember = true,
    does_block_move = true,
    block_move = true,
    block_sight = true,
}

newEntity{
    define_as = "FFH_SKIRMISH_FIRE",
    type = "floor", subtype = "fire",
    name = "hellfire scar",
    image = "terrain/lava_floor.png", add_mos = { { image = "terrain/fire_floor.png" } },
    display = '*', color = colors.LIGHT_RED, back_color = colors.DARK_RED,
    special_minimap = colors.RED,
}

newEntity{
    define_as = "FFH_SKIRMISH_UP_WORLDMAP",
    type = "floor", subtype = "ash",
    name = "return to the Black Tower",
    image = "terrain/lava_floor.png", add_mos = { { image = "terrain/worldmap.png" } },
    display = '<', color_r = 255, color_g = 0, color_b = 255,
    always_remember = true,
    notice = true,
    change_level = 1,
    change_zone = "fall-from-heaven+worldmap",
    change_level_check = function()
        return dofile("/data-fall-from-heaven/ffh/skirmish.lua").retreat()
    end,
}
