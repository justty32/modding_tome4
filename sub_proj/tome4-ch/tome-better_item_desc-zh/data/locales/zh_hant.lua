locale "zh_hant"

section "data-better_item_desc/init.lua"

t("Better Item Description", "更好的物品描述", "init.lua long_name")
t([[This addon makes items description easier to read and determine on a glance it's usefulness
- sorts all stats by category - DPS/DEF/MISC
- item's passive power always the same blue color (not a random blue-yellow-pink-green)
- item's usable power - always yellow
- all rarity categories are displayed
- encumbrance value moved to the right under item name
- "on hit" powers always green
- "Stats" have an ornage highlight and placed before others because it's most important one
- Removed many extra-explain details, which any veteran player would not want to read each time
for example, stat "S.pwr/crit" shorten from "Spellpower on spell critical (stacks up to 3 times)"
means you do remember that it can stack only 3 times, and is not so super important anyway
- DLC supported - Orcs/Ashes
- few bug-fixes along the way

Most important thing to remember
- Requirements only shown for those you don't meet. If you want to see all reqs - hold CTRL
- "Phasing" stat means - "Damage Shield penetration", the name was taken from the source and looks good to me, and short enough
- The "-"  minus sign at the end of stat mean immunity or reduction of some sort, for example "Blind-" = "Blindness immunity", 
- "Max.summ" = Max wilder summons
- "Summ.HP.reg" = Life regen bonus (wilder-summons)
- "Def/telep" = Defense after a teleport
- "Res/telep" = Resist all after a teleport
- "Dur/telep" = New effects duration reduction after a teleport

it's not recommended to use this mod if you'r new to the game
]], [[此 Addon 使裝備描述更易閱讀，以便一目了然其用途
- 將所有屬性按類別排序：DPS/DEF/MISC
- 裝備的被動效果固定顯示為藍色（不再隨機顯示藍/黃/粉/綠色）
- 裝備的主動效果固定顯示為黃色
- 顯示所有稀有度類別
- 負重值移至裝備名稱下方的右側
- 「擊中時」效果固定顯示為綠色
- 「屬性」會以橘色高亮顯示，且因其最為重要而置於最前
- 移除了許多老玩家不想重複閱讀的冗餘解釋細節
例如：屬性「S.pwr/crit」由原先的「法術暴擊時的法術強度（最多疊加 3 次）」簡化而來
意指你確實記得它只能疊加 3 次，而且這也不是那麼至關重要
- 支援 DLC：Orcs / Ashes
- 順便修正了些許錯誤

最需要注意的事項
- 僅顯示未達成的需求。若想查看所有需求，請按住 CTRL
- 「Phasing」屬性意指「傷害護盾穿透」，該名稱取自源碼，看起來不錯且足夠簡短
- 屬性末尾的「-」減號表示某種免疫或減免，例如「致盲-」=「致盲免疫」，
- 「Max.summ」= 最大自然召喚物數量
- 「Summ.HP.reg」= 生命回復加成 (自然召喚物)
- 「Def/telep」= 傳送後的防禦值
- 「Res/telep」= 傳送後的全屬性抵抗
- 「Dur/telep」= 傳送後新效果的持續時間縮減

建議新手玩家不要使用此 Mod
]], "init.lua description")

section "data-better_item_desc/superload/engine/Object.lua"

t("%s (level %d)", "%s (等級 %d)", "tformat")
t("Level %d", "等級 %d", "tformat")

section "data-better_item_desc/superload/mod/class/Actor.lua"

t("no talent", "無技能", "_t")
t("Use mode", "使用模式", "_t")
t("Sustain %s cost", "持續%s消耗", "tformat")
t("%sCooldown", "%s冷卻", "tformat")
t("Usage Speed", "使用速度", "_t")
t("Won't Break Stealth", "不會打破潛行", "_t")
t("Will Deactivate", "會解除", "_t")

section "data-better_item_desc/superload/mod/class/DemonologistsDLC.lua"

t("%+d", "%+d", "_t")

section "data-better_item_desc/superload/mod/class/Object.lua"

