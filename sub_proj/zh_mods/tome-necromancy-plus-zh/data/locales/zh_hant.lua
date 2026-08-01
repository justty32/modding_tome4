locale "zh_hant"

section "data-necromancy+/data/birth/classes/mage.lua"

t("Spiritmancer", "通靈法師", "birth descriptor name")
t("The dead do not always rest easy, even free from fell influences.", "死者未必總能安息，即使已擺脫邪惡力量的影響。", "_t")
t("Some linger, wishing to finish some unfinished business.", "有些亡魂流連不去，只為了完成未竟之事。", "_t")
t("Others want to pass on a message to a loved one.", "有些則想將訊息傳達給心愛之人。", "_t")
t("Some seek another chance for glory in battle or revenge against those who killed them.", "有些則渴望再戰一場以贏得榮耀，或是向殺害自己的兇手復仇。", "_t")
t("They all eventually find a Spiritmancer, and bargain temporary servitude for closure.", "他們最終都會尋得一位通靈法師，以短暫的效命換取解脫。", "_t")
t("The Spiritmancer can give form to the lost souls, allowing them to fight again. They also have powerful light and lightning magic.", "通靈法師能賦予迷失亡魂以形體，讓他們得以再度戰鬥。他們也擅長強大的光明與雷電魔法。", "_t")
t("elm staff", "榆木法杖", "birth descriptor name")
t("linen robe", "亞麻長袍", "birth descriptor name")

section "data-necromancy+/data/boss-artifacts.lua"

t("long sharp scalpel", "鋒利的長解剖刀", "entity name")

section "data-necromancy+/data/cults-artifacts.lua"

t("Staff of Bones", "白骨法杖", "entity name")
t("bone staff", "骨製法杖", "entity name")
t("A staff made out of the bones of fallen foes. Disgustingly powerful.", "一根以倒下敵人的骨骸打造而成的法杖，其力量令人作嘔地強大。", "_t")
t("It seems willing and able to talk to you (use Command Staff).", "它似乎願意且能夠與你交談（使用「法杖掌控」）。", "_t")
t("Growing more powerful? Still pathetic compared to a True Necromancer!", "變得更強大了？跟真正的死靈法師比起來還是弱得可悲！", "_t")
t("Ahh the rush of power... I love that!", "啊～那股力量湧現的快感……我最愛這個了！", "_t")
t("What feeble power you wield now is nothing!", "你現在揮舞的這點微弱力量根本不算什麼！", "_t")
t("Yes yes you've leveled up, so what?", "對對對，你升級了，那又怎樣？", "_t")
t("One more level, that's hardly impressive you know?", "又升了一級，這沒什麼好得意的，你知道嗎？", "_t")
t("If you weren't so useless I'd be nearly impressed by that new level...", "要不是你這麼沒用，我幾乎要對這次升級感到佩服了……", "_t")
t("KILL! KILL!", "殺！殺！", "_t")
t("We require more souls!", "我們需要更多靈魂！", "_t")
t("Destroy them all! OBEY!", "把他們全部消滅！服從命令！", "_t")
t("FEED ME!", "餵飽我！", "_t")
t("I nee ..err.. you need more souls. Yes you...", "我需...呃...你需要更多靈魂。對，是你……", "_t")
t("Pain and misery, spread them!", "散播痛苦與悲慘！", "_t")
t("I love the smell of a fresh corpse.", "我喜愛新鮮屍體的氣味。", "_t")
t("Splatter me with the blood of our foes!", "用敵人的鮮血潑灑我吧！", "_t")
t("That one wasn't such an impressive kill...", "那次擊殺沒什麼了不起的……", "_t")
t("Getting a bit sloppy on the kills no?", "殺得有點隨便了，是吧？", "_t")

section "data-necromancy+/data/damage_types.lua"

t("crystaline snare", "水晶陷阱", "damage type")
t("pool of light", "光池", "damage type")

section "data-necromancy+/data/talents/spells/alter-spells.lua"

t("Summon Wisp", "召喚光靈", "talent name")
t([[Surround yourself with ghostly energies, increasing you cold damage and resistance by %d%%. When one of your minions is destroyed while inside your necrotic aura, it has a %d%% chance to create a will o' the wisp.
The will o' the wisp will take a random target in sight and home in on it. When it reaches the target, it will explode for %0.2f cold damage.
Also, when you hit an enemy with a spell you have a %d%% chance of summoning a wisp.
The damage will increase with your Spellpower.]], [[以幽靈能量環繞自身，提升你的寒冷傷害與抵抗 %d%%。當你的一個僕從在死亡光環內被摧毀時，有 %d%% 機率產生一個鬼火。
鬼火會選擇視野內的一個隨機目標並朝其飛去。當它接觸到目標時，會爆炸並造成 %0.2f 點寒冷傷害。
此外，當你用法術擊中敵人時，有 %d%% 機率召喚一個光靈。
傷害受法術強度加成。]], "tformat")
t("cold flames", "冷焰", "talent name")
t([[Cold Flames slowly spread from %d spots in a radius of %d around the targeted location. The flames deal %0.2f cold damage, and have a chance of freezing.
These flames will also slowly burn physical and magical status effects, beneficial from enemies, detrimental form allies.
Damage improves with your Spellpower.]], [[冷焰緩慢自 %d 個地點擴散，範圍在目標位置半徑 %d 內。火焰造成 %0.2f 點寒冷傷害，並有機率凍結。
這些火焰也會緩慢燃燒物理與魔法狀態效果（敵方的有益狀態與盟友的有害狀態）。
傷害受法術強度加成。]], "tformat")
t("Ghost Touch", "幽靈之觸", "talent name")
t([[Curse your target with a deathly chill, weakening their mind save, cold resistance and stun resistance by %d for 10 turns.
		Becomes radius 1 with Essence of the Dead.
		The curse will increase with your Spellpower.]], [[以死亡般的寒意詛咒目標，降低其精神豁免、寒冷抵抗與震懾抵抗 %d ，持續 10 回合。
		搭配「亡者精華」時半徑變為 1。
		此詛咒效果受法術強度加成。]], "tformat")
