locale "zh_hant"

section "data-deathknight/data/birth/classes/mage.lua"

t("Deathknight", "死亡騎士", "birth descriptor name")
t("Some Necromancers instead choose to turn their dark magic inwards, enhancing their physical power and martial prowess to become Deathknights.", "有些死靈法師選擇將黑暗魔法轉向內在，強化自身的體魄與武藝，進而成為死亡騎士。", "_t")
t("Masters of both two-handed and shield fighting, Deathknights channel cold and darkness through their weapons and can even carry on fighting through fatal wounds.", "死亡騎士精通雙手武器與盾牌戰法，能透過武器引導寒冷與暗影之力，即使身受致命傷仍能繼續戰鬥。", "_t")
t("Rather than raising an undead army through captured souls, they instead use the souls to massively empower their spells and melee techniques.", "他們不是靠奪取的靈魂喚起亡靈大軍，而是用這些靈魂大幅強化自身的法術與近戰技巧。", "_t")
t("#LIGHT_BLUE# * +4 Strength, +0 Dexterity, +0 Constitution", "#LIGHT_BLUE# * +4 力量 , +0 敏捷 , +0 體質", "_t")
t("#LIGHT_BLUE# * +5 Magic, +0 Willpower, +0 Cunning", "#LIGHT_BLUE# * +5 魔法 , +0 意志 , +0 靈巧", "_t")
t("greatsword", "巨劍", "effect subtype")
t("iron greatsword", "鐵製巨劍", "birth descriptor name")
t("iron mail armour", "鐵製鎖子甲", "birth descriptor name")
t("iron longsword", "鐵製長劍", "birth descriptor name")
t("iron shield", "鐵製盾牌", "birth descriptor name")

section "data-deathknight/data/damage_types.lua"

t("shadowfrost", "暗霜", "damage type")
t("remorseless winter", "無情寒冬", "damage type")
t("draining darkness", "汲取暗影", "damage type")
t("debilitating darkness", "衰弱暗影", "damage type")
t("purging darkness", "淨化暗影", "damage type")
t("living shadows", "活影", "damage type")
t("wasting darkness", "衰竭暗影", "damage type")

section "data-deathknight/data/effects.lua"

t("Reap", "收割", "_t")
t("The target's soul has been claimed, causing them to grant the caster %0.2f souls on death. If this effect expires while the target still lives, they will instead take cold damage equal to %d%% of their missing health (to a maximum of %d).", "目標的靈魂已被標記，死亡時會賦予施法者 %0.2f 點靈魂。若此效果在目標仍存活時消失，目標將改為承受相當於其已損失生命 %d%% 的寒冷傷害（上限 %d）。", "tformat")
t("#Target#'s soul has been claimed.", "#Target#的靈魂已被收割。", "tformat")
t("#Target#'s soul is free of the claim.", "#Target#的靈魂已解除收割。", "tformat")
t("Meat Shield", "肉盾", "_t")
t("%d%% of all damage you take is taken by a ghoul.", "你所受到的全部傷害中，有 %d%% 會由食屍鬼代為承受。", "tformat")
t("#DARK_GREEN##Source# shares damage with %s ghoul!", "#DARK_GREEN##Source#與 %s 食屍鬼分攤了傷害！", "tformat")
t("#DARK_GREEN#(%d shared)#LAST#", "#DARK_GREEN#（分擔 %d）#LAST#", "tformat")
t("Pale Rider", "蒼白騎士", "_t")
t("#Target# seems much more resilient!.", "#Target#看起來變得更加堅韌了！", "tformat")
t("+Pale Rider", "+蒼白騎士", "_t")
t("#Target# no longer seems as resilient.", "#Target#不再顯得那般堅韌。", "tformat")
t("-Pale Rider", "-蒼白騎士", "_t")
t("Soulforge", "鑄魂", "_t")
t("Next spell gains additional effects.", "下一個法術獲得額外效果。", "tformat")
t("Soul Fragment", "靈魂碎片", "_t")
t("Prevents the target from dying until they fall below -%d life.", "使目標不會死亡，直到生命降至 -%d 以下。", "tformat")
t("Hungering Blade", "饑餓之刃", "_t")
t("Deals %0.2f cold damage on hit and has %d%% increased lifesteal.", "命中時造成 %0.2f 點寒冷傷害，並提升 %d%% 吸血。", "tformat")
t("#Target# weapon burns with cold flames!", "#Target#的武器燃燒著冰冷火焰！", "tformat")
t("+Hungering Blade", "+饑餓之刃", "_t")
t("The cold fire around #Target#'s weapon dies down.", "#Target# 的武器周圍的冰冷火焰熄滅了。", "tformat")
t("-Hungering Blade", "-饑餓之刃", "_t")
t("Undying", "不朽", "_t")
t("The target is filled with necrotic energy, increasing healing by %d%%.", "目標充滿死靈能量，使治療效果提升 %d%%。", "tformat")
t("Icebound Fortitude", "冰封堅毅", "_t")
t("Reduces all damage taken by %d%% of shield block value, to a minimum of 50%%.", "將所受到的全部傷害降低相當於格擋值 %d%% 的量，最低降至 50%%。", "tformat")
t("#Target#'s armor is covered in a thick layer of ice.", "#Target# 的護甲覆蓋了一層厚冰。", "tformat")
t("+Icebound Fortitude", "+冰封堅毅", "_t")
t("#Target#'s ice armor melts away.", "#Target#的冰甲融化了。", "tformat")
t("-Icebound Fortitude", "-冰封堅毅", "_t")
t("[PROJECTOR] after static reduction dam", "[傷害投射器] 靜態減免後傷害", "_t")
t("Remorseless Winter", "無情寒冬", "_t")
t("The target's is taking %0.2f cold damage each turn. At 5 stacks they will be frozen solid for 3 turns.", "目標每回合承受 %0.2f 點寒冷傷害。疊加至 5 層時，將被徹底凍結 3 回合。", "tformat")
t("Numbing Cold", "凍麻嚴寒", "_t")
t("The target's global speed has been reduced by %d%% and damage dealt has been reduced by %d%%.", "目標的全域速度降低了 %d%%，造成的傷害降低了 %d%%。", "tformat")
t("Enervate", "衰竭", "_t")
t("The target has been drained, reducing its damage by %d%%, resists by %d%% and all saves by %d.", "目標遭到汲取，傷害降低 %d%%、抗性降低 %d%%，且所有豁免降低 %d。", "tformat")
t("#Target# is weakened by the necrotic aura.", "#Target#因死靈光環而衰弱。", "tformat")
t("#Target# regains their strength.", "#Target#恢復了力量。", "tformat")
t("Death Vortex", "死亡漩渦", "_t")
t("The target is surrounded by necrotic energy, dealing %0.2f cold damage and %0.2f darkness damage each turn to those within it's aura.", "目標周圍環繞著死靈能量，使光環範圍內的敵人每回合承受 %0.2f 點寒冷傷害與 %0.2f 點暗影傷害。", "tformat")
t("#Target# begins drawing in the souls of nearby foes!", "#Target# 開始吸取附近敵人的靈魂！", "tformat")
t("+Death Vortex", "+死亡漩渦", "_t")
t("The necrotic vortex surrounding #Target# dissipates.", "圍繞 #Target# 的壞死漩渦消散了。", "tformat")
t("-Death Vortex", "-死亡漩渦", "_t")
t("Lightbane", "滅光", "_t")
t("The target is wielding a weapon of pure darkness.", "目標揮舞著一把純粹暗影構成的武器。", "tformat")
t("#Target# wields a blade of pure darkness!", "#Target#揮舞著純粹黑暗之刃！", "tformat")
t("+Lightbane", "+滅光", "_t")
t("#Target#'s dark weapon fades.", "#Target#的黑暗武器消失了。", "tformat")
t("-Lightbane", "-滅光", "_t")
t("Soul Rend", "裂魂", "_t")
t("The target's soul has been rent.", "目標的靈魂已遭撕裂。", "tformat")
t("#Target#'s soul has been rent.", "#Target#的靈魂已被撕裂。", "tformat")
t("#Target#'s soul is whole again.", "#Target#的靈魂再次完好如初。", "tformat")
t("Blizzard", "暴風雪", "_t")
t("Rains down an icy shard each turn doing %0.2f cold damage in radius 1, with a 25%% chance to freeze.", "每回合降下冰晶，對半徑 1 範圍造成 %0.2f 點寒冷傷害，並有 25%% 機率使目標凍結。", "tformat")
t("Living Shadows", "活影", "_t")
t("The target is being assaulted by living shadows, taking %0.2f darkness damage each turn.", "目標正遭受活影侵襲，每回合承受 %0.2f 點暗影傷害。", "tformat")
t("Chilled to the Bone", "寒澈入骨", "_t")
t("Reduces cold resistance by %d%%.", "使寒冷抗性降低 %d%%。", "tformat")
t("Wail of Doom", "末日哀嚎", "_t")
t("The target's mind has been shattered. Each time it tries to use a talent there is %d%% chance of failure.", "目標的心智已被擊碎。每次嘗試使用天賦時，都有 %d%% 機率失敗。", "tformat")
t("#Target#'s mind is shattered!", "#Target#的精神已粉碎！", "tformat")
t("+Wail of Doom", "+末日哀嚎", "_t")
t("#Target#'s mind recovers.", "#Target#的精神已恢復。", "tformat")
t("-Wail of Doom", "-末日哀嚎", "_t")
t("Dark Simulacrum", "暗影替身", "_t")
t("The target has taken the soul of another, allowing use of an additional ability.", "目標奪取了他人的靈魂，因而能使用一項額外的能力。", "tformat")
t("Reaper's Embrace", "死神擁抱", "_t")
t("This unit has %d%% resistance penetration.", "此單位擁有 %d%% 抗性穿透。", "tformat")
t("#Target# crackles with necrotic energy!", "#Target#身上死靈能量激盪！", "tformat")
t("+Reaper's Embrace", "+死神擁抱", "_t")
t("The necrotic energy around #Target# fades", "#Target#周圍的死靈能量消退了", "tformat")
t("-Reaper's Embrace", "-死神擁抱", "_t")
t("Dirge", "輓歌", "_t")
t(" Dirge", " 輓歌", "_t")
t("Ghoul Frenzy", "食屍狂暴", "_t")
t("Shadow of Death", "死亡之影", "_t")
t("This unit has become an vengeful spirit!", "此單位化為了復仇之靈！", "tformat")
t("#PURPLE#As #Target# falls, a terrible wraith rises from their body!", "#PURPLE#隨著 #Target# 倒下，一隻可怕的怨靈從其身軀中升起！", "tformat")
t("+Shadow of Death", "+死亡之影", "_t")
t("The wraith returns to #Target#'s body", "怨靈回歸#Target#的軀體", "tformat")
t("-Shadow of Death", "-死亡之影", "_t")
t("Frost Armour", "冰霜護甲", "_t")
t("The target is shielded in frost, reducing all damage taken by %d%%.", "目標受到寒冰護盾庇護，使所受到的全部傷害降低 %d%%。", "tformat")
t("Soulburn", "燃魂", "_t")
t("Next spell has %d%% increased spellpower, %d%% reduced cooldown and grants %d%% of a turn.", "下一個法術的法術強度提升 %d%%、冷卻時間降低 %d%%，並額外獲得 %d%% 的回合時間。", "tformat")
t("Necrosis", "壞死", "_t")
t("Necrotic energy is eating away at the target, causing %0.2f darkness damage each turn and reducing powers by %d%%.", "死靈能量正侵蝕著目標，使其每回合承受 %0.2f 點暗影傷害，並使各項強度降低 %d%%。", "tformat")
t("#Target#'s wastes away!", "#Target#正在枯萎！", "tformat")
t("#Target# recovers from the wasting.", "#Target#從枯萎中恢復。", "tformat")
t("Dark Transformation", "黑暗蛻變", "_t")
t("Target has become an undead monstrosity, massively increasing their power.", "目標化為不死怪物，大幅提升自身力量。", "tformat")
t("#Target#'s becomes an undead monstrosity!", "#Target#變成了亡靈畸體！", "tformat")
t("+Dark Transformation", "+黑暗蛻變", "_t")
t("#Target#'s returns to their original form.", "#Target#恢復了原本的形體。", "tformat")
t("-Dark Transformation", "-黑暗蛻變", "_t")
t("#GREY#(%d negated)#LAST#", "#GREY#（抵銷 %d）#LAST#", "tformat")
t("freeze", "凍結", "effect subtype")