t("better_item_desc: ERROR: no data for ", "better_item_desc: 錯誤：找不到 ", "_t")
t(" mode found", " 模式的資料", "_t")
t(" font size found", " 字型大小的資料", "_t")
t(" font type found", " 字型類型的資料", "_t")
t("#595959#dps ----------#LAST#", "#595959#dps ----------#LAST#", "_t")
t("#595959#----- def -----#LAST#", "#595959#----- 防禦 -----#LAST#", "_t")
t("#595959#---------- misc#LAST#", "#595959#---------- 雜項#LAST#", "_t")
t("phys.bleed", "物理流血", "_t")
t("void", "虛空", "_t")
t("you have set the ring to grant you", "你已設定戒指賦予你", "_t")
t("%1#LIGHT_GREEN#%2#LAST#", "%1#LIGHT_GREEN#%2#LAST#", "_t")
t("#LIGHT_GREEN#%1#LAST#", "#LIGHT_GREEN#%1#LAST#", "_t")
t(" %% chance of ", " %% 機率 ", "tformat")
t("2H ", "雙手(2H) ", "_t")
t("1H ", "單手(1H) ", "_t")
t("[Rare]", "[稀有]", "_t")
t("[Ego++]", "[詞綴++]", "_t")
t("[Ego+]", "[詞綴+]", "_t")
t("[Ego]", "[詞綴]", "_t")
t("[Normal]", "[普通]", "_t")
t("It can cause special effects when it strikes in combat.", "在戰鬥中擊中時可能產生特殊效果。", "_t")
t("It can cause special effects when a melee attack is blocked.", "格擋近戰攻擊時可能產生特殊效果。", "_t")
t("A part of set.", "套裝部件。", "_t")
t("On ", "當 ", "_t")
t(" #LIGHT_GREEN#%d%%#LAST# %s #LIGHT_GREEN#%d#LAST#", " #LIGHT_GREEN#%d%%#LAST# %s #LIGHT_GREEN#%d#LAST#", "tformat")
t(" #ORANGE#%s#LAST#", " #ORANGE#%s#LAST#", "tformat")
t("%+.1f%%", "%+.1f%%", "tformat")
t("%+d%%", "%+d%%", "tformat")
t("%+.2f%%", "%+.2f%%", "tformat")
t("Melee+", "近戰+", "_t")
t("Ranged+", "遠程+", "_t")
t("%+d%% ", "%+d%% ", "tformat")
t("Melee Ret", "近戰反傷", "_t")
t("On Hit (Melee):", "擊中時 (近戰)：", "_t")
t("On Hit (Ranged):", "擊中時 (遠程)：", "_t")
t("#GREEN#On Melee Ret:", "#GREEN#近戰反擊時：", "_t")
t("Crit.chn-", "暴擊率-", "_t")
t("Crit.dmg-", "暴擊傷害-", "_t")
t("Talent.cat+", "技能分類+", "_t")
t("%+.2f", "%+.2f", "_t")
t("HP.leech%%", "生命吸取%%", "tformat")
t("Blind-", "致盲-", "_t")
t("Poison-", "毒素-", "_t")
t("Disease-", "疾病-", "_t")
t("Cut-", "流血-", "_t")
t("Silence-", "沉默-", "_t")
t("Disarm-", "繳械-", "_t")
t("Confus-", "混亂-", "_t")
t("Sleep-", "睡眠-", "_t")
t("Pinning-", "定身-", "_t")
t("Fear-", "恐懼-", "_t")
t("Knockbk-", "擊退-", "_t")
t("Instkill-", "即死-", "_t")
t("Teleport-", "傳送-", "_t")
t("Res.leech%%", "資源吸取%%", "tformat")
t("Telpty rng", "心靈感應範圍", "_t")
t("%+.2f(-) %s", "%+.2f(-) %s", "tformat")
t("(%+d)", "(%+d)", "_t")
t("%s %+d(-)", "%s %+d(-)", "tformat")
t("(%+.2f) ", "(%+.2f) ", "_t")
t("%+.2f(-) %s ", "%+.2f(-) %s ", "tformat")
t("Blind-Fight: No penalty when attacking invisible/stealthed", "盲鬥：攻擊隱形/潛行目標時無懲罰", "_t")
t("May act while sleeping", "可在睡眠時行動", "_t")
t("Instant Weapon Swap", "瞬間切換武器", "_t")
t("Avoid Pressure Traps", "避開壓力陷阱", "_t")
t("May understand old Sher'Tul language.", "可理解古代謝爾圖語。", "_t")
t("Unarmed combat:", "徒手戰鬥：", "_t")
t("When used to Attack:", "用於攻擊時：", "_t")
t("Cannot be teleported.", "無法被傳送。", "_t")
t("While equipped:", "裝備時：", "_t")
t("While carried:", "攜帶時：", "_t")
t("Attachable to ", "可附加於 ", "_t")
t("When attached:", "附加時：", "_t")
t("#PURPLE#Spell#LAST# Hit:", "#PURPLE#法術#LAST#擊中時：", "_t")
t("#LIGHT_GREEN#Nature#LAST# Hit:", "#LIGHT_GREEN#自然#LAST#擊中時：", "_t")
t("#YELLOW#Mind#LAST# Hit:", "#YELLOW#精神#LAST#擊中時：", "_t")
t("On block: ", "格擋時： ", "_t")
t("Item imbue powers:", "鑲嵌效果：", "_t")
t("%s%+d%%#LAST#", "%s%+d%%#LAST#", "tformat")
t("%s%+.1fx#LAST#", "%s%+.1fx#LAST#", "tformat")
t(" %3d%% (%s)  Range: %.1fx (%s)", " %3d%% (%s)  波動範圍：%.1fx (%s)", "tformat")
t(" %3d%%  Range: %.1fx", " %3d%%  波動範圍：%.1fx", "tformat")
t("%s%+.1f#LAST# - %s%+.1f#LAST#", "%s%+.1f#LAST# - %s%+.1f#LAST#", "tformat")
t("Acc uses", "命中屬性", "_t")
t("%+.0f%%", "%+.0f%%", "tformat")
t("Rld cld", "裝填冷卻", "_t")
t("On Hit.r1", "擊中爆發(半徑1)", "_t")
t("On Crit.r2", "暴擊爆發(半徑2)", "_t")
t("On Hit:", "擊中時：", "_t")
t("On Crit:", "暴擊時：", "_t")
t("On Kill:", "擊殺時：", "_t")
t("Crushing Blows: Damage dealt by this weapon is increased by half your critical multiplier, if doing so would kill the target.", "毀滅打擊：若能以此擊殺目標，此武器造成的傷害將增加你的一半暴擊加成。", "_t")
t("Acc+", "命中+", "_t")
t("\nActivation is instant.", "\n瞬間使用。", "_t")
t(" (Instant)", " (瞬間)", "_t")
t("Uses %d charges out of %d", "剩餘次數 %d/%d", "tformat")
t("Talent ", "技能 ", "_t")
t("Puts %s on %d cooldown", "使 %s 進入 %d 回合冷卻", "tformat")
t("Uses %d power out of %d/%d", "消耗 %d 能量，目前 %d/%d", "tformat")
t("Puts all charms on %d cooldown", "使所有護符進入 %d 回合冷卻", "tformat")
t("% to ", "% 機率 ", "_t")