t("Aura Mastery", "光環掌控", "talent name")
t("Your dark power radiates further as you grow stronger. Increases the radius of your necrotic aura by %d, and reduces the decay rate of your minions outside the aura by %d%%.", "隨著你變得更強，你的黑暗力量傳播得更遠。使你的死亡光環半徑提升 %d，並降低光環外僕從 %d%% 的衰退速度。", "tformat")
t("degenerated skeleton warrior", "退化骷髏戰士", "talent name")
t("greatsword", "大劍", "effect subtype")
t("skeleton warrior", "骷髏戰士", "talent name")
t("armoured skeleton warrior", "披甲骷髏戰士", "talent name")
t("longsword", "長劍", "effect subtype")
t("heavy", "重型", "effect subtype")
t("skeleton archer", "骷髏射手", "talent name")
t("longbow", "長弓", "effect subtype")
t("arrow", "箭矢", "effect subtype")
t("skeleton master archer", "骷髏大師射手", "talent name")
t("skeleton mage", "骷髏法師", "talent name")
t("staff", "法杖", "effect subtype")
t("ghoul", "食屍鬼", "talent name")
t("ghast", "妖鬼", "talent name")
t("ghoulking", "食屍鬼王", "talent name")
t("vampire", "吸血鬼", "effect subtype")
t("vampire", "吸血鬼", "talent name")
t("master vampire", "吸血鬼大師", "talent name")
t("wight", "屍妖", "effect subtype")
t("grave wight", "墓穴屍妖", "talent name")
t("barrow wight", "古塚屍妖", "talent name")
t("ghost", "幽靈", "effect subtype")
t("dread", "懼魔", "talent name")
t("cloth", "布甲", "effect subtype")
t("head", "頭部", "effect subtype")
t("feet", "腳部", "effect subtype")
t("cloak", "披風", "effect subtype")
t("amulet", "護身符", "effect subtype")
t("ring", "戒指", "effect subtype")
t("lich", "巫妖", "talent name")
t("mummy", "木乃伊", "effect subtype")
t("mummy lord", "木乃伊領主", "talent name")
t("giant", "巨人", "effect subtype")
t("bone giant", "骨巨人", "talent name")
t("heavy bone giant", "重裝骨巨人", "talent name")
t("eternal bone giant", "永恆骨巨人", "talent name")
t("runed bone giant", "符文骨巨人", "talent name")
t("Undeath Link", "亡靈連結", "talent name")
t([[Absorb up to %d%% of the maximum life of each of your necrotic minions (even negative life, possibly destroying them). This will heal you for half of the total amount absorbed.
		The healing will increase with your Spellpower.]], [[吸收你每個亡靈僕從最多 %d%% 的最大生命（即使是負生命，也可能因此摧毀牠們）。這會治療你所吸收總量的一半。
		治療效果受法術強度加成。]], "tformat")
t([[Minions are only tools. You may dispose of them... violently.
Makes the targeted minion explode for %d%% of its maximum life as blight damage.
If used on a Wisp, it will do cold/freeze damage instead.
If used on a Bone Giant, it will do physical damage instead and form a temporary shield around you that prevents any attacks from doing more than %d%% of your total life for %d turns.
Beware! Don't get caught in the blast! (unless you know Dark Empthy: %d%% chance to ignore damage)]], [[僕從只是工具。你可以...暴力地處置牠們。
使目標僕從爆炸，造成其最大生命 %d%% 的枯萎傷害。
若對光靈使用，會改為造成寒冷/凍結傷害。
若對骨巨人使用，會改為造成物理傷害，並在你周圍形成一個臨時護盾，限制任何單次攻擊傷害不超過你總生命的 %d%%，持續 %d 回合。
當心！別被爆炸波及！（除非你習得黑暗共鳴：有 %d%% 機率無視傷害）]], "tformat")
t([[Combines 3 of your skeletons into a bone giant.
At level 1, it makes a bone giant.
At level 3, it makes a heavy bone giant.
At level 5, it makes an eternal bone giant.
At level 7, it makes a runed bone giant.
Only one bone giant can be active at any time.]], [[將你的 3 個骷髏組合成一個骨巨人。
在等級 1 時，製造一個骨巨人。
在等級 3 時，製造一個重裝骨巨人。
在等級 5 時，製造一個永恆骨巨人。
在等級 7 時，製造一個符文骨巨人。
同一時間只能存在一個骨巨人。]], "tformat")
t("Soulwinds", "靈魂之風", "talent name")
t([[Surround yourself with unearthly winds. When one of your minions is destroyed the Soulwinds have a %d%% chance to restore the soul to you.
		The Soulwinds will also increase the movement speed of all your undead minions by %d%%.
		The speed boost will increase with your Spellpower.]], [[以異界之風環繞自身。當你的一個僕從被摧毀時，靈魂之風有 %d%% 的機率為你恢復靈魂。
		靈魂之風也會提升你所有亡靈僕從 %d%% 的移動速度。
		速度提升效果受法術強度加成。]], "tformat")
