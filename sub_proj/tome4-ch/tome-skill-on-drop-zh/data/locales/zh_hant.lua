locale "zh_hant"

section "data-skill-on-drop/init.lua"

t("Skill on Drop", "掉落技能", "init.lua long_name")
t([[破碎回响MOD：怪物死亡时，其掉落的装备将被附加一个随机的怪物技能。
有小概率一件装备会获得多个技能。]], [[破碎迴響 MOD：怪物死亡時，其掉落的裝備將被附加一個隨機的怪物技能。
有小機率一件裝備會獲得多個技能。]], "init.lua description")

section "data-skill-on-drop/superload/engine/Map.lua"

t("\n#LIGHT_BLUE#装备后获得技能：%s (等级 %d)#WHITE#", "\n#LIGHT_BLUE#裝備後獲得技能：%s (等級 %d)#WHITE#", "tformat")
