-- Parsed from Fall from Heaven II: Assets/XML/Scenarios/The Black Tower.CivBeyondSwordWBSave.
-- Civ4 plot coordinates are preserved as civ_x/civ_y; map_x/map_y are the ToME static map coordinates.

return {
    scenario = "The Black Tower",
    width = 84,
    height = 52,

    factions = {
        [0] = { type = "CIVILIZATION_LANUN", leader = "Falamar", playable = true },
        [1] = { type = "CIVILIZATION_SHEAIM", leader = "Tebryn Arbandi", playable = false },
        [2] = { type = "CIVILIZATION_SHEAIM", leader = "Averax", playable = false },
        [3] = { type = "CIVILIZATION_SHEAIM", leader = "Gosea", playable = false },
        [4] = { type = "CIVILIZATION_SHEAIM", leader = "Malchavic", playable = false },
        [5] = { type = "CIVILIZATION_INFERNAL", leader = "Hyborem", playable = false },
        [6] = { type = "CIVILIZATION_CLAN_OF_EMBERS", leader = "Jonas Endain", playable = false },
    },

    cities = {
        { id = "steinvik", name = "Steinvik", key = "TXT_KEY_CITY_SHEAIM_5", owner = 5, civ_x = 25, civ_y = 24, map_x = 25, map_y = 27, population = 1, palace = "BUILDING_PALACE_SHEAIM" },
        { id = "graelingvig", name = "Graelingvig", key = "TXT_KEY_CITY_SHEAIM_4", owner = 4, civ_x = 30, civ_y = 40, map_x = 30, map_y = 11, population = 1, palace = "BUILDING_PALACE_SHEAIM" },
        { id = "grottiburg", name = "Grottiburg", key = "TXT_KEY_CITY_SHEAIM_2", owner = 2, civ_x = 37, civ_y = 15, map_x = 37, map_y = 36, population = 1, palace = "BUILDING_PALACE_SHEAIM" },
        { id = "vargstad", name = "Vargstad", key = "TXT_KEY_CITY_SHEAIM_7", owner = 1, civ_x = 44, civ_y = 23, map_x = 44, map_y = 28, population = 1 },
        { id = "galveholm", name = "Galveholm", key = "TXT_KEY_CITY_SHEAIM_1", owner = 1, civ_x = 47, civ_y = 28, map_x = 47, map_y = 23, population = 1, palace = "BUILDING_PALACE_SHEAIM", notable_units = { "UNIT_ABASHI" } },
        { id = "kuldevind", name = "Kuldevind", key = "TXT_KEY_CITY_SHEAIM_6", owner = 1, civ_x = 49, civ_y = 24, map_x = 49, map_y = 27, population = 1 },
        { id = "tongurstad", name = "Tongurstad", key = "TXT_KEY_CITY_SHEAIM_3", owner = 3, civ_x = 59, civ_y = 31, map_x = 59, map_y = 20, population = 1, palace = "BUILDING_PALACE_SHEAIM" },
        { id = "braduk", name = "Braduk the Burning", key = "TXT_KEY_CITY_CLAN_OF_EMBERS_1", owner = 6, civ_x = 74, civ_y = 5, map_x = 74, map_y = 46, population = 1, palace = "BUILDING_PALACE_CLAN_OF_EMBERS" },
        { id = "renegade_hill", name = "Renegade Hill", key = "TXT_KEY_CITY_CLAN_OF_EMBERS_2", owner = 6, civ_x = 79, civ_y = 10, map_x = 79, map_y = 41, population = 1 },
    },

    starts = {
        { id = "lanun_landing", name = "Lanun landing camp", owner = 0, civ_x = 77, civ_y = 37, map_x = 77, map_y = 14, units = { "UNIT_GALLEON", "UNIT_ARCHER", "UNIT_WORKER", "UNIT_SUPPLIES", "UNIT_SETTLER" } },
    },
}