t([[Each minion you summon has a chance to be a more advanced form of undead. 
In addition all damage done by your minions to other minions is reduced by %d%% (except Retch).
Your chance for each type of minion is as follows:%s]], [[你召喚的每個僕從都有機率成為更進階的亡靈。
此外，你的僕從對其他僕從造成的所有傷害都降低 %d%%（嘔吐除外）。
你召喚各類型僕從的機率如下：%s]], "tformat")
t("human farmer", "人類農夫", "talent name")
t("human", "人類", "effect subtype")
t("A weather-worn human farmer, looking at a loss as to what's going on.", "一個飽經風霜的人類農夫，對眼前的狀況感到一頭霧水。", "_t")
t("halfling gardener", "半身人園丁", "talent name")
t("halfling", "半身人", "effect subtype")
t("A rugged halfling gardener, looking quite confused as to what he's doing here.", "一個健壯的半身人園丁，對自己為何在此感到相當困惑。", "_t")
t("shalore scribe", "夏洛爾抄寫員", "talent name")
t("shalore", "夏洛爾", "effect subtype")
t("A scrawny elven scribe, looking bewildered at his surroundings.", "一個瘦弱的精靈抄寫員，對周圍的環境感到茫然。", "_t")
t("dwarven lumberjack", "矮人伐木工", "talent name")
t("dwarf", "矮人", "effect subtype")
t("A brawny dwarven lumberjack, looking a bit upset at his current situation.", "一個強壯的矮人伐木工，對自己目前的處境似乎有點生氣。", "_t")
t("cute bunny", "可愛小兔", "talent name")
t("rodent", "齧齒動物", "effect subtype")
t("It is so cute!", "牠好可愛！", "_t")
t([[Surround your minions in a veil of darkness. The darkness will teleport them to you, and grant them %d%% evasion for 5 turns.
Also reaches through the shadows into quieter places, summoning %d harmless creatures.
Those creatures are then cursed with a Curse of Hate, making all hostile foes try to kill them.
If the summoned creatures are killed by hostile foes, you have 70%% chance to gain a soul.
The evasion chance will increase with your Spellpower.]], [[用黑暗面紗包圍你的僕從。黑暗會將他們傳送到你身邊，並提供 %d%% 閃避，持續 5 回合。
同時穿過陰影抵達更寧靜之處，召喚 %d 隻無害的生物。
這些生物隨後會被施加仇恨詛咒，使所有敵對目標試圖殺死牠們。
如果召喚的生物被敵對目標殺死，你有 70%% 機率獲得一個靈魂。
閃避機率隨你的法術強度提升。]], "tformat")
t("Nether Breach", "幽冥裂隙", "talent name")
t([[Rupture reality to temporarily open a passage to the nether, triggering %d random darkness explosions in the target area.
Each explosion does %0.2f darkness damage in radius 2, and will each trigger at one turn intervals.
Counts as a Nightfall spell for determining if it will hurt minions.
The damage will increase with your Spellpower.]], [[撕裂現實以暫時開啟一條通往冥界的通道，在目標區域觸發 %d 次隨機黑暗爆炸。
每次爆炸在半徑 2 內造成 %0.2f 點黑暗傷害，且每次爆炸會間隔一回合觸發。
在判定是否會傷害僕從時，此技能視為暮光法術。
傷害隨你的法術強度提升。]], "tformat")

section "data-necromancy+/data/talents/spells/charnel.lua"

t("Blood Burst", "血爆", "talent name")
t([[Cause the target's bodily fluids to explode ourwards doing %0.2f blight damage in radius %d.
		Undead hit by this explosion are healed instead of damaged.
		Does not work on Undead.
		Damage scales with Spellpower.]], [[使目標體液向外爆裂，造成 %0.2f 點枯萎傷害，範圍半徑 %d。
		被此爆炸波及的亡靈會受到治療而非傷害。
		對亡靈無效。
		傷害受法術強度加成。]], "tformat")
t("Meat Shield", "肉盾", "talent name")
t([[Everytime you or one of your minions kills a creature, the fallen corpse becomes a shield for you that grants +3 armour and +2%% resist all.
		These shields can stack up to %d stacks.
		The number of stacks decreases by 1 every %d turns.]], [[每當你或你的其中一名手下擊殺生物時，倒下的屍體就會化為你的護盾，賦予 +3 護甲與 +2%% 全體抗性。
		此護盾最多可疊加 %d 層。
		每 %d 回合，層數減少 1 層。]], "tformat")
t("Grasping Claws", "攫取之爪", "talent name")
t([[Skeletal claws reach up from the grave, grabbing hold of any creatures in a radius of %d around you.
		This pins enemies for %d turns, and the claws inflict %0.2f bleeding damage over 5 turns.
		The damage will increase with your Spellpower.]], [[骸骨之爪自墳墓中伸出，攫住你周圍半徑 %d 內的所有生物。
		這會使敵人定身 %d 回合，爪擊在 5 回合內造成 %0.2f 點流血傷害。
		傷害受法術強度加成。]], "tformat")
t("Vampiric Gift", "吸血餽贈", "talent name")
t([[Vampiric energies fill you; each time you deal damage, you have %d%% chance to heal for %d%% of the damage done.
		The absorption percent will increase with your Spellpower.]], [[吸血能量充盈你的全身；每次你造成傷害時，有 %d%% 機率治療你所造成傷害的 %d%%。
		此汲取比例受法術強度加成。]], "tformat")

