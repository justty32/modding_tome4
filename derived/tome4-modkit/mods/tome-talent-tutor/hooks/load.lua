-- 在大地圖（wilderness）上放置「技藝導師」。
--
-- 這些必須在這裡 require：它們在 modules/tome/mod/load.lua 是 local 不是全域。

local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local Map = require "engine.Map"

-- 德斯城（Derth）在大地圖的座標（modules/tome/data/maps/wilderness/eyal.lua:177）。
-- 導師擺在它**旁邊**——那是絕大多數角色最早會經過的城鎮。
local ANCHOR_X, ANCHOR_Y = 25, 17
local SEARCH_RADIUS = 8

--- 從 (cx,cy) 向外一圈一圈找一個站得住人的大地圖格子。
---
--- ⚠️ 從 r = 1 開始，而且要跳過任何有 `change_zone` / `change_level` 的格子。
--- 城鎮與地城的入口本身是「可站人、可 encounter」的地形
--- （data/zones/wilderness/grids.lua:509-513 的 TOWN_DERTH 就是 change_zone="town-derth"），
--- 把 NPC 放上去會**擋住玩家進城**。實機第一次跑就是放到德斯城入口格上才發現的。
---
--- 不寫死座標的原因：能不能站人是 terrain 屬性決定的
--- （data/zones/wilderness/zone.lua:77 挑 encounter 位置用的就是這兩個條件）。
local function usable_spot(x, y)
    if not game.level.map:isBound(x, y) then return false end
    if game.level.map(x, y, Map.ACTOR) then return false end
    if game.level.map:checkAllEntities(x, y, "block_move") then return false end
    if not game.level.map:checkAllEntities(x, y, "can_encounter") then return false end
    -- 區域入口不可佔用
    if game.level.map:checkAllEntities(x, y, "change_zone") then return false end
    if game.level.map:checkAllEntities(x, y, "change_level") then return false end
    return true
end

local function find_spot(cx, cy)
    for r = 1, SEARCH_RADIUS do
        for dx = -r, r do
            for dy = -r, r do
                if math.max(math.abs(dx), math.abs(dy)) == r then
                    local x, y = cx + dx, cy + dy
                    if usable_spot(x, y) then return x, y end
                end
            end
        end
    end
end

local function already_there()
    if game.level.__talent_tutor_placed then return true end
    for _, e in pairs(game.level.entities or {}) do
        if e.__talent_tutor then return true end
    end
    return false
end

local function place_tutor()
    local WorldNPC = require "mod.class.WorldNPC"

    local x, y = find_spot(ANCHOR_X, ANCHOR_Y)
    if not x then
        print("[TALENT-TUTOR] 找不到可放置的大地圖格子，放棄")
        return
    end

    local npc = WorldNPC.new {
        name = "技藝導師",
        type = "humanoid", subtype = "human",
        faction = "allied-kingdoms",
        display = '@', color = colors.LIGHT_BLUE,
        image = "npc/humanoid_human_apprentice_mage.png",
        -- engine/Chat.lua:83-90 的 "<addon>+<file>" 慣例 → /data-talent-tutor/chats/tutor.lua
        can_talk = "talent-tutor+tutor",
        cant_be_moved = true,
        never_move = true,
        unit_power = 3000,
        __talent_tutor = true,
    }
    npc:resolve()
    npc:resolve(nil, true)
    game.zone:addEntity(game.level, npc, "actor", x, y)
    game.level.__talent_tutor_placed = true
    print(("[TALENT-TUTOR] 已放置導師於大地圖 (%d,%d)"):format(x, y))
end

-- Game:changeLevel 在 changeLevel 收尾時觸發（mod/class/Game.lua:1442），
-- 此時 game.zone 與 game.level 都已就緒。wilderness 是 persistent zone，
-- 放過一次就會存進存檔，所以要擋重複。
class:bindHook("Game:changeLevel", function(self, data)
    if not game.zone or not game.level then return end
    if game.zone.short_name ~= "wilderness" then return end
    if already_there() then return end
    place_tutor()
end)

-- 自我檢查：給 tools/verify.sh grep 用。
class:bindHook("ToME:load", function(self, data)
    local checks = {
        { "chatfile", fs.exists("/data-talent-tutor/chats/tutor.lua") },
        { "talenttypes", (function()
            local n = 0
            for tt in pairs(ActorTalents.talents_types_def) do
                if type(tt) == "string" then n = n + 1 end
            end
            return n > 100
        end)() },
        { "worldnpc", pcall(require, "mod.class.WorldNPC") },
    }
    for _, c in ipairs(checks) do
        print(("[TALENT-TUTOR] selfcheck %s = %s"):format(c[1], c[2] and "OK" or "FAIL"))
    end
    print("[TALENT-TUTOR] hook complete")
end)
