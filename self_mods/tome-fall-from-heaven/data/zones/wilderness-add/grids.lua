newEntity{
    base = "PLAINS",
    define_as = "FFH_EYAL_PORTAL",
    name = "black tower omen",
    desc = "A scorched ring of stones. Past its heat-shimmer lies an Erebus map from Fall from Heaven.",
    display = '&', color = colors.CRIMSON, back_color = colors.DARK_GREEN,
    image = "terrain/grass.png",
    add_displays = { mod.class.Grid.new{ image = "terrain/maze_teleport.png" } },
    special_minimap = colors.CRIMSON,
    notice = true, show_tooltip = true, glow = true,
    nice_tiler = false,
    can_encounter = false,

    change_level = 1,
    change_zone = "fall-from-heaven+worldmap",
    ffh_arrive = { x = 44, y = 23 },

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