section "data-necromancy+/data/talents/spells/dawn.lua"

t("Shining Binds", "光耀束縛", "talent name")
t([[Conjures up a bolt of light that moves toward the target and explodes into a flash of light, doing %0.2f light damage in a radius of %d.
		Any enemy hit by the flash will also be bound by chains of light, pinning them for 4 turns.
		The damage will increase with your Spellpower.]], [[召喚一道朝目標飛去的光箭，並在命中時爆發出一道閃光，造成 %0.2f 點光明傷害，範圍半徑 %d。
		被閃光波及的敵人也會被光鏈束縛，定身 4 回合。
		傷害受法術強度加成。]], "tformat")
t("Pool of Light", "光池", "talent name")
t([[Create a magical pool of ethereal light, healing all friendly creatures within a radius of %d for %0.2f per turn. The effect lasts for %d turns.
		Enemies touching the pool will take %0.2f light damage per turn and have a 25%% chance of being blinded.
		It also lights up the affected zone.
		The healing and damage scales with your Spellpower.]], [[創造一座充滿虛靈之光的魔法光池，治療半徑 %d 內的所有友軍，每回合治療 %0.2f 點生命，效果持續 %d 回合。
		碰觸光池的敵人每回合會受到 %0.2f 點光明傷害，並有 25%% 機率陷入目盲。
		它也會照亮受影響的區域。
		治療與傷害皆受法術強度加成。]], "tformat")
t("Holy Word", "聖言", "talent name")
t([[The origin of the Holy Word is lost, but its power is not.
		Speaking the Holy Word will inflict %0.2f light and %0.2f arcane damage on all undead, horrors and demons within a radius of %d from you.
		All enemy creatures will also be stunned for 4 turns.
		Damage scales with your Spellpower.]], [[聖言的起源早已佚失，但其威能猶存。
		唸誦聖言，將造成 %0.2f 點光明傷害與 %0.2f 點奧術傷害，波及你周圍半徑 %d 內所有亡靈、恐魔與惡魔。
		所有敵方生物也會被震懾 4 回合。
		傷害受法術強度加成。]], "tformat")
t("Endless Light", "無盡之光", "talent name")
t("Tap into the Endless Light, increasing all your light damage by %d%%, ignoring %d%% of your target's light resistance and reducing spell cooldowns by %d%%.", "汲取無盡之光的力量，提升所有光明傷害 %d%%，無視目標 %d%% 的光明抗性，並降低技能冷卻時間 %d%%。", "tformat")

section "data-necromancy+/data/talents/spells/dead-secrets.lua"

t("Grave Resolve", "墓中決意", "talent name")
t([[You venture into darkness unfazed. 
		+%d%% fear resistance, %d%% less damage from undead and +%d mental save.]], [[你毫無畏懼地踏入黑暗之中。
		+%d%% 恐懼抵抗，受到亡靈傷害減少 %d%%，並 +%d 精神豁免。]], "tformat")
t("Darktouched", "暗觸者", "talent name")
t([[Your soul has been touched by darkness and death. Grants +%d resistance to cold, darkness.
		You can also invoke this darkness to touch another, which heals undead for %d life, or hurts others for %d darkness damage.
		Changes to Rigor Mortis damage with Essence of the Dead.
		The Darktouch scales with Mindpower.]], [[你的靈魂已被黑暗與死亡所觸碰，獲得 +%d 點寒冷、黑暗抗性。
		你也可以喚起這股黑暗之力觸碰他人：治療亡靈 %d 點生命，或對其他生物造成 %d 點黑暗傷害。
		搭配「亡者精華」時，會改為造成屍僵症傷害。
		暗觸的效果受精神強度加成。]], "tformat")
t("Dead Whispers", "死者低語", "talent name")
t([[Links your mind to all nearby undead for %d turns. Allowing you to know their position.
		Also allows you to see in a radius of %d around your minions when active.]], [[將你的心智與周圍所有亡靈連結 %d 回合，使你能得知牠們的位置。
		啟動時，也能讓你看見手下周圍半徑 %d 內的區域。]], "tformat")
t("Necroanatomy", "死靈解剖學", "talent name")
t([[You are well versed in the anatomy of undead creatures. 
		You do +%d%% damage to undead and -%d%% damage to your undead minions.
		Increases the maximum life of any undead you summon by %d%%.
		Also when you use Surge of Undeath, you will heal your undead minions by %d life.
		Healing scales with your Mindpower.]], [[你精通亡靈生物的解剖學。
		對亡靈造成 +%d%% 傷害，對你自己的亡靈手下造成 -%d%% 傷害。
		你召喚的亡靈最大生命提升 %d%%。
		此外，當你使用「不死狂潮」時，會治療你的亡靈手下 %d 點生命。
		治療效果受精神強度加成。]], "tformat")

section "data-necromancy+/data/talents/spells/ghosts.lua"

t("Ghostly Bulwark", "幽靈衛士", "talent name")
t("You can not summon, you are suppressed!", "你無法召喚，你被壓制了！", "logPlayer")
t("ghostly bulwark", "幽靈衛士", "talent name")
t("The ghost of a fallen warrior.", "陣亡戰士的幽靈。", "_t")
t("massive", "重型", "effect subtype")
t([[Conjure the ghostly form of a fallen bulwark, complete with massive armour, shield and longsword.
		This ghostly defender will guard you and your friends.
		Its stats scale with your level and Spellpower.
		Blighted Summoning grants Bone Grab.]], [[召喚配備重型護甲、盾牌與長劍的墮落盾衛幽靈化身。
		這個幽靈防衛者將保護你與你的盟友。
		其屬性隨你的等級與法術強度提升。
		枯萎召喚會賦予骨之抓取。]], "tformat")
