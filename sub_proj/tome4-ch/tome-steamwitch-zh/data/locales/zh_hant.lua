locale "zh_hant"

section "data-steamwitch/data/birth/classes/tinker.lua"

t("Steam Witch", "蒸汽女巫", "birth descriptor name")
t("The Steam Witch was born into time magic but found the ordered ways of the Wardens boring and struck out to find a path of their own.  Travelling through time and space they found an affinity for technology and integrated their time magic with steam mechanisms.  Steam Witches attack enemies at range with a steam gun and projected dagger attacks while using time magic to keep out of harm's way.  Their hexes make enemies vulnerable to attacks and further magical assaults.  Steam-powered equipment provides additional offensive/defensive capabilities.  Primary stats are Magic and Cunning.", "蒸汽女巫天生具有時空魔法天賦，但她們覺得守衛者墨守成規的行徑十分乏味，因而動身尋找屬於自己的道路。在穿梭時空的旅途中，她們發現了自己對科技的熱忱，並將時空魔法與蒸汽機械相結合。蒸汽女巫會使用蒸汽槍在遠距離攻擊敵人，並射出匕首進行攻擊，同時利用時空魔法避開危險。她們的邪術能使敵人更容易受到攻擊與後續的魔法傷害。蒸汽動力裝備能提供額外的攻防能力。主要屬性為魔力與靈巧。", "_t")
t("#LIGHT_BLUE# * +4 Cunning, +1 Willpower,", "#LIGHT_BLUE# * +4 靈巧, +1 意志,", "_t")
t("#LIGHT_BLUE# * +4 Magic, +0 Constitution,", "#LIGHT_BLUE# * +4 魔力, +0 體質,", "_t")
t("#LIGHT_BLUE# * +0 Strength, +0 Dexterity", "#LIGHT_BLUE# * +0 力量, +0 敏捷", "_t")
t("steamgun", "蒸汽槍", "effect subtype")
t("iron steamgun", "鐵蒸汽槍", "birth descriptor name")
t("dagger", "匕首", "effect subtype")
t("iron dagger", "鐵匕首", "birth descriptor name")
t("shot", "彈丸", "effect subtype")
t("pouch of iron shots", "鐵彈袋", "birth descriptor name")
t("head", "頭部", "effect subtype")
t("rough leather hat", "粗糙皮帽", "birth descriptor name")
t("cloth", "布甲", "effect subtype")
t("linen robe", "亞麻長袍", "birth descriptor name")
t("cloak", "披風", "effect subtype")
t("linen cloak", "亞麻披風", "birth descriptor name")
t("implant", "植入物", "effect subtype")
t("steam generator implant", "蒸汽產生器植入物", "birth descriptor name")
t("Steam Witch", "蒸汽女巫", "_t")

section "data-steamwitch/data/damage_types.lua"

t("timefire blast", "時火爆裂", "damage type")
t("burn over time", "持續燃燒", "damage type")
t("elemental chaos", "元素混沌", "damage type")
t("timeshock", "時間震懾", "damage type")
t("temporal confuse", "時空混亂", "damage type")
t("temporal confuse steam", "時空混亂蒸汽", "damage type")
t("quantum", "量子", "damage type")
t("seeping darkness", "滲流黑暗", "damage type")
t("temporal repulsion", "時空排斥", "damage type")
t("cauldron spill", "大釜溢流", "damage type")

section "data-steamwitch/data/talents/chronomancy/other.lua"

t([[Sets preferred paradox level to 320 and tunes towards that level when resting.  Steam Witches do not have the training required to set their preferred paradox level, nor do they gain spellpower from paradox.
	Base Paradox :  %d
	Willpower Paradox Modifier : -%d
	Paradox Sustain Modifier : +%d
	Total Modifed Paradox :  %d
	Current Anomaly Chance :  %d%%]], [[將首選時空悖論值設為 320，並在休息時調整至該數值。蒸汽女巫並未接受過設定首選時空悖論值所需的訓練，也無法從時空悖論中獲得法術強度。
	基礎時空悖論：%d
	意志時空悖論修正：-%d
	持續技能時空悖論修正：+%d
	修改後時空悖論總值：%d
	目前時空異常機率：%d%%]], "tformat")

section "data-steamwitch/data/talents/magic/fatemanipulation.lua"

t("Reactive Fate", "反應命運", "talent name")
t([[Fate reacts to negative events to further your destiny.
		If hit by a negative effect gain %d physical, mental, and spell saves for 3 turns, stacking up to 3 times.
		If you take damage gain %d%% resistance (less for Physical) to that damage type for 3 turns, stacking up to %d times when hit by that same damage type.
		If you miss a ranged attack gain %d accuracy for 3 turns, stacking up to 5 times (effect removed on a successful hit).
		]], [[命運會對負面事件做出反應，以推進你的天命。
		若受到負面效果影響，獲得 %d 物理、精神與法術豁免，持續 3 回合，最多可疊加 3 次。
		若受到傷害，獲得 %d%% 該傷害類型的抵抗（物理抵抗較少），持續 3 回合，若被相同傷害類型擊中，最多可疊加 %d 次。
		若遠程攻擊未命中，獲得 %d 命中，持續 3 回合，最多可疊加 5 次（命中後效果移除）。
		]], "tformat")
t("Prolong Fate", "延長命運", "talent name")
t([[Activate to Prolong Fate for %d turns.  When you damage a target while Prolong Fate is active you have a %d%% chance to increase the duration of one detrimental status effect on it by one turn.
		The duration increase can occur up to %d times per turn.]], [[激活以延長命運 %d 回合。當延長命運處於激活狀態且你對目標造成傷害時，你有 %d%% 機率將其身上的一個有害狀態效果持續時間延長一回合。
		此時間延長效果每回合最多可觸發 %d 次。]], "tformat")
t("Shared Fate", "共享命運", "talent name")
t([[For the next %d turns you displace %d%% of any damage you receive onto a random enemy. Once per turn you have a %d%% chance of sharing a negative effect with an enemy in range 3.
		Shared Fate can't be used while Fickle Fate Field is active.  If you activate Fickle Fate Field while Shared Fate is active it will be consumed to empower Fickle Fate Field.]], [[在接下來的 %d 回合內，你將受到的任何傷害的 %d%% 轉移到隨機一個敵人身上。每回合一次，你有 %d%% 的機率與範圍 3 內的一個敵人共享一個負面效果。
		變幻命運領域處於啟用狀態時無法使用共享命運。如果你在共享命運啟用時激活變幻命運領域，它將被消耗以增強變幻命運領域。]], "tformat")
t("Contingent Fate", "應急命運", "talent name")
t("#LIGHT_RED#Your Contingent Fate has failed to cast %s!", "#LIGHT_RED#你的應急命運未能施放 %s！", "logPlayer")
t("#STEEL_BLUE#Your Contingent Fate triggered %s!", "#STEEL_BLUE#你的應急命運觸發了 %s！", "logPlayer")
t([[Choose an activatable spell that affects only you, does not require a target, and does not have a fixed cooldown.  When you take damage that reduces your life below %d%% the spell will automatically cast.
		This spell will cast even if it is currently on cooldown, will not consume a turn or resources, and uses the talent level of Contingent Fate or its own, whichever is lower.
		This effect can only occur once every %d turns and takes place after the damage is resolved.

		Current Contingent Fate Spell: %s]], [[選擇一個僅影響自身、不需要目標且沒有固定冷卻時間的主動法術。當你受到傷害使生命值降至 %d%% 以下時，該法術將自動施放。
		即使該法術目前處於冷卻中，它依然會施放，且不消耗回合或資源，並使用應急命運的技能等級或其自身的技能等級，以較低者為準。
		此效果每 %d 回合只能觸發一次，並在傷害結算後發生。

		目前應急命運法術：%s]], "tformat")

section "data-steamwitch/data/talents/magic/magic.lua"

t("Mystic Birthright", "神秘傳承", "talent type")
t("Ancient Power.", "古老力量。", "_t")
t("Witch Hexes", "女巫詛咒", "talent type")
t("Cast hexes to weaken and damage opponents.", "施放詛咒以削弱並傷害對手。", "_t")
t("Time and Space", "時間與空間", "talent type")
t("Control time and space to stay out of harm's way.", "控制時間與空間以遠離傷害。", "_t")
t("Witchcraft", "巫術", "talent type")
t("Tap into the powers of your birthright.", "汲取你傳承的力量。", "_t")
t("Witch Brews", "女巫魔藥", "talent type")
t("Augment your abilities with brews from your cauldron.", "用大釜裡的釀造藥水增強你的技能。", "_t")
t("Fate Manipulation", "命運操縱", "talent type")
t("Redirect the threads of Fate.", "引導命運之線。", "_t")
t("'s temporal clone", "的時空分身", "_t")

section "data-steamwitch/data/talents/magic/mysticbirthright.lua"

t("Touch of Clotho", "克洛托之觸", "talent name")
t([[Your projected attack returns %d%% of the damage (up to %d life) as stacking life regeneration over 3 turns, plus %d immediately.  The healing increases if you are below 50%% of max life.
		]], [[你的投射攻擊會將 %d%% 的傷害（最多 %d 生命值）轉化為可疊加的生命再生，在 3 回合內持續回復，並立即回復 %d。若你的生命值低於最大生命值的 50%%，治療效果會提升。
		]], "tformat")
