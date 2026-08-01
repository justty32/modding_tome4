-- 盧恩精通 —— 被動樹。提高充能上限、強化銘文，並開啟「共鳴」。

newTalentType {
    type = "spell/runic-mastery",
    name = "盧恩精通",
    description = "對盧恩符文本質的理解，讓你的銘文更強、承載更多力量。",
    generic = false,
    allow_random = true,
}

newTalent {
    name = "符文容量",
    short_name = "RW_RUNIC_MASTERY",
    image = "talents/spellcraft.png",
    type = { "spell/runic-mastery", 1 },
    mode = "passive",
    points = 5,
    getMaxCharge = function(self, t) return math.floor(self:getTalentLevel(t) * 3) end,
    getInscriptionPower = function(self, t) return self:getTalentLevel(t) * 0.05 end,
    -- passives 在 learnTalent 時被呼叫（engine/interface/ActorTalents.lua:562-625）
    passives = function(self, t, p)
        self:talentTemporaryValue(p, "max_runecharge", t.getMaxCharge(self, t))
        self:talentTemporaryValue(p, "inscriptions_stat_multiplier", t.getInscriptionPower(self, t))
    end,
    info = function(self, t)
        return ("符文充能上限 +%d，銘文的屬性加成效果 +%d%%。"):
            format(t.getMaxCharge(self, t), t.getInscriptionPower(self, t) * 100)
    end,
}

newTalent {
    name = "共鳴之心",
    short_name = "RW_RESONANT_MIND",
    image = "talents/arcane_supremacy.png",
    type = { "spell/runic-mastery", 2 },
    mode = "passive",
    points = 1, -- 開關型：學會即開啟共鳴機制
    -- 每回合重算共鳴。共鳴取決於身上的銘文組合，玩家換裝銘文時不會經過 postUseTalent，
    -- 所以需要一個週期性的檢查點。callbackOnActBase 由 Actor.lua:646 的
    -- fireTalentCheck("callbackOnActBase") 觸發，只在學會此天賦時才會跑。
    -- runewrightSyncResonances() 內部會在集合沒變時直接返回，不會每回合重建 temporary value。
    callbackOnActBase = function(self, t)
        self:runewrightSyncResonances()
    end,
    info = function(self, t)
        local lib = self:runewrightResonanceLib()
        local lines = { "你能感知銘文之間的共鳴。當身上的銘文符合特定組合時，自動獲得額外效果。\n" }
        for _, def in ipairs(lib and lib.defs or {}) do
            lines[#lines + 1] = ("#YELLOW#%s#LAST#：%s"):format(def.name, def.desc)
        end
        local active = self:runewrightResonances()
        if #active > 0 then
            local names = {}
            for _, d in ipairs(active) do names[#names + 1] = d.name end
            lines[#lines + 1] = ("\n#LIGHT_GREEN#目前啟動中：%s#LAST#"):format(table.concat(names, "、"))
        end
        return table.concat(lines, "\n")
    end,
}
