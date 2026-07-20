locale "zh_hant"
------------------------------------------------
section "data-possessors/achievements/possessors.lua"

t("Bill Kill!", "比爾殺死！", "achievement name")
t("Kill your own Doomed Shade in the body of Bill.", "使用比爾的身體殺死你的影子。", "_t")
t("Unneshasshhary Kryl'ty", "相愛相殺", "achievement name")
t("Kill Kryl'Feijan with the body of Shasshhiy'Kaish, or vice-versa.", "使用卡洛·斐濟的身體殺死莎西·凱希，或者使用莎西·凱希的身體殺死卡洛·斐濟。", "_t")
t("Unneshasshhary Kryl'ty (Redux)", "相愛相殺（重複）", "achievement name")
t("Kill High Paladin Aeryn with the body of Sun Paladin John.", "使用太陽騎士約翰的身體殺死太陽騎士艾琳。", "_t")

------------------------------------------------
section "data-possessors/data/birth/psionic.lua"

t("Possessor", "支配者", "birth descriptor name")
t("#CRIMSON#BEWARE: This class is very #{italic}#strange#{normal}# and may be confusing to play for beginners.#LAST#", "#CRIMSON#注意: 該職業機制相當 #{italic}#奇怪#{normal}# ，可能不適合新手使用。#LAST#", "_t")
t("Possessors are a rare breed of psionics. Some call them body snatchers. Some call them nightmarish.", "支配者是一類極其稀有的靈能力者。有些人稱其爲身體掠奪者，有些人視其爲噩夢。", "_t")
t("They are adept at stealing their foes corpses for their own use. Discarding their own bodies for a while to use other's.", "他們擅長偷取敵人死亡後的身體，能暫時拋棄自己的軀體，使用其他身體。", "_t")
t("Their most important stats are: Willpower and Cunning", "他們最重要的屬性是：意志和靈巧。", "_t")
t("#GOLD#Stat modifiers:", "#GOLD# 屬性修正：", "_t")
t("#LIGHT_BLUE# * +2 Strength, +2 Dexterity, +0 Constitution", "#LIGHT_BLUE# * +2 力量 , +2 敏捷 , +0 體質", "_t")
t("#LIGHT_BLUE# * +0 Magic, +3 Willpower, +2 Cunning", "#LIGHT_BLUE# * +0 魔法 , +3 意志 , +2 靈巧", "_t")
t("#GOLD#Life per level:#LIGHT_BLUE# -4", "#GOLD# 每等級生命加值： #LIGHT_BLUE# -4", "_t")

------------------------------------------------
section "data-possessors/data/talents/psionic/battle-psionics.lua"