t("Touch of Lachesis", "拉刻西斯之觸", "talent name")
t([[Your projected attack temporarily increases spell crit by %d%% and applies a stacking spell power bonus (%d start, approaching %d max) for 3 turns; hits will also tune Paradox towards your preferred level by %d.
		]], [[你的投射攻擊會暫時提高法術暴擊率 %d%%，並施加可疊加的法術強度加成（初始為 %d，最大可達 %d），持續 3 回合；命中還會將時空悖論值朝你首選的數值調整 %d。
		]], "tformat")
t("Touch of Atropos", "阿特羅波斯之觸", "talent name")
t([[Your projected attack has a %d%% chance of firing a beam at the target for %d warp damage.
		]], [[你的投射攻擊有 %d%% 的機率對目標射出一道射線，造成 %d 點扭曲傷害。
		]], "tformat")
t("Witch Touch", "女巫之觸", "talent name")
t([[Create a magical synergy between your weapons.  If you make a successful ranged attack and have an offhand dagger with no attached tinker you project an offhand attack at the same target for %d%% weapon damage.  
		Successful projected attacks count as melee attacks for on-hit effects and have various additional effects based on Touch sustains:
		Touch of Clotho: Projected attack returns %d%% of the damage (up to %d life) as stacking life regeneration over 3 turns, plus %d immediately.  The healing increases if you are below 50%% of max life.
		Touch of Lachesis: Temporarily increases spell crit by %d%% and applies a stacking spell power bonus (%d start, approaching %d max) for 3 turns; hits will also tune Paradox towards your preferred level by %d.
		Touch of Atropos: %d%% chance of firing a beam at the target for %d warp damage.
		Touch values will increase with talent level and Spellpower.]], [[使你的武器之間產生魔法協同作用。如果你成功進行遠程攻擊，且副手裝備了未安裝配件的匕首，你將對同一目標投射副手攻擊，造成 %d%% 的武器傷害。
		成功的投射攻擊在觸發命中效果時視為近戰攻擊，並根據激活的『觸碰』持續技能產生不同的額外效果：
		克洛托之觸：投射攻擊會將 %d%% 的傷害（最多 %d 生命值）轉化為可疊加的生命再生，在 3 回合內持續回復，並立即回復 %d。若你的生命值低於最大生命值的 50%%，治療效果會提升。
		拉刻西斯之觸：暫時提高法術暴擊率 %d%%，並施加可疊加的法術強度加成（初始為 %d，最大可達 %d），持續 3 回合；命中還會將時空悖論值朝你首選的數值調整 %d。
		阿特羅波斯之觸：有 %d%% 的機率對目標射出一道射線，造成 %d 點扭曲傷害。
		觸碰的數值將隨技能等級和法術強度提升。]], "tformat")
t("Witch Sight", "女巫之眼", "talent name")
t("#ORCHID#%s has a vision!", "#ORCHID#%s 獲得了啟示！", "logSeen")
t([[Improves your capacity to see invisible/stealthed foes by +%d and accuracy by +%d.  
		Additionally every turn an enemy is present you have a %d%% chance to gain Witch Sight (+%d%% Physical Crit, +%d%% Physical Damage, +%d detection, sense creatures in radius 8).
		Sense and accuracy will scale with your Cunning stat, Witch Sight chance/power will scale with your Magic stat.]], [[提升你對隱形/潛行敵人的偵測能力 +%d，並提高命中 +%d。
		此外，每當有敵人出現的回合，你都有 %d%% 的機率獲得女巫之眼（增加 +%d%% 物理暴擊率、+%d%% 物理傷害、+%d 偵測能力，並感知半徑 8 內的生物）。
		感知與命中將隨你的靈巧屬性提升，女巫之眼的機率與強度將隨你的魔力屬性提升。]], "tformat")
t("Ancestral Bloodline", "先祖血脈", "talent name")
t("Your blood is infused with ancient magic.  Increase blind, poison, disease, and blight resist by %d%%, and spell resist by %d.", "你的血液中融入了古代魔法。使你的致盲、毒素、疾病與荒蕪抵抗提高 %d%%，且法術抵抗提高 %d。", "tformat")
t("Empowered Strike", "強化打擊", "talent name")
t("You require an offhand dagger to use this talent.", "你必須裝備副手匕首才能使用此技能。", "logPlayer")
t("%s resists the warp!", "%s 抵抗了扭曲！", "logSeen")
t([[Channel mystic energy into your offhand dagger and attempt to strike the target for %d%% weapon damage.  If the target survives, inflict additional effects based on the active Witch Touch:
		Touch of Clotho: Target is affected by Enfeeblement (reduce combat powers by %d and movement speed by %d%%) for %d turns.
		Touch of Lachesis: Non-destabilized targets are teleported %d spaces away; destabilized targets are first blinded and if that fails confused for %d turns.
		Touch of Atropos: If the target is below 20%% health it may be instantly slain; targets at 20%% health or greater are stunned for %d turns.
		]], [[引導神秘能量至你的副手匕首，並嘗試對目標造成 %d%% 武器傷害。若目標存活，根據啟用中的女巫之觸施加額外效果：
		克洛托之觸：目標受到衰弱影響（降低 %d 戰鬥強度與 %d%% 移動速度），持續 %d 回合。
		拉刻西斯之觸：未時空不穩定的目標會被傳送至 %d 格外；時空不穩定的目標會先被致盲，若失敗則被混亂，持續 %d 回合。
		阿特羅波斯之觸：若目標生命值低於 20%%，可能被立即斬殺；生命值在 20%% 或以上的目標會被震懾 %d 回合。
		]], "tformat")

section "data-steamwitch/data/talents/magic/timeandspace.lua"

t("Displacement", "位移", "talent name")
t("[phase door] final location of ", "[相位之門] 最終位置 ", "_t")
t([[Teleports you randomly within a range of %d to %d grids.
		The range will increase with talent level.
		Every point in this talent passively increases your out-of-phase bonus by +6 defense, +4%% resist all, and hostile new effect duration reduction by +4%%.
		]], [[將你隨機傳送至 %d 到 %d 格的範圍內。
		該範圍會隨著技能等級提升而增加。
		此技能的每點投入都會被動增加你的異相加成：+6 防禦、+4%% 全抵抗，以及敵對新效果持續時間縮短 +4%%。
		]], "tformat")
t("Patchwork", "縫補", "talent name")
t("Apply repairs to your frayed strands of fate.  For %d turns regenerate %d health and reduce the duration of %d negative effects by %d turn(s).", "修復你磨損的命運之線。持續 %d 回合，回復 %d 生命值，並將 %d 個負面效果的持續時間縮短 %d 回合。", "tformat")
t("Chrono Nova", "時空新星", "talent name")
t([[Releases unstable temporal energy in a wave of repulsion in all directions out to a radius of %d.
		All creatures are struck for %d temporal damage (based on paradox level) and knocked away.
		All enemy projectiles are reflected back to their source.
		Paradox is reduced by %d.
		Damage and paradox reduction scales with Spellpower and talent level; damage may be reduced if paradox level is low.
		This ability requires a minimum paradox level of %d.]], [[向外釋放一波不穩定的時空排斥波，擴散至半徑 %d。
		所有生物將受到 %d 時空傷害（基於悖論值）並被擊退。
		所有敵方彈射物將被反彈回其發射源。
		悖論值降低 %d。
		傷害與悖論值降低值隨法術強度和技能等級增幅；若悖論值過低，傷害可能會降低。
		此能力需要至少 %d 的悖論值。]], "tformat")
t("Time Barrier", "時間屏障", "talent name")
t("materialize barrier", "具現屏障", "talent name")
t([[Manifest %d time barrier(s) for %d turns.
		]], [[顯現 %d 個時間屏障，持續 %d 回合。
		]], "tformat")

section "data-steamwitch/data/talents/magic/timeandspacex.lua"

t([[Manifest %d obstructing wall(s) of congealed time energy on the battlefield for %d turns.
		]], [[在戰場上顯現 %d 個由凝結時間能量構成的阻擋牆，持續 %d 回合。
		]], "tformat")

section "data-steamwitch/data/talents/magic/witchbrews.lua"

t("Vintage of Violence", "暴虐佳釀", "talent name")
t("[PROJECTOR] Vintage of Violence (source) dam", "[傷害投射器] 暴虐佳釀 (來源) 傷害", "_t")
t([[Your skill with weapons is enhanced; increase physical attack speed by %d%% and physical power by %d (increases with spellpower).
		If you know Resourceful Brewer: Increase movement speed by %d%%; on activate restore %d%% health.
		If you know Two-Hundred Proof Brews: Slow projectiles by %d%% and reduce the damage from enemies 3 or more spaces away by %d%%.
		You may only have one Brew active at once.]], [[提升你的武器技巧；增加 %d%% 物理攻擊速度與 %d 物理強度（隨法術強度提升）。
		若你習得巧思釀造者：增加 %d%% 移動速度；主動使用時回復 %d%% 生命值。
		若你習得兩百度佳釀：使彈射物減速 %d%%，並降低來自距離 3 格或更遠敵人的傷害 %d%%。
		你同時只能啟用一種佳釀。]], "tformat")
