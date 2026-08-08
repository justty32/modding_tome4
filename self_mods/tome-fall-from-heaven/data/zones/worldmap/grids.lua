load("/data/zones/wilderness/grids.lua")

local FFH_ASSETS = dofile("/data-fall-from-heaven/ffh/assets.lua")

newEntity{ base = "WATER_BASE_DEEP", define_as = "FFH_OCEAN", name = "Erebus ocean" }
newEntity{ base = "WATER_BASE_DEEP", define_as = "FFH_COAST", name = "Erebus coast" }
newEntity{ base = "PLAINS", define_as = "FFH_GRASS", name = "Erebus grassland" }
newEntity{ base = "PLAINS", define_as = "FFH_PLAINS", name = "Erebus plains" }
newEntity{ base = "DESERT", define_as = "FFH_DESERT", name = "Erebus desert" }
newEntity{ base = "POLAR_CAP", define_as = "FFH_SNOW", name = "Erebus snowfield" }
newEntity{ base = "FROZEN_SEA", define_as = "FFH_ICE", name = "Erebus ice" }
newEntity{ base = "JUNGLE_PLAINS", define_as = "FFH_MARSH", name = "Erebus marsh" }
newEntity{ base = "FOREST", define_as = "FFH_FOREST", name = "Erebus forest" }
newEntity{ base = "JUNGLE_FOREST", define_as = "FFH_JUNGLE", name = "Erebus jungle" }
newEntity{ base = "CHARRED_SCAR", define_as = "FFH_HELL", name = "broken lands" }
newEntity{ base = "CHARRED_SCAR", define_as = "FFH_PERDITION", name = "fields of perdition" }
newEntity{ base = "BURNT_FOREST", define_as = "FFH_BURNT", name = "burnt woods" }
newEntity{ base = "OASIS", define_as = "FFH_OASIS", name = "Erebus oasis" }

newEntity{
    base = "CHARRED_SCAR", define_as = "FFH_CITY",
    name = "Fall from Heaven city",
    display = '*', color = colors.WHITE, back_color = colors.DARK_RED,
    image = "terrain/lava_floor.png",
    add_displays = { mod.class.Grid.new{ image = FFH_ASSETS.icons.city_sheaim, z = 4 } },
    special_minimap = colors.WHITE,
    notice = true, show_tooltip = true, glow = true, nice_tiler = false,
    can_encounter = false,
    change_level = 1,
    change_zone = "fall-from-heaven+city",
}

newEntity{
    base = "PLAINS", define_as = "FFH_START",
    name = "Lanun landing camp",
    display = 'S', color = colors.GOLD, back_color = colors.DARK_GREEN,
    image = "terrain/grass.png",
    add_displays = { mod.class.Grid.new{ image = FFH_ASSETS.icons.landing_camp, z = 4 } },
    special_minimap = colors.GOLD,
    notice = true, show_tooltip = true, glow = true, nice_tiler = false,
    can_encounter = false,
    change_level = 1,
    change_zone = "fall-from-heaven+landing-camp",
}

newEntity{
    base = "CHARRED_SCAR", define_as = "FFH_DUNGEON",
    name = "Fall from Heaven lair",
    display = '>', color = colors.VIOLET, back_color = colors.DARK_GREY,
    image = "terrain/lava_floor.png",
    add_displays = { mod.class.Grid.new{ image = FFH_ASSETS.icons.beast, z = 4 } },
    special_minimap = colors.VIOLET,
    notice = true, show_tooltip = true, glow = true, nice_tiler = false,
    can_encounter = false,
}

newEntity{
    base = "PLAINS", define_as = "FFH_MANA",
    name = "mana node",
    display = 'm', color = colors.LIGHT_BLUE, back_color = colors.DARK_GREEN,
    image = "terrain/grass.png",
    add_displays = { mod.class.Grid.new{ image = FFH_ASSETS.icons.fallen_angel, z = 4 } },
    special_minimap = colors.LIGHT_BLUE,
    notice = true, show_tooltip = true, glow = true, nice_tiler = false,
    can_encounter = false,
}

newEntity{
    base = "PLAINS", define_as = "FFH_TOWER",
    name = "ancient tower",
    display = 'T', color = colors.LIGHT_RED, back_color = colors.DARK_GREEN,
    image = "terrain/grass.png",
    add_displays = { mod.class.Grid.new{ image = FFH_ASSETS.icons.wrath, z = 4 } },
    special_minimap = colors.LIGHT_RED,
    notice = true, show_tooltip = true, glow = true, nice_tiler = false,
    can_encounter = false,
}

newEntity{
    base = "CHARRED_SCAR", define_as = "FFH_RETURN_PORTAL",
    name = "return omen",
    desc = "The shimmer here leads back to Maj'Eyal.",
    display = '<', color = colors.CRIMSON, back_color = colors.DARK_RED,
    image = "terrain/lava_floor.png",
    add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
    special_minimap = colors.CRIMSON,
    notice = true, show_tooltip = true, glow = true,
    nice_tiler = false,
    can_encounter = false,

    change_level = 1,
    change_zone = "wilderness",
    ffh_arrive = { x = 22, y = 17 },

    change_level_check = function(self, who)
        who.ffh_wild_pos = who.ffh_wild_pos or {}
        if game.zone and game.zone.wilderness and game.zone.short_name then
            who.ffh_wild_pos[game.zone.short_name] = { x = who.wild_x, y = who.wild_y }
        end
        local saved = who.ffh_wild_pos[self.change_zone]
        if saved then
            who.wild_x, who.wild_y = saved.x, saved.y
        elseif self.ffh_arrive then
            who.wild_x, who.wild_y = self.ffh_arrive.x, self.ffh_arrive.y
        end
        return false
    end,
}