t("You are disarmed.", "你被繳械了。", "logPlayer")
t("You require a mainhand weapon and an offhand mindstar to use this talent.", "你需要主手武器副手靈晶才能使用這一技能。", "logPlayer")
t("Psionic Disruption", "靈能瓦解", "talent name")
t([[You imbue your offhand mindstar with wild psionic forces.
		While active you gain %d%% more of your mindstar's mindpower and mind critical chance.
		Each time you make a melee attack you also add a stack of Psionic Disruption to your target.
		Each stack lasts for %d turns and deals %0.2f mind damage over the duration (max %d stacks).
		If you do not have a one handed weapon and a mindstar equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[向副手靈晶灌注狂暴的靈能力量。
		生效時，靈晶的精神強度和精神暴擊機率增加 %d%% 。
		每次攻擊，都會給目標附加 1 層靈能瓦解效果。
		每層效果持續 %d 回合造成 %0.2f 精神傷害 (最多 %d 層).
		如果你沒有裝備單手武器和靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Shockstar", "震撼之星", "talent name")
t([[You make a first attack with your mainhand for %d%% weapon damage.
		If the attack hits the target is distracted and you use that to violently slam your mindstar into it, dealing %d%% damage.
		The shock is so powerful the target is stunned for %d turns and all creatures around in radius %d are dazed for the same time.
		The stun and daze duration is dependant on the number of psionic disruption charges on the target, the given number is for 4 charges.
		If you do not have a one handed weapon and a mindstar equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[用主手武器造成 %d%% 武器傷害。
		如果命中目標立刻用靈晶攻擊目標造成 %d%% 傷害。
		震懾目標 %d 回合且半徑 %d 範圍內的生物眩暈同樣的回合。
		靈能瓦解層數決定震懾和眩暈的持續時間，已給出的數據是靈能瓦解 4 層的情況下。
		如果你沒有裝備單手武器和靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Dazzling Lights", "炫目之光", "talent name")
t([[Raising your mindstar in the air you channel a bright flash of light through it. Any creatures in radius %d is blinded for %d turns.
		If any foe in melee range is blinded by the effect you quickly use that to your advantage by striking them with a blow of your main hand weapon doing %d%% damage.
		If you do not have a one handed weapon and a mindstar equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[舉起靈晶，致盲半徑 %d 內的生物 %d 回合。
		在近戰範圍內的敵人被此效果致盲，立刻用主手武器造成 %d%% 傷害。
		如果你沒有裝備單手武器和靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Psionic Block", "靈能格擋", "talent name")
t([[You concentrate to create a psionic block field all around you for 5 turns.
		While the effect holds all damage against you have a %d%% chance to be fully ignored.
		When damage is cancelled you instinctively make a retaliation mind strike against the source, dealing %0.2f mind damage. (The retaliation may only happen 2 times per turn.)
		]], [[創造一個持續 5 回合的靈能盾牌圍繞你。
		技能生效時有 %d%% 機率會無視傷害。
		如果傷害被無視，你會對目標進行反擊，造成 %0.2f 精神傷害。(每回合最多 2 次 )
		]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/body-snatcher.lua"

t("Bodies Reserve", "軀體儲備", "talent name")
t([[Your mind is so powerful it can bend reality, providing you with an extra-natural #{italic}#storage#{normal}# for bodies you snatch.
		You can store up to %d bodies.]], [[你的頭腦是如此強大，它可以扭曲現實，爲你提供一個非自然的 #{italic}#倉庫#{normal}# 讓你儲存搶奪過來的身體。
		倉庫容量增加 %d 。]], "tformat")
t("Psionic Minion", "靈能奴役", "talent name")
t("Not enough space to invoke your minion!", "沒有足夠空間召喚隨從！", "logPlayer")
t("%s (Psionic Minion)", "%s (靈能僕從)", "tformat")
t([[You imbue a part of your own mind into a body without actually taking its form.
		The body will work as your minion for %d turns.
		Psionic minions can not heal in any way.
		When the effect ends the body is permanently lost.]], [[你將自己的心靈的一部分融入一個身體，而不需要完全佔據它的身體。
		身體會作爲你的僕從工作 %d 回合。
		靈能僕從無法被任何方法治療。
		當效果結束時，身體永久丟失。]], "tformat")
t("Psionic Duplication", "靈能複製", "talent name")
t([[When you store a body you also store %d more identical copies of it that you can use later.
		When you store a rare/unique/boss or higher rank creature you only get a third of the uses (but never less than one).]], [[當你獲得一個身體時複製 %d 個克隆體.
		當你獲得稀有/史詩/Boss 或者更高階級的身體時，複製的數量除以 3 (至少一個)。]], "tformat")
t("Cannibalize", "合併", "talent name")
t("You require need to assume a form first.", "你需要現在佔據一個身體。", "logPlayer")
t("Rank of body too low.", "這個身體的階級太低。", "logPlayer")
t([[When you assume a form you may cannibalize a body in your reserve to replenish your current body.
		You can only use bodies that are of same or higher rank for the effect to work and each time you heal a body the effect will be reduced by 33%% for that body.
		Your current body will heal for %d%% of the max life of the cannibalized one and you will also regenerate 50%% of this value as psi.
		The healing effect is more psionic in nature than a real heal. As such may things that prevent healing will not prevent cannibalize from working.
		Cannibalize is the only possible way to heal a body.
		]], [[合併一個身體，用來補充現在使用的身體。
		你只能合併同階級或者更高階級的身體且每次治療效果降低 33%% 。
		生命值恢復被合併的身體的最大血量 %d%% 且你的靈能值恢復這個數值的 50%% 。
		該治療不會被其他效果減低，合併是治療身體的唯一方法。
		]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/deep-horror.lua"

t("Mind Steal", "精神竊取", "talent name")
t("%s resists the mind steal!", "%s抵制了精神竊取！", "logSeen")
t("%s has no stealable talents.", "%s沒有可以竊取的技能。", "logPlayer")
t("Mind Steal", "精神竊取", "_t")
t("Choose a talent to steal:", "選擇要竊取的技能：", "_t")
t([[Your mere presence is a blight in your foes minds. Using this link you are able to reach out and steal a talent from a target.
		For %d turns you will be able to use a random active (not passive, not sustained) talent from your target, and they will loose it.
		You may not steal a talent which you already know.
		The stolen talent will not use any resources to activate.
		At level 5 you are able to choose which talent to steal.
		The talent stolen will be limited to at most level %d.]], [[鏈接目標，偷取目標一個技能。
		持續 %d 回合，你獲得目標一個隨機主動技能 (非被動，非持續) ，目標會失去該技能。
		你不會偷取一個已有的技能。
		偷取的技能不消耗任何能量。
		在等級 5 時，可選擇偷取的技能。
		偷取的技能等級被限制成最高爲 %d 級。]], "tformat")
t("Spectral Dash", "光譜衝鋒", "talent name")
t([[For a brief moment your whole body becomes etheral and you dash into a nearby creature and all those in straight line behind it (in range %d).
		You reappear on the other side, with %d more psi and having dealt %0.2f mind damage to your targets.
		]], [[短暫的一瞬間，你的整個身體變得飄渺，你對附近一個生物進行一次直線衝鋒 (範圍 %d )。
		你再次出現在另一邊，獲得 %d 靈能值並對目標造成 %0.2f 精神傷害。
		]], "tformat")
t("Writhing Psionic Mass", "扭曲裝甲", "talent name")
t([[Your physical form is but a mere extension of your mind, you can bend it at will for %d turns.
		While under the effect you gain %d%% all resistances and have %d%% chance to ignore all critical hits.
		On activation you also remove up to %d physical or mental effects.
		]], [[你的身體形態只不過是你心靈的延伸，你可以隨意扭曲它 %d 回合。
		效果生效時，你全部抗性提升 %d%% 並有 %d%% 機率避免被暴擊。
		激活時，你最多可以移除 %d 個物理或者精神效果。
		]], "tformat")
t("Ominous Form", "不祥軀體", "talent name")
t("You are already assuming a form.", "你已經佔據了一個軀體", "logPlayer")
t("%s resists your attack!", "%s抵抗了你的攻擊！", "logPlayer")
t([[Your psionic powers have no limits. You are now able to assault a target and clone its body without killing it.
		The form is only temporary, lasting %d turns and subject to the same restrictions as your normal powers.
		While using a stolen form your health is bound to your target. (Your life%% will always be identical to your target's life%%)
		]], [[你的靈能力量沒有限制。你現在能夠攻擊一個目標，克隆它的身體，且不需要殺死它。
		身體只是暫時的，持續 %d 回合並受到你正常力量的限制。
		使用竊取的身體時，你的生命值%%永遠與目標的生命值%%相同。
		]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/possession.lua"

t("Possession Talent %d", "支配技能%d", "tformat")
t("You must assume a form to use that form's talents.", "你必須佔據一個身體才能使用這個身體的技能。", "logPlayer")
t([[When you assume a form, this talent will be replaced with one of the body's talents.
			The only use for this talent is to pre-organize your hotkeys bar.]], [[附身時，該技能會被替換成身體的其中一個技能。
			該技能的唯一用法是放在熱鍵欄上。]], "tformat")
t("none", "沒有", "_t")
t("\
%s%s%d)%s#LAST# (#LIGHT_BLUE#lv %d#LAST#, #LIGHT_RED#HP:%d/%d#LAST#)", "\
%s%s%d)%s#LAST# (#LIGHT_BLUE#等級 %d#LAST#, #LIGHT_RED#生命值:%d/%d#LAST#)", "tformat")
t("Destroy Body", "摧毀身體", "talent name")
t("You have no stored bodies to delete.", "你沒有存儲的身體，無需刪除。", "logPlayer")
t([[Discard a body from your psionic reserve.
		Bodies possessed:
		%s]], [[從你的靈能倉庫中丟棄身體。
		擁有的身體 :
		%s]], "tformat")
t("Assume Form", "附身", "talent name")
t("You have no stored bodies to use.", "你沒有可以用於附身的身體。", "logPlayer")
t("#CRIMSON#A strange feeling comes over you as two words imprint themselves on your mind: '#{italic}#Not yet.#{normal}#'", "#CRIMSON#一種奇怪的感覺油然而生，印在你的腦海裏時: '#{italic}#不是現在。#{normal}#'", "logPlayer")
t([[You call upon one of your reserve bodies, assuming its form.
		A body used this way may not be healed in any way.
		You can choose to exit the body at any moment by using this talent again, returning it to your reserve as it is.
		When you reach 0 life you are forced out of it and the shock deals %d%% of the maximum life of your normal body to you while reducing your movement speed by 50%% and your damage by 60%% for 6 turns.
		The cooldown only starts when you resume your normal form.
		While in another body all experience you gain still goes to you but will not be applied until you revert back.
		While in another body your currently equiped objects are #{italic}#merged#{normal}# in you, you can not take them of or wear new ones.
		Bodies possessed:
		%s]], [[選擇一個身體，附身。
		以這種方式使用的身體不會以任何方式被治癒。
		你可以隨時通過再次使用這個技能來選擇退出身體，將其原樣恢復到你的儲備中。
		當生命爲 0 時你會被迫離開身體，衝擊對你造成相當於正常身體最大血量 %d%% 的傷害，並在 6 回合內降低 50%% 移動速度和 60%% 傷害。
		技能冷卻僅在恢復正常形式時才開始計算。
		附身時仍會持續獲得經驗，但不會生效，直到你回到自己的身體。
		附身時你現有的裝備會#{italic}#合併#{normal}#到你身上，你無法脫下或更換新裝備。
		擁有的身體 :
		%s]], "tformat")
t("Possess", "支配", "talent name")
t("You do not have enough room in your bodies storage.", "你的身體存儲空間不夠。", "logPlayer")
t("This creature is immune to possession.", "這個生物免疫附身。", "logPlayer")
t("You may not possess a creature which you summoned.", "你不能附身你自己召喚的生物。", "logPlayer")
t("You may not possess a creature which has an expiration time or a master.", "你不能附身有時間限制或者主人的生物。", "logPlayer")
t("You may not possess a creature of this rank (%s%s#LAST#).", "你不能附身這個階級的生物(%s%s#LAST#).", "logPlayer")
t("Possess", "支配", "_t")
t("Permanently learn to possess creatures of type #LIGHT_BLUE#%s#LAST# (you may only do that a few times, based on talent level) ?", "確認要永久性地學習佔據#LIGHT_BLUE#%s#LAST#身體的能力嗎（你只能學習有限次，基於技能等級）？", "tformat")
t("No", "否", "_t")
t("Yes", "是", "_t")
t("You may not possess this kind of creature.", "你不能附身這類生物。", "logPlayer")
t("You have no more room available to store a new body.", "你沒有足夠的位置來存放新的身體。", "logPlayer")
t("Your target is dead!", "你的目標死了！", "logPlayer")
t([[You cast a psionic web at a target that lasts for %d turns. Each turn it deals %0.2f mind damage.
		If the target dies with the web in place you will capture its body and store it in a hidden psionic reserve.
		At any further time you can use the Assume Form talent to temporarily shed your own body and assume your new form, strengths and weaknesses both.
		You may only use this power if you have room for a new body in your storage.

		You may only steal the body of creatures of the following rank %s%s#LAST# or lower.
		At level 3 up to rank %s%s#LAST#.
		At level 5 up to rank %s%s#LAST#.
		At level 7 up to rank %s%s#LAST#.

		You may only steal the body of creatures of the following types: #LIGHT_BLUE#%s#LAST#
		When you try to possess a creature of a different type you may learn this type permanently, you can do that %d more times.]], [[你對目標投擲一個持續 %d 回合的靈能網。每回合造成 %0.2f 精神傷害。
		如果目標在持續時間內死亡，你會獲得它的身體並放入你的靈能倉庫中。
		在任何時候，你可以使用附身技能暫時脫離你的身體進入新的身體，繼承其優勢和弱點。
		靈能倉庫有位置時才能使用該技能。

		你可以偷取以下階級生物的身體 %s%s#LAST# 或者更低。
		等級 3 時最多可偷取 %s%s#LAST#.
		等級 5 時最多可偷取 %s%s#LAST#.
		等級 7 時最多可偷取 %s%s#LAST#.

		你可能只會偷走以下類型的生物的屍體 : #LIGHT_BLUE#%s#LAST#
		當你嘗試擁有不同類型的生物時，你可以永久學習此類型，你還可以執行 %d 次。]], "tformat")
t("Self Persistence", "自我堅持", "talent name")
t("When you assume the form of an other body you can still keep %d%% of the values (defences, crits, powers, save, ...) of your own body.", "當你附身時，你還可以保留自己身體的屬性 %d%% 。 (閃避, 暴擊, 強度, 豁免, ……)", "tformat")
t("Improved Form", "身體改進", "talent name")
t([[When you assume the form of another body you gain %d%% of the values (defences, crits, powers, save, ...) of the body.
		In addition talents gained from bodies are limited to level %0.1f.]], [[當你附身時，你獲得身體 %d%% 的數值 (閃避, 暴擊, 強度, 豁免, ...)。
		此外，從身體獲得的技能等級最高爲 %0.1f。]], "tformat")
t("Full Control", "完全控制", "talent name")
t([[When you assume the form of an other body you gain more control over the body:
		- at level 1 you gain one more talent slot
		- at level 2 you gain one more talent slot
		- at level 3 you gain resistances and flat resistances
		- at level 4 you gain one more talent slot
		- at level 5 you gain all speeds (only if they are superior to yours)
		- at level 6+ you gain one more talent slot
		]], [[附身時，可更好的控制身體 :
		- 在等級 1 時，可額外獲得一個技能位
		- 在等級 2 時，可額外獲得一個技能位
		- 在等級 3 時，可獲得抗性和固定減傷
		- 在等級 4 時，可額外獲得一個技能位
		- 在等級 5 時，可獲得得所有速度（只有當他們優於你時）
		- 在等級 6 以上時，可額外獲得一個技能位
		]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/psionic-menace.lua"

t("You are disarmed.", "你被繳械了。", "logPlayer")
t("You require two mindstars to use this talent.", "你需要雙持靈晶才能使用這一技能。", "logPlayer")
t("Mind Whip", "心靈鞭打", "talent name")
t([[You lash out your psionic fury at a distant creature, doing %0.2f mind damage.
		The whip can cleave to one nearby foe.
		If you do not have two mindstars equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[對一個生物釋放你的靈能怒氣造成 %0.2f 精神傷害。
		鞭子可同時對目標身邊的一個敵人造成傷害。
		如果你沒有雙持靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Psychic Wipe", "精神鞭打", "talent name")
t([[You project ethereal fingers inside the target's brain.
		Over %d turns it will take %0.2f total mind damage and have its mental save reduced by %d.
		This powerful effect uses 130%% of your Mindpower to try to overcome your target's initial mental save.
		If you do not have two mindstars equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[你在目標腦中投射空靈的手指。
		持續 %d 回合總共造成 %0.2f 精神傷害並減少 %d 精神豁免。
		這個強大的效果嘗試使用 130%% 你的精神強度去對抗目標的精神豁免。
		如果你沒有雙持靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Ghastly Wail", "恐怖嚎叫", "talent name")
t([[You let your mental forces go unchecked for an instant. All foes in a radius %d are knocked 3 grids away from you.
		Creatures that fail a mental save are also dazed for %d turns and take %0.2f mind damage.
		If you do not have two mindstars equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[釋放你的心靈力量，把你身邊半徑 %d 內的敵人擊退 3 格。
		沒有通過精神豁免的生物會眩暈 %d 回合並受到 %0.2f 精神傷害。
		如果你沒有雙持靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")
t("Finger of Death", "死亡一指", "talent name")
t("#PURPLE##Source# shatters #Target#'s mind, utterly destroying it.", "#PURPLE##Source#粉碎了#Target#的精神，完全摧毀了它。", "logCombat")
t("#PURPLE##Source# shatters #Target#'s mind, utterly destroying it but has no room to store the body.", "#PURPLE##Source#粉碎了#Target#的精神，完全摧毀了它，但是沒有空間存儲它的身體。", "logCombat")
t("#CRIMSON#Target is not affected by ghastly wail!", "#CRIMSON#目標沒有受到恐怖嚎叫的影響！", "logPlayer")
t([[You point your ghastly finger at a foe affected by Ghastly Wail and send a psionic impulse to tell it to simply die.
		The target will take %d%% of the life it already lost as mind damage.
		On targets of rank boss or higher the damage is limited to %d.
		If the target dies from the Finger and is of a type you can already absorb it is directly absorbed into your bodies reserve.
		If you do not have two mindstars equiped, but have them in your off set, you instantly automatically switch. The wild psionic powers are incompatible with the focused nature of psiblades.]], [[用手指對受到恐怖嚎叫效果影響的敵人射出一道衝擊波。
		對目標已造成 %d%% 已損失生命值的精神傷害。
		對 boss 或者更高階級的目標傷害最高爲 %d 。
		如果目標因此死亡，且屬於你已能吸收的類型，則會直接吸收進你的身體儲備中。
		如果你沒有雙持靈晶，但是在副手欄裏裝備了，你會立刻自動切換。此技能與心靈利刃不兼容。]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/psionic.lua"

t("psionic", "靈能", "talent category")
t("possession", "支配", "talent type")
t("Learn to possess the bodies of your foes!", "學會支配敵人的身體！", "_t")
t("body snatcher", "軀體奪取", "talent type")
t("Manipulate your dead foes bodies for power and success!", "複製敵人的身體，獲取力量和勝利！", "_t")
t("psionic menace", "靈能威嚇", "talent type")
t("Laught terrible mind attacks to wear down your foes from afar with your double mindstars!", "使用雙持靈晶遠程擊敗敵人", "_t")
t("psychic blows", "靈能打擊", "talent type")
t("Wield a two handed weapon to channel your psionics into your foes' faces!", "用靈能操控雙手武器攻擊對手！", "_t")
t("battle psionics", "靈能戰鬥", "talent type")
t("Dual wield a one handed weapon and a mindstar to assail your enemies's minds and bodies!", "使用單手武器和靈晶攻擊敵人的身體和精神！", "_t")
t("deep horror", "無盡恐懼", "talent type")
t("Through your psionic powers you become a nightmare for your foes.", "通過靈能量，你成爲了敵人的夢魘！", "_t")
t("ravenous mind", "極度飢渴", "talent type")
t("Your mind hungers for pain and suffering! Feed it!", "你的精神渴望痛苦！滿足它吧！", "_t")

------------------------------------------------
section "data-possessors/data/talents/psionic/psychic-blows.lua"

t("You are disarmed.", "你被繳械了。", "logPlayer")
t("You require a two handed weapon to use this talent.", "你需要裝備一把雙手武器來施展這個技能。", "logPlayer")
t("Psychic Crush", "精神粉碎", "talent name")
t("%s's Psychic Image", "%s的精神影像", "tformat")
t("A temporary psionic imprint.", "一個臨時的心靈印記", "_t")
t("#ROYAL_BLUE#%s's psychic imprint appears!", "#ROYAL_BLUE#%s的心靈印記浮現了！", "logSeen")
t("%s resists the psychic blow!", "%s抵抗了精神打擊！", "logSeen")
t([[Using both your mind and your arms you propel your two handed weapon to deal a huge strike doing %d%% weapon mind damage.
		If the blow connects and the target fails a mental save there is %d%% chance that the blow was so powerful it ripped a psychic imprint off the target.
		It will appear nearby and serve you for %d turns.
		If you do not have a two handed weapon equiped, but have it in your off set, you instantly automatically switch.]], [[用雙手武器攻擊敵人造成 %d%% 武器精神傷害。
		如果命中且目標沒有通過精神豁免有 %d%% 機率剝奪目標的心靈印記。
		它會出現在附近，併爲你服務 %d 回合。
		如果你沒有裝備雙手武器，但是在副手欄裏裝備了，你會立刻自動切換。]], "tformat")
t("Force Shield", "力場盾", "talent name")
t([[You create a psionic shield from your weapon that prevents you from ever taking blows that deal more than %d%% of your maximum life and gives you %d%% evasion.
		In addition, each time you take a melee hit the attacker automatically takes revenge strike that deals %d%% weapon damage as mind damage. (This effect can only happen once per turn)
		If you do not have a two handed weapon equiped, but have it in your off set, you instantly automatically switch.]], [[你通過你的武器創造力場盾，每次受到傷害時，傷害不會超過最大生命值 %d%% 並有 %d%% 迴避攻擊。
		此外，每次受到近戰攻擊時，攻擊者會受到 %d%% 武器精神傷害的反擊，(每回合一次)
		如果你沒有裝備雙手武器，但是在副手欄裏裝備了，你會立刻自動切換。]], "tformat")
t("Unleashed Mind", "心靈釋放", "talent name")
t([[You concentrate your powerful psionic powers on your weapon and briefly unleash your fury.
		All foes in radius %d will take a melee attack dealing %d%% weapon damage as mind damage.
		Any psionic clones in the radius will have its remaining time extended by %d turns.
		If you do not have a two handed weapon equiped, but have it in your off set, you instantly automatically switch.]], [[你將強大的靈能力集中在你的武器上，並簡單地釋放你的憤怒。
		半徑 %d 內的敵人受到近戰攻擊造成 %d%% 武器精神傷害。
		範圍內的所有靈能克隆體將延長 %d 回合。
		如果你沒有裝備雙手武器，但是在副手欄裏裝備了，你會立刻自動切換。]], "tformat")
t("Seismic Mind", "心靈地震", "talent name")
t([[You shatter your weapon in the ground, projecting a psionic shockwave in a cone of radius %d.
		Any foes in the area will take %d%% weapon damage as mind damage.
		Any psionic clones hit will instantly shatter, exploding for %0.2f physical damage in radius 1.
		If you do not have a two handed weapon equiped, but have it in your off set, you instantly automatically switch.]], [[你在地面上打碎你的武器，將一個心靈的衝擊波投射在半徑爲 %d 的圓錐上。
		範圍內的所有敵人受到 %d%% 武器精神傷害。
		任何被擊中的靈能克隆體將立即破碎，在半徑 1 的範圍內爆炸造成 %0.2f 物理傷害。
		如果你沒有裝備雙手武器，但是在副手欄裏裝備了，你會立刻自動切換。]], "tformat")

------------------------------------------------
section "data-possessors/data/talents/psionic/ravenous-mind.lua"

t("Sadist", "虐待狂", "talent name")
t([[You feed on the pain of all foes in sight. For each one of them with life under 80%% you gain a stack of Sadist effect that increases your raw mindpower by %d.
		]], [[你從視野內所有敵人的痛苦中得到養分。每一個生命值低於 80%% 的敵人將讓你獲得一層虐待狂效果，每層增加你的原始精神強度 %d 。
		]], "tformat")
t("Channel Pain", "痛苦連接", "talent name")
t("#ORANGE#%s channels pain to %s!", "#ORANGE#%s連接痛苦到%s！", "logSeen")
t("#ORANGE#%s channels pain!", "#ORANGE#%s連接痛苦！", "logSeen")
t([[As long as you have at least a stack of Sadist whenever you take damage you use %d psi to harness your stacks of Sadist to divide the damage by your stacks + 1.
		Each time this happens a random foe in sight with 80%% or less life left will take a backlash of %d%% of the absorbed damage as mind damage.
		This effect can only happen once per turn and only triggers for hits over 10%% of your max life.]], [[當你至少有一層虐待狂效果時，每當你受到傷害你使用虐待狂效果減免傷害，最終受到的傷害爲受到傷害除以虐待狂效果層數。
		計算時層數 + 1 ，每層效果消耗 %d 靈能值。
		每次生效時，視野內隨機一個生命值低於 80%% 的敵人，會受到傷害反彈，傷害爲所吸收傷害的 %d%% 的精神傷害。
		該效果每回合一次，且只會在傷害超過你 10%% 最大生命值時才觸發。]], "tformat")
t("Radiate Agony", "痛苦輻射", "talent name")
t("You need a Sadist stack to use this talent.", "你需要有一層虐待狂效果才能使用這一技能。", "logPlayer")
t([[As long as you have at least a stack of Sadist you can radiate agony to all those you see in radius %d with 80%% or lower life left.
		For 5 turns their mind will be so focused on their own pain that they will deal %d%% less damage to you.]], [[當你至少有一層虐待狂效果時，你可以分享你的痛苦給半徑 %d 所有可見的生命值少於 80%% 的敵人。
		持續 5 回合，他們的頭腦將如此專注於自己的痛苦，對你的傷害減少 %d%% 。]], "tformat")
t("Torture Mind", "精神拷打", "talent name")
t([[As long as you have at least a stack of Sadist you can mentally lash out at a target, sending horrible images to its mind.
		The target will reel from the effect for %d turns, rendering %d random talents unusable for the duration.]], [[當你至少有一層虐待狂效果時，你可以精神鞭打一個目標，發送恐怖的圖像到目標的腦海中。
		在 %d 回合內，目標隨機 %d 個技能將無法使用。]], "tformat")

------------------------------------------------
section "data-possessors/data/timed_effects.lua"

t("psionic", "靈能", "effect subtype")
t("possession", "支配", "effect subtype")
t("Ominous Form", "不祥軀體", "_t")
t("You stole your current form and share damage and healing with it.", "你偷取了當前軀體，並和它共享傷害與治療。", "_t")
t("Assume Form", "附身", "_t")
t("You use the body of one of your fallen victims. You can not heal in this form.", "你使用你最近消滅的敵人的身體。在這個狀態下你不能被治療。", "_t")
t("#CRIMSON#While you assume a form you may not levelup. All exp gains are delayed and will be granted when you reintegrate your own body.", "#CRIMSON#當你附身一個身體的時候，你不能升級。所有獲得的經驗值都會被保存，在你回到自己的身體的時候獲得。", "_t")
t("#CRIMSON#Your body died! You quickly return to your normal one but the shock is terrible!", "#CRIMSON#你的身體死掉了！你快速回到了你原來的身體，但是這對你產生了極大的衝擊！", "say")
t("was killed by possession aftershock", "被附身的影響殺死", "_t")
t("Kryl-Feijan", "卡洛·斐濟", "_t")
t("Your possessed body's eyelids briefly flutter, and a tear rolls down its cheek. You didn't tell it to do that.", "你控制的身軀眼瞼微微顫動，眼淚順着臉頰滾落。你沒有讓它這麼做。", "_t")
t("Shasshhiy'Kaish", "莎西·凱希", "_t")
t("The flames surrounding Shasshhiy'Kaish slowly die as she falls to her knees.  \"Fiend...  and I thought #{italic}#I#{normal}# could cause suffering.  It's the one thing Eyalites always did best,\" she spits.  \"I heard what had happened to him, and my followers have given more than enough of their life to restore me after this.  All you've accomplished here - [cough] - is giving us a worthwhile new goal...  and target.  All will be repaid tenfold, Eyalite.\"  Her coughing grows weaker, until she abruptly bursts into flame; her ashes scatter into the wind.", "莎西·凱希跪倒在地，她周圍的火焰慢慢熄滅。“你們纔是真正的惡魔……我以爲#{italic}#我#{normal}#是製造痛苦的大師。但現在看來，你們埃亞爾人才是最擅長帶來折磨的人。”她催了一口唾沫。“我聽說了他所發生的事情，我的追隨者給了我足夠的生命，讓我可以東山再起。你對我所做的一切——【咳嗽】——只是給了我一個新的目標……一個復仇的對象。你們所做的一切都將被十倍償還，埃亞爾人”她的咳嗽聲越來越輕，直到最終迸發成一團火焰。她的灰燼散落在風中。", "_t")
t("High Sun Paladin Aeryn", "太陽騎士艾琳", "_t")
t("Aeryn's bewildered and terrified cries grow quiet, but...  your ears don't ring or hurt as screams of horror and rage surround you, louder than should be deafening.  When they shift to accusations, an unfamiliar guilt dominates your thoughts; you are forced to abandon your body before it can compel you to punish yourself.", "艾琳困惑而驚恐的哭聲漸漸平靜下來，但是……當恐懼和憤怒的尖叫聲圍繞着你，比震耳欲聾還要響亮的時候，你的耳朵不會響也不會痛。當他們轉向指責時，一種陌生的罪惡感支配着你的思想；在它迫使你懲罰自己之前，你被迫放棄你的身體。", "_t")
t("stun", "震懾", "effect subtype")
t("Possession Aftershock", "支配餘震", "_t")
t("The target is reeling from the aftershock of a destroyed possessed body, reducing damage by 60%%, reducing movement speed by 50%%.", "目標正承受支配身體被摧毀的餘震，傷害減少 60%%, 移動速度減少 50%%。", "tformat")
t("#Target# is stunned!", "#Target#被震懾！", "_t")
t("+Stunned", "+震懾", "_t")
t("#Target# is not stunned anymore.", "#Target#不再被震懾。", "_t")
t("-Stunned", "-震懾", "_t")
t("possess", "支配", "effect subtype")
t("mind", "精神", "effect subtype")
t("Possess", "支配", "_t")
t("The victim is snared in a psionic web that is destroying its mind and preparing its body for possession.  It takes %0.2f Mind damage per turn.", "目標被靈能網困住，將會被支配，每回合受到 %0.2f 精神傷害。", "tformat")
t("#Target#'s mind is convulsing.", "#Target#的精神在抽搐。", "_t")
t("#Target#'s mind is not convulsing anymore.", "#Target#的精神不再抽搐。", "_t")
t("#PURPLE##Source# shatters #Target#'s mind and takes possession of its body.", "#PURPLE##Source#粉碎了#Target#的精神，控制了它的身體。", "logCombat")
t("#PURPLE##Source# shatters #Target#'s mind, utterly destroying it.", "#PURPLE##Source#粉碎了#Target#的精神，完全摧毀了它。", "logCombat")
t("Psychic Wipe", "精神鞭打", "_t")
t("Ethereal fingers destroy the brain dealing %0.2f mind damage per turn and reducing mental save by %d.", "空靈手指摧毀目標大腦，每回合造成 %0.2f 精神傷害，並減少 %d 精神豁免。", "tformat")
t("#Target# suddently feels strange in the brain.", "#Target# 突然覺得腦袋裏很奇怪。", "_t")
t("#Target# feels less strange.", "#Target#不再覺得奇怪。", "_t")
t("Ghastly Wail", "恐怖嚎叫", "_t")
t("The target is dazed, rendering it unable to move, halving all damage done, defense, saves, accuracy, spell, mind and physical power. Any damage will remove the daze.", "目標被眩暈，無法移動，所有攻擊傷害、閃避、豁免、命中、法術、精神和物理強度減半。任何傷害均會打斷眩暈效果。", "_t")
t("#Target# is dazed!", "#Target#被眩暈！", "_t")
t("+Dazed", "+眩暈", "_t")
t("#Target# is not dazed anymore.", "#Target#從眩暈中恢復。", "_t")
t("-Dazed", "-眩暈", "_t")
t("Mind Steal", "精神竊取", "_t")
t("Stolen talent: %s", "偷取技能: %s", "tformat")
t("#Target# stole a talent!", "#Target#偷取了一個技能！", "_t")
t("#Target# forgot a talent.", "#Target#忘掉了一個技能。", "_t")
t("%s can not use %s because it was stolen!", "%s無法使用%s，因爲它被偷走了！", "_t")
t("Writhing Psionic Mass", "扭曲裝甲", "_t")
t("All resists increased by %d%%, chance to be crit reduced by %d%%.", "所有抗性增加 %d%%, 被暴擊率減少 %d%%。", "tformat")
t("#Target#'s body writhe in psionic energies!", "#Target#的身體在靈能中扭曲！", "_t")
t("#Target#'s body looks more at rest.", "#Target#的身體恢復了原狀。", "_t")
t("damage", "傷害", "effect subtype")
t("Psionic Disruption", "靈能瓦解", "_t")
t("%d stacks. Each stack deals %0.2f mind damage per turn.", "%d 層。每層效果每回合造成 %0.2f 精神傷害。", "tformat")
t("#Target# is disprupted by psionic energies!", "#Target#被靈能力量干擾！", "_t")
t("#Target# no longer tormented by psionic energies.", "#Target#不再被靈能力量折磨。", "_t")
t("Psionic Block", "靈能格擋", "_t")
t("%d%% chances to ignore damage and to retaliate with %0.2f mind damage.", "%d%% 機率無視傷害並反擊 %0.2f 精神傷害。", "tformat")
t("#Target# is protected by a psionic block!", "#Target#被靈能格擋保護！", "_t")
t("#Target# no longer protected by the psionic block.", "#Target#不再被靈能格擋保護。", "_t")
t("#ROYAL_BLUE#The attack against %s is cancelled by a psionic block!", "#ROYAL_BLUE#對%s的攻擊被靈能格擋！", "logSeen")
t("Sadist", "虐待狂", "_t")
t("Mindpower (raw) increased by %d.", "精神強度 ( 原始值 ) 增加 %d。", "tformat")
t("#Target# is empowered by the suffering of others!", "#Target#被其他人的痛苦強化！", "_t")
t("#Target# is no longer empowered.", "#Target#不再被強化。", "_t")
t("Radiate Agony", "痛苦輻射", "_t")
t("All damage reduced by %d%%.", "所有傷害減少 %d%%。", "tformat")
t("#Target# focuses on pain!", "#Target#聚焦痛苦！", "_t")
t("#Target# is no longer focusing on pain.", "#Target#不再聚焦痛苦。", "_t")
t("lock", "封鎖", "effect subtype")
t("Tortured Mind", "精神拷打", "_t")
t("%d talents unusable.", "%d 項技能不能使用。", "tformat")
t("#Target# is tormented!", "#Target#被折磨！", "_t")
t("#Target# is less tormented.", "#Target#不再被折磨。", "_t")
t("%s can not use %s because of Tortured Mind!", "由於精神拷打，%s無法使用%s！", "_t")

------------------------------------------------
section "data-possessors/init.lua"

t("Possessor Bonus Class", "支配者職業包", "init.lua long_name")
t("Possessor class.", "支配者職業。", "init.lua description")

------------------------------------------------
section "data-possessors/overload/mod/dialogs/AssumeForm.lua"

t("Assume Form", "附身", "_t")
t("Possess Body", "使用身體", "_t")
t("#SLATE##{italic}#Choose which body to assume. Bodies can never be healed and once they reach 0 life they are permanently destroyed.", "#SLATE##{italic}#選擇附身哪個身體。身體不能被治療，死亡時永久摧毀。", "_t")
t("Create Minion", "製造隨從", "_t")
t("Summon", "召喚", "_t")
t("#SLATE##{italic}#Choose which body to summon. Once the effect ends the body will be lost.", "#SLATE##{italic}#選擇召喚哪個身體。效果結束後，身體將消失。", "_t")
t("Cannibalize Body", "合併身體", "_t")
t("Cannibalize", "合併", "_t")
t("#SLATE##{italic}#Choose which body to cannibalize. The whole stack of clones will be destroyed.", "#SLATE##{italic}#選擇合併哪個身體。所有克隆體將同時被摧毀。", "_t")
t("Destroy Body", "摧毀身體", "_t")
t("#SLATE##{italic}#Choose which body to destroy.", "#SLATE##{italic}#選擇摧毀哪個身體。", "_t")
t("You have no bodies to use.", "你沒有能使用的身體。", "logPlayer")
t("Discard Body", "丟棄身體", "_t")
t("Destroy: %s", "摧毀: %s", "tformat")
t("Destroy the most damage copy or all?", "摧毀受傷最嚴重的或者全部摧毀？", "_t")
t("Most damaged", "受傷最嚴重的", "_t")
t("All", "所有", "_t")
t("Cancel", "取消", "_t")
t("Destroy it?", "摧毀它嗎？", "_t")
t("Destroy", "摧毀", "_t")
t("#AQUAMARINE#You cannot destroy a body you are currently possessing.", "#AQUAMARINE#你不能摧毀正在使用的身體。", "log")
t("#AQUAMARINE#You are already using that body!", "#AQUAMARINE#你正在使用這個身體！", "log")
t("%s%s (level %d) [Uses: %s]", "%s%s (等級 %d) [使用次數: %s]", "tformat")
t(" **ACTIVE**", " **使用中**", "_t")
t("Life: ", "生命值：", "_t")
t("#FFD700#Accuracy#FFFFFF#: ", "#FFD700#命中值　#FFFFFF#：", "_t")
t("#0080FF#Defense#FFFFFF#:  ", "#0080FF#閃避值　#FFFFFF#：", "_t")
t("#FFD700#P. power#FFFFFF#: ", "#FFD700#物理強度#FFFFFF#：", "_t")
t("#0080FF#P. save#FFFFFF#:  ", "#0080FF#物理豁免#FFFFFF#：", "_t")
t("#FFD700#S. power#FFFFFF#: ", "#FFD700#法術強度#FFFFFF#：", "_t")
t("#0080FF#S. save#FFFFFF#:  ", "#0080FF#法術豁免#FFFFFF#：", "_t")
t("#FFD700#M. power#FFFFFF#: ", "#FFD700#精神強度#FFFFFF#：", "_t")
t("#0080FF#M. save#FFFFFF#:  ", "#0080FF#精神豁免#FFFFFF#：", "_t")
t("#00FF80#Str/Dex/Con#FFFFFF#:  ", "#00FF80#力/敏/體#FFFFFF#:  ", "_t")
t("#00FF80#Mag/Wil/Cun#FFFFFF#:  ", "#00FF80#魔/意/靈#FFFFFF#:  ", "_t")
t("Cannibalize penalty: %d%%", "合併懲罰: %d%%", "tformat")
t("Resists: ", "抗性：", "_t")
t("Hardiness/Armour: ", "護甲強度/護甲值：", "_t")
t("Size: ", "體型：", "_t")
t("Critical Mult: ", "暴擊加成：", "_t")
t("Melee Retaliation: ", "近戰反傷：", "_t")
t("Passive Talents: ", "被動技能: ", "_t")
t("Active Talents: ", "主動技能: ", "_t")

------------------------------------------------
section "data-possessors/overload/mod/dialogs/AssumeFormSelectTalents.lua"

t("Assume Form: Select Talents (max talent level %0.1f)", "附身: 選擇技能 (最大技能等級 %0.1f)", "tformat")
t("Possess Body", "使用身體", "_t")
t("Cancel", "取消", "_t")
t("#SLATE##{italic}#Your level of #LIGHT_BLUE#Full Control talent#LAST# is not high enough to use all the talents of this body. Select which to keep, your choice will be permanent for this body and its clones.", "#SLATE##{italic}#你的 #LIGHT_BLUE#完全控制#LAST# 技能 等級 不足，無法使用該身體的所有技能，選擇需要保留的技能。 你的選擇對該身體及其克隆永久生效。", "_t")