t("Tincture of Timeliness", "時效酊劑", "talent name")
t([[Quaff this beverage to feel closer to time.  Increase temporal damage by %d%%, temporal resistance by %d%%, and spell crit by %d.  The damage increase and resistance will increase with your Spellpower.
		If you know Resourceful Brewer: Reduce paradox by %d every turn; on activate reduce paradox by %d.
		If you know Two-Hundred Proof Brews: Increase physical resistance by %d%% and gain talent Twist Fate (holds minor temporal anomalies briefly) at level %d.
		You may only have one Brew active at once.]], [[暢飲此飲品以感受更貼近時間。增加 %d%% 時空傷害、%d%% 時空抵抗，以及 %d 法術暴擊。傷害增幅與抵抗將隨你的法術強度提升。
		若你習得巧思釀造者：每回合降低 %d 悖論值；主動使用時降低 %d 悖論值。
		若你習得兩百度佳釀：增加 %d%% 物理抵抗，並 於等級 %d 獲得技能「扭轉命運」（能短暫容納微小時空異常）。
		你同時只能啟用一種佳釀。]], "tformat")
t("Elixir of Engineering", "工程靈藥", "talent name")
t("#ORCHID#%s's Elixir charges their Powercell!", "#ORCHID#%s 的靈藥為其動力電池充能！", "logSeen")
t([[Throw back a tall glass of this Elixir to boost Cunning by %d and steam crit by %d%%.
		If you know Resourceful Brewer: Increase steam regeneration by %d; on activate restore %d steam.
		If you know Two-Hundred Proof Brews: Increase fire resistance by %d%%; if you know Future Relics and enemies are present you have a %d%% chance per turn of gaining 1 Powercell charge.
	You may only have one Brew active at once.]], [[一飲而盡這杯靈藥，以提升 %d 靈巧與 %d%% 蒸氣暴擊。
		若你習得巧思釀造者：增加 %d 蒸氣回復；主動使用時回復 %d 蒸氣。
		若你習得兩百度佳釀：增加 %d%% 火燄抵抗；若你習得未來遺物且有敵人在場，你每回合有 %d%% 的機率獲得 1 點動力電池能量。
	你同時只能啟用一種佳釀。]], "tformat")
t("Witchbrew Mixer", "女巫釀造調配器", "talent name")
t([[Working dilligently at your cauldron you have formulated a series of Brews to enhance your abilities.
			Vintage of Violence: Increase physical attack speed by %d%% and attack power by %d.
			Tincture of Timeliness: Increase temporal damage by %d%%, temporal resistance by %d%%, and spell crit by %d.
			Elixir of Engineering: Increase Cunning by %d and steam crit by %d%%.
			You may only have one Brew active at a time.]], [[在你的大釜旁辛勤工作，你配製出了一系列的佳釀來增強你的能力。
			暴虐佳釀：增加 %d%% 物理攻擊速度與 %d 攻擊強度。
			時效酊劑：增加 %d%% 時空傷害、%d%% 時空抵抗，以及 %d 法術暴擊。
			工程靈藥：增加 %d 靈巧與 %d%% 蒸氣暴擊。
			你同時只能啟用一種佳釀。]], "tformat")
t("Resourceful Brewer", "巧思釀造者", "talent name")
t([[Your Brews now have additional abilities, and an on-activation ability.
			Vintage of Violence: Increase movement speed by %d%%; on activate restore %d%% health.
			Tincture of Timeliness: Reduce paradox by %d every turn; on activate reduce paradox by %d.
			Elixir of Engineering: Increase steam regeneration by %d; on activate restore %d steam.
		]], [[你的佳釀現在擁有額外能力，以及一個主動使用能力。
			暴虐佳釀：增加 %d%% 移動速度；主動使用時回復 %d%% 生命值。
			時效酊劑：每回合降低 %d 悖論值；主動使用時降低 %d 悖論值。
			工程靈藥：增加 %d 蒸氣回復；主動使用時回復 %d 蒸氣。
		]], "tformat")
t("Two-Hundred Proof Brews", "兩百度佳釀", "talent name")
t([[Strong, but smooth!  Your Brews now give you new active or passive benefits.
			Vintage of Violence: Slow projectiles by %d%% and reduce the damage from enemies 3 or more spaces away by %d%%.
			Tincture of Timeliness: Increase physical resistance by %d%% and gain talent Twist Fate (holds minor temporal anomalies briefly) at level %d.
			Elixir of Engineering: Increase fire resistance by %d%%; if you know Future Relics and enemies are present you have a %d%% chance per turn of gaining 1 Powercell charge.
		]], [[強勁而順口！你的佳釀現在帶給你全新的主動或被動效果。
			暴虐佳釀：使彈射物減速 %d%%，並降低來自距離 3 格或更遠敵人的傷害 %d%%。
			時效酊劑：增加 %d%% 物理抵抗，並 於等級 %d 獲得技能「扭轉命運」（能短暫容納微小時空異常）。
			工程靈藥：增加 %d%% 火燄抵抗；若你習得未來遺物且有敵人在場，你每回合有 %d%% 的機率獲得 1 點動力電池能量。
		]], "tformat")
t("Tip the Cauldron", "傾倒大鍋", "talent name")
t([[Tip over your cauldron, unleashing a wall of foulness that for for %d turns oozes out from the caster with radius 1, increasing once every two turns to a maximum eventual radius of %d, inflicting %0.2f Insidious Poison damage over 8 turns, and possibly knocking the target back.
		The damage and duration will increase with your spellpower.]], [[推翻你的大釜，釋放一堵惡臭之牆。這堵牆持續 %d 回合，從施法者處以 半徑 1 向外滲出，每兩回合擴大一次，直至最終最大半徑 %d，造成 %0.2f 隱性毒素傷害，持續 8 回合，並有可能擊退目標。
		傷害與持續時間將隨你的法術強度提升。]], "tformat")

section "data-steamwitch/data/talents/magic/witchbrewsx.lua"

t([[Your skill with weapons is enhanced; increase physical attack speed by %d%% and physical power by %d (increases with spellpower).
		Every turn you shoot you stack Sustained Fire (+4%% physical crit, up to +16%%).
		If you know Resourceful Brewer: Increase movement speed by %d%%; on activate restore %d%% health.
		If you know Two-Hundred Proof Brews: Slow projectiles by %d%% and reduce the damage from enemies 3 or more spaces away by %d%%.
		You may only have one Brew active at once.]], [[提升你的武器技巧；增加 %d%% 物理攻擊速度與 %d 物理強度（隨法術強度提升）。
		你每回合射擊都會疊加持續射擊（+4%% 物理暴擊，最高 +16%%）。
		若你習得巧思釀造者：增加 %d%% 移動速度；主動使用時回復 %d%% 生命值。
		若你習得兩百度佳釀：使彈射物減速 %d%%，並降低來自距離 3 格或更遠敵人的傷害 %d%%。
		你同時只能啟用一種佳釀。]], "tformat")
t([[Quaff this beverage to feel closer to time.  Increase temporal damage by %d%%, temporal resistance by %d%%, and spell crit by %d%%.  The damage increase and resistance will increase with your Spellpower.
		If you know Resourceful Brewer: Tune paradox towards your preferred level by %d every turn; on activate tune paradox by %d.
		If you know Two-Hundred Proof Brews: Increase physical resistance by %d%% and gain talent Twist Fate (holds minor temporal anomalies briefly) at level %d.
		You may only have one Brew active at once.]], [[飲下此飲品以感覺更接近時間。增加 %d%% 時間傷害、%d%% 時間抵抗與 %d%% 法術暴擊。傷害加成與抵抗隨法術強度提升。
		若你習得巧思釀造者：每回合調整時空混亂度 %d 點至你偏好的數值；啟用時調整時空混亂度 %d 點。
		若你習得兩百度佳釀：增加 %d%% 物理抵抗，並於等級 %d 獲得技能扭轉命運（短暫滯留微小時空異常）。
		你同時只能啟用一種佳釀。]], "tformat")
t([[Throw back a tall glass of this Elixir to boost Cunning by %d and steam crit by %d%%.
		If you know Resourceful Brewer: Increase steam regeneration by %d per turn; on activate restore %d steam.
		If you know Two-Hundred Proof Brews: Increase fire resistance by %d%%; if you know Future Relics and enemies are present you have a %d%% chance per turn of gaining 1 Powercell charge.
	You may only have one Brew active at once.]], [[一口飲下這大杯靈藥以提升 %d 點靈巧與 %d%% 蒸汽暴擊。
		若你習得巧思釀造者：每回合增加 %d 點蒸汽回復；啟用時回復 %d 點蒸汽。
		若你習得兩百度佳釀：增加 %d%% 火焰抵抗；若你習得未來遺物且有敵人在場，你每回合有 %d%% 機率獲得 1 點動力電池充能。
	你同時只能啟用一種佳釀。]], "tformat")
t([[Working dilligently at your cauldron you have formulated a series of Brews to enhance your abilities.
			Vintage of Violence: Increase physical attack speed by %d%% and attack power by %d. Every turn you shoot you stack Sustained Fire (+4%% physical crit, up to +16%%).
			Tincture of Timeliness: Increase temporal damage by %d%%, temporal resistance by %d%%, and spell crit by %d%%.
			Elixir of Engineering: Increase Cunning by %d and steam crit by %d%%.
			You may only have one Brew active at a time.]], [[在大釜旁勤奮工作，你配製了一系列的佳釀來增強你的能力。
			暴虐佳釀：增加 %d%% 物理攻擊速度與 %d 點攻擊強度。每回合射擊時你將疊加持續射擊（+4%% 物理暴擊，最高 +16%%）。
			時效酊劑：增加 %d%% 時間傷害、%d%% 時間抵抗與 %d%% 法術暴擊。
			工程靈藥：增加 %d 點靈巧與 %d%% 蒸汽暴擊。
			同時只能啟用一種佳釀。]], "tformat")
