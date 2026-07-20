locale "zh_hant"

section "data-mod-descriptions/init.lua"

t("Modified Item Descriptions", "修改後的物品描述", "init.lua long_name")
t([[这是基于 Cleaner Item Descriptions 制作的插件，为中文玩家进行了汉化。
按'Alt'键可以临时切换回原显示模式
此外，进行了以下调整：
提示信息的背景始终处于不透明状态
某些属性会归类显示
调整了部分属性的显示顺序
This is a fork of Cleaner Item Descriptions that translated for Chinese players.
Other tweaks:
Tooltip are always opaque no matter locked or not.
Some attributes are displayed in a group instead of seperate lines.
Adjust the display order of several attributes.
]], [[此為基於 Cleaner Item Descriptions 製作的模組，已為中文玩家進行繁體中文化。
按 'Alt' 鍵可以臨時切換回原始顯示模式
此外，進行了以下調整：
提示資訊的背景將始終保持不透明
部分屬性會歸類顯示
調整了部分屬性的顯示順序
此為 Cleaner Item Descriptions 的分支版本，已為中文玩家進行繁體中文化。
其他調整：
不論是否鎖定，提示資訊的背景始終保持不透明。
部分屬性會歸類顯示，而非分行顯示。
調整了部分屬性的顯示順序。
]], "init.lua description")

section "data-mod-descriptions/superload/engine/Object.lua"

t("%s (level %d)", "%s（等級 %d）", "tformat")
t("Level %d", "等級 %d", "tformat")
t("Talent %s (level %d)", "技能 %s（等級 %d）", "tformat")

section "data-mod-descriptions/superload/mod/class/Actor.lua"

t("no talent", "無此技能", "_t")

section "data-mod-descriptions/superload/mod/class/DemonologistsDLC.lua"

t("%+d", "%+d", "_t")
t("Shadow Power", "暗影之力", "_t")

section "data-mod-descriptions/superload/mod/class/Object.lua"

