-- 攔截天賦使用，讓「觸發任何銘文」都累積符文充能。
--
-- 為什麼是 postUseTalent 而不是 usedInscription：
--   mod/class/interface/ActorInscriptions.lua:149 的 usedInscription() 在整個模組裡
--   **沒有任何呼叫者**（grep 全庫只有定義本身），它是死代碼。
--   真正可靠的識別方式是天賦上的 is_inscription 旗標
--   （data/talents/misc/inscriptions.lua:60 由 newInscription 統一加上）。
--   而 ToME 沒有提供 "Actor:postUseTalent" 這個 hook（Actor.lua 只有 preUseTalent 的 hook，
--   見 mod/class/Actor.lua:5946），所以只能 superload。

local _M = loadPrevious(...)

local base_postUseTalent = _M.postUseTalent

--- 取得共鳴判定庫（純函數模組，由 hooks/load.lua 掛上全域）
function _M:runewrightResonanceLib()
    return _G.__runewright_resonance
end

--- 目前身上的銘文清單，轉成共鳴庫吃的格式。
--- id 用 t.short_name（英文、與語系無關）；t.name 已被 _t 翻譯過，只能拿來顯示。
function _M:runewrightInscriptionList()
    local list = {}
    if not self.inscriptions then return list end
    for i = 1, (self.max_inscriptions or 3) do
        local name = self.inscriptions[i]
        if name then
            local t = self:getTalentFromId(self["T_" .. name])
            if t then
                local kind = (t.type and t.type[1] or ""):gsub("^inscriptions/", "")
                list[#list + 1] = { id = t.short_name, name = t.name, kind = kind }
            end
        end
    end
    return list
end

--- 目前啟動中的共鳴。學會「共鳴之心」才有效。
function _M:runewrightResonances()
    local lib = self:runewrightResonanceLib()
    if not lib then return {} end
    if not self:knowTalent(self.T_RW_RESONANT_MIND) then return {} end
    return lib.evaluate(self:runewrightInscriptionList())
end

--- ᛗ Mannaz（曼納茲・人之符）的加成隨「啟動中的共鳴數量」浮動，
--- 所以不能寫在天賦的 passives（那只在學習時計算一次）。
--- 每次共鳴集合變動時，撤掉舊的 temporary value 再上新的。
function _M:runewrightApplyMannaz(active_count)
    if self.__rw_mannaz_tv then
        self:removeTemporaryValue("combat_spellpower", self.__rw_mannaz_tv)
        self.__rw_mannaz_tv = nil
    end
    if not self:knowTalent(self.T_RW_MANNAZ) then return end
    local t = self:getTalentFromId(self.T_RW_MANNAZ)
    local bonus = active_count * t.getPowerPerResonance(self, t)
    if bonus > 0 then
        self.__rw_mannaz_tv = self:addTemporaryValue("combat_spellpower", bonus)
    end
end

--- 套用共鳴的宣告式效果。
--- 效果資料放在 data/lib/resonance.lua 的 def.effects（純資料），
--- 這裡只負責泛用地 addTemporaryValue / removeTemporaryValue。
function _M:runewrightApplyResonanceEffects(active)
    -- 先撤掉上一輪的全部加成
    if self.__rw_resonance_tvs then
        for _, tv in ipairs(self.__rw_resonance_tvs) do
            self:removeTemporaryValue(tv[1], tv[2])
        end
    end
    self.__rw_resonance_tvs = {}

    for _, def in ipairs(active) do
        for attr, val in pairs(def.effects or {}) do
            -- addTemporaryValue 對表值（resists / inc_damage）與純量都適用
            local id = self:addTemporaryValue(attr, val)
            table.insert(self.__rw_resonance_tvs, { attr, id })
        end
    end
end

--- 共鳴集合變動時：套用效果、Mannaz 加成，並通知玩家。
--- 由 RW_RESONANT_MIND 的 callbackOnActBase 每回合呼叫（Actor.lua:646 fireTalentCheck），
--- 以及 postUseTalent 觸發銘文時呼叫。集合沒變就直接返回，避免每回合重建 temporary value。
function _M:runewrightSyncResonances()
    local active = self:runewrightResonances()
    local now = {}
    for _, d in ipairs(active) do now[d.id] = true end

    local prev = self.__runewright_active_resonances or {}
    local changed = false
    for id in pairs(now) do if not prev[id] then changed = true end end
    for id in pairs(prev) do if not now[id] then changed = true end end
    if not changed and self.__rw_resonance_tvs then return end

    for _, d in ipairs(active) do
        if not prev[d.id] then
            game.logPlayer(self, "#YELLOW#共鳴啟動：%s#LAST# %s", d.name, d.desc)
        end
    end
    for id in pairs(prev) do
        if not now[id] then game.logPlayer(self, "#GREY#一道共鳴消失了。#LAST#") break end
    end

    self.__runewright_active_resonances = now
    self:runewrightApplyResonanceEffects(active)
    self:runewrightApplyMannaz(#active)
end

function _M:postUseTalent(ab, ret, silent)
    local r = base_postUseTalent(self, ab, ret, silent)

    -- 觸發任何銘文 → 累積 1 點符文充能。
    -- getRunecharge/incRunecharge 由 data/resources.lua 的 defineResource 生成；
    -- 沒學 T_RUNE_CHARGE_POOL 的角色 getter 恆回 0（ActorResource.lua:87-94），
    -- 所以這裡要用 knowTalent 擋掉，不然非本職業的角色會被無謂地 inc。
    if ret and ab.is_inscription and self:knowTalent(self.T_RUNE_CHARGE_POOL) then
        self:incRunecharge(1)
        self:runewrightSyncResonances()
    end

    return r
end

return _M