t([[Your Brews now have additional abilities, and an on-activation ability.
			Vintage of Violence: Increase movement speed by %d%%; on activate restore %d%% health.
			Tincture of Timeliness: Tune paradox towards your preferred level by %d every turn; on activate tune paradox by %d.
			Elixir of Engineering: Increase steam regeneration by %d per turn; on activate restore %d steam.
			Movement speed, resource regeneration, and resource boost increase with talent level.
		]], [[你的佳釀現在擁有額外能力，以及啟用效果。
			暴虐佳釀：增加 %d%% 移動速度；啟用時回復 %d%% 生命值。
			時效酊劑：每回合調整時空混亂度 %d 點至你偏好的數值；啟用時調整時空混亂度 %d 點。
			工程靈藥：每回合增加 %d 點蒸汽回復；啟用時回復 %d 點蒸汽。
			移動速度、資源回復與資源增幅隨技能等級提升。
		]], "tformat")
t([[Tip over your cauldron, unleashing a wall of foulness that for for %d turns oozes out from the caster with radius 1, increasing once every two turns to a maximum eventual radius of %d, inflicting %0.2f Insidious Blight damage over 8 turns, and possibly knocking the target back.
		The damage and duration will increase with your spellpower.]], [[推翻你的大釜，釋放一面汙穢之牆。在 %d 回合內從施法者處向外滲出，半徑 1，每兩回合增加一次，直到最大半徑為 %d，造成 %0.2f 點陰險荒蕪傷害（持續 8 回合），並可能擊退目標。
		傷害與持續時間隨法術強度提升。]], "tformat")

section "data-steamwitch/data/talents/magic/witchcraft.lua"

t("Cut the Threads", "斬斷絲線", "talent name")
t([[Sever the lifelines of those you have marked.  Inflict random damage (varying around %d) and/or effects (%d duration) for each hex targets are afflicted by (applied separately). Possible effects:
		Enervation: Physical damage, Temporal damage, Stoning, Wasting + Turn Back The Clock
		Frailty: Lightning Daze, Ice Slow, Burning Shock, Fire/Cold/Lighting damage + Blind
		Vile: Blight damage, Life Drain, Spydric Poison, Crippling Poison, Crippling Blight
		.]], [[斬斷你所標記之人的生命線。目標每受到一個邪術影響，便造成隨機傷害（在 %d 左右波動）和/或效果（持續 %d 回合）（分別套用）。可能的效果：
		衰竭：物理傷害、時間傷害、石化、衰弱 + 倒轉時空
		脆弱：閃電眩暈、冰霜減速、火焰震懾、火焰/冰冷/閃電傷害 + 致盲
		邪惡：荒蕪傷害、生命汲取、蜘蛛毒素、致殘毒素、致殘荒蕪
		。]], "tformat")
t("Fickle Fate Field", "變幻命運領域", "talent name")
t("#PINK#%s consumes Shared Fate to empower Fickle Fate Field.", "#PINK#%s 消耗共享命運以增強變幻命運領域。", "logSeen")
t([[Surround yourself with a mystic field for %d turns that can change your fate.  Gain %d damage reduction and have a chance of displacing, smearing, or delaying incoming damage by %d%% (varies by effect).
		Damage reduction based on Spellpower, damage mitigation based on talent level.]], [[用一個能改變你命運的神秘領域圍繞自身，持續 %d 回合。獲得 %d 點傷害減免，且有機會使受到的傷害偏轉、抹除或延遲 %d%%（依效果而異）。
		傷害減免基於法術強度，傷害緩和基於技能等級。]], "tformat")
t("Reversal of Fortune", "命運逆轉", "talent name")
t([[Attempts to remove up to %d effects from the enemy target (spellpower vs. resist) and temporarily grants you 5 Spellpower and 3%% Spell Crit per effect removed.
		]], [[嘗試從敵方目標身上移除最多 %d 個效果（法術強度對抗抵抗），且每移除一個效果，暫時賦予你 5 點法術強度與 3%% 法術暴擊。
		]], "tformat")
t("Summon Familiar", "召喚魔寵", "talent name")
t([[Draw upon your connections to time and witchcraft to summon a friendly weaver matriarch for %d turns.  The weaver will be enchanted with Haste.
		At talent level 3+ the weaver will gain an additional enchantment.
		Enchantment power will increase with talent level.]], [[汲取你與時間及巫術的聯繫，召喚一隻友好的編織者女族長，持續 %d 回合。該編織者將獲得加速附魔。
		於技能等級 3+ 時，編織者將獲得額外附魔。
		附魔強度隨技能等級提升。]], "tformat")

section "data-steamwitch/data/talents/magic/witchhexes.lua"

t("Enervating Hex", "衰弱詛咒", "talent name")
t([[Hexes your target and everything in a 2 radius ball around it for %d turns, reducing physical, temporal, knockback, teleport, and pin resistance by %d%%.
		Targets also have a %d%% chance of becoming pinned for %d turns.
		If Inevitibility is active the hex also reduces bleed resistance, and causes %d Bleed damage.
		Effectiveness and damage increase with spellpower.]], [[施邪術於你的目標及其周圍半徑 2 範圍內的所有事物 %d 回合，降低其 %d%% 物理、時間、擊退、傳送與定身抵抗。
		目標亦有 %d%% 機率被定身 %d 回合。
		若必然性處於啟用狀態，此邪術還會降低流血抵抗，並造成 %d 點流血傷害。
		效果與傷害隨法術強度提升。]], "tformat")
t("Frailty Hex", "脆弱詛咒", "talent name")
t([[Hexes your target and everything in a 2 radius ball around it for %d turns, reducing fire, cold, lightning, light, and blind resistances by %d%%.
		Targets also have a %d%% chance of becoming blinded for %d turns.
		If Inevitibility is active the hex also reduces stun resistance, and causes %d Fireburn damage.
		Effectiveness and damage increase with spellpower.]], [[施邪術於你的目標及其周圍半徑 2 範圍內的所有事物 %d 回合，降低其 %d%% 火焰、冰冷、閃電、光系與致盲抵抗。
		目標亦有 %d%% 機率被致盲 %d 回合。
		若必然性處於啟用狀態，此邪術還會降低震懾抵抗，並造成 %d 點火焰灼燒傷害。
		效果與傷害隨法術強度提升。]], "tformat")
t("Vile Hex", "惡毒詛咒", "talent name")
t([[Hexes your target and everything in a 2 radius ball around it for %d turns, reducing blight, nature, disease, poison, and confusion resistances by %d%%.
		Targets also have a %d%% chance of becoming confused for %d turns.
		If Inevitibility is active the hex also causes Malady (%d damage over time and %d reduced powers).
		Effectiveness and damage increase with spellpower.]], [[施邪術於你的目標及其周圍半徑 2 範圍內的所有事物 %d 回合，降低其 %d%% 荒蕪、自然、疾病、毒素與混亂抵抗。
		目標亦有 %d%% 機率被混亂 %d 回合。
		若必然性處於啟用狀態，此邪術還會造成疫病（%d 點持續傷害與降低 %d 點強度）。
		效果與傷害隨法術強度提升。]], "tformat")
t("Inevitibility", "必然性", "talent name")
t([[Seeing the span of time you know that everything will eventually end; when is the question and the right tweaks in time can change the answer.
		Hasten the end for your enemies: Hexes gain additional abilities and are applied with 25%% more spellpower (though hexes do not apply spellshock).
		Delay the end for yourself: you can only die when you reach -%d health.]], [[看清時間的跨度，你深知萬物終將迎來終結；問題只在於何時，而適當的時間調整可以改變答案。
		加速敵人的終結：邪術獲得額外能力，並以增加 25%% 的法術強度施放（儘管邪術不會觸發法術衝擊）。
		延遲你自身的終結：你只有在生命值降至 -%d 時才會死亡。]], "tformat")

section "data-steamwitch/data/talents/steam/clockworkmenagerie.lua"

t("Infuriating Pest", "惱人害蟲", "talent name")
t("#GREEN#%s escapes death!", "#GREEN#%s免於死亡！", "logSeen")
t("This pest is harder to kill than you'd expect. %d%% chance of escaping fatal damage.", "這討厭鬼比你預期的更難殺死。有 %d%% 機率逃過致命傷害。", "tformat")
t("Bat Screech", "蝙蝠尖叫", "talent name")
t("@Source@ screeches!", "@Source@發出尖叫！", "_t")
t([[You let out a screech that sends your foes into utter confusion for %d turns in a radius of %d.
		]], [[你發出一聲尖叫，使你的敵人陷入徹底混亂，持續 %d 回合，半徑 %d。
		]], "tformat")
t("Exploit Vulnerability", "利用弱點", "talent name")
t([[Systematically find the weaknesses in your opponents' physical resists.  Each time you hit an opponent with a melee attack, you reduce their physical resistance by 5%%, up to a maximum of %d%%.
		]], [[系統性地尋找對手物理抵抗的弱點。每次你以近戰攻擊命中對手，會降低其 5%% 物理抵抗，最高可達 %d%%。
		]], "tformat")
