-- tome-witchwood 的載入入口。**三個 agent 都不要改這個檔。**
--
-- 形狀抄自 self_mods/tome-runeisles/hooks/load.lua（本 repo 已驗證過的
-- 「地圖＋劇情＋NPC」範本）。要加東西之前先去讀那一份。
--
-- 為什麼這裡幾乎沒有 loadDefinition：
--   * zone   —— 進入時才依路徑載入，不需要事先註冊。
--   * npcs   —— 由各 zone 的 npcs.lua 用 load("/data-witchwood/npcs/xxx.lua") 拉進去。
--   * quest  —— grantQuest 當下才 loadfile 的惰性載入。
-- 所以本檔的主要職責是**自我檢查**：印出可驗證的事實給 tools/verify.sh 判定。
--
-- 每一項都用 fs.exists 各自獨立判斷，**缺的只會 FAIL 不會崩潰**——
-- 這是三個 agent 能平行工作、各自跑 verify 的前提。

local class = require "engine.class"

-- ---------------------------------------------------------------------------
-- 大地圖入口（由 Agent B 提供，本 session 代為掛上——契約禁止 agent 改本檔）
-- ---------------------------------------------------------------------------
-- 兩個 hook 的形狀抄自 self_mods/tome-runeisles/hooks/load.lua:28,43。
--
-- ⚠️ zone 名稱要寫 "witchwood+portal" 這種 <addon>+<name> 形式：
--    engine/Zone.lua:159-164 看到 `+` 才會把查找根從 /data 換成 /data-witchwood；
--    只寫 "portal" 會去讀原版不存在的 /data/zones/portal/，進圖直接失敗。
--    runeisles 的入口同樣是 "runeisles+worldmap"（wilderness-add/grids.lua:28）。
local WITCHWOOD_WILD_GRIDS = "/data/zones/wilderness/grids.lua"
local WITCHWOOD_ADD_GRIDS  = "/data-witchwood/zones/witchwood/wilderness-add.lua"

-- Derth 在 (25,17)，西北方取 (23,15)：周邊 8 格全是平原，且不與 runeisles 的
-- (23,17) 入口衝突。
local WITCHWOOD_PORTAL_X, WITCHWOOD_PORTAL_Y = 23, 15

class:bindHook("Entity:loadList", function(self, data)
    if data.file ~= WITCHWOOD_WILD_GRIDS then return end
    self:loadList(WITCHWOOD_ADD_GRIDS, data.no_default, data.res, data.mod, data.loaded)
end)

class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
    if data.mapfile ~= "wilderness/eyal" then return end
    data.list[#data.list + 1] = {
        x = WITCHWOOD_PORTAL_X - 1, y = WITCHWOOD_PORTAL_Y - 1, w = 3, h = 3,
        overlay = true,
        generator = "engine.generator.map.Static",
        data = { map = "witchwood+portal" },
    }
end)

class:bindHook("ToME:load", function(self, data)
    -- A：怪物
    local npcs_ok = fs.exists("/data-witchwood/npcs/witchwood.lua")

    -- B：地圖
    local zone_ok = fs.exists("/data-witchwood/zones/witchwood/zone.lua")
        and fs.exists("/data-witchwood/zones/witchwood/npcs.lua")
        and fs.exists("/data-witchwood/zones/witchwood/grids.lua")

    -- C：劇情
    local quest_ok = fs.exists("/data-witchwood/quests/witchwood-curse.lua")
        and fs.exists("/data-witchwood/chats/witchwood-crone.lua")
        and fs.exists("/data-witchwood/npcs/witchwood-quest.lua")

    for _, c in ipairs {
        { "npcs",  npcs_ok },
        { "zone",  zone_ok },
        { "quest", quest_ok },
    } do
        print(("[WITCHWOOD] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
    end
    print("[WITCHWOOD] hook complete")
end)
