return {
    name = "Fall from Heaven skirmish",
    level_range = { 1, 20 },
    level_scheme = "player",
    max_level = 1,
    width = 34, height = 22,
    all_lited = true,
    all_remembered = true,
    persistent = "zone",

    generator = {
        map = {
            class = "engine.generator.map.Static",
            map = "fall-from-heaven+sites/skirmish",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {0, 0},
        },
    },
}