section "data-deathknight/data/talents/spells/desecration.lua"

t("Drain Essence", "精華吸取", "talent name")
t([[Your melee attacks have a 40%% chance to steal a soul fragment from the target, preventing you from dying until you fall below -%d life. This stacks up to 5 times, to a maximum of -%d life.
You can activate this ability to consume all soul fragments, restoring %d life, %d mana and %d souls.
The life limit, life and mana restored will increase with your Spellpower.]], [[你的近戰攻擊有 40%% 的機率從目標身上竊取一個靈魂碎片，使你在生命值降至 -%d 以下之前不會死亡。此效果最多可疊加 5 次，最多可至 -%d 生命值。
你可以啟用此技能以消耗所有靈魂碎片，回復 %d 生命值、%d 法力與 %d 靈魂。
生命值限制、回復的生命值與法力將隨你的法術強度提升。]], "tformat")
t("Pale Rider", "蒼白騎士", "talent name")
t([[You become as inevitable as death itself, preventing you from dying until you reach -%d life for 8 turns.
#PURPLE#Soulforge 3: Increases your resilience, preventing any blow from dealing more than 50%% of your maximum life.]], [[你變得如同死亡本身般無法避免，使你在生命值降至 -%d 之前免於死亡，持續 8 回合。
#PURPLE#靈魂熔爐 3：提升你的韌性，使任何單次攻擊造成的傷害不會超過最大生命值的 50%%。]], "tformat")
t("Hungering Blade", "飢渴之刃", "talent name")
t([[Your weapons cut deeper into the souls of your enemies, increasing the chance for Essence Drain to trigger by an additional %d%% and causing it to deal %0.2f darkness damage. On activating Essence Drain, for the next 5 turns you gain %d%% lifesteal and your melee attacks inflict an additional %0.2f cold damage.
The damage dealt will increase with your Spellpower.]], [[你的武器能更深地切入敵人的靈魂，使精華汲取的觸發機率額外提高 %d%%，並使其造成 %0.2f 點暗影傷害。啟用精華汲取時，在接下來的 5 回合內你將獲得 %d%% 生命偷取，且近戰攻擊會造成額外 %0.2f 點冰冷傷害。
造成的傷害將隨你的法術強度提升。]], "tformat")
t("Undying", "不滅", "talent name")
t([[The line between life and death blurs further, increasing your healing factor by %d%% while below 0 life and granting additional effects:
	-On falling below 0 life, you surge with necrotic energy that extends the duration of all positive effects by %d turns.
	-On healing above 0 life, the necrotic energy animating you surges outwards, inflicting darkness damage equal %0.2f + %d%% of your negative life threshold (currently %0.2f) to all enemies within radius %d healing you for 50%% of the damage dealt.
		]], [[生與死的界線進一步模糊，當生命值低於 0 時，使你的治療係數提升 %d%%，並獲得額外效果：
	-當生命值跌破 0 時，你體內湧動的壞死能量會使所有有益效果的持續時間延長 %d 回合。
	-當治療使生命值回升至 0 以上時，驅動你的壞死能量會向外噴發，造成相當於 %0.2f + 負生命值閾值的 %d%%（當前為 %0.2f）的暗影傷害，波及半徑 %d 內的所有敵人，並為你回復相當於造成傷害 50%% 的生命值。
		]], "tformat")

section "data-deathknight/data/talents/spells/dread.lua"

t("Frostblast", "冰霜衝擊", "talent name")
t([[Fires a blast of frost doing %0.2f cold damage.
		The damage will increase with your Spellpower.]], [[發射一發冰霜衝擊，造成 %0.2f 點冰冷傷害。
		傷害將隨你的法術強度提升。]], "tformat")
t("ghost", "幽靈", "effect subtype")
t("wraith", "怨靈", "talent name")
t("Necrotic Aura", "死靈光環", "talent name")
t("Noooooo!", "不——！", "_t")
t("Save me, Master, save meeee---", "救救我，主人，救救我——", "_t")
t("Aaaauuuggghhh!", "啊啊啊啊啊！", "_t")
t("Did I do good?", "我做得好嗎？", "_t")
t("Bwuh? Nwaaah!", "唔？哇啊！", "_t")
t("Why, Master, whyyyyy---?", "為什麼，主人，為什麼——？", "_t")
t("I thought you loved me! I thought-", "我以為您是愛我的！我以為——", "_t")
t("For Master's glory!", "為了主人的榮耀！", "_t")
t("Bye... bye....", "再見……再見……", "_t")
t("We love you, Master!", "我們愛您，主人！", "_t")
t("EeeeeeeaaaAAAAAUUUUUGGGGGHHHHH!!!!", "呃啊啊啊啊啊啊啊啊——！！！！", "_t")
t("The pain, the PAAAAAIN!", "好痛，好痛啊——！", "_t")
t("Please, no, nooo--", "拜託，不要，不要——", "_t")
t("Unlife no more for this dead matter, the time comes for my flesh to splatter.", "此等死物不再維持不死，我的血肉橫飛之時已至。", "_t")
t("You gave back life, you gave back dreams, but now I'm bursting at the seams...", "你帶回了生命，帶回了夢想，但現在我的縫線快要撐破了……", "_t")
t("Remember meeeee!", "記住我——！", "_t")
t("My tummy hurts...", "我的肚子好痛……", "_t")
t("Whu..?", "咦……？", "_t")
t("Ahahahahaha!", "啊哈哈哈哈！", "_t")
t("Me go boom, me go BOOM!", "我要爆炸了，我要爆炸了！", "_t")
t("Grave circumstances, Master....", "情況嚴峻，主人……", "_t")
t("I see the light.. I see, oh.. just a wisp....", "我看到光了……我看到了，哦……只是一縷微光……", "_t")
t("Master, wait... I thought I saw a....Master? ..", "主人，等等……我好像看到了……主人？……", "_t")
t("I'm not.. so sure my spine is supposed to bend this way....", "我不太.. 確定我的脊椎應該這樣彎曲....", "_t")
t("I told you I could Dash 100 yards and back in time! You owe me 10 gol....", "我就說我能衝刺 100 碼並及時趕回來！你欠我 10 金....", "_t")
t("%s rips more animus from its victim. (+1 more soul)", "%s從受害者身上撕扯出更多怨念。(+1 更多靈魂)", "logPlayer")
t("necrotic-aura", "凋零光環", "_t")
t([[Emits a necrotic aura, sustaining your undead minions in a radius of %d. Minions outside the radius will lose %d%% life per turn.
		Any creature you or your minions kill within your aura will be absorbed as a soul that can be used to raise minions.
		Retch from your ghouls will also heal you, even if you are not undead.]], [[散發死靈光環，在半徑 %d 內維持你的亡靈僕從。半徑外的僕從每回合會損失 %d%% 生命。
		你或你的僕從在光環內擊殺的任何生物都將被吸收為一個靈魂，可用於召喚僕從。
		即使你不是亡靈，你食屍鬼的嘔吐技能也一樣能治療你。]], "tformat")
t("Enervate", "衰弱", "talent name")
t([[Enemies inside your necrotic aura become weakened and drained, reducing saves by %d, resistances by %d%%, and damage dealt by %d%%. 
Stacks each turn up to 5 times.
The first point in this talent increases the range of your Necrotic Aura by 1.]], [[在你的死靈光環內的敵人會變得虛弱並被汲取，降低 %d 豁免、%d%% 抵抗以及 %d%% 造成的傷害。
每回合疊加一次，最多 5 次。
投入此技能的第一點會使你的死靈光環範圍增加 1。]], "tformat")
t("Shackle Soul", "靈魂枷鎖", "talent name")
t("A #WHITE##Source##LAST# rises from the corpse of #Target#!", "#WHITE##Source##LAST#從#Target#的屍體中站了起來！", "logCombat")
t([[Your Enervate shackles the souls of your enemies, giving a %d%% chance per Enervate stack for them to raise as a wraith after their death, serving you for %d turns. Wraiths assault your enemies with blasts of cold that deal %0.2f cold damage each turn.
		You cannot have more than 3 wraiths active at a time.
		The first point in this talent increases the range of your Necrotic Aura by 1.]], [[你的衰弱會束縛敵人的靈魂，每層衰弱使他們在死後有 %d%% 機率復活為怨靈，為你效力 %d 回合。怨靈會用寒冰衝擊襲擊你的敵人，每回合造成 %0.2f 點冰霜傷害。
		你同時最多只能擁有 3 隻活躍的怨靈。
		投入此技能的第一點會使你的死靈光環範圍增加 1。]], "tformat")
t("Vampiric Embrace", "吸血擁抱", "talent name")
t([[Drain the life of those you Enervate, causing the melee attacks of you and your allies against them to heal for %d per stack. This effect cannot occur more than once per turn.
		The first point in this talent increases the range of your Necrotic Aura by 1.]], [[汲取受你衰弱目標的生命，使你與盟友對其進行的近戰攻擊每層可治療 %d。此效果每回合最多觸發一次。
		投入此技能的第一點會使你的死靈光環範圍增加 1。]], "tformat")
t("Death Vortex", "死亡漩渦", "talent name")
t([[Your necrotic aura becomes a vortex of pure death for %d turns, dealing %0.2f cold damage and %0.2f darkness damage each turn to all within.
		Foes closer to you take up to 50%% more damage.
		The damage will increase with your Spellpower.
		The first point in this talent increases the range of your Necrotic Aura by 1.
		#PURPLE#Soulforge 4: Targets are pulled towards you.]], [[你的死靈光環化為純粹死亡漩渦，持續 %d 回合，每回合對內部的所有人造成 %0.2f 點冰霜傷害與 %0.2f 點黑暗傷害。
		離你越近的敵人受到的傷害越高，最多增加 50%%。
		傷害將隨著你的法術強度而提升。
		投入此技能的第一點會使你的死靈光環範圍增加 1。
		#PURPLE#靈魂熔爐 4：目標會被拉向你。]], "tformat")

section "data-deathknight/data/talents/spells/dusk.lua"

t("Enshroud", "暗影籠罩", "talent name")
t("'s dark cloud", "的暗雲", "_t")
t([[Shrouds your weapon in darkness, increasing your critical strike chance by %d%%, darkness penetration by %d%% and darkness damage by %d%%. 
		Your critical strikes create living shadows on the target’s tile for 5 turns, which inflict %0.2f darkness damage each turn. 
		Requires a two-handed weapon.
		The damage of the shadows increases with your Spellpower.]], [[以黑暗籠罩你的武器，使你的暴擊機率提升 %d%%、黑暗穿透提升 %d%%，以及黑暗傷害提升 %d%%。
		你的暴擊會在目標的格子上產生一具活體陰影，持續 5 回合，每回合造成 %0.2f 點黑暗傷害。
		需要雙手武器。
		陰影造成的傷害隨你的法術強度提升。]], "tformat")
t("Duskwake", "暮光之跡", "talent name")
t([[Slice through the shadows, moving to the target location and dealing %d%% weapon damage as darkness to all in your path and leaving behind living shadows on the tiles for 5 turns.
#PURPLE#Soulforge 3: On reaching your end location, also attacks adjacent targets and leaves living shadows. Does not attack targets already hit by Duskwake.]], [[斬開陰影並移動至目標位置，對路徑上的所有人造成 %d%% 武器傷害的黑暗傷害，並在格子上留下活體陰影，持續 5 回合。
#PURPLE#靈魂熔爐 3：抵達終點位置時，還會攻擊相鄰的目標並留下活體陰影。不會攻擊已被暮光之跡擊中的目標。]], "tformat")
t("Night's Edge", "夜之鋒刃", "talent name")
t([[Each time you make a melee attack you summon shadow blades that strike up to %d targets within your living shadows for %d%% weapon damage as darkness. This can only occur once per turn, and does not hit the target you originally struck.
		In addition, you deal %d%% increased damage and gain %d%% lifesteal against targets within your living shadows.]], [[每次進行近戰攻擊時，你都會召喚影刃，對你活體陰影內的最多 %d 個目標造成 %d%% 武器傷害的黑暗傷害。此效果每回合只能觸發一次，且不會擊中你原本攻擊的目標。
		此外，你對處於活體陰影內的目標造成的傷害提升 %d%%，並獲得 %d%% 生命偷取。]], "tformat")
t("Lightbane", "毀光者", "talent name")
t("Enshroud must be sustained to cast this spell.", "必須維持「暗影籠罩」才能施放此法術。", "logPlayer")
t([[You form and wield a blade of pure darkness for %d turns. This increases your disarm and silence immunity by 100%%, increases the bonuses from your Enshroud ability by %d%%, and causes your melee attacks to trigger shadow lightning that arcs to up to %d targets, dealing %0.2f darkness damage that leaves behind living shadows.
		The shadow lightning cannot trigger more than once per turn.
		The damage dealt by the shadow lightning will increase with your Spellpower.
#PURPLE#Soulforge 5: All damage you deal is converted to darkness.]], [[你塑造並揮舞一把純粹黑暗之刃，持續 %d 回合。這會使你的繳械與沉默免疫提高 100%%，使你的暗影籠罩能力加成提升 %d%%，並使你的近戰攻擊觸發暗影閃電，最多彈射至 %d 個目標，造成 %0.2f 點黑暗傷害並留下活體陰影。
		暗影閃電每回合最多只能觸發一次。
		暗影閃電造成的傷害將隨你的法術強度提升。
#PURPLE#靈魂熔爐 5：你造成的所有傷害都將轉化為黑暗傷害。]], "tformat")

section "data-deathknight/data/talents/spells/frost.lua"

t("Rime", "白霜", "talent name")
t([[Coats your shield in a thick layer of rime, increasing your block value by %d%% and causing it to retaliate against attackers. On taking damage from an attacker within range 5 there is a %d%% chance for your shield to shock them with frost for %d%% shield damage as cold. 
		If you are blocking, the chance is increased to 100%% and their frost resistance will be reduced by %d%% for 2 turns.
		You get one chance to deal this damage to a particular target each turn]], [[在你的盾牌上塗上一層厚厚的白霜，使你的格擋值提升 %d%%，並使其能對攻擊者進行反擊。當受到距離 5 以內的攻擊者傷害時，有 %d%% 機率使你的盾牌以冰霜震擊對手，造成 %d%% 盾牌傷害的冰霜傷害。
		如果你正在進行格擋，此機率提升至 100%%，且他們的冰霜抵抗將降低 %d%%，持續 2 回合。
		你每回合只有一次機會對特定目標造成此傷害]], "tformat")
t("Icebound Fortitude", "冰封堅韌", "talent name")
t("While Rime is sustained your block ability hardens your armor with a layer of ice, reducing all damage taken by %d%% of your block value (to a minimum of 50%%) for 3 turns.", "當維持白霜時，你的格擋能力會用一層冰霜硬化你的護甲，使受到的所有傷害降低你格擋值的 %d%%（最低降至 50%%），持續 3 回合。", "tformat")
t("Hungering Cold", "飢渴之寒", "talent name")
t("You cannot use Hungering Cold without a shield!", "沒有裝備盾牌，無法使用「飢渴之寒」！", "logPlayer")
t([[Raise your shield, granting a free block and projecting a vortex of freezing air that deals %0.2f cold damage in a radius %d cone and pulls targets towards you. Any target pulled adjacent to you will slam into your shield, taking %d%% shield damage.
	The cold damage dealt will increase with your Spellpower.
#PURPLE#Soulforge 3: After the shield slam, raise your shield for a free Block.]], [[舉起你的盾牌，獲得一次免費格擋，並噴射出一股冰凍空氣漩渦，造成 %0.2f 點冰霜傷害（半徑 %d 的錐形區域），並將目標拉向你。任何被拉到你相鄰位置的目標都會撞上你的盾牌，受到 %d%% 盾牌傷害。
	造成的冰霜傷害將隨你的法術強度提升。
#PURPLE#靈魂熔爐 3：在盾牌猛擊後，舉起你的盾牌獲得一次免費格擋。]], "tformat")
t("Remorseless Winter", "無情凜冬", "talent name")
t([[Surrounds you in a radius 3 storm of freezing cold for %d turns that drains the heat from those around you, dealing %0.2f cold damage over 4 turns and reducing global speed by 10%%, stacking up to 5 times. 
On reaching 5 stacks all stacks are consumed, dealing %0.2f cold damage and freezing the target solid for 3 turns.
This ice block is exceptionally durable, and so ignores stun immunity and is nearly invulnerable, but damage can still pass through it as per a normal iceblock. 
The damage will increase with your Spellpower.
#PURPLE#Soulforge 5: While the storm persists you gain 30%% resist all.]], [[在你周圍產生一個半徑 3 的極寒風暴，持續 %d 回合，汲取周圍目標的熱量，在 4 回合內造成 %0.2f 點冰霜傷害，並降低 10%% 全域速度，最多疊加 5 次。
達到 5 層疊加時會消耗所有層數，造成 %0.2f 點冰霜傷害並將目標凍結 3 回合。
此冰塊異常堅固，因此忽略震懾免疫且近乎無敵，但傷害仍能像普通冰塊一樣穿透它。
傷害將隨你的法術強度提升。
#PURPLE#靈魂熔爐 5：當風暴持續時，你獲得 30%% 所有抵抗。]], "tformat")

section "data-deathknight/data/talents/spells/necrotic-might.lua"

t("Necrotic Strike", "凋零打擊", "talent name")
t([[Channel necrotic forces through your weapon, dealing %d%% weapon damage split evenly between darkness and cold.
The darkness numbs the target and the cold slows the target, reducing the target's damage dealt and global speed by 20%% for %d turns.
All your Necrotic Might attacks also attack with your shield at 50%% damage.
#PURPLE#Soulforge 1: Enemies within radius 2 of the target are also numbed and slowed.]], [[透過武器引導死靈之力，造成 %d%% 武器傷害，平均分配為黑暗與寒冷兩種傷害。
黑暗使目標麻木、寒冷使目標遲緩，令目標造成的傷害與整體速度降低 20%%，持續 %d 回合。
你所有的死靈威能攻擊都會同時以盾牌進行一次 50%% 傷害的攻擊。
#PURPLE#靈魂熔爐 1：目標半徑 2 內的敵人也會被麻木與遲緩。]], "tformat")
t("Soul Reaper", "靈魂收割者", "talent name")
t([[Warp through the darkness to the target, attacking for %d%% weapon damage and claiming their soul for 5 turns. When the claim expires they will take cold damage equal to %d%% of their missing health (to a maximum of %d). 
If they die while marked you consume their soul, gaining %d extra souls.
#PURPLE#Soulforge 4: Gain 50%% resistance penetration for 8 turns.]], [[穿越黑暗直達目標，造成 %d%% 武器傷害並索取其靈魂 5 回合。索取期滿時，目標受到等同其已損失生命 %d%%（上限 %d）的寒冷傷害。 
若目標在標記期間死亡，你將吞噬其靈魂，額外獲得 %d 個靈魂。
#PURPLE#靈魂熔爐 4：獲得 50%% 抵抗穿透，持續 8 回合。]], "tformat")
t("Dark Tide", "黑暗潮汐", "talent name")
t([[Sweep your weapon forward, striking targets in front of you for %d%% weapon damage as cold and projecting a radius %d wave of darkness that inflicts a bane of blindness or confusion. Banes last 5 turns and deal %0.2f darkness damage each turn.
#PURPLE#Soulforge 3: The wave also deals %d%% weapon damage as darkness.]], [[向前橫掃武器，對面前的目標造成 %d%% 武器傷害（寒冷），並放出半徑 %d 的黑暗波動，施加致盲或混亂災厄。災厄持續 5 回合，每回合造成 %0.2f 黑暗傷害。
#PURPLE#靈魂熔爐 3：波動同時造成 %d%% 武器傷害（黑暗）。]], "tformat")
t("Grim Harvest", "冷酷收割", "talent name")
t([[You absorb the fading lifeforce of your foes to rejuvenate yourself.
Each time you kill or deal damage above %d%% of your target’s maximum life with darkness damage you reduce the cooldown of %d talents by 1 turn.
Each time you kill or deal damage above %d%% of your target’s maximum life with cold damage you reduce the duration of a negative effect by %d turns.
Each of these effects cannot occur more than once per turn.]], [[你吸收敵人消逝的生命力來恢復自身。
每當你以黑暗傷害擊殺目標、或單次造成超過目標生命上限 %d%% 的黑暗傷害時，隨機 %d 個技能的冷卻時間減少 1 回合。
每當你以寒冷傷害擊殺目標、或單次造成超過目標生命上限 %d%% 的寒冷傷害時，一個負面效果的持續時間減少 %d 回合。
以上效果每回合各最多觸發一次。]], "tformat")

section "data-deathknight/data/talents/spells/reaping.lua"

t("Spirit Feed", "精魂反哺", "talent name")
t([[Your captured souls empower you, increasing your physical power and spell power by %0.1f, all saves by %0.1f, and your mana regeneration by %0.2f. 
		For each soul you have, the power bonus is increased by %0.2f, the saves by %0.2f, and the mana regeneration by %0.2f, to a maximum of 5 souls.
Current bonuses: %0.2f power, %0.2f saves, %0.2f mana regeneration.]], [[你捕獲的靈魂賦予你力量，使你的物理強度與法術強度提高 %0.1f、所有豁免提高 %0.1f、法力回復提高 %0.2f。 
		你每持有一個靈魂，力量加成額外提高 %0.2f、豁免額外提高 %0.2f、法力回復額外提高 %0.2f，至多計算 5 個靈魂。
目前加成：力量 %0.2f、豁免 %0.2f、法力回復 %0.2f。]], "tformat")
t("Reaper's Shroud", "收割者帷幕", "talent name")
t([[Each time you kill a target you form part of their soul into a protective shield for %d turns, absorbing %d damage. Kills while this talent is on cooldown reduce the cooldown by 1 turn.
		The damage absorbed increases with your spellpower.]], [[每當你擊殺一個目標，你將其部分靈魂鑄成防護之盾，持續 %d 回合，吸收 %d 傷害。本技能冷卻期間的擊殺會使冷卻時間減少 1 回合。
		傷害吸收量隨法術強度提高。]], "tformat")
t("Dark Simulacrum", "黑暗擬態", "talent name")
t("This target has no valid abilities to steal!", "此目標沒有可偷取的有效技能！", "logPlayer")
t([[You steal part of the target’s soul for %d turns. While under this effect, you are able to use one of their abilities at talent level %d, chosen at random.
This cannot steal sustained abilities, prodigies, inscriptions or those with equipment requirements.]], [[你竊取目標的部分靈魂，持續 %d 回合。在此效果期間，你能以技能等級 %d 使用其一項隨機選出的能力。
無法竊取持續型能力、天賦異稟、銘文或有裝備需求的能力。]], "tformat")
t("Shadow of Death", "死亡之影", "talent name")
t([[On taking fatal damage, if you have any souls active you consume them all to become a wraith for %d turns, granting you immunity to all damage and negative effects. 
When this effect ends, if you have any souls you consume them all to resurrect, restoring you to life with %d%% maximum life per soul. If you have no souls you die.]], [[受到致命傷害時，若你持有任何靈魂，將全數消耗並化身怨靈 %d 回合，期間免疫所有傷害與負面效果。 
效果結束時，若你仍持有靈魂，將全數消耗以復活，每個靈魂恢復 %d%% 生命上限；若沒有靈魂，你將死亡。]], "tformat")

section "data-deathknight/data/talents/spells/soul.lua"

t("soul fragment", "靈魂碎片", "_t")
t("Soul Rend", "靈魂撕裂", "talent name")
t([[ Your melee attacks have a 25%% chance to rend the target’s soul for 6 turns, stunning them for %d turns and creating a soul fragment in an adjacent tile lasting %d turns.
		Soul fragments take no actions, and if struck the target will take %0.2f cold damage plus %d%% of their current health (to a maximum of %0.2f) as darkness.
		Targets already affected by Soul Rend will instead take %0.2f cold damage.
		At talent level 4, your melee attacks also have a 25%% chance to rend the soul of those adjacent to your target.
		The damage will increase with your Spellpower.]], [[ 你的近戰攻擊有 25%% 機率撕裂目標的靈魂，持續 6 回合：震懾目標 %d 回合，並在相鄰格生成一個靈魂碎片，存在 %d 回合。
		靈魂碎片不會行動；若碎片被擊中，原目標將受到 %0.2f 寒冷傷害，外加其當前生命 %d%%（上限 %0.2f）的黑暗傷害。
		已受靈魂撕裂影響的目標改為受到 %0.2f 寒冷傷害。
		技能等級 4 時，你的近戰攻擊也有 25%% 機率撕裂目標相鄰敵人的靈魂。
		傷害隨法術強度提高。]], "tformat")
t("Devour Soul", "吞噬靈魂", "talent name")
t([[Devours the souls of targets in a radius %d cone, dealing %0.2f darkness damage. This will consume Soul Rend to remove up to %d beneficial physical or magical effects from the target.
		Against those unaffected by Soul Rend, this has a 50%% chance to inflict Soul Rend.
		The damage will increase with your Spellpower.
#PURPLE#Soulforge 2: Increase the chance of Soul Rend to 100%% and increase the number of beneficial effects removed by 1.]], [[吞噬半徑 %d 錐形範圍內目標的靈魂，造成 %0.2f 黑暗傷害。這會消耗目標身上的靈魂撕裂效果，移除其至多 %d 個物理或魔法增益效果。
		對未受靈魂撕裂影響的目標，有 50%% 機率施加靈魂撕裂。
		傷害隨法術強度提高。
#PURPLE#靈魂熔爐 2：靈魂撕裂的施加機率提高到 100%%，且移除的增益效果數量 +1。]], "tformat")
t("Wail of Doom", "末日哀嚎", "talent name")
t([[You let out a chilling wail that shatters the minds of enemies within radius %d, dealing %0.2f cold damage. For %d turns they have a %d%% chance to fail when using a talent.
		If the target is affected by Soul Rend, the effect is removed to increase damage and duration by 50%%.
		The damage will increase with your Spellpower.
#PURPLE#Soulforge 3: Spellshocks and Brainlocks for the duration.]], [[你發出令人膽寒的哀嚎，粉碎半徑 %d 內敵人的心智，造成 %0.2f 寒冷傷害。之後 %d 回合內，他們使用技能時有 %d%% 機率失敗。
		若目標受靈魂撕裂影響，移除該效果並使傷害與持續時間提高 50%%。
		傷害隨法術強度提高。
#PURPLE#靈魂熔爐 3：期間施加法術震盪與腦域封鎖。]], "tformat")
t("Black Mirror", "黑鏡", "talent name")
t("'s Dark Reflection", "的黑暗倒影", "_t")
t("A blurred, shadowy copy of the original creature.", "原生物的一份模糊暗影複製體。", "_t")
t("#F53CBE#%s's soul is drawn out and attacks!", "#F53CBE#%s的靈魂被抽離並發動攻擊！", "logSeen")
t([[You draw out powerful soul fragments from all targets within 10 tiles under the effect of Soul Rend, removing the effect and creating an exact duplicate of them with 30%% of their maximum life and 40%% of their damage that lasts %d turns.
#PURPLE#Soulforge 5: Increases the life of fragments to 45%% and damage to 60%%.]], [[你從 10 格內所有受靈魂撕裂影響的目標身上抽出強大的靈魂碎片，移除該效果並創造他們的完全複製體，複製體擁有本體 30%% 的生命上限與 40%% 的傷害，持續 %d 回合。
#PURPLE#靈魂熔爐 5：複製體的生命提高至 45%%、傷害提高至 60%%。]], "tformat")

section "data-deathknight/data/talents/spells/soulforge.lua"

t("Soulforge", "靈魂熔爐", "talent name")
t([[You begin forging souls into your weapon, causing your next active ability to trigger an additional effect at the cost of souls. The soul cost and effect is displayed on each individual ability tooltip.
This ability takes no time to activate.]], [[你開始將靈魂鍛入武器，使你的下一個主動能力以靈魂為代價觸發額外效果。靈魂消耗與效果顯示在各能力的提示框中。
此能力不消耗行動時間。]], "tformat")
t("Soul Tap", "靈魂汲取", "talent name")
t([[Each time you trigger your soulforge ability you tap into the soul’s energy, restoring %d life and %d mana per soul.
The life and mana restored will increase with your Spellpower.]], [[每當你觸發靈魂熔爐能力，你汲取靈魂的能量，每個靈魂恢復 %d 生命與 %d 法力。
生命與法力恢復量隨法術強度提高。]], "tformat")
t("Dirge", "輓歌", "talent name")
t("Each time you trigger your soulforge ability you are empowered by the soul, increasing your global speed by %d%% for %d turns. Stacks up to 5 times.", "每當你觸發靈魂熔爐能力，靈魂將賦予你力量，整體速度提高 %d%%，持續 %d 回合。至多疊加 5 層。", "tformat")
t("Endless Cycle", "無盡循環", "talent name")
t("Each time you trigger your soulforge ability, you have a %d%% chance to refund 1 soul.", "每當你觸發靈魂熔爐能力，你有 %d%% 機率返還 1 個靈魂。", "tformat")
t("Soulburn", "靈魂燃燒", "talent name")
t("You draw on the power of your souls to fuel your spells, causing your next spell within 1 turn to have %d%% increased Spellpower, %d%% reduced cooldown and refund %d%% of a turn.", "你汲取靈魂之力灌注法術，使你 1 回合內的下一個法術獲得 %d%% 法術強度加成、冷卻時間減少 %d%%，並返還 %d%% 的行動時間。", "tformat")

section "data-deathknight/data/talents/spells/spells.lua"

t("necrotic might", "死靈威能", "talent type")
t("Powerful weapon techniques fuelled by necrotic magic.", "以死靈魔法驅動的強大武技。", "_t")
t("undeath", "不死", "talent type")
t("Raise the living dead to overwhelm your enemies.", "喚起亡者以壓制你的敵人。", "_t")
t("desecration", "褻瀆", "talent type")
t("Twist the boundries between life and death to empower yourself.", "扭曲生死的界線以強化自身。", "_t")
t("frost", "冰霜", "talent type")
t("Call upon the chill of the grave to protect yourself.", "召喚墓穴的寒意來保護自己。", "_t")
t("dread", "畏懼", "talent type")
t("Inflict dread and despair on those within your necrotic aura.", "對身處你死靈光環內的敵人施加恐懼與絕望。", "_t")
t("dusk", "暮光", "talent type")
t("Imbue your weapon with utter darkness.", "為你的武器灌注絕對的黑暗之力。", "_t")
t("reaping", "收割", "talent type")
t("Use the stolen souls of your enemies to empower yourself.", "利用奪取自敵人的靈魂來強化自身。", "_t")
t("soul", "靈魂", "talent type")
t("Rend the very souls of your foes apart.", "將敵人的靈魂徹底撕裂。", "_t")
t("squire", "侍從", "talent type")
t("Raise a loyal undead squire to fight by your side.", "喚起一名忠誠的不死侍從並肩作戰。", "_t")
t("soulforge", "靈魂熔爐", "talent type")
t("Forge the souls of your fallen enemies into your weapon.", "將倒下敵人的靈魂鑄入你的武器之中。", "_t")

section "data-deathknight/data/talents/spells/squire.lua"

t("Squire Talents:", "侍從技能：", "_t")
t("Shadow Assault", "暗影突襲", "talent name")
t("Step through the shadows to your target, striking it with your shield for %d%% damage as darkness. If this attack lands, you will stun the target for %d turns and follow up with a melee attack for %d%% weapon damage.", "穿越暗影來到目標身邊，以盾牌打擊目標，造成 %d%% 傷害（黑暗）。若此擊命中，震懾目標 %d 回合，並接著發動一次 %d%% 武器傷害的近戰攻擊。", "tformat")
t("Challenging Shout", "挑戰怒吼", "talent name")
t("Leap to the targeted area and taunt all enemies within radius %d, as well as gaining a damage shield for 8 turns absorbing %d damage.", "躍向目標區域並嘲諷半徑 %d 內的所有敵人，同時獲得吸收 %d 傷害的傷害護盾，持續 8 回合。", "tformat")
t("Dusk Shield", "暮光之盾", "talent name")
t("Your block ability now grants your summoner a shield absorbing %d%% of your shield's block value, and each time you take damage from an adjacent enemy, there is a %d%% chance to retaliate with a melee attack for %d%% weapon damage as darkness. You get one chance to deal this damage to a particular target each turn.", "你的格擋能力現在會為你的召喚者提供一個護盾，吸收量為你盾牌格擋值的 %d%%；且每當你受到相鄰敵人的傷害，有 %d%% 機率以近戰反擊，造成 %d%% 武器傷害（黑暗）。對同一目標每回合僅能觸發一次此反擊。", "tformat")
t("Dark Aegis", "黑暗神盾", "talent name")
t("Increases your maximum life by %d%% and reduces your chance to be critically hit and the duration of negative effects by %d%%.", "生命上限提高 %d%%，被暴擊的機率與負面效果的持續時間降低 %d%%。", "tformat")
t("Squire: Melee", "侍從：近戰", "talent name")
t("undead squire", "亡靈侍從", "talent name")
t("Clad in nigh-impenetrable armour and wielding sword and shield with great skill, this undead warrior tirelessly defends it's master.", "這名亡靈戰士身披近乎無法穿透的重甲，嫻熟地揮舞著劍與盾，不知疲倦地守護其主人。", "_t")
t("longsword", "長劍", "effect subtype")
t("massive", "巨型", "effect subtype")
t("hands", "手部", "effect subtype")
t("feet", "腳部", "effect subtype")
t([[Call your undead squire to your side, commanding him to defend you with sword and shield. The squire gains +%d Strength, +%d Dexterity, and +%d Constitution, and learns the Riposte, Armor Training, Weapon Mastery and Weapon Accuracy talents.
		Your squire also knows the following talents at a level equal to your Raise Dead, based off your total talent point investment in the Squire category:
		0: Shadow Assault - Teleport to a foe, striking them with all weapons and stunning them.
		6: Challenging Shout - Leap to a target area, taunting foes and gaining a damage shield.
		11: Dusk Shield - Retaliate against attackers with darkness damage, and grant your master a shield on using block.
		16: Dark Aegis - Increases maximum life and reduces the chance to be critically struck and the duration of negative effects.
		You can only have a single squire active at one time.
		The stat bonuses will improve with your Spellpower.]], [[呼喚你的亡靈侍從來到身邊，命令他以劍盾護衛你。侍從獲得 +%d 力量、+%d 敏捷與 +%d 體質，並學會還擊、護甲訓練、武器掌握與武器命中技能。
		你的侍從還會依你在侍從系的技能點總投資，以等同你「喚醒死者」的等級掌握下列技能：
		0：暗影突襲——傳送至敵人身邊，以所有武器攻擊並震懾之。
		6：挑戰怒吼——躍向目標區域，嘲諷敵人並獲得傷害護盾。
		11：暮光之盾——以黑暗傷害反擊攻擊者，並在格擋時為主人提供護盾。
		16：黑暗神盾——提高生命上限，降低被暴擊機率與負面效果持續時間。
		同一時間只能有一名侍從。
		屬性加成隨法術強度提高。]], "tformat")
t("Raise Dead", "喚醒死者", "talent name")
t([[Summon your loyal undead squire to your side, ready for battle. Your squire's primary stat will be improved by %d, its two secondary stats by %d, and it inherits base stats from you.
		The squire wields a sword and shield, and knows unique combat techniques.
		Your squire will teleport back to you if you are more than %d tiles from you.
		The squire's stat bonuses will improve with your Spellpower.]], [[召喚你忠誠的亡靈侍從加入戰鬥。侍從的主屬性提高 %d、兩項副屬性提高 %d，並繼承你的基礎屬性。
		侍從持劍與盾，掌握獨特的戰鬥技巧。
		當侍從距離你超過 %d 格時會傳送回你身邊。
		侍從的屬性加成隨法術強度提高。]], "tformat")
t("Death Pact", "死亡契約", "talent name")
t("#CRIMSON##Source# transfers his wounds to #Target#!", "#CRIMSON##Source# 將他的傷勢轉移給 #Target#！", "_t")
t([[You transfer your wounds to your squire, healing yourself for %d%% of your maximum life and damaging them for 50%% of this value.
		This can be used on your other minions at 50%% effectiveness and cooldown, but the minion will be destroyed.
		The healing increases with your Spellpower.
		#PURPLE#Soulforge 2: Also transfers 3 negative effects if used on your squire.]], [[你將自身傷勢轉移給侍從，治療自己 %d%% 生命上限，並對侍從造成該數值 50%% 的傷害。
		也可對其他僕從使用，效果與冷卻時間皆為 50%%，但該僕從會被摧毀。
		治療量隨法術強度提高。
		#PURPLE#靈魂熔爐 2：對侍從使用時額外轉移 3 個負面效果。]], "tformat")
t("Soul Link", "靈魂連結", "talent name")
t("#PURPLE#(%d shared)#LAST#", "#PURPLE#(%d 共享)#LAST#", "tformat")
t("You and your squire link your souls, causing %d%% of all damage you take to be redirected to your squire, and %d%% of all damage you deal to heal your squire.", "你與侍從靈魂相繫，你受到的所有傷害的 %d%% 轉由侍從承受，你造成的所有傷害的 %d%% 用於治療侍從。", "tformat")
t("Dark Transformation", "黑暗轉化", "talent name")
t([[Your squire becomes a powerful undead monstrosity for %d turns, greatly increasing their combat ability. While under this effect all damage they take is reduced by %d%%, they automatically taunt all foes in radius %d each turn, their Dusk Shield counterattack can attack at range %d, and all melee attacks trigger a shield bash for %d%% shield damage as darkness.
		#PURPLE#Soulforge 5: Grants immunity to negative effects and increase global speed by 30%%.]], [[你的侍從化為強大的亡靈巨怪，持續 %d 回合，大幅提升其戰鬥能力。在此效果期間，其受到的所有傷害降低 %d%%、每回合自動嘲諷半徑 %d 內的所有敵人、暮光之盾的反擊可達 %d 格射程，且所有近戰攻擊都會觸發一次 %d%% 盾牌傷害（黑暗）的盾擊。
		#PURPLE#靈魂熔爐 5：免疫負面效果，且整體速度提高 30%%。]], "tformat")

section "data-deathknight/data/talents/spells/undeath.lua"

t("Grasping Claws", "攫取之爪", "talent name")
t([[Grab a target, holding it down and strangling it for %d turns.
		The grab will also deal %0.2f physical damage per turn.
		The damage will increase with your Physical Power.]], [[抓住目標，將其按倒並絞勒，持續 %d 回合。
		擒拿期間每回合造成 %0.2f 物理傷害。
		傷害隨物理強度提高。]], "tformat")
t("ghoul warrior", "食屍鬼戰士", "talent name")
t("This ghoul has been equipped with some tattered chainmail and a rusted mace, which it swings with inhuman force.", "這隻食屍鬼披掛著破爛的鎖甲、握著一柄生鏽的釘頭錘，以非人的力量揮舞著它。", "_t")
t("mace", "釘頭錘", "effect subtype")
t("heavy", "重型", "effect subtype")
t("%s explodes into a burst of necrotic energy!", "%s 爆炸並釋放出一股壞死能量！", "logSeen")
t("Unlike it's lesser brethren, this ghoul has retained it's mastery of combat, and has been further enhanced with dark magic to give it greater strength and skill.", "與低等的同類不同，這隻食屍鬼保留了生前的戰鬥造詣，更被黑暗魔法強化，獲得了更強的力量與技巧。", "_t")
t("elite ghoul warrior", "精英食屍鬼戰士", "talent name")
t("greatmaul", "巨槌", "effect subtype")
t("Call of the Grave", "墓穴召喚", "talent name")
t([[You raise 2 ghouls from the ground around the target and channel an attack through each, dealing %d%% weapon damage as cold. Ghouls last 6 turns.
#PURPLE#Soulforge 3: Instead summon elite ghoul warriors, who wield greatmauls and have increased combat ability.]], [[你在目標周圍的地面喚起 2 隻食屍鬼，並透過每一隻引導攻擊，造成 %d%% 武器傷害（寒冷）。食屍鬼存在 6 回合。
#PURPLE#靈魂熔爐 3：改為召喚精英食屍鬼戰士，他們持巨錘且戰鬥能力更強。]], "tformat")
t("Meat Shield", "肉盾", "talent name")
t("Not enough space for the ghoul to block!", "沒有足夠的空間讓食屍鬼格擋！", "logPlayer")
t("Your ghouls taunt enemies within radius %d when summoned, and when a single hit deals more than %d%% of your maximum life a ghoul will rise to block the blow, absorbing %d%% of the damage from the blow and other attacks for 3 turns.", "你的食屍鬼在被召喚時嘲諷半徑 %d 內的敵人；當你單次受到超過生命上限 %d%% 的傷害時，一隻食屍鬼會挺身格擋，吸收該擊與其後攻擊的 %d%% 傷害，持續 3 回合。", "tformat")
t([[On your ghouls dying they explode in a radius %d burst of necrotic energy. All enemies struck will waste away, taking %0.2f darkness damage over 6 turns and having their powers reduced by %d%%.
The damage will increase with your Spellpower.]], [[你的食屍鬼死亡時會爆發半徑 %d 的死靈能量。被波及的敵人將逐漸凋零，在 6 回合內受到共 %0.2f 黑暗傷害，且各項強度降低 %d%%。
傷害隨法術強度提高。]], "tformat")
t("Necrotic Wall", "壞死之牆", "talent name")
t("horror", "恐懼之物", "effect subtype")
t("corpsewall", "屍牆", "talent name")
t("A towering wall of flesh and bone.", "一堵高聳的血肉白骨之牆。", "_t")
t([[Creates a towering wall of flesh and bone of %d length at the target location for 8 turns.
Each segment deals an additional %0.2f blight damage (with a 20%% chance to disease) and %0.2f bleed damage over 5 turns on dealing or taking a melee hit.
Segments are extremely durable (40%% resist all) and completely block line of sight.
#PURPLE#Soulforge 5: The wall segments learn the Grasping Claws talent, allowing them to grapple and disable enemies.]], [[在目標位置創造一道長度 %d、由血肉與白骨築成的高牆，持續 8 回合。
每一段牆體在造成或受到近戰攻擊時，額外造成 %0.2f 枯萎傷害（20%% 機率致病）與 5 回合內共 %0.2f 的流血傷害。
牆體極為堅固（40%% 全抵抗）且完全阻擋視線。
#PURPLE#靈魂熔爐 5：牆體習得攫取之爪技能，能擒拿並癱瘓敵人。]], "tformat")

section "data-deathknight/init.lua"

t("Deathknight", "死亡騎士", "init.lua long_name")
t("Adds the Deathknight class.", "新增死亡騎士職業。", "init.lua description")

section "salvage-extra"

t("%s resists the stun!", "%s抵抗了震懾！", "logSeen")
t("%s resists the blindness!", "%s抵抗了致盲!", "logSeen")
t("%s resists the silence!", "%s抵抗了沉默！", "logSeen")
t("%s resists the confusion!", "%s抵抗了混亂！", "logSeen")
t("#Source# drains life from #Target#!", "#Source#從#Target#吸取了生命！", "logCombat")
t("Their most important stats are: Strength and Magic", "他們最重要的屬性是：力量和魔法。", "_t")
t("#GOLD#Stat modifiers:", "#GOLD# 屬性修正：", "_t")
t("#GOLD#Life per level:#LIGHT_BLUE# +2", "#GOLD# 每等級生命加值： #LIGHT_BLUE# +2", "_t")
t("necrotic might", "死靈偉力", "_t")
t("undeath", "不死", "_t")
t("desecration", "褻瀆", "_t")
t("frost", "冰霜", "_t")
t("dread", "夢魘", "_t")
t("dusk", "黃昏", "_t")
t("reaping", "靈魂收割", "_t")
t("soul", "靈魂", "_t")
t("squire", "侍從", "_t")
t("soulforge", "鑄魂", "_t")
t("#Target#'s soul has been claimed.", "#Target#的靈魂已被標記。", "logSeen")
t("#Target#'s soul is free of the claim.", "#Target#的靈魂已擺脫標記。", "logSeen")
t("#DARK_GREEN##Source# shares damage with %s ghoul!", "#DARK_GREEN##Source#將傷害分擔給了%s的食屍鬼！", "logSeen")
t("The target will not die until falling below -%d life.", "目標不會死亡，直到生命降至 -%d 以下。", "tformat")
t("#Target# seems much more resilient!.", "#Target#看起來更加強韌了！", "logSeen")
t("#Target# no longer seems as resilient.", "#Target#看起來不再那麼強韌。", "logSeen")
t("Next spell gains additional effects.", "下一個法術將獲得額外效果。", "_t")
t("#Target# weapon burns with cold flames!", "#Target#的武器燃起了寒冷的火焰！", "logSeen")
t("The cold fire around #Target#'s weapon dies down.", "#Target#武器周圍的寒冷火焰逐漸熄滅。", "logSeen")
t("#Target#'s armor is covered in a thick layer of ice.", "#Target#的護甲覆上了一層厚厚的寒冰。", "logSeen")
t("#Target#'s ice armor melts away.", "#Target#的寒冰護甲逐漸融化。", "logSeen")
t("%s(%d deflected)#LAST#", "%s（偏斜 %d）#LAST#", "tformat")
t("#Target# is weakened by the necrotic aura.", "#Target#因死靈光環而變得虛弱。", "logSeen")
t("#Target# regains their strength.", "#Target#恢復了力量。", "logSeen")
t("#Target# begins drawing in the souls of nearby foes!", "#Target#開始汲取附近敵人的靈魂！", "logSeen")
t("The necrotic vortex surrounding #Target# dissipates.", "圍繞#Target#的死靈漩渦逐漸消散。", "logSeen")
t("%s is pulled in!", "%s被拉了過去！", "logSeen")
t("#Target# wields a blade of pure darkness!", "#Target#揮舞出一把純粹暗影構成的利刃！", "logSeen")
t("#Target#'s dark weapon fades.", "#Target#的暗影武器逐漸消退。", "logSeen")
t("#Target#'s soul has been rent.", "#Target#的靈魂已遭撕裂。", "logSeen")
t("#Target#'s soul is whole again.", "#Target#的靈魂恢復完整。", "logSeen")
t("#Target#'s mind is shattered!", "#Target#的心智被擊碎了！", "logSeen")
t("#Target#'s mind recovers.", "#Target#的心智恢復了。", "logSeen")
t("#Target# crackles with necrotic energy!", "#Target#周身迸發出死靈能量的劈啪聲！", "logSeen")
t("The necrotic energy around #Target# fades", "圍繞#Target#的死靈能量逐漸消退", "logSeen")
t("Increases global speed by %d%%.", "使全域速度提升 %d%%。", "tformat")
t("#PURPLE#As #Target# falls, a terrible wraith rises from their body!", "#PURPLE#當#Target#倒下時，一個可怕的怨靈從其軀體中升起！", "logSeen")
t("The wraith returns to #Target#'s body", "怨靈返回了#Target#的軀體", "logSeen")
t("#Target#'s wastes away!", "#Target#正逐漸衰敗！", "logSeen")
t("#Target# recovers from the wasting.", "#Target#從衰敗中恢復過來。", "logSeen")
t("#Target#'s becomes an undead monstrosity!", "#Target#化為了不死怪物！", "logSeen")
t("#Target#'s returns to their original form.", "#Target#恢復成了原本的樣貌。", "logSeen")
