-- 把新物品與新 ego 追加進原版清單。
--
-- 一切物品清單都經過 engine/interface/Entity 的 loadList，而 loadList 在檔尾必廣播
-- "Entity:loadList" hook（engine/Entity.lua:1267），並交出同一個 res 表。用同一個 res
-- 再 loadList 我們自己的檔，就是 append（engine/Entity.lua:1238 的 res[#res+1]=e）。
-- ego 檔也走同一條路（engine/Zone.lua:360 的 getEgosList → loadList），所以一樣攔得到。
--
-- 前例：nullpack/hooks/load.lua:41-57（追加 ego 與 artifact）、
--       verdant/hooks/load.lua:58-63、arcanum/hooks/load.lua:161-217。
--
-- 這些必須在這裡 require：它們在 modules/tome/mod/load.lua 是 local，hook 閉包看不到。
local class = require "engine.class"

local ARTIFACTS = "/data/general/objects/world-artifacts.lua"
-- 被攔截的原版檔（key）→ 我們要 append 的檔（value，掛在私有的 /data-relics/）
local APPEND = {
    [ARTIFACTS]                                   = "/data-relics/general/objects/relics-artifacts.lua",
    ["/data/general/objects/egos/weapon.lua"]     = "/data-relics/general/objects/egos-weapon.lua",
    ["/data/general/objects/egos/armor.lua"]      = "/data-relics/general/objects/egos-armor.lua",
}
local WANT = {
    { "lantern", "RELIC_RUBBING_LANTERN" },
    { "goggles", "RELIC_EXCAVATOR_GOGGLES" },
    { "gloves",  "RELIC_EXCAVATOR_GLOVES" },
    { "pick",    "RELIC_CHRONICLE_PICK" },
}

class:bindHook("Entity:loadList", function(self, data)
    local add = APPEND[data.file]
    if not add then return end
    -- 原封轉傳 no_default/res/mod/loaded——用同一個 res 才是 append 語意。
    -- ego 載入時 no_default=true，轉傳即正確。
    self:loadList(add, data.no_default, data.res, data.mod, data.loaded)

    -- 神器的自我檢查：**在真的 append 完成時**做，而不是在 ToME:load。
    -- 原因：神器用 base="BASE_LITE" 等，只有此刻的 data.res 同時含有原版基底才 resolve 得了；
    -- 而且原版 world-artifacts.lua:24 在載入時就會參照全域 game，ToME:load 太早（game 還是布林）。
    -- 這裡的 data.res 就是剛 append 完的完整清單，掃它即可證明我們的 unique 真的註冊進去。
    -- 用旗標確保只印一次（world-artifacts 每次進 zone 都會重載）。
    if data.file == ARTIFACTS and not _G.__relics_checked then
        _G.__relics_checked = true
        local found = {}
        for _, e in ipairs(data.res) do if e.define_as then found[e.define_as] = true end end
        for _, w in ipairs(WANT) do
            print(("[RELICS] selfcheck %s = %s"):format(w[1], found[w[2]] and "OK" or "FAIL"))
        end
        print("[RELICS] hook complete")
    end
end)

-- ego 的自我檢查：ego 檔沒有 base，單獨 loadList 即可安全載入並計數。
-- 這在 ToME:load 就能做（不依賴 game 或 zone）。
class:bindHook("ToME:load", function(self, data)
    local Object = require "mod.class.Object"
    local function egoCount(file)
        local ok, list = pcall(function() return Object:loadList(file, true) end)
        if not ok then print("[RELICS] probe error "..file..": "..tostring(list)) return 0 end
        return type(list) == "table" and #list or 0
    end
    print(("[RELICS] selfcheck ego_weapon = %s"):format(
        egoCount("/data-relics/general/objects/egos-weapon.lua") >= 1 and "OK" or "FAIL"))
    print(("[RELICS] selfcheck ego_armor = %s"):format(
        egoCount("/data-relics/general/objects/egos-armor.lua") >= 1 and "OK" or "FAIL"))
end)
