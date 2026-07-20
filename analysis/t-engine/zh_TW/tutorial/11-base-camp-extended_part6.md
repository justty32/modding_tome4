
### 新增 `mod/data/chats/build_manager.lua`

```lua
-- mod/data/chats/build_manager.lua
-- 建造管理員對話腳本

-- ── 輔助函式（local，不依賴 _M）────────────────────────────────

local function countItem(player, item_id)
    local inven = player:getInven("INVEN")
    if not inven then return 0 end
    local count = 0
    for _, obj in ipairs(inven) do
        if obj.define_as == item_id then
            count = count + (obj.stacked or 1)
        end
    end
    return count
end

--- 消耗資源並在地圖上替換對應建造地塊
-- @param player  玩家
-- @param cost    {item_id = qty}
-- @param btype   建造類型（需與 Grid 的 build_tag 對應）
local function build(player, cost, btype)
    -- 初始化 camp_state（防禦性初始化）
    game.camp_state = game.camp_state or {
        buildings={}, farms={}, workers={}
    }
    local cs = game.camp_state
    cs.buildings = cs.buildings or {}

    -- 消耗材料（從後往前遍歷避免索引偏移）
    local inven = player:getInven("INVEN")
    for item_id, qty in pairs(cost) do
        local remaining = qty
        for i = #inven, 1, -1 do
            if remaining <= 0 then break end
            local obj = inven[i]
            if obj.define_as == item_id then
                if (obj.stacked or 1) > 1 then
                    obj.stacked = (obj.stacked or 1) - 1
                    remaining = remaining - 1
                else
                    player:removeObject(inven, i)
                    remaining = remaining - 1
                end
            end
        end
    end

    -- 標記建造完成
    cs.buildings[btype] = true

    -- 掃描地圖，把對應 build_tag 的建造地塊替換為設施 Grid
    _applyBuildingToMap(btype)

    game.logPlayer(player, "#LIGHT_GREEN#建造完成：%s！新設施已出現在據點地圖上。", btype)
end

--- 掃描地圖，把所有 build_tag == btype 的格子替換為完成後的設施 Grid
local function _applyBuildingToMap(btype)
    local Map = require "engine.Map"
    local map = game.level.map

    -- 建造類型 → 替換為哪個 Grid（與 camp.lua 的 define_as 一致）
    local replacements = {
        farm          = "FARM_EMPTY",
        chest         = "CAMP_CHEST",
        upgraded_fire = "CAMPFIRE_UPGRADED",
    }
    local new_grid_id = replacements[btype]
    if not new_grid_id then return end

    -- 掃描全圖
    for y = 0, map.h - 1 do
        for x = 0, map.w - 1 do
            local t = map(x, y, Map.TERRAIN)
            if t and t.build_site and t.build_tag == btype then
                local new_grid = game.zone.grid_list[new_grid_id]
                if new_grid then
                    map(x, y, Map.TERRAIN, new_grid)
                    map.changed = true
                end
            end
        end
    end
end

-- ── 對話定義 ─────────────────────────────────────────────────

newChat{
    id = "welcome",
    text = function(npc, player)
        local cs = game.camp_state or {}
        local bs = cs.buildings   or {}
        return ("歡迎，指揮官。\n\n目前據點建造狀況：\n" ..
            "  農田：" ..         (bs.farm          and "✓ 已建造" or "✗ 未建造") .. "\n" ..
            "  儲物箱：" ..       (bs.chest         and "✓ 已建造" or "✗ 未建造") .. "\n" ..
            "  強化篝火：" ..     (bs.upgraded_fire and "✓ 已建造" or "✗ 未建造") .. "\n\n" ..
            "你有：木材 " .. countItem(player, "WOOD") ..
            "，石塊 " ..          countItem(player, "STONE") ..
            " 個。\n\n選擇要建造的設施：")
    end,
    answers = {
        -- 建造農田
        {
            text = "建造農田（木材×5）",
            cond = function(npc, player)
                local bs = (game.camp_state or {}).buildings or {}
                return not bs.farm and countItem(player, "WOOD") >= 5
            end,
            action = function(npc, player)
                build(player, {WOOD=5}, "farm")
            end,
            jump = "built",
        },
        -- 建造儲物箱
        {
            text = "建造儲物箱（木材×3 + 石塊×2）",
            cond = function(npc, player)
                local bs = (game.camp_state or {}).buildings or {}
                return not bs.chest
                   and countItem(player, "WOOD")  >= 3
                   and countItem(player, "STONE") >= 2
            end,
            action = function(npc, player)
                build(player, {WOOD=3, STONE=2}, "chest")
            end,
            jump = "built",
        },
        -- 強化篝火
        {
            text = "強化篝火（石塊×5 + 木材×2）",
            cond = function(npc, player)
                local bs = (game.camp_state or {}).buildings or {}
                return not bs.upgraded_fire
                   and countItem(player, "STONE") >= 5
                   and countItem(player, "WOOD")  >= 2
            end,
            action = function(npc, player)
                build(player, {STONE=5, WOOD=2}, "upgraded_fire")
            end,
            jump = "built",
        },
        -- 農田已建造
        {
            text = "農田已建造。",
            cond = function(npc, player)
                return ((game.camp_state or {}).buildings or {}).farm == true
            end,
            jump = "farm_done",
        },
        {text = "資源不足，先去探索。"},
    },
}

newChat{
    id = "built",
    text = "建造完成！新設施已出現在據點地圖上，請前往查看。",
    answers = {
        {text = "繼續建造…", jump = "welcome"},
        {text = "謝謝。"},
    },
}

newChat{
    id = "farm_done",
    text = "農田已建造完成。記得取得草藥種子後，踩上農田按 [>] 種植。工人可以加速農作成熟。",
    answers = {
        {text = "繼續建造…", jump = "welcome"},
        {text = "明白了。"},
    },
}
```

---