t("Pounce", "撲擊", "talent name")
t("@Source@ pounces, claws sharp and ready!", "@Source@猛撲而上，利爪已蓄勢待發！", "_t")
t([[Pounce onto a target in range %d dealing %d%% damage. If your attack hits, the target is left reeling and vulnerable, reducing their physical save by %d and their stun, blind, confusion and pin immunities to 50%% of normal for %d turns.
		This effect bypasses saves.]], [[在範圍 %d 內撲擊一個目標，造成 %d%% 傷害。如果你的攻擊命中，目標會步履蹣跚且脆弱，降低其物理豁免 %d，並使其震懾、致盲、混亂與定身免疫降至正常的 50%%，持續 %d 回合。
		此效果無視豁免。]], "tformat")
t("Primed: Blight Cloud", "起爆預備：枯萎雲霧", "talent name")
t([[On death will explode in a radius 1 infective blight cloud that lasts for %d turns and causes %d damage.
		]], [[死亡時會爆炸並產生半徑 1 的傳染性枯萎雲霧，持續 %d 回合並造成 %d 傷害。
		]], "tformat")
t("Primed: Mire Cloud", "起爆預備：泥沼雲霧", "talent name")
t([[On death will explode in a radius 1 cloud of caustic mire that lasts for %d turns and causes %d acid damage plus %d%% slow.
		]], [[死亡時會爆炸並產生半徑 1 的腐蝕泥沼雲霧，持續 %d 回合，造成 %d 酸性傷害與 %d%% 減速。
		]], "tformat")
t("Primed: Fireblast Cloud", "起爆預備：火爆雲霧", "talent name")
t([[On death will explode in a radius 1 cloud of stunning fire that lasts for %d turns and causes %d fire damage.
		]], [[死亡時會爆炸並產生半徑 1 的震懾之火雲霧，持續 %d 回合並造成 %d 火焰傷害。
		]], "tformat")
t("Safety Check", "安全檢查", "talent name")
t("Checks distance from summoner before detonating.", "在引爆前檢查與召喚者的距離。", "tformat")
t("Click-Boom", "喀噠-砰", "talent name")
t("Detonate your clockwork summons.  This will override Safety Protocol!", "引爆你的發條召喚物。這將會覆寫安全協定！", "tformat")
t("Safety Protocol", "安全協定", "talent name")
t("Prevents Clockworks from exploding within range of yourself.", "阻止發條在你的範圍內爆炸。", "tformat")
t("Clockwork Rat", "發條老鼠", "talent name")
t("clockwork", "發條", "effect subtype")
t("clockwork rat", "發條老鼠", "talent name")
t("%s explodes in a cloud of infective blight!", "%s 爆炸並化作一團傳染性枯萎雲霧！", "logSeen")
t([[Summon a Clockwork Rat for %d turns to attack your foes. Clockwork Rats are melee pests that can inflict diseases (%d damage and %d reduced stat for 5 turns).
		It will get %d Strength, %d Dexterity, %d Constitution, and %d Cunning (increases with Steampower and talent level).
		Clockwork summons inherit your increased damage%% and are immune to most status effects.  Summoning one Clockwork will put the others on cooldown for 7 turns.
		]], [[召喚一隻發條老鼠，持續 %d 回合來攻擊你的敵人。發條老鼠是近戰有害生物，能施加疾病（造成 %d 傷害並在 5 回合內降低 %d 屬性）。
		牠將獲得 %d 力量、%d 敏捷、%d 體質與 %d 靈巧（隨蒸汽強度與技能等級提升）。
		發條召喚物繼承你的傷害增加%%且免疫大部分狀態效果。召喚一隻發條召喚物將使其他召喚物進入 7 回合的冷卻。
		]], "tformat")
t("Clockwork Bat", "發條蝙蝠", "talent name")
t("clockwork bat", "發條蝙蝠", "talent name")
t("%s explodes in a cloud of caustic mire!", "%s 爆炸並化作一團腐蝕泥沼雲霧！", "logSeen")
t([[Summon a Clockwork Bat for %d turns to attack your foes. Clockwork Bats share sight of enemies with their summoner and emit confusing screeches (radius %d, confuse duration %d).
		It will get %d Strength, %d Dexterity and %d Constitution (increases with Steampower and talent level).
		Clockwork summons inherit your increased damage%% and are immune to most status effects.  Summoning one Clockwork will put the others on cooldown for 7 turns.
		]], [[召喚一隻發條蝙蝠，持續 %d 回合來攻擊你的敵人。發條蝙蝠與召喚者共享敵人視野，並發出混亂尖叫（半徑 %d，混亂持續 %d）。
		牠將獲得 %d 力量、%d 敏捷與 %d 體質（隨蒸汽強度與技能等級提升）。
		發條召喚物繼承你的傷害增加%%且免疫大部分狀態效果。召喚一隻發條召喚物將使其他召喚物進入 7 回合的冷卻。
		]], "tformat")
t("Clockwork Cat", "發條貓", "talent name")
t("clockwork cat", "發條貓", "talent name")
t("%s explodes in a cloud of flame!", "%s 在一片烈焰中爆炸！", "logSeen")
t([[Summon a Clockwork Cat for %d turns to attack your foes. Clockwork Cats are melee attackers that bleeds enemies and exploits their weaknesses.
		It will get %d Strength, %d Dexterity and %d Constitution (increases with Steampower and talent level).
		Clockwork summons inherit your increased damage%% and are immune to most status effects.  Summoning one Clockwork will put the others on cooldown for 7 turns.
		]], [[召喚一隻發條貓，持續 %d 回合來攻擊你的敵人。發條貓是近戰攻擊者，能使敵人流血並利用其弱點。
		牠將獲得 %d 力量、%d 敏捷與 %d 體質（隨蒸汽強度與技能等級提升）。
		發條召喚物繼承你的傷害增加%%且免疫大部分狀態效果。召喚一隻發條召喚物將使其他召喚物進入 7 回合的冷卻。
		]], "tformat")
t("Hardwired to Self-Destruct", "內置自爆", "talent name")
t([[Your engineering efficiency has found a way for your clockworks to serve you in death as well as life.  On dying or timing out if enemies are present clockworks explode in a variety of ways:
		Clockwork Rat: A cloud of infective blight causing %d damage.
		Clockwork Bat: A cloud of caustic mire causing %d damage and %d%% slow.
		Clockwork Cat: A cloud of stunning fire causing %d damage.
		Upon learning this talent you also learn Click-Boom (remotely detonate your clockworks).
		At level 3+ you learn Safety Protocol (prevents clockworks from detonating when within range of you).
		Note that clockworks install Hardwired and Safety Protocol at time of summon.]], [[你的工程效率找到了一種方法，讓你的發條在生與死中都能為你效勞。當死亡或時間結束時，若現場有敵人存在，發條將以各種方式爆炸：
		發條老鼠：傳染性枯萎雲霧，造成 %d 傷害。
		發條蝙蝠：腐蝕泥沼雲霧，造成 %d 傷害與 %d%% 減速。
		發條貓：震懾之火雲霧，造成 %d 傷害。
		學習此技能後，你還會學到喀噠-砰（遠程引爆你的發條）。
		在等級 3+ 時，你將學到安全協定（阻止發條在靠近你的範圍內引爆）。
		請注意，發條 於 召喚時安裝硬連線與安全協定。]], "tformat")

section "data-steamwitch/data/talents/steam/futurerelics.lua"

t("Transporter Clone (", "傳送器複製體 (", "_t")
t("An echo of yourself.", "你自身的回聲。", "_t")
t("Transporter Clone", "傳送器複製體", "_t")
t("Charge Powercell", "動力電池充能", "talent name")
t("Powercell already charged!", "動力電池已充能！", "logPlayer")
t("Generate two charges for your Powercell for %d turns.  Future Relic talents require the use of a Powercell charge.", "為你的動力電池產生兩個充能，持續 %d 回合。後續的遺物技能需要使用動力電池充能。", "tformat")
t("Phase Engine", "相位引擎", "talent name")
t("You require a charged Powercell for this talent.", "此技能需要已充能的動力電池。", "logPlayer")
t("%s's phase fizzles!", "%s 的相位失效了！", "logSeen")
t([[Transports you to a target location within %d tiles.	The range will increase with talent level.
		At talent level 3+ a Transporter Clone will be left in your old location.]], [[將你傳送到 %d 格內的目標位置。	範圍將隨技能等級增加。
		在技能等級 3+ 時，會在你的舊位置留下一個傳送器複製體。]], "tformat")
t("Photon Emitter", "光子發射器", "talent name")
t([[Fire a beam of energy that deals %0.2f light damage to all foes in a line.  At talent level 3+ it may blind targets.
		The damage done will increase with your Steampower.
		When you learn this talent you will also learn Charge Powercell (spend a large amount of Steam to charge your Powercell).  Future Relic talents require one Powercell charge for use.]], [[發射一束能量射線，對直線上的所有敵人造成 %0.2f 光系傷害。在技能等級 3+ 時，它可能會致盲目標。
		造成的傷害會隨你的蒸汽強度提升。
		當你學習此技能時，你也會學到動力電池充能（消耗大量蒸汽為你的動力電池充能）。後續的遺物技能需要消耗一個動力電池充能。]], "tformat")
