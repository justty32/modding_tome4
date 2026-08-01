-- 銘文學識 —— 通用（generic）技能樹。
-- generic = true 的樹消耗通用技能點（unused_generics），不是職業點。

newTalentType {
    type = "spell/inscription-lore",
    name = "銘文學識",
    description = "對銘文本身的鑽研，讓你能承載更多符文與輸能。",
    generic = true,
    allow_random = true,
}

newTalent {
    name = "銘文擴容",
    short_name = "RW_INSCRIPTION_LORE",
    image = "talents/arcane_cunning.png",
    type = { "spell/inscription-lore", 1 },
    mode = "passive",
    points = 5,
    -- max_inscriptions 預設 3（mod/class/interface/ActorInscriptions.lua:30）
    getSlots = function(self, t) return self:getTalentLevelRaw(t) >= 3 and 1 or 0 end,
    passives = function(self, t, p)
        self:talentTemporaryValue(p, "max_inscriptions", t.getSlots(self, t))
    end,
    info = function(self, t)
        return ("鑽研銘文之道。3 點時獲得 1 個額外的銘文欄位。\n目前額外欄位：%d"):
            format(t.getSlots(self, t))
    end,
}

-- 符文盤：一個純 UI 的天賦。
--
-- 「用天賦開一個自訂面板」是原版就有的做法：
-- modules/tome/data/talents/cursed/cursed-aura.lua:255-258 的「褻瀆之觸」
-- 就是 no_energy=true + action 裡 game:registerDialog(...)。
--
-- 刻意不設 is_spell：這只是查表，不該被沉默、法術失敗率或反魔干擾。
-- 建角時自動學會（見 data/birth/classes/mage.lua），不花技能點。
newTalent {
    name = "符文盤",
    short_name = "RW_RUNEBOARD",
    image = "talents/rune_of_the_rift.png",
    type = { "spell/inscription-lore", 1 },
    mode = "activated",
    points = 1,
    cooldown = 0,
    no_energy = true,
    no_npc_use = true,
    action = function(self, t)
        -- dialog 類別在 overload/mod/dialogs/（addon 的 data/ require 不到，見該檔頭註解）
        game:registerDialog(require("mod.dialogs.RunewrightRuneBoard").new(self))
        return true
    end,
    info = function(self, t)
        return "攤開你的符文盤：查看目前刻在身上的銘文、哪些共鳴正在運作，"
            .. "以及把背包裡的某個銘文換上去之後，共鳴會怎麼變。\n\n不消耗行動，也不會被沉默阻止。"
    end,
}
