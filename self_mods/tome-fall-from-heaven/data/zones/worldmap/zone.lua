return {
    name = "Erebus: The Black Tower",
    level_range = { 1, 50 },
    level_scheme = "player",
    max_level = 1,

    width = 84, height = 52,

    all_lited = true,
    persistent = "zone",
    wilderness = true,
    wilderness_see_radius = 4,

    generator = {
        map = {
            class = "engine.generator.map.Static",
            map = "fall-from-heaven+worldmap",
        },
    },
}