t("Ghostly Berserker", "幽靈狂戰士", "talent name")
t("ghostly berserker", "幽靈狂戰士", "talent name")
t("battleaxe", "戰斧", "effect subtype")
t([[Conjure the ghostly form of a fallen berserker, complete with massive armour and greataxe.
		This ghostly warrior will destroy your enemies.
		Its stats scale with your level and Spellpower.
		Blighted Summoning grants Execution.]], [[召喚配備重型護甲與巨斧的墮落狂戰士幽靈化身。
		這個幽靈戰士將消滅你的敵人。
		其屬性隨你的等級與法術強度提升。
		枯萎召喚會賦予斬殺。]], "tformat")
t("Pale Veil", "蒼白面紗", "talent name")
t([[Grants your ghosts the ability to Fade when they take damage, making them invulnerable for a turn.
		Increasing this talent decreases the cooldown of this effect.]], [[賦予你的幽靈在受到傷害時虛無化的能力，使牠們無敵一回合。
		提升此技能會縮短此效果的冷卻時間。]], "tformat")
t("Banshee", "報喪女妖", "talent name")
t("banshee", "報喪女妖", "talent name")
t("The ghost of a fallen maiden.", "陣亡少女的幽靈。", "_t")
t([[Conjure the ghostly form of a fallen maiden who was slain unjustly.
		Her sorrow will weaken your enemies.
		Its stats scale with your level and Spellpower.
		Blighted Summoning grants Pacification Hex.]], [[召喚冤死的墮落少女幽靈化身。
		她的悲傷將削弱你的敵人。
		其屬性隨你的等級與法術強度提升。
		枯萎召喚會賦予安撫邪術。]], "tformat")

section "data-necromancy+/data/talents/spells/justice.lua"

t("Lightning Flash", "閃電光爆", "talent name")
t([[Conjures up a bolt of lightning that moves toward the target and explodes into a flash of lightning, doing %0.2f lightning damage in a radius of %d.
		Any enemy hit by the flash will also be blinded by the flash for 4 turns.
		The damage will increase with your Spellpower.]], [[召喚一道朝目標飛去的雷球，並在命中時爆發出一道閃光，造成 %0.2f 點閃電傷害，範圍半徑 %d。
		被閃光波及的敵人也會被閃光致盲，持續 4 回合。
		傷害受法術強度加成。]], "tformat")
t("Peacemakers", "締和者", "talent name")
t([[A surge of power radiates to all your summoned creatures, increasing their Physical Power, Spellpower and Accuracy by %d, their Global Speed by %d%% for 6 turns.
		The effects will increase with your Spellpower.]], [[一股力量湧向你所有召喚生物，提升牠們的物理強度、法術強度與命中 %d，並提升整體速度 %d%%，持續 6 回合。
		效果受你的法術強度加成。]], "tformat")
t("Indignation", "義憤", "talent name")
t("indignation", "憤怒", "talent name")
t("spell", "法術", "_t")
t([[Enscribe a powerful rune of justice on the ground. Next turn it will trigger a small but powerful explosion of lightning with a radius of %d.
		All creatures hit by this explosion will take %0.2f lightning damage and be dazed for %d turns.
		The damage scales with your Spellpower.]], [[在地面刻畫一枚強大的正義符文。下一回合它將引爆一場範圍半徑 %d 的強力雷擊爆炸。
		所有被爆炸波及的生物都會受到 %0.2f 點閃電傷害，並眩暈 %d 回合。
		傷害受法術強度加成。]], "tformat")
t("Righteous Fury", "正義之怒", "talent name")
t("Fills you and your summoned creatures with righteous fury. This increases your lightning damage by %d%%, your lightning damage penetration by %d%% and adds %0.2f lightning damage to your summons' hits.", "讓你與你召喚的生物充滿正義之怒。此效果提升你的閃電傷害 %d%%，無視目標 %d%% 的閃電抗性，並為你召喚物的攻擊增加 %0.2f 點閃電傷害。", "tformat")

section "data-necromancy+/data/talents/spells/karma.lua"

t("Shockbolt", "閃電彈", "talent name")
t([[Spits a bolt of lightning, doing %0.2f lightning damage.
		The damage will increase with your Spellpower.]], [[吐出雷電箭，造成 %0.2f 點閃電傷害。
		傷害隨你的法術強度提升。]], "tformat")
t("Sprites", "閃電精靈", "talent name")
t("sprite", "閃電精靈", "talent name")
t("A floating orb of magical energy. It crackles with sparks of lightning. ", "一個漂浮的魔法能量球，劈啪閃爍著閃電火花。 ", "_t")
t([[Call spirits of the dead to inhabit Sprites of lightning. This creates 3 Sprites which last for %d turns before unsummoning.
		They fire bolts of lightning and if killed, they will explode for %0.2f lightning damage against enemies or healing friendly spirits.
		Their stats and explosion damage scale with your Spellpower.
		Critical spells increase the number of Sprites summoned instead of their strength.
		This scales with your crit power strength. Current bonus gives +%d.
		Blighted Summoning grants Shock.]], [[呼喚亡者的通靈來寄宿於閃電精靈。這會創造 3 個閃電精靈，持續 %d 回合後消失。
		牠們會發射雷電箭，若被殺死，牠們會爆炸並對敵人造成 %0.2f 點閃電傷害，或是治療友方通靈。
		牠們的屬性與爆炸傷害隨你的法術強度提升。
		法術暴擊會增加召喚的閃電精靈數量，而非提升其強度。
		這隨你的暴擊傷害強度提升。目前加成為 +%d。
		枯萎召喚會賦予閃電衝擊。]], "tformat")
