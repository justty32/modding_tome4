return {
    name = "Lanun landing camp",
    level_range = { 1, 20 },
    level_scheme = "player",
    max_level = 1,
    width = 34, height = 20,
    persistent = "zone",
    all_remembered = true,
    all_lited = true,
    day_night = true,

    generator = {
        map = {
            class = "engine.generator.map.Static",
            map = "fall-from-heaven+sites/landing-camp",
        },
    },
}