t("#ORANGE#offense ------#LAST#", "#ORANGE#攻擊 ------#LAST#", "_t")
t("#ORANGE#defense ------#LAST#", "#ORANGE#防禦 ------#LAST#", "_t")
t("#ORANGE#other -------#LAST#", "#ORANGE#其他 -------#LAST#", "_t")
t("phys.bleed", "物理流血", "_t")
t("void", "虛空", "_t")
t("you have set the ring to grant you", "你已設定戒指賦予你", "_t")
t("%1#LIGHT_GREEN#%2#LAST#", "%1#LIGHT_GREEN#%2#LAST#", "_t")
t("#LIGHT_GREEN#%1#LAST#", "#LIGHT_GREEN#%1#LAST#", "_t")
t(" %% chance of ", " %% 機率 ", "tformat")
t("T%d", "T%d", "tformat")
t("Random Unique", "隨機獨特物品", "_t")
t("Ego++", "詞綴++", "_t")
t("Ego+", "詞綴+", "_t")
t("%s %s (%0.1f Encumbrance)", "%s %s (%0.1f 負重)", "tformat")
t("%s %s %s/%s (%0.1f Encumbrance)", "%s %s %s/%s (%0.1f 負重)", "tformat")
t("2H ", "2手 ", "_t")
t("1H ", "1手 ", "_t")
t("Arcane Power", "奧術強度", "_t")
t("Nature Power", "自然強度", "_t")
t("Antimagic Power", "反魔法強度", "_t")
t("Psionic Power", "靈能強度", "_t")
t("Unknown Power", "未知強度", "_t")
t("It can cause special effects when it strikes in combat.", "擊中時可產生特殊效果。", "_t")
t("It can cause special effects when a melee attack is blocked.", "格擋近戰攻擊時可產生特殊效果。", "_t")
t("Keywords: ", "關鍵字：", "_t")
t("%d%% %s level %d", "%d%% %s 等級 %d", "tformat")
t("On Spell Hit:", "法術擊中時：", "_t")
t("On Nature Hit:", "自然擊中時：", "_t")
t("On Mind Hit:", "精神擊中時：", "_t")
t("%+d%%", "%+d%%", "tformat")
t("Global Speed", "全局速度", "_t")
t("%+.2f%%", "%+.2f%%", "tformat")
t("Critical power", "暴擊強度", "_t")
t("Damage Change", "傷害變化", "_t")
t("Ignore resists", "無視抵抗", "_t")
t("Spell Speed", "法術速度", "_t")
t("Spell Crit", "法術暴擊", "_t")
t("Mind Speed", "精神速度", "_t")
t("Mind Crit", "精神暴擊", "_t")
t("Steam Speed", "蒸汽速度", "_t")
t("Steam Crit", "蒸汽暴擊", "_t")
t("Combat Speed", "戰鬥速度", "_t")
t("%+.1f%%", "%+.1f%%", "tformat")
t("Physical Crit", "物理暴擊", "_t")
t("Physical Power", "物理強度", "_t")
t("Ignore Armor", "無視護甲", "_t")
t("On-Hit", "擊中時", "_t")
t("On-Ranged-Hit", "遠程擊中時", "_t")
t("When Hit", "被擊中時", "_t")
t("On-Hit (Melee):", "擊中時 (近戰):", "_t")
t("On-Hit (Ranged):", "擊中時 (遠程):", "_t")
t("When Hit:", "被擊中時:", "_t")
t("Ignore Shields", "無視護盾", "_t")
t("%+d%% ", "%+d%% ", "tformat")
t("Ranged Defense", "遠程防禦", "_t")
t("Max Resistance", "最大抵抗", "_t")
t("Damage Reduction", "傷害減免", "_t")
t("Resist Against", "抵抗", "_t")
t("Out-of-Phase Defense", "相位偏移防禦", "_t")
t("Out-of-Phase Resistance", "相位偏移抵抗", "_t")
t("Out-of-Phase Resilience", "相位偏移韌性", "_t")
t("Crit Resistance", "暴擊抵抗", "_t")
t("Crit Avoidance", "暴擊迴避", "_t")
t("Deflect Projectile", "投射物偏折", "_t")
t("Damage Avoidance", "傷害迴避", "_t")
t("Shield Duration", "護盾持續時間", "_t")
t("Shield Power", "護盾強度", "_t")
t("Mind save", "精神豁免", "_t")
t("%+.2f", "%+.2f", "_t")
t("Life Regen", "生命再生", "_t")
t("Lifesteal Chance", "吸血機率", "_t")
t("Heal-on-summon", "召喚時治療", "_t")
t("Slow Projectiles", "投射物減速", "_t")
t("Resist unseen", "未見之物抵抗", "_t")
t("Category Bonus", "類別加成", "_t")
t("Move Speed", "移動速度", "_t")
t("Spell cooldown", "法術冷卻", "_t")
t("Disarm Traps", "解除陷阱", "_t")
t("Max stamina", "最大體力", "_t")
t("Stamina when hit", "被擊中時體力", "_t")
t("Max mana", "最大法力", "_t")
t("Mana when hit", "被擊中時法力", "_t")
t("Max vim", "最大活力", "_t")
t("Vim when hit", "被擊中時活力", "_t")
t("Max soul", "最大靈魂", "_t")
t("Max pos.", "最大正能量", "_t")
t("Max neg.", "最大負能量", "_t")
t("Anomly control", "異常控制", "_t")
t("Eq. when hit", "被擊中時失衡值", "_t")
t("Max hate", "最大仇恨", "_t")
t("Hate when hit", "被擊中時仇恨", "_t")
t("Max psi", "最大靈能", "_t")
t("Psi when hit", "被擊中時靈能", "_t")
t("Max steam", "最大蒸汽", "_t")
t("Max air", "最大空氣", "_t")
t("Heightened Senses", "感官敏銳", "_t")
t("See Stealth", "看破潛行", "_t")
t("See Invisibility", "看破隱形", "_t")
t("Leech Chance", "吸取機率", "_t")
t("Max Summons", "最大召喚數量", "_t")
t("Summon Regen", "召喚物再生", "_t")
t("Pierce Iceblocks", "冰塊穿透", "_t")
t("Telepath range", "心靈感應範圍", "_t")
t("%+.2f(-) %s", "%+.2f(-) %s", "tformat")
t("(%+d)", "(%+d)", "_t")
t("%s %+d(-)", "%s %+d(-)", "tformat")
t("(%+.2f) ", "(%+.2f) ", "_t")
t("%+.2f(-) %s ", "%+.2f(-) %s ", "tformat")
t("Unarmed combat:", "徒手戰鬥：", "_t")
t("When used to attack:", "用於攻擊時：", "_t")
t("Cannot be teleported.", "無法被傳送。", "_t")
t("While equipped:", "裝備時：", "_t")
t("While carried:", "攜帶時：", "_t")
t("entity on slot", "槽位上的實體", "_t")
t("Attachable to ", "可附加於 ", "_t")
t("When attached:", "附加時：", "_t")
t("On block: ", "格擋時：", "_t")
t("Item imbue powers:", "物品灌注能力：", "_t")
t("%s%+d%%#LAST#", "%s%+d%%#LAST#", "tformat")
t("%s%+.1fx#LAST#", "%s%+.1fx#LAST#", "tformat")
t([[Power: %3d%% (%s)
Range: %.1fx (%s)]], [[強度：%3d%% (%s)
距離：%.1fx (%s)]], "tformat")
t([[Power: %3d%%
Range: %.1fx]], [[強度：%3d%%
距離：%.1fx]], "tformat")
t("%s%+.1f#LAST# - %s%+.1f#LAST#", "%s%+.1f#LAST# - %s%+.1f#LAST#", "tformat")
t("Weapon Damage", "武器傷害", "_t")
t("Accuracy Stat", "命中屬性", "_t")
t("Critical Rate", "暴擊率", "_t")
t("Critical Power", "暴擊強度", "_t")
t("%+.0f%%", "%+.0f%%", "tformat")
t("Attack Speed", "攻擊速度", "_t")
t("Damage Multiplier", "傷害倍率", "_t")
t("Auto Reload", "自動裝填", "_t")
t("Projectile Speed", "投射物速度", "_t")
t("On-hit", "命中時", "_t")
t("On-ranged-hit", "遠程命中時", "_t")
t("Damage Conversion", "傷害轉換", "_t")
t("Damage Against", "對特定目標傷害", "_t")
t("On-Hit, radius 1", "命中時，半徑 1", "_t")
t("On-crit, radius 2", "暴擊時，半徑 2", "_t")
t("On Hit:", "命中時：", "_t")
t("On Crit:", "暴擊時：", "_t")
t("On Critical:", "暴擊時：", "_t")
t("On Kill:", "擊殺時：", "_t")
t("Recursion Amount", "遞迴量", "_t")
t("Accuracy bonus", "命中加成", "_t")
t("\nActivation is instant.", "\n瞬間啟用。", "_t")
t(" (Instant)", " (瞬發)", "_t")
t("Uses %d charges out of %d", "使用 %d/%d 次充能", "tformat")
t("Talent ", "技能 ", "_t")
t("Puts %s on %d turn cooldown", "使 %s 進入 %d 回合冷卻", "tformat")
t("Uses %d power out of %d/%d", "使用 %d 能量（當前 %d/%d）", "tformat")
t("Power cost", "能量消耗", "_t")
t("Puts all charms on %d turn cooldown", "使所有護符進入 %d 回合冷卻", "tformat")
t("% to ", "% 轉換為 ", "_t")