t("Jolt of Fate", "命運震擊", "talent name")
t([[Call upon Fate to strike down your enemies. Up to three visible enemies within range 10 will be struck by lightning doing %0.2f damage.
		The damage will increase with your Spellpower.
		Critical spells increase the number of enemies hit instead of the damage done.
		This scales with your crit power strength. Current bonus gives +%d.]], [[祈求命運擊倒你的敵人。距離 10 以內最多三個可見的敵人將被閃電擊中，造成 %0.2f 點傷害。
		傷害隨你的法術強度提升。
		法術暴擊會增加擊中的敵人數量，而非提升造成的傷害。
		這隨你的暴擊傷害強度提升。目前加成為 +%d。]], "tformat")
t("Karmic Shield", "因果護盾", "talent name")
t([[Protect yourself with a Karmic Shield that absorbs all damage for %d turns.
		When it expires, it will release the absorbed damage as a radius %d explosion doing %d%% of the damage absorbed as lightning.]], [[使用因果護盾保護自己，吸收所有傷害，持續 %d 回合。
		當護盾結束時，它會釋放吸收的傷害，造成半徑 %d 的爆炸，並將吸收傷害的 %d%% 轉化為閃電傷害。]], "tformat")
t("Karmic Wave", "因果之波", "talent name")
t([[Create a wave of karmic energies in a radius %d cone that does %0.2f lightning damage to all enemies with a 25%% chance of dazing them.
		The damage will increase with your Spellpower and how injured you are.]], [[在半徑 %d 的錐形區域內產生因果能量波，對所有敵人造成 %0.2f 點閃電傷害，並有 25%% 的機率使其眩暈。
		傷害隨你的法術強度以及你的受傷程度提升。]], "tformat")

section "data-necromancy+/data/talents/spells/life-giver.lua"

t("Clay Aura", "陶土光環", "talent name")
t("Your Aura of Clay reduces all damage taken by allies in a radius of %d by %d.", "你的陶土光環能使半徑 %d 內盟友受到的所有傷害減少 %d。", "tformat")
t("Clay Golem", "陶土傀儡", "talent name")
t("clay golem", "陶土傀儡", "talent name")
t([[Shape clay and call upon a spirit to inhabit it, bringing it to life.
		The Clay Golem is strong, but not a very good fighter. Its main ability is its Clay Aura which reduces all damage allies  in a radius of %d take by %d.
		The golem's stats and the aura scale with your Spellpower.
		Blighted Summoning grants Empathic Hex.
		Warning: Clay Golem is water soluble.]], [[塑造陶土並呼喚一個通靈寄宿其中，賦予其生命。
		陶土傀儡很強壯，但不是很擅長戰鬥。牠的主要能力是陶土光環，能使半徑 %d 內的盟友受到的所有傷害減少 %d。
		傀儡的屬性與光環隨你的法術強度提升。
		枯萎召喚會賦予共感邪術。
		警告：陶土傀儡易溶於水。]], "tformat")
t("Poltergeist", "騷靈", "talent name")
t([[Give life to a mischievous spirit who will follow you unseen and harass your enemies. 
		Each turn a random enemy in a radius of 4 around you has a %d%% chance of being disarmed and a %d%% chance of being knocked back.]], [[賦予一個頑皮的通靈生命，牠會隱形跟隨你並騷擾你的敵人。
		每回合你周圍半徑 4 內的隨機一個敵人有 %d%% 的機率被繳械，且有 %d%% 的機率被擊退。]], "tformat")
t("Gift of Life", "生命之贈", "talent name")
t("gave life to their ghosts", "賦予他們的鬼魂生命", "_t")
t([[Give up some of your own life to sustain your summoned creatures. You lose %d life.
		Your summoned creatures are healed for %d life and gain +%d maximum life and %0.1f life regeneration per turn for %d turns.
		Temporary summoned creatures will have their duration extended by %d.
		The effects will increase with your Spellpower.
		Investment in this talent passively increases the life regen of your ghosts and clay golem by %0.2f per turn. ]], [[犧牲你的一部分生命來維持你的召喚生物。你失去 %d 點生命。
		你的召喚生物獲得 %d 點生命治療，並獲得 +%d 最大生命與每回合 %0.1f 點生命回復，持續 %d 回合。
		臨時召喚生物的持續時間將延長 %d 回合。
		此效果隨你的法術強度提升。
		投資此技能會被動增加你的幽靈與陶土傀儡每回合 %0.2f 點生命回復。]], "tformat")
t("Hope", "希望", "talent name")
t([[Increases your fear resistance by %d%% and decreases the duration of detrimental effects by %d%%.
		These values scale with your Spellpower.]], [[提升你的恐懼抵抗 %d%%，並縮短有害效果的持續時間 %d%%。
		這些數值隨你的法術強度提升。]], "tformat")

section "data-necromancy+/data/talents/spells/spells.lua"

