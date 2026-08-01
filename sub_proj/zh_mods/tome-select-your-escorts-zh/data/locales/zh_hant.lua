locale "zh_hant"

section "data-select-your-escorts/init.lua"

t("Select your Escorts", "選擇你的護送對象", "init.lua long_name")
t([[Allows you to choose which escorts you will encounter at the start of the game.
You may change the future encounters in the game menu (Esc).

There is an option to choose a random escort in case you just wanted to guarantee some unlocks before continuing with the base game's behavior.

Note: You're only supposed to be able to choose the lost tinker once. (Must have the Embers of Rage DLC and unlocked by playing in the Orcs campaign)
Note: Unfortunately the only time that addons can get the possible escort types is after the random escort quest is assigned.
This means escorts added by other addons will not be available for selection, but will still be possible to find using the random selection.
]], [[允許你在遊戲開始時選擇將會遇到哪些護送對象。
你可以在遊戲選單（Esc）中更改未來的遭遇。

若你只是想先確保解鎖某些獎勵，再回到基礎遊戲的隨機行為，也可以選擇隨機護送對象。

注意：迷途工匠每局理應只能選擇一次。（需要 Embers of Rage DLC，且須在獸人戰役中解鎖）
注意：很遺憾，addon 只能在隨機護送任務被分配後取得可能的護送類型。
這代表其他 addon 新增的護送對象不會出現在選擇清單中，但仍可能透過隨機選項遇到。
]], "init.lua description")

section "data-select-your-escorts/hooks/load.lua"

t("Select your Escorts!", "選擇你的護送對象！", "_t")
t("Addon: Select your Escorts (again)", "Addon：再次選擇你的護送對象", "_t")
t("All escorts encountered!", "已遇過所有護送對象！", "_t")
t("[an unknown adventurer (random)]", "[未知的冒險者（隨機）]", "_t")

section "data-select-your-escorts/overload/data/chats/escort-select.lua"

t("#LIGHT_GREEN#*The #YELLOW#", "#LIGHT_GREEN#*你看見的第 #YELLOW#", "tformat")
t("#LIGHT_GREEN# stranger you see appears to be...*#WHITE#", "#LIGHT_GREEN# 位陌生人似乎是...*#WHITE#", "_t")
t([[#LIGHT_GREEN#*You receive a vision of strangers.*
*You have a feeling you will meet them on your adventures.*

#YELLOW#[You may change your future encounters using the game menu (Esc)]
#LIGHT_RED#[The lost tinker may only be encountered once per game]#WHITE#]], [[#LIGHT_GREEN#*你看見了一群陌生人的幻象。*
*你感覺自己會在冒險途中遇見他們。*

#YELLOW#[你可以透過遊戲選單（Esc）更改未來的遭遇]
#LIGHT_RED#[迷途工匠每局只能遇到一次]#WHITE#]], "_t")
t("[ok]", "[確定]", "_t")
t("[all random]", "[全部隨機]", "_t")
t("All escorts selected! Good luck!", "所有護送對象已選定！祝你好運！", "_t")

section "data-select-your-escorts/overload/data/chats/escorts-already-encountered.lua"

t("#LIGHT_RED#You have already encountered all nine escorts!#WHITE#", "#LIGHT_RED#你已經遇過全部九名護送對象！#WHITE#", "_t")