section "salvage-extra"

t([[这是基于 Cleaner Item Descriptions 制作的插件，为中文玩家进行了汉化。
按'Alt'键可以临时切换回原显示模式
此外，进行了以下调整：
提示信息的背景始终处于不透明状态
某些属性会归类显示
调整了部分属性的显示顺序
This is a fork of Cleaner Item Descriptions that translated for Chinese players.
Other tweaks:
Tooltip are always opaque no matter locked or not.
Some attributes are displayed in a group instead of seperate lines.
Adjust the display order of several attributes.
]], [[這是基於 Cleaner Item Descriptions 製作的插件，為中文玩家進行了漢化。
按 'Alt' 鍵可以暫時切換回原顯示模式
此外，進行了以下調整：
提示資訊的背景始終處於不透明狀態
某些屬性會歸類顯示
調整了部分屬性的顯示順序
This is a fork of Cleaner Item Descriptions that translated for Chinese players.
Other tweaks:
Tooltip are always opaque no matter locked or not.
Some attributes are displayed in a group instead of seperate lines.
Adjust the display order of several attributes.
]], "_t")
t("Requires:", "需求：", "_t")
t("Talent %s", "技能 %s", "tformat")
t("Effective talent level: ", "有效技能等級：", "_t")
t("Use mode: ", "使用模式：", "_t")
t("Passive", "被動技能", "_t")
t("Sustained", "持續技能", "_t")
t("Activated", "主動技能", "_t")
t("Feedback cost: ", "反饋值消耗：", "_t")
t("Fortress Energy cost: ", "堡壘能量消耗", "_t")
t("Sustain feedback cost: ", "持續反饋值消耗：", "_t")
t("%s %s: ", "%s%s：", "tformat")
t("cost", "消耗", "_t")
t("gain", "獲得", "_t")
t("Sustain %s cost: ", "持續%s消耗：", "tformat")
t("Generates", "產生", "_t")
t("Removes", "移除", "_t")
t("Drains", "吸收", "_t")
t("Replenishes", "補充", "_t")
t("Range: ", "使用範圍：", "_t")
t("melee/personal", "近戰/單體", "_t")
t("%sCooldown: ", "%s冷卻時間：", "tformat")
t("Fixed ", "固定", "_t")
t("Travel Speed: ", "飛行速度：", "_t")
t("%d%% of base", "%d%%基礎速度", "tformat")
t("instantaneous", "瞬間", "_t")
t("Full Turn", "完整回合", "_t")
t("Instant (#LIGHT_GREEN#0%#LAST# of a turn)", "瞬間(#LIGHT_GREEN#0%#LAST#回合)", "_t")
t("Special", "特殊", "_t")
t("%s (#LIGHT_GREEN#%d%%#LAST# of a turn)", "%s(#LIGHT_GREEN#%d%%#LAST#回合)", "tformat")
t("Usage Speed: ", "使用速度：", "_t")
t("Won't Break Stealth:  ", "不會打破潛行：", "_t")
t("Is: ", "是：", "_t")
t(" and ", "和", "_t")
t("Will Deactivate: ", "會解除：", "_t")
t("Description: ", "介紹：", "_t")
t("Steamtech", "蒸汽科技", "_t")