t("#{bold}#%s decays into a pile of ash!#{normal}#", "#{bold}#%s化為一堆灰燼！#{normal}#", "logSeen")
t("charnel", "藏骸", "talent type")
t("Necromatic power over blood and bone.", "掌控鮮血與白骨的死靈力量。", "_t")
t("dead secrets", "亡者之祕", "talent type")
t("Ancient knowledge of Undeath.", "關於亡靈的古老知識。", "_t")
t("spirit", "通靈", "talent type")
t("Summoning of spirits and light magic.", "召喚靈體與光明法術。", "_t")
t("karma", "因果", "talent type")
t("Control of lightning and fate.", "掌控閃電與命運。", "_t")
t("life-giver", "賜命者", "talent type")
t("Giving life back to the fallen.", "賦予逝者生命。", "_t")
t("dawn", "破曉", "talent type")
t("Powerful light magic.", "強大的光明法術。", "_t")
t("justice", "正義", "talent type")
t("Powerful lightning magic.", "強大的閃電法術。", "_t")
t("ghosts", "幽靈", "talent type")
t("Summoning of fallen warrior ghosts.", "召喚陣亡戰士的幽靈。", "_t")

section "data-necromancy+/data/talents/spells/spirit.lua"

t("Ghost Lights", "幽靈之光", "talent name")
t("wisp", "光靈", "talent name")
t("A floating orb of magical energy. It shines with a radiant light. ", "一個漂浮的魔法能量球。它散發著耀眼的光芒。", "_t")
t([[Call spirits of the dead to inhabit Wisps of light. This creates 3 Wisps which last for %d turns before unsummoning.
		They do light damage in melee and if killed, they will explode for %0.2f light damage against enemies or healing friendly spirits.
		Their stats and explosion damage scale with your Spellpower.
		Critical spells increase the number of Wisps summoned instead of their strength.
		This scales with your crit power strength. Current bonus gives +%d.
		Blighted Summoning grants Blindside.]], [[召喚死者的通靈寄宿於光之微光中。這會創造 3 個微光，在解除召喚前持續 %d 回合。
		它們在近戰中造成光系傷害，若被擊殺，則會爆炸對敵人造成 %0.2f 光系傷害，或治療友方的通靈。
		它們的屬性與爆炸傷害隨你的法術強度提升。
		法術暴擊會增加召喚的微光數量，而非提升其強度。
		這隨你的暴擊強度提升。目前加成：+%d。
		荒蕪召喚會賦予襲擊技能。]], "tformat")
t("Rest in Peace", "安息", "talent name")
t([[Conjures up a bolt of light, doing %0.2f light damage to the target.
		If the target is undead, they take 50%% more damage.
		At level 5, it will create a beam of light.
		The damage will increase with your Spellpower.]], [[召喚一道光箭，對目標造成 %0.2f 光系傷害。
		若目標是亡靈，會多承受 50%% 傷害。
		在等級 5 時，它會產生一道光束。
		傷害隨你的法術強度提升。]], "tformat")
t("Spirit Guide", "靈體指引", "talent name")
t([[Your Spirits guide and protect you, granting %d defense and saves for each Spiritmancer summoned creature you have.
		This bonus cannot exceed %d. Current bonus: %d.]], [[你的通靈引導並保護你，你每擁有一個通靈師召喚生物，便獲得 %d 防禦與豁免。
		此加成不能超過 %d。目前加成：%d。]], "tformat")
t("Spirit Form", "靈體形態", "talent name")
t([[Turn into a spirit, allowing you to walk through walls (but not preventing suffocation) for %d turns.
		Also grants %d%% resistance and affinity (heal) to light damage.
		While in effect, Wisp explosions will heal you.
		If you are still in a wall when the effect ends you will randomly teleport.]], [[化身為通靈，使你能穿過牆壁（但無法防止窒息），持續 %d 回合。
		同時獲得 %d%% 光系傷害抵抗與親和（治療）。
		效果生效期間，微光爆炸會治療你。
		若效果結束時你仍處於牆壁中，你將會隨機傳送。]], "tformat")

section "data-necromancy+/data/timed-effects.lua"