t("Panic Button", "恐慌按鈕", "talent name")
t("%s's teleport fizzles!", "%s 的傳送失效了！", "logSeen")
t([[Teleports you randomly within a range of %d to %d grids and generate a %d point damage shield.  The range will increase with talent level.  Costs 2 Powercell charges if available (will work with 1).
		When you learn this talent you will also learn Phase Engine (phase door to a target location in range %d).
		At talent level 3+ when either talent is used a Transporter Clone will be left in your old location.
		]], [[將你隨機傳送 %d 到 %d 格範圍內，並產生 %d 點的傷害護盾。範圍隨技能等級提高。若有動力電池充能則消耗 2 次（1 次亦可運作）。
		當你學習此技能時，也將學會相位引擎（傳送至範圍 %d 內的目標位置）。
		當技能等級達 3+ 以上時，使用任一技能都會在原本的位置留下一個傳送器複製體。
		]], "tformat")
t("Vortex Box", "漩渦盒", "talent name")
t("maelstrom", "大漩渦", "effect subtype")
t("'s vortex", " 的漩渦", "_t")
t([[Create a powerful maelstrom for %d turns.  Each turn, the maelstrom will pull in targets within a radius of %d, and inflict %0.2f physical damage.
		At talent level 3+ a field will be set up around friendly targets to protect them from the effects of the maelstrom.
		The damage will scale with your Steampower.]], [[創造一個強大的大漩渦，持續 %d 回合。每回合，大漩渦會拉引半徑 %d 內的目標，並造成 %0.2f 物理傷害。
		當技能等級達 3+ 以上時，友方目標周圍會產生一個保護力場，使其免受大漩渦的影響。
		傷害隨你的蒸汽強度提高。]], "tformat")
t("Time Scrambler", "時間干擾器", "talent name")
t([[Void the warranty on your time travel equipment and project an unstable burst of chrono energy at a target, inflicting at most %d negative temporal effects (damaging effects vary around %d damage).
		The damage will scale with your Steampower.]], [[使你的時間旅行設備保固失效，並於目標投射一股不穩定的時間能量爆發，最多施加 %d 個負面時間效果（傷害效果在 %d 傷害左右浮動）。
		傷害隨你的蒸汽強度提高。]], "tformat")

section "data-steamwitch/data/talents/steam/steam.lua"

t("Timegun Training", "時間槍訓練", "talent type")
t("Ranged fighting techniques that combine magic and steam.", "結合魔力與蒸汽的遠程戰鬥技巧。", "_t")
t("Timegear", "時間齒輪", "talent type")
t("Utilize steam devices infused with time magic.", "使用融入時間魔法的蒸汽裝置。", "_t")
t("Future Relics", "未來遺物", "talent type")
t("Relics from a now-lost future time.  Relics require Powercell charges for use.", "來自已逝去未來時空的遺物。使用遺物需要動力電池充能。", "_t")
t("Clockwork Menagerie", "發條珍獸", "talent type")
t("Command an array of mechanical creatures just short of a winged monkey with cymbals.", "指揮一系列機械生物，就差一隻敲鈸的飛猴了。", "_t")

section "data-steamwitch/data/talents/steam/timegear.lua"

t("Timethrower", "時間噴射器", "talent name")
t([[Conjures up a cone of timefire with radius %d. Any targets caught in the area will take %d Timefire damage and suffer Timeshock (Global Slow of %d%% + movement speed slow of %d%%).
		The damage will increase with your Steampower.]], [[召喚一個半徑 %d 的錐形時間之火。任何處於區域內的目標都將受到 %d 點時間之火傷害，並遭受時間震盪（全域減速 %d%% + 移動速度減速 %d%%）。
		傷害隨你的蒸汽強度提高。]], "tformat")
t("Time Bombs", "時間炸彈", "talent name")
t("timebomb", "時間炸彈", "talent name")
t("%s travel time!", "%s 旅途時間！", "logSeen")
t("instability", "不穩定度", "effect subtype")
t("temporal instability", "時空不穩定度", "talent name")
t([[You focus on a target zone of radius 2 to make up to %d timebombs appear.
		The first timebomb will appear at the center of the target zone, while others will appear at random spots.
		Each timebomb lasts %d turns and explodes when a hostile creature walks over it, dealing %d Temporal damage and possibly removing the target from the timeline for %d turns.
		The damage will increase with your Spellpower.]], [[你聚焦於一個半徑 2 的目標區域，使最多 %d 個時間炸彈出現。
		第一個時間炸彈會出現於目標區域中心，其餘的則出現於隨機地點。
		每個時間炸彈持續 %d 回合，當敵對生物踩上去時會爆炸，造成 %d 點時空傷害，並可能將目標移出時間線 %d 回合。
		傷害隨你的法術強度提高。]], "tformat")
t("Quantum Mortar", "量子迫擊砲", "talent name")
t([[You lob a special mortar shell at a target that explodes in radius %d for %d Quantum damage (applied 2-4 times for a corresponding fraction of the damage).
		At talent level 4+ radius increases to 2.
		Damage increases with steampower.]], [[你於目標投擲一枚特殊的迫擊炮彈，在半徑 %d 內爆炸並造成 %d 點量子傷害（重複觸發 2-4 次，每次造成相應比例的傷害）。
		當技能等級達 4+ 以上時，半徑增加至 2。
		傷害隨蒸汽強度提高。]], "tformat")
t("Regulator", "調節器", "talent name")
t([[The Regulator recirculates your blood, infusing it with a specially-formulated witch's brew and filtering out negative elements.
		Increases life regeneration by %0.2f%% of maximum health, healing factor by %d%%, and negative effects duration by %d%%.
		It also empowers your spells with %d%% of your steampower (%d spellpower).
		]], [[調節器使你的血液循環，為其注入特調的女巫魔藥並過濾掉有害成分。
		使生命回復提高最大生命值的 %0.2f%%、治療係數提高 %d%%，且負面效果持續時間提高 %d%%。
		它還會以你蒸汽強度的 %d%%（%d 法術強度）來增強你的法術。
		]], "tformat")

section "data-steamwitch/data/talents/steam/timegun-training.lua"

t([[Your projected attack temporarily increases spell power by %d and spell crit by %d%% for 3 turns; hits will also tune Paradox towards your preferred level by an amount (%d) depending on current paradox level.
		]], [[你的投影攻擊會暫時提高法術強度 %d 點，並提高法術暴擊 %d%%，持續 3 回合；命中時還會將時空偏差朝你期望的數值調整，調整值（%d）取決於當前的時空偏差水平。
		]], "tformat")
t("Timegun Mastery", "時間槍專精", "talent name")
t([[Increases Physical Power by %d, increases weapon damage by %d%%, and increases your reload rate by %d when using steamguns.
		Weapons and ammo use Cunning instead of Dexterity for requirements.
		Weapons use Magic instead of Dexterity and Cunning instead of Strength for damage calculations.
		If you make a successful steamgun attack and have an offhand dagger with no attached tinker you project an attack with the offhand weapon at the same target for %d%% weapon damage.  
		Successful projected attacks also have various effects based on Touch sustains:
		Touch of Clotho: Projected attack returns %d%% of the damage (up to %d life) as stacking life regeneration over 3 turns, plus %d immediately.  The healing increases if you are below 50%% of max life.
		Touch of Lachesis: Temporarily increases spell power by %d and spell crit by %d%% for 3 turns; hits will also tune Paradox towards your preferred level by %d.
		Touch of Atropos: %d%% chance of firing a beam at the target for %d warp damage.
		Offhand projected attack damage and Touch values will increase with Spellpower.]], [[提高物理強度 %d 點、提高武器傷害 %d%%，並在使用蒸汽槍時提高裝填速度 %d 點。
		武器與彈藥的需求屬性以靈巧代替敏捷。
		武器傷害計算以魔力代替敏捷，並以靈巧代替力量。
		若你成功進行蒸汽槍攻擊，且副手裝備無附加配件的匕首，你會於相同目標投射副手武器的攻擊，造成 %d%% 的武器傷害。
		成功的投影攻擊還會根據啟用的「之觸」持續技能產生不同效果：
		克洛托之觸：投影攻擊會將 %d%% 的傷害（最多 %d 點生命值）轉化為可在 3 回合內疊加的生命回復，外加立即回復 %d 點。若你生命值低於最大生命值的 50%%，治療效果還會提升。
		拉刻西斯之觸：暫時提高法術強度 %d 點，並提高法術暴擊 %d%%，持續 3 回合；命中時還會將時空偏差朝你期望的數值調整 %d 點。
		阿特羅波斯之觸：有 %d%% 的機率於目標射出一道光束，造成 %d 點扭曲傷害。
		副手投影攻擊傷害與「之觸」的數值隨法術強度提高。]], "tformat")
t("Hasted Gunnery", "急速槍術", "talent name")
t("You require a steamgun for this talent.", "此技能需要配備蒸汽槍。", "logPlayer")
t([[Use localized spacial acceleration to fire your gun three times.
	Each shot (targeted separately) deals %d%% damage.]], [[利用局部空間加速，連續開槍射擊三次。
	每發彈丸（分別瞄準目標）造成 %d%% 的傷害。]], "tformat")
t("Warp Bullets", "扭曲子彈", "talent name")
t([[Infuse your bullets with warp energy for %d turns.  Bullets will inflict %d temporal damage and may (%d%%) attempt to teleport the target randomly in range %d.
		Additionally your bullets will bypass friendly targets for the duration.
		Duration is based on Steam Power; Damage, Teleport Apply Power, and Teleport Range is based on Spell Power.]], [[為你的子彈注入扭曲能量，持續 %d 回合。子彈會造成 %d 點時空傷害，並有機率（%d%%）嘗試在範圍 %d 內隨機傳送目標。
		此外，在持續時間內，你的子彈會繞過友方目標。
		持續時間取決於蒸汽強度；傷害、傳送施放強度與傳送範圍取決於法術強度。]], "tformat")
