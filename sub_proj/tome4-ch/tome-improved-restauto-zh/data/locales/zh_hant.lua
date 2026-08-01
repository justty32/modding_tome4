locale "zh_hant"

section "data-improved-restauto/hooks/load.lua"

t("[MARSON] ", "[瑪森] ", "_t")
t("Continue?", "繼續？", "_t")
t("You have a quest member in your party. Are you sure you want to autoexplore?", "你的隊伍裡有任務相關成員，確定要自動探索嗎？", "_t")
t("You have a quest member in your party. Are you sure you want to rest?", "你的隊伍裡有任務相關成員，確定要休息嗎？", "_t")
t([[Determines how auto-explore and running respond to telepathy, including mouse moves. Regardless of the setting, hostiles seen via telepathy will not halt resting or the Rod of Recall, nor trigger automated talents. Unique or powerful monsters will always trigger a stop via telepathy unless #YELLOW#Original#WHITE# is chosen. Hostiles spotted via telepathy are not remembered from session to session..
			
• #YELLOW#Original#WHITE# is standard ToME auto-explore behavior which ignores telepathy when running or auto-exploring.
• #YELLOW#Always Viligant#WHITE# always stops running when a hostile creature is seen via telepathy.]], [[決定自動探索與奔跑如何對心靈感應（包括滑鼠移動）做出反應。無論如何設定，透過心靈感應看見的敵對目標不會中止休息或召回之杖，也不會觸發自動使用技能。除非選擇 #YELLOW#原始#WHITE#，否則透過心靈感應發現獨特或強大怪物時總是會觸發中止。透過心靈感應發現的敵對目標不會跨對局保留..
			
• #YELLOW#原始#WHITE#是標準的 ToME 自動探索行為，在奔跑或自動探索時會忽略心靈感應。
• #YELLOW#時刻警惕#WHITE#在透過心靈感應看見敵對生物時，總是會停止奔跑。]], "_t")
t("#GOLD##{bold}#Auto-explore telepathy#WHITE##{normal}#", "#GOLD##{bold}#自動探索心電感應設定#WHITE##{normal}#", "_t")
t("Original", "原始", "_t")
t("Always Viligant", "時刻警惕", "_t")
t("Auto-explore behavior", "自動探索行為", "_t")
t("Select behavior", "選擇行為", "_t")
t("When resting, determines whether or not to use Heal and Regeneration infusions to speed HP recovery if available.", "休息時，決定是否使用可用的治療與回復注入劑來加速 HP 恢復。", "_t")
t("#GOLD##{bold}#Recover HP when resting with Infusions#WHITE##{normal}#", "#GOLD##{bold}#休息時用注入劑恢復 HP#WHITE##{normal}#", "_t")
t("Enable/Disable Infusions for HP on Rest", "啟用／停用休息時的 HP 注入劑", "_t")
t("When resting, determines whether or not to use Heal and Regeneration infusions to speed Equilibrium recovery if available.", "休息時，決定是否使用可用的治療與回復注入劑來加速失衡值恢復。", "_t")
t("#GOLD##{bold}#Recover Equilibrium when resting with Infusions#WHITE##{normal}#", "#GOLD##{bold}#休息時用注入劑恢復失衡值#WHITE##{normal}#", "_t")
t("Enable/Disable Infusions for Equilibrium on Rest", "啟用／停用休息時的失衡值注入劑", "_t")
t("When resting, determines whether or not to use Mana runes to speed MP recovery if available.", "休息時，決定是否使用可用的法力符文來加速 MP 恢復。", "_t")
t("#GOLD##{bold}#Recover MP when resting with Runes#WHITE##{normal}#", "#GOLD##{bold}#休息時用符文恢復 MP#WHITE##{normal}#", "_t")
t("When resting, determines whether to ignore low damage events and just recover past it.", "休息時，決定是否忽略微量傷害事件，直接恢復下去。", "_t")
t("#GOLD##{bold}#Ignore Small Damage When Resting#WHITE##{normal}#", "#GOLD##{bold}#休息時忽略微量傷害#WHITE##{normal}#", "_t")
t("Enable/Disable Ignoring Small Damage When Resting", "啟用／停用休息時忽略微量傷害", "_t")
t("When auto-exploring, determines whether to ignore low damage events, and keep rushing on.", "自動探索時，決定是否忽略微量傷害事件，繼續向前。", "_t")
t("#GOLD##{bold}#Ignore Small Damage When Running#WHITE##{normal}#", "#GOLD##{bold}#奔跑時忽略微量傷害#WHITE##{normal}#", "_t")
t("Enable/Disable Ignoring Small Damage When Running", "啟用／停用奔跑時忽略微量傷害", "_t")
t("When resting, determines whether or not to use Steam implants to speed steam recovery if available.", "休息時，決定是否使用可用的蒸氣植入裝置來加速蒸氣恢復。", "_t")
t("#GOLD##{bold}#Recover Steam when resting with Implants#WHITE##{normal}#", "#GOLD##{bold}#休息時用植入裝置恢復蒸氣#WHITE##{normal}#", "_t")
t("Enable/Disable Implants for Steam on Rest", "啟用／停用休息時的蒸氣植入裝置", "_t")
t("When resting, trigger stealth if available.", "休息時，若可行則自動觸發潛行。", "_t")
t("#GOLD##{bold}#When resting, trigger stealth if available#WHITE##{normal}#", "#GOLD##{bold}#休息時若可行則自動觸發潛行#WHITE##{normal}#", "_t")
t("Enable/Disable Auto-Stealth while Resting", "啟用／停用休息時自動潛行", "_t")
t("Ignore quest members for auto-exploring and resting.", "自動探索與休息時忽略任務相關隊伍成員。", "_t")
t("#GOLD##{bold}#Ignore quest members for auto-exploring and resting#WHITE##{normal}#", "#GOLD##{bold}#自動探索與休息時忽略任務相關成員#WHITE##{normal}#", "_t")

section "data-improved-restauto/init.lua"

t("Improved Auto-explore and Rest", "改良自動探索與休息", "init.lua long_name")
t([[Quality of Life improvements for resting and auto-exploring.

v3.5.1 *** FOR ToME v1.7.2 ***
This is a fork (with permission) of Marson's auto-explore and rest tweaks.  It includes as well C.Lowe/CaptainTrip's improvements as well.  It does not include, but recommends also using Johnny0's Faster RRE add-on for even better rest and auto-explore experience.  This add-on contains numerous Quality of Life improvements designed to make resting and auto-exploring easier to use, brings the add-on overall up to being compatible with 1.7.x, and generally seeks to remove it being more optimal to do timed rests or manual recovery (particularly to help higher difficulty level and players without Faster RRE).  Cleaned up feature list in this take, to make it easier to see what it does.

It is recommended to turn off Marson's Rest and Auto-Explore as well as C.Lowe's Rest Tweaks if using.  This addon is meant to include all of them.

This mod provides several options to control it.  These may be found by opening the Game Menu->Game Options->Gameplay menu.  Feel free to customize to preference with the defaults meant to be free of questionable behavior.

Latest Update Notes:
• Double checked compatibility with 1.7.2 and added to mod notes how to get to the menu.
• Added an exclusion for track as it plays poorly with auto-use track.

Existing Features:
• removed First Sighting and Reset on Rest.  Someone can patch them in if they'd like it back, but I'm not really keeping them alive.
• Fixed actor bugs causing Elemental Surge to never reset.  Thanks Reca♥den.
• Fixed bug with Paradox Spacetime Tuning from 1.5.5.  This may rebreak posessors with paradox, hard to kinda test. 
• Mostly verified working on 1.6.0
• Compatibility with restart sustains.  Thanks zizzo.
• When resting, it will check for infusions and runes that could be used to accelerate HP, Mana, or Equilibrium (via Ancestral Life or Meditation) recovery.  If the acceleration appears significant, it will use them, rotating from first available infusion or rune outward.  In experiment, I found this often reduced rest turn time by 50-80 percent, improving the more drained the resource was.  Particularly helpful for Mana, as it avoids trade-off advantages of short term resting (for increased mana regen) + rune use by just handling that more optimal play for you automatically without breaking rest. 
• Support for steam implants, with usual checkboxes.  This may not always be faster based on steam sustains that may disable after the initial round of rest and steam implants having very long cooldowns (30+ turns) and steam's resource max being pretty small.  It tries to be conservative on that, so will most likely help for cases where your functional steam regen rate is < 2.00 and never activate for things much above it.  I found I was often getting 5-20 steam per turn, which makes the implant support useless.
• Supports for medical healing salve injectors.  Cooldown measurements are a bit odd here, since they can range from 5-20 depending on injector.  Went with 10 as a happy medium for how many turns of natural regen is considered to be equal to the cooldown cost of using it.
• Adding support to auto-stealth if available and not stealthed.
• Option for ignoring small damage when moving and resting, basically if it is <5%, it will ignore it by default, prevent small DoTs from preventing rest.
• Options added to control whether or not to use inscriptions to accelerate recovery of things. 
• Fixes a ToME bug that can cause autoexplore or running to move only a single square and hang if used immediately after killing an enemy.
• Lore discovery will only stop autoexplore if it triggers a popup.
• Autoexplore will ignore Exploratory/Infinite Farportal return portals until the entire level has been explored.
• Ignores special terrain features such as Font of Healing after they are first discovered.
• Ignores open chests and alt Maze floor cracks.
• Rest and AE ask for confirmation if you have an escort in your party.
• Ignore already activated pedestals.
• Checks for and waits on any rechargeable items.
• Checks for and reloads any ammo in offhand quiver.
• Waits for cooldowns of talents set to auto-use.
• Waits for depleted air to replenish.
• Combines all checks into a single instance of rest, rather than having cooldowns etc. require a second resting phase.

Determines how auto-explore and running respond to telepathy, including mouse moves. Regardless of the setting, hostiles seen via telepathy will not halt resting or the Rod of Recall, nor trigger automated talents. Unique or powerful monsters (rank > 3) will always trigger a halt to running when they are spotted via telepathy for any mode except 'Original'.
			
Available modes:			
• 'Always Viligant' always stops running when a hostile creature is seen via telepathy.
• 'Original' is standard ToME auto-explore behavior, which ignores telepathy when running or auto-exploring.

• Compatible with ToME v1.6.0

Notes:
Folks who have helped with bugfixes over the years:
Reca♥den
St_ranger_er
zizzo

• Telepathy will not prevent auto-exploring the way normal sight will. If a halt is triggered by telepathy, hitting auto-explore again will move you at least one more square in the direction of the auto-explore path. If in 'Always Viligant' mode and a hostile is within telepathic sight (but not normal sight), you will auto-explore in 1 square per keypress increments.]], [[針對休息與自動探索的遊戲體驗（QoL）優化。

v3.5.1 *** 適用於 ToME v1.7.2 ***
本插件是 Marson 的自動探索與休息微調插件的分支版本（已獲授權）。同時也整合了 C.Lowe/CaptainTrip 的優化內容。本插件未包含但推薦搭配 Johnny0 的 Faster RRE 插件，以獲得更好的休息與自動探索體驗。本插件包含多項體驗優化，旨在使休息與自動探索更易於使用，並使插件整體相容於 1.7.x 版本。此外，本插件旨在消除以往進行定時休息或手動回復會更有效率的弊端（特別是為了幫助高難度模式以及未使用 Faster RRE 的玩家）。在此版本中整理了功能列表，以便更清楚地了解其作用。

若有使用 Marson's Rest and Auto-Explore 以及 C.Lowe's Rest Tweaks，建議將其關閉。本插件已包含上述所有功能。

本 Mod 提供多個選項供調整。您可以在 遊戲選單 -> 遊戲選項 -> 遊戲設定（Gameplay）中找到它們。請根據個人偏好進行自訂，預設值已排除任何可能有疑慮的行為。

最新更新說明：
• 重新確認與 1.7.2 的相容性，並在 Mod 說明中新增了進入選單的方法。
• 為「追蹤」（track）新增了排除項，因為它與自動使用追蹤功能搭配得不好。

現有功能：
• 移除了「首次目擊」與「休息時重置」。如果有人想要的話可以自行打包補丁，但我不想維護它們了。
• 修復了導致「元素湧動」（Elemental Surge）無法重置的角色 Bug。感謝 Reca♥den。
• 修復了來自 1.5.5 版本的時空微調（Paradox Spacetime Tuning）Bug。這可能會讓擁有時空值的奪魂者再次出現問題，有點難以測試。
• 大致已確認可在 1.6.0 正常運作。
• 相容於重新啟動維持技能。感謝 zizzo。
• 休息時，會檢查是否能使用紋身或符文來加速生命值、法力或失衡值（透過祖先生命或冥想）的回復。若加速效果顯著，則會輪流使用第一個可用的紋身或符文。經測試，我發現這通常能減少 50-80% 的休息回合，資源消耗得越乾淨，效果越明顯。這對法力特別有幫助，因為它能幫你自動完成最優的操作，而不用打破休息來權衡短期休息（增加法力回復）與符文使用的利益。
• 支援蒸汽植入物，並帶有常用的核取方塊。這並不一定總是更快，因為蒸汽維持技能可能會在第一輪休息後停用，且蒸汽植入物的冷卻時間非常長（30+ 回合），且蒸汽資源上限相當低。本插件對此處理較為保守，因此最有可能在你的實際蒸汽回復率小於 2.00 的情況下提供幫助，而對於遠高於此數值的情況則不會啟用。我發現自己經常每回合獲得 5-20 點蒸汽，這使得植入物支援變得沒有用處。
• 支援醫療治療藥膏注射器。這裡的冷卻時間計算有點奇特，因為根據不同的注射器，冷卻時間在 5-20 回合不等。折中採用了 10 回合，作為自然回復回合數與使用注射器冷卻代價相等的合理平衡點。
• 新增支援：如果可用且尚未潛行，則自動潛行。
• 新增在移動與休息時忽略微量傷害的選項，基本上如果傷害小於 5%，預設會將其忽略，以防止微弱的持續傷害干擾休息。
• 新增控制是否使用刻印來加速回復資源的選項。
• 修復了一個 ToME 的 Bug：在擊殺敵人後立即使用自動探索或奔跑，可能會導致只移動一格便卡住。
• 只有在觸發彈出視窗時，發現歷史文獻才會中止自動探索。
• 自動探索會忽略探險/無限深邃之門的回程傳送門，直到整個層級都探索完畢。
• 在首次發現後，會忽略治療之泉等特殊地形要素。
• 忽略已開啟的寶箱與迷宮的地板裂縫。
• 若隊伍中有護送目標，休息與自動探索會要求確認。
• 忽略已啟動的底座。
• 檢查並等待任何可充能道具冷卻。
• 檢查並裝填副手箭袋中的彈藥。
• 等待設定為自動使用的技能冷卻。
• 等待消耗的空氣回復。
• 將所有檢查整合至單次休息中，而不需要因為技能冷卻等原因而進行第二次休息。

決定自動探索與奔跑如何對心靈感應（包括滑鼠移動）做出反應。無論如何設定，透過心靈感應看見的敵對目標不會中止休息或召回之杖，也不會觸發自動使用技能。除了「原始」模式外，在任何模式下，當心靈感應發現獨特或強大的怪物（階級 > 3）時，總是會中止奔跑。
			
可用模式：			
• 「時刻警惕」在透過心靈感應看見敵對生物時，總是會停止奔跑。
• 「原始」是標準的 ToME 自動探索行為，在奔跑或自動探索時會忽略心靈感應。

• 相容於 ToME v1.6.0

備註：
歷年來協助修復 Bug 的夥伴：
Reca♥den
St_ranger_er
zizzo

• 心靈感應不會像正常視野那樣阻止自動探索。如果因心靈感應觸發中止，再次按下自動探索將使你朝著自動探索路徑的方向至少再移動一格。如果處於「時刻警惕」模式，且敵對目標處於心靈感應視野內（但不在正常視野內），你將以每次按鍵移動 1 格的幅度進行自動探索。]], "init.lua description")

section "data-improved-restauto/overload/mod/class/interface/PlayerExplore.lua"

t("opening door", "開門", "_t")
t("at ", "在 ", "_t")

section "data-improved-restauto/superload/mod/class/Player.lua"

t("no ammo", "無彈藥", "_t")
t("bad ammo", "錯誤彈藥", "_t")
t("bad type", "錯誤類型", "_t")

section "data-improved-restauto/superload/mod/class/interface/PartyLore.lua"

t("[LORE] learnt", "[歷史文獻] 已習得", "_t")

section "salvage-extra"

t("You may not auto-explore this level.", "你不能自動探索這一層", "log")
t("You may not auto-explore with enemies in sight (%s to the %s%s)!", "當有敵人在視野裏時，你不能自動探索！ (%s 在 %s方%s)!", "log")
t("There is nowhere left to explore.", "這一層沒有地方可以探索了。", "log")
t([[Determines how auto-explore and running respond to telepathy, including mouse moves. Regardless of the setting, hostiles seen via telepathy will not halt resting or the Rod of Recall, nor trigger automated talents. Unique or powerful monsters will always trigger a stop via telepathy unless #YELLOW#Original#WHITE# is chosen. Hostiles spotted via telepathy are not remembered from session to session..
			
• #YELLOW#Original#WHITE# is standard ToME auto-explore behavior which ignores telepathy when running or auto-exploring.
• #YELLOW#Always Viligant#WHITE# always stops running when a hostile creature is seen via telepathy.]], [[決定自動探索與奔跑（含滑鼠移動）對心電感應的反應方式。無論設定為何，透過心電感應察覺的敵意生物都不會中斷休息或回城卷軸，也不會觸發自動使用的天賦。除非選擇#YELLOW#Original#WHITE#，否則稀有或強大的怪物一律會透過心電感應觸發停止奔跑。透過心電感應發現的敵人不會在不同場次之間被記住。
			
• #YELLOW#Original#WHITE# 是 ToME 的標準自動探索行為，奔跑或自動探索時會忽略心電感應。
• #YELLOW#Always Viligant#WHITE# 只要透過心電感應偵測到敵意生物，就一律會停止奔跑。]], "_t")
