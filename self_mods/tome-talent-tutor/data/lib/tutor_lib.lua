-- 技藝導師對話輔助函式。
-- 收集技能樹、判斷傳授狀態、提供 UI 輔助字串與分頁 ID。
-- 由 chats/tutor.lua 載入，不應直接引用。

local ActorTalents = require "engine.interface.ActorTalents"

local M = {}

M.PER_PAGE = 10
local SKIP_CAT = { base = true, inscriptions = true }

M.CAT_NAME = {
    technique = "戰技", cunning = "靈巧", spell = "法術", celestial = "星辰",
    chronomancy = "時空", corruption = "腐化", cursed = "詛咒", psionic = "靈能",
    ["wild-gift"] = "自然", undead = "不死", golem = "傀儡", race = "種族",
    uber = "傳奇", steamtech = "蒸汽科技", other = "其他", misc = "雜項",
}
M.CAT_ORDER = {
    "technique", "cunning", "spell", "celestial", "chronomancy",
    "corruption", "cursed", "psionic", "wild-gift",
    "golem", "undead", "race", "uber", "steamtech", "other", "misc",
}

--- 遍歷所有技能樹，依大類分組並排序，回傳 by_cat table。
-- talents_types_def 同時有陣列部分與字串鍵（ActorTalents.lua:59-60），
-- 所以濾掉數字鍵，否則每棵樹會出現兩次。
function M.buildByCat()
    local by_cat = {}
    for tt, def in pairs(ActorTalents.talents_types_def) do
        if type(tt) == "string" then
            local cat = tt:match("^([^/]+)/")
            if cat and not SKIP_CAT[cat] then
                by_cat[cat] = by_cat[cat] or {}
                table.insert(by_cat[cat], { id = tt, name = def.name or tt, generic = def.generic })
            end
        end
    end
    for _, list in pairs(by_cat) do
        table.sort(list, function(a, b) return a.name < b.name end)
    end
    return by_cat
end

--- 玩家對某棵樹的三種狀態（ActorTalents.lua:889-891）：
---   nil   = 沒聽過
---   false = 已顯現，但要花類別點才能加點
---   true  = 已解鎖
function M.known_state(player, tt) return player:knowTalentType(tt) end

--- 將一棵樹傳授給玩家。
-- learnTalentType 的短路條件是 `if self.talents_types[tt] then return end`
-- （ActorTalents.lua:989），**只有 true 會擋**；false 是 falsy，
-- 所以 false → true 其實它自己就能做到。這裡分開寫只是把三種狀態講明白。
-- 不會幫忙補熟練度，那要自己設。
function M.grant(player, tt)
    if M.known_state(player, tt) == nil then
        player:learnTalentType(tt, true)
    else
        player.talents_types[tt] = true
    end
    if player:getTalentTypeMastery(tt) < 1 then
        player:setTalentTypeMastery(tt, 1.0)
    end
    player.changed = true
end

--- 回傳 true 表示這棵樹還可以傳授（尚未學會）。
function M.grantable(player, tt) return M.known_state(player, tt) ~= true end

--- 對話選項的標籤文字（靜態字串，Chat.lua:101 直接取 a[1]）。
-- 已學會的樹靠 cond 濾掉，不靠標籤標示。
function M.tree_label(e)
    local tag = e.generic and " #GREY#(通用)#LAST#" or ""
    return ("學習 #LIGHT_BLUE#%s#LAST#%s"):format(e.name, tag)
end

--- 生成每個大類分頁用的對話 id。
function M.cat_chat_id(cat, page) return ("cat_%s_%d"):format(cat, page) end

return M
