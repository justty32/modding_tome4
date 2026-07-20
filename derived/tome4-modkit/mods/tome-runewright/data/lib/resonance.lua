-- 共鳴（Resonance）判定 —— 純函數，無副作用。
--
-- 設計約束（來自 workflows/specs/runewright.md）：
-- 這裡的判定必須是純函數，因為之後的「符文盤」UI 面板要對「假設玩家再刻上 X」
-- 的假想銘文清單求值，來顯示預測提示。任何依賴 actor 狀態的邏輯都不准寫進來。
--
-- 輸入：inscriptions = { {id="RUNE:_SHIELDING_1", name="符文：護盾", kind="runes"}, ... }
--   id   ＝ 銘文天賦的 short_name。**比對只准用它。**
--   name ＝ 顯示名，只給 UI 用。
--   kind ＝ 天賦 type[1] 去掉 "inscriptions/" 前綴（runes / infusions / taints）
-- 輸出：已觸發的共鳴定義陣列
--
-- ⚠️ 為什麼比對 id 而不是 name：
--   engine/interface/ActorTalents.lua:88 在建立天賦時做 `t.name = _t(t.name, "talent name")`，
--   而 short_name 早在 data/talents/misc/inscriptions.lua:24 就用**英文原名**算好了。
--   所以 t.name 是**已翻譯**的（中文語系下是「符文：護盾」），拿英文去比對永遠不會中。
--   這個 bug 只有實機跑中文語系才會現形——靜態檢查與載入驗證都抓不到。

local M = {}
local defs = require("data.lib.resonance_defs")
M.defs = defs.defs
M.hasId = defs.hasId

--- 依 kind 統計數量
function M.countKinds(list)
    local counts = {}
    for _, ins in ipairs(list) do
        if ins.kind then counts[ins.kind] = (counts[ins.kind] or 0) + 1 end
    end
    return counts
end

--- 對一份銘文清單求值，回傳已觸發的共鳴
function M.evaluate(list)
    list = list or {}
    local counts = M.countKinds(list)
    local out = {}
    for _, def in ipairs(M.defs) do
        if def.matches(counts, list) then out[#out + 1] = def end
    end
    return out
end

--- 兩份銘文清單之間的共鳴差異。回傳 gained, lost 兩個陣列。
--
-- 符文盤面板用這個來回答「把槽 2 換成背包裡這顆符文，我會得到什麼、失去什麼」。
-- 依 M.defs 的順序輸出，結果是確定的（不依賴 pairs 的迭代順序）。
function M.diff(before, after)
    local was, now = {}, {}
    for _, d in ipairs(M.evaluate(before)) do was[d.id] = true end
    for _, d in ipairs(M.evaluate(after)) do now[d.id] = true end

    local gained, lost = {}, {}
    for _, d in ipairs(M.defs) do
        if now[d.id] and not was[d.id] then
            gained[#gained + 1] = d
        elseif was[d.id] and not now[d.id] then
            lost[#lost + 1] = d
        end
    end
    return gained, lost
end

--- 把 list 的第 index 項換成 candidate（index 為 nil 或超出範圍＝單純追加）。
-- 回傳一份新清單，不動原清單——面板要對很多個假想組合求值。
function M.withReplacement(list, index, candidate)
    local out = {}
    for i, v in ipairs(list) do out[i] = v end
    if index and out[index] then
        out[index] = candidate
    else
        out[#out + 1] = candidate
    end
    return out
end

--- 預測：若再加上 candidate，會新觸發哪些共鳴？（UI 面板用）
-- 這就是為什麼 evaluate 必須是純函數。
function M.predict(list, candidate)
    local now = {}
    for _, d in ipairs(M.evaluate(list)) do now[d.id] = true end

    local hypothetical = {}
    for i, v in ipairs(list) do hypothetical[i] = v end
    hypothetical[#hypothetical + 1] = candidate

    local gained = {}
    for _, d in ipairs(M.evaluate(hypothetical)) do
        if not now[d.id] then gained[#gained + 1] = d end
    end
    return gained
end

return M