t("Ghost Touched", "幽靈觸碰", "_t")
t("Reduced mind save, cold resist and stun resist.", "降低精神豁免、寒冷抵抗與震懾抵抗。", "tformat")
t("#F53CBE##Target# is touched by a deathly chill!", "#F53CBE##Target#被死亡般的寒意觸碰！", "tformat")
t("+Ghost Touched", "+幽靈觸碰", "_t")
t("#Target# is free from the deathly chill", "#Target#從死亡般的寒意中解脫", "tformat")
t("-Ghost Touched", "-幽靈觸碰", "_t")
t("Meat Shielded", "肉盾護體", "_t")
t("The target's armour is increased by %d, and all damage resistance is increased by %d%%.", "目標的護甲提升 %d，且所有傷害抗性提升 %d%%。", "tformat")
t("Nether Breach", "虛空裂隙", "_t")
t("Fires a darkness explosion each turn doing %0.2f darkness damage in radius 1.", "每回合引爆一次黑暗爆炸，對半徑 1 內造成 %0.2f 點黑暗傷害。", "tformat")
t("Spiritform", "靈體形態", "_t")
t("Turn into a spirit, passing through walls (but not natural obstacles), granting %d%% light resistance and affinity.", "化為靈體，可穿越牆壁（但無法穿越天然障礙），獲得 %d%% 光明抗性與親和。", "tformat")
t("#Target# turns into a spirit.", "#Target#化為靈體。", "tformat")
t("+Spiritform", "+靈體形態", "_t")
t("#Target# returns to normal.", "#Target#恢復正常。", "tformat")
t("-Spiritform", "-靈體形態", "_t")
t("Karmic Shield", "因果護盾", "_t")
t("This shield absorbs all damage then releases it as a lightning explosion.", "此護盾吸收所有傷害，並在消失時以雷擊爆炸的形式將其釋放。", "tformat")
t("#STEEL_BLUE#(%d absorbed)#LAST#", "#STEEL_BLUE#(%d 護盾吸收)#LAST#", "tformat")
t("Clay Aura", "陶土光環", "_t")
t("A thin shell of clay reduces damage taken by %d.", "一層薄薄的陶土外殼減少 %d 點所受傷害。", "tformat")
t("Gift of Life", "生命之贈", "_t")
t("Creature has been fortified with life from its summoner, increasing its maximum life by %d and its regeneration by %d.", "生物從召喚者處獲得生命強化，最大生命值提升 %d，生命回復提升 %d。", "tformat")
t("#Target# is filled with life.", "#Target#被生命力充滿。", "tformat")
t("+Gift of Life", "+生命之贈", "_t")
t("#Target#'s life returns to normal.", "#Target#的生命力恢復正常。", "tformat")
t("-Gift of Life", "-生命之贈", "_t")
t("Peacemakers", "締和者", "_t")
t("Increases the target combat power, spellpower, accuracy by %d and %d increased global speed.", "提升目標的物理強度、法術強度、命中 %d，並提升整體速度 %d。", "tformat")
t("#Target# is engulfed in light energies.", "#Target#被光明能量所籠罩。", "tformat")
t("+Peacemakers", "+締和者", "_t")
t("#Target# seems less powerful.", "#Target#似乎變弱了。", "tformat")
t("-Peacemakers", "-締和者", "_t")

section "data-necromancy+/hooks/load.lua"

t("Swaps Acid damage on the Bonestaff aspect for Physical damage.", "將白骨法杖面向的酸性傷害替換為物理傷害。", "_t")
t("#BLACK##{bold}#Necromancy+: Make Bonestaves use Physical instead of Acid?#WHITE##{normal}#", "#BLACK##{bold}#死靈法師擴充：讓白骨法杖使用物理傷害取代酸性傷害？#WHITE##{normal}#", "_t")
t("Change Selection", "變更選擇", "_t")
t("Alter Bonestaff Aspect? #RED#Best not to change this if you already have a Bonestaff.#LAST#", "變更白骨法杖面向？#RED#若你已經擁有白骨法杖，最好不要更改此選項。#LAST#", "_t")

section "data-necromancy+/init.lua"

t("Necromancy+", "死靈術+", "init.lua long_name")
t("Adds a new categories for Necromancer and the Spiritmancer class.", "為死靈法師與通靈法師職業新增技能分類。", "init.lua description")

section "salvage-extra"

t("The road to necromancy is a macabre path indeed. Walk with the dead, and drink deeply of their black knowledge.", "通往死靈法師的道路是極其可怕的，與死亡相伴隨並沉溺在他們的黑暗知識之中。", "_t")
t("Their most important stats are: Magic and Willpower", "他們最重要的屬性是：魔法和意志。", "_t")
t("#GOLD#Stat modifiers:", "#GOLD# 屬性修正：", "_t")
t("#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution", "#LIGHT_BLUE# * +0 力量 , +0 敏捷 , +0 體質", "_t")
t("#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning", "#LIGHT_BLUE# * +5 魔法 , +3 意志 , +1 靈巧", "_t")
t("#GOLD#Life per level:#LIGHT_BLUE# -3", "#GOLD# 每等級生命加值： #LIGHT_BLUE# -3", "_t")
t("holy light", "聖光", "damage type")
t("Unerring Scalpel", "精準的解剖刀", "entity name")
t("long sharp scalpel", "鋒利的長解剖刀", "_t")
t("This scalpel was used by the dread sorcerer Kor'Pul when he began learning the necromantic arts in the Age of Dusk.  Many were the bodies, living and dead, that became unwilling victims of his terrible experiments.", "這把解剖刀曾經被可怕的巫師卡·普爾在黃昏紀剛開始學習死靈法術時使用。許多人，生物和屍體都成爲了他那可怕實驗的犧牲品。", "_t")
t("bone staff", "骨製法杖", "_t")
t("Reduced mind save, cold resist and stun resist.", "降低精神豁免、寒冷抗性與暈眩抗性。", "_t")
t("#F53CBE##Target# is touched by a deathly chill!", "#F53CBE##Target#被死亡般的寒意觸碰！", "_t")
t("#Target# is free from the deathly chill", "#Target#從死亡般的寒意中解脫", "_t")
t("#Target# turns into a spirit.", "#Target#化為靈體。", "_t")
t("#Target# returns to normal.", "#Target#恢復正常。", "_t")
t("This shield absorbs all damage then releases it as a lightning explosion.", "此護盾吸收所有傷害，並在消失時以雷擊爆炸的形式將其釋放。", "_t")
t("#Target# is filled with life.", "#Target#被生命力充滿。", "_t")
t("#Target#'s life returns to normal.", "#Target#的生命力恢復正常。", "_t")
t("#Target# is engulfed in light energies.", "#Target#被光明能量所籠罩。", "_t")
t("#Target# seems less powerful.", "#Target#似乎變弱了。", "_t")