t([[Improves your capacity to see invisible/stealthed foes by +%d and accuracy by +%d.  
		Additionally every turn an enemy is present you have a %d%% chance to gain Witch Sight (+%d%% Physical Crit, +%d%% Physical Damage, +%d detection).
		Sense and accuracy will scale with your Cunning stat, Witch Sight chance/power will scale with your Magic stat.]], [[提升偵測隱形/潛行敵人的能力 +%d，並提高命中 +%d。
		此外，每當有敵人出現的回合，你有 %d%% 的機率獲得女巫之眼（+%d%% 物理暴擊率、+%d%% 物理傷害、+%d 偵測）。
		偵測與命中隨你的靈巧屬性提升，女巫之眼的機率/強度隨你的魔力屬性提升。]], "tformat")

section "data-steamwitch/data/talents/steam/timegun-trainingx.lua"

t([[Increase Physical Power by %d, weapon damage by %d%%, and reload rate by %d when using steamguns.
		Weapons and ammo use Cunning instead of Dexterity for requirements.
		Weapons use Magic instead of Dexterity and Cunning instead of Strength for damage calculations.
		]], [[使用蒸汽槍時，增加物理強度 %d、武器傷害 %d%% 以及裝彈速度 %d。
		武器與彈藥的需求屬性以靈巧代替敏捷。
		武器的傷害計算以魔力代替敏捷，並以靈巧代替力量。
		]], "tformat")
t([[Infuse your bullets with warp energy for %d turns.  Adds %d temporal damage, inflicts Warptouched (reduces defense and saves), and may (%d%%) attempt to teleport the target randomly in range %d.
		Additionally your bullets will bypass friendly targets for the duration.
		Duration is based on Steam Power; Damage, Teleport Apply Power, and Teleport Range is based on Spell Power.]], [[在你的子彈中注入歪曲能量，持續 %d 回合。額外造成 %d 時空傷害，施加歪曲之觸（降低防禦與豁免），並有機率（%d%%）嘗試將目標隨機傳送至距離 %d 內。
		此外，在持續時間內，你的子彈會穿過友方目標。
		持續時間取決於蒸汽強度；傷害、傳送施加強度與傳送範圍取決於法術強度。]], "tformat")
t("Destined Shot", "宿命射擊", "talent name")
t("[Destined shot] targetting", "[宿命射擊] 瞄準中", "_t")
t("[Destined shot] looking for more targets", "[宿命射擊] 正在尋找更多目標", "_t")
t(" at ", " 於 ", "_t")
t("radius ", "半徑 ", "_t")
t("[Destined shot] found possible actor", "[宿命射擊] 找到可能的角色", "_t")
t("[Destined shot] Found targets:", "[宿命射擊] 找到目標：", "_t")
t("[Destined shot] jumping from", "[宿命射擊] 跳躍自", "_t")
t([[Let time take its own course, whether to bring many together or to tear one apart.  
		Aim your steamgun at a target within range.
		If there are enemies within 3 radius of the target: Deal %d temporal damage (increasing with talent and steam power) to up to %d targets and Braid their lifelines (take %d%% damage of any other Braided target; percentage increases if less than half of targets struck) for %d turns.  
		If not: Deal shot damage to the target plus temporal damage equal to %d%% (reduced by rank) of the target's maximum life.  If the target survives, pin for %d turns.
		]], [[讓時間順其自然，不論是聚沙成塔還是分崩離析。 
		將你的蒸汽槍瞄準於範圍內的目標。
		若目標半徑 3 內有敵人：造成 %d 時空傷害（隨技能與蒸汽強度提升），影響最多 %d 個目標，並編織他們的生命線（承受任何其他被編織目標受到傷害的 %d%%；若擊中的目標少於一半，此百分比會提高），持續 %d 回合。 
		否則：對目標造成彈丸傷害，並附加等同於目標最大生命值 %d%%（隨階級降低）的時空傷害。若目標存活，則定身 %d 回合。
		]], "tformat")

section "data-steamwitch/data/timed_effects/magical.lua"

t("Witch Sight", "女巫之眼", "_t")
t("Physical damage increased by %d%%, physical crit increased by %d%%, stealth/invisibility detection increased by %d, and sense creatures in range 8.", "物理傷害增加 %d%%，物理暴擊增加 %d%%，潛行/隱形偵測增加 %d，並感知範圍 8 內的生物。", "tformat")
t("Seeping Darkness", "滲流黑暗", "_t")
t("Darkness seeping within, causing %0.2f Darkness damage per turn.", "黑暗滲入體內，每回合造成 %0.2f 點黑暗傷害。", "tformat")
t("Enervating Hex", "衰弱詛咒", "_t")
t("The target is hexed, reducing physical, temporal, knockback, teleport, and pin resistances by %d%%.", "目標被施加邪術，降低物理、時空、擊退、傳送與定身抵抗 %d%%。", "tformat")
t("The target is hexed, reducing physical, temporal, knockback, teleport, pin, and bleed resistances by %d%%.", "目標被施加邪術，降低物理、時空、擊退、傳送、定身與流血抵抗 %d%%。", "tformat")
t("#Target# is hexed.", "#Target#中了詛咒。", "tformat")
t("+hex", "+詛咒", "_t")
t("#Target# is no longer hexed.", "#Target#不再受詛咒影響。", "tformat")
t("-hex", "-詛咒", "_t")
t("Frailty Hex", "脆弱詛咒", "_t")
t("The target is hexed, reducing fire, cold, lightning, light, and blind resistances by %d%%.", "目標被施加邪術，降低火焰、寒冰、閃電、光系與致盲抵抗 %d%%。", "tformat")
t("The target is hexed, reducing fire, cold, lightning, light, blind, and stun resistances by %d%%.", "目標被施加邪術，降低火焰、寒冰、閃電、光系、致盲與震懾抵抗 %d%%。", "tformat")
t("Vile Hex", "惡毒詛咒", "_t")
t("The target is hexed, reducing blight, nature, disease, poison, and confusion resistances by %d%%.", "目標被施加邪術，降低荒萎、自然、疾病、毒素與混亂抵抗 %d%%。", "tformat")
t("Patchwork", "縫補", "_t")
t("The target is regaining %d life per turn.", "目標每回合回復 %d 點生命值。", "tformat")
t("#Target# is being patched up.", "#Target#正在被縫補。", "tformat")
t("+Patchwork", "+縫補", "_t")
t("#Target# is no longer being patched.", "#Target#不再被縫補。", "tformat")
t("-Patchwork", "-縫補", "_t")
t("Fickle Fate Field", "變幻命運領域", "_t")
t("The target's fate is fickle, absorbing %d damage and possibly deflecting %d%% damage (varying by effect).", "目標的命運難以捉摸，吸收 %d 點傷害且可能偏轉 %d%% 的傷害（視效果而異）。", "tformat")
t("#Target#'s fate is fickle.", "#Target#的命運變化無常。", "tformat")
t("+FFF", "+變幻命運領域", "_t")
t("#Target#'s fate is again following the thread.", "#Target#的命運重新遵循命運之線。", "tformat")
t("-FFF", "-變幻命運領域", "_t")
t("#LIGHT_BLUE##Source# delays their fate!", "#LIGHT_BLUE##Source#延後了其命運！", "_t")
t("#LIGHT_BLUE#(%d deferred)#LAST#", "#LIGHT_BLUE#(%d 延後)#LAST#", "tformat")
t("reality smearing", "現實模糊", "_t")
t("#LIGHT_BLUE##Source# converts damage to paradox!", "#LIGHT_BLUE##Source#將傷害轉化為悖論！", "_t")
t("#LIGHT_BLUE##Source# displaces damage!", "#LIGHT_BLUE##Source#轉移了傷害！", "_t")
t("%s(%d fickle fate field)#LAST#", "%s(%d 變幻命運領域)#LAST#", "tformat")
t("Stolen Fortune", "竊取幸運", "_t")
t("Increases the target combat power and spellpower by %d, and critical chance by %d%%.", "增加目標的戰鬥強度與法術強度 %d，以及暴擊機率 %d%%。", "tformat")
t("Fortune shines on #Target#.", "幸運眷顧著#Target#。", "tformat")
t("+Stolen Fortune", "+竊取幸運", "_t")
t("#Target# seems less fortunate.", "#Target#看起來沒那麼幸運了。", "tformat")
t("-Stolen Fortune", "-竊取幸運", "_t")
t("Gift of Lachesis", "拉刻西斯的恩賜", "_t")
t("Increases the target spellpower by %d and spell critical chance by %d%%.", "增加目標的法術強度 %d，以及法術暴擊機率 %d%%。", "tformat")
t("Lachesis gifts #Target#.", "拉刻西斯眷顧了#Target#。", "tformat")
t("+Gift of Lachesis", "+拉刻西斯的恩賜", "_t")
t("#Target#'s gift has faded.", "#Target#的恩賜已消逝。", "tformat")
t("-Gift of Lachesis", "-拉刻西斯的恩賜", "_t")
t("Gift of Clotho", "克洛托的恩賜", "_t")
t("Life returns to the target, restoring %0.2f life per turn.", "生命值重回目標身上，每回合恢復 %0.2f 點生命。", "tformat")
t("Clotho gifts #Target#.", "克洛托眷顧了#Target#。", "tformat")
t("+Gift of Clotho", "+克洛托的恩賜", "_t")
t("-Gift of Clotho", "-克洛托的恩賜", "_t")
t("Delayed Fate", "延後命運", "_t")
t("The target's fate is catching up to them, taking %0.2f damage per turn.", "目標的命運已然追上他們，每回合受到 %0.2f 點傷害。", "tformat")
t("#Target# is delaying fate!", "#Target#正在延後命運！", "tformat")
t("#Target# rejoins the thread.", "#Target#重新回到命運之線。", "tformat")
t("unable to escape their fate", "無法逃脫其命運", "_t")
t("%s%d %s#LAST#", "%s%d %s#LAST#", "tformat")
t("Enfeeblement", "衰弱", "_t")
t("Decreases combat powers by %d and movement speed by %d%%.", "降低戰鬥強度 %d 與移動速度 %d%%。", "tformat")
t("#Target# has been weakened.", "#Target#變得衰弱。", "tformat")
t("+Enfeeblement", "+衰弱", "_t")
t("#Target# regains strength.", "#Target#恢復了力量。", "tformat")
t("-Enfeeblement", "-衰弱", "_t")
t("Reactive Fate", "反應命運", "_t")
t("The target's defense and saves have been increased by %d and accuracy by %d.", "目標的閃避與豁免提升了 %d，命中提升了 %d。", "tformat")
t(" Charges", " 次", "_t")
t("#Target#'s timeline reacts.", "#Target#的時間線產生反應。", "tformat")
t("+Reactive Fate", "+反應命運", "_t")
t("#Target#'s timeline normalizes.", "#Target#的時間線恢復正常。", "tformat")
t("-Reactive Fate", "-反應命運", "_t")
t("Prolong Fate", "延長命運", "_t")
t("+Prolong Fate", "+延長命運", "_t")
t("-Prolong Fate", "-延長命運", "_t")
t("Shared Fate", "共享命運", "_t")
t("+Shared Fate", "+共享命運", "_t")
t("-Shared Fate", "-共享命運", "_t")
t("%s(%d shared fate)#LAST#", "%s(%d 共享命運)#LAST#", "tformat")
t("cross tier", "跨階", "_t")
t("#STEEL_BLUE#%s shares the effect '%s'!", "#STEEL_BLUE#%s 共享了 '%s' 效果！", "logSeen")
t("Warptouched", "歪曲之觸", "_t")
t("The target's defense and saves have been reduced by %d.", "目標的閃避與豁免降低了 %d。", "tformat")
t("#Target# doesn't feel right...", "#Target# 感覺不太對勁...", "tformat")
t("+Warptouched", "+歪曲之觸", "_t")
t("#Target# feels better.", "#Target# 感覺好多了。", "tformat")
t("-Warptouched", "-歪曲之觸", "_t")
t("Resilient Fate", "堅韌命運", "_t")
t("The target's saves have been increased by %d.", "目標的豁免提高了 %d。", "tformat")
t("+Resilient Fate", "+堅韌命運", "_t")
t("-Resilient Fate", "-堅韌命運", "_t")
t("Enduring Fate", "持久命運", "_t")
t("+Enduring Fate", "+持久命運", "_t")
t("-Enduring Fate", "-持久命運", "_t")
t("Guiding Fate", "指引命運", "_t")
t("The target's accuracy has been increased by %d (removed on hit).", "目標的命中提升了 %d (命中時移除)。", "tformat")
t("+Guiding Fate", "+指引命運", "_t")
t("-Guiding Fate", "-指引命運", "_t")
t("Malady", "疫病", "_t")
t("Illness causing %d damage and reducing powers by %d.", "疾病造成 %d 點傷害，並降低強度 %d。", "tformat")
t("steamtech", "蒸汽科技", "effect subtype")
t("unresistable", "無法抵抗", "effect subtype")

section "data-steamwitch/data/timed_effects/physical.lua"

t("Timefire", "時間之火", "_t")
t("The target is coated in timefire, taking %0.2f fire and temporal damage per turn.", "目標被時空之火覆蓋，每回合受到 %0.2f 點火焰與時空傷害。", "tformat")
t("#Target# is coated in timefire!", "#Target# 身上覆蓋著時間之火！", "tformat")
t("+Timefire", "+時間之火", "_t")
t("#Target# stops burning.", "#Target# 停止燃燒。", "tformat")
t("-Timefire", "-時間之火", "_t")
t("Timeshock", "時間震盪", "_t")
t("Reduces global action speed by %d%% and movement speed by %d%%.", "降低整體動作速度 %d%% 與移動速度 %d%%。", "tformat")
t("Warp Bullets", "歪曲子彈", "_t")
t("Bullets cause %d additional temporal damage, inflict Warptouched (reduces defense and saves), and may teleport the target to a random location.", "子彈造成 %d 點額外時空傷害，施加歪曲之觸（降低閃避與豁免），且可能將目標傳送至隨機位置。", "tformat")
t("Powercell", "動力電池", "_t")
t(" Charge(s)", " 充能", "_t")
t("Powercell has %d charge(s).", "動力電池有 %d 次充能。", "tformat")
t("Primed", "準備就緒", "_t")
t("Primed to explode.", "準備爆炸。", "tformat")
t("Sight Relay", "視野中繼", "_t")
t("Clockwork Bat relaying enemy sight.", "發條蝙蝠正在中繼敵方視野。", "tformat")
t("Improves senses, allowing the detection of remote enemies.", "提升感官，可偵測遠處的敵人。", "tformat")
t("Sustained Fire", "持續射擊", "_t")
t("The target's physical crit chance has been increased by %d%%.", "目標的物理暴擊機率提升了 %d%%。", "tformat")
t("#Target# is on a shooting streak.", "#Target#正處於連射狀態。", "tformat")
t("+Sustained Fire", "+持續射擊", "_t")
t("#Target#'s streak ends.", "#Target#的連射狀態結束。", "tformat")
t("-Sustained Fire", "-持續射擊", "_t")

section "data-steamwitch/init.lua"

t("Steam Witch", "蒸汽女巫", "init.lua long_name")
t([[Adds the Steam Witch, a Tinker sub-class.  The Steam Witch was born into time magic but found the ordered ways of the Wardens boring and struck out to find a path of their own.  Travelling through time and space they found an affinity for technology and integrated their time magic with steam mechanisms.
		
Steam Witches are a ranged attack and spell casting class.  Their tl;dr description is ‘magical Psyshot’.  Class highlights:

Mystic Combat: Steam Witches fight with a steamgun in one hand and a dagger in other, projecting ranged dagger attacks when attacking with the steamgun.  Successful dagger attacks will trigger additional effects based on a selected Touch ability (possible magical attack, magic enhancement, or lifesteal regeneration).
Timegear: Use steam-powered devices that are infused with magical effects.
Hexes: Cast hexes on enemies to render them vulnerable to damage types.  Later abilities add damage-over-time and effect vulnerabilities to hexes, plus a special attack based on the hexes a target is afflicted with.
Witchbrews: Customize your character build with one of three Brew sustains that enhance either combat, magic, or steampower.
Future Relics: Activate powerful offensive and defensive abilities that require a turn and a large amount of steam to charge up.
Time Magic: Phase away from enemies, deflect and delay damage, repair your timeline, summon a spider familiar, and create walls out of thin air!  Be careful though, as Steam Witches lack the rigorous training of Chronomancers and thus do not benefit from and have less control over Paradox.
Clockwork Menagerie: Command an array of mechanical creatures just short of a winged monkey with cymbals.

Link to forum: http://forums.te4.org/viewtopic.php?f=50&t=49638 ]], [[新增修補匠子職業：蒸汽女巫。蒸汽女巫天生擁有時間魔法天賦，但她們覺得時空守衛那套井然有序的行事風格十分無趣，因而決定開創屬於自己的道路。在穿越時空的旅途中，她們發現了自己對科技的熱愛，並將時間魔法與蒸汽機械融為一體。
		
蒸汽女巫是遠程攻擊與法術施放職業。一句話簡介：『魔法版心靈射手』。職業特色：

神秘戰鬥：蒸汽女巫一手持蒸汽槍，一手持匕首，在用蒸汽槍攻擊時會投射出遠程匕首攻擊。匕首攻擊命中時，會根據所選的『觸碰』技能觸發額外效果（可能是魔法攻擊、魔法強化或生命吸取再生）。
時間齒輪：使用注入魔法效果的蒸汽動力裝置。
邪術：對敵人施加邪術使其對特定傷害類型產生易傷。後續的技能會為邪術添加持續傷害與負面效果易傷，還能根據目標身上的邪術施展特殊攻擊。
女巫釀：使用三種能增強戰鬥、魔法或蒸汽動力的釀造持續技能之一，來客製化你的角色流派。
未來遺物：激活強大的攻防技能，這需要花費一回合和大量蒸汽來進行充能。
時間魔法：傳送遠離敵人、偏轉並延後傷害、修復你的時間線、召喚蜘蛛魔寵，甚至憑空製造牆壁！但請小心，蒸汽女巫缺乏時空使徒那樣的嚴格訓練，因此無法從時空悖論中獲得益處，對時空悖論的控制力也較低。
發條珍獸：指揮一系列機械生物，只差沒有拿著鈸的飛天猴子了。

論壇連結：http://forums.te4.org/viewtopic.php?f=50&t=49638 ]], "init.lua description")
