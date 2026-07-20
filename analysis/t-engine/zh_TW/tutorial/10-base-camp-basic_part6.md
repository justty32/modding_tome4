### 檔案：`mod/data/chats/workbench.lua`

```lua
-- mod/data/chats/workbench.lua
-- 合成工作台對話腳本
-- 注意：Chat 環境沒有 _M，輔助函式使用 local function 定義

-- ── 輔助函式 ─────────────────────────────────────────────────

--- 計算玩家背包中某物品的數量（依 define_as 比對）
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

--- 消耗材料並產生產品
-- @param player  玩家 Actor
-- @param cost    {define_as = 數量} 消耗表
-- @param result  產品的 define_as
-- @param amount  產品數量
local function craft(player, cost, result, amount)
    -- 1. 消耗材料（從後往前遍歷避免索引偏移）
    local inven = player:getInven("INVEN")
    for item_id, qty in pairs(cost) do
        local remaining = qty
        for i = #inven, 1, -1 do
            if remaining <= 0 then break end
            local obj = inven[i]
            if obj.define_as == item_id then
                if (obj.stacked or 1) > 1 then
                    obj.stacked = (obj.stacked or 1) - 1
                    remaining   = remaining - 1
                else
                    player:removeObject(inven, i)
                    remaining = remaining - 1
                end
            end
        end
    end

    -- 2. 產生產品
    for i = 1, (amount or 1) do
        local obj = game.zone:makeEntityByName(game.level, "object", result)
        if obj then
            player:addObject(player:getInven("INVEN"), obj)
            game.logPlayer(player, "合成了 %s！", obj:getName{do_color=true})
        else
            game.logPlayer(player,
                "#RED#合成失敗：找不到產品模板 [%s]。請確認 object_list 已包含此物品。",
                result)
        end
    end
end

-- ── 對話定義 ─────────────────────────────────────────────────

newChat{
    id = "welcome",
    text = function(npc, player)
        return ("歡迎使用合成工作台。\n\n你的背包：\n" ..
            "  草藥   × " .. countItem(player, "HERB")         .. "\n" ..
            "  空瓶   × " .. countItem(player, "EMPTY_BOTTLE") .. "\n\n" ..
            "選擇要合成的物品：")
    end,
    answers = {
        -- 合成治療藥水
        {
            text = "合成治療藥水（草藥×2 + 空瓶×1）",
            cond = function(npc, player)
                return countItem(player, "HERB") >= 2
                   and countItem(player, "EMPTY_BOTTLE") >= 1
            end,
            action = function(npc, player)
                craft(player, {HERB=2, EMPTY_BOTTLE=1}, "POTION_HEALING", 1)
            end,
            jump = "crafted",
        },
        -- 合成強效治療藥水
        {
            text = "合成強效治療藥水（草藥×5 + 空瓶×1）",
            cond = function(npc, player)
                return countItem(player, "HERB") >= 5
                   and countItem(player, "EMPTY_BOTTLE") >= 1
            end,
            action = function(npc, player)
                craft(player, {HERB=5, EMPTY_BOTTLE=1}, "POTION_GREATER_HEALING", 1)
            end,
            jump = "crafted",
        },
        -- 材料不足
        {
            text = "材料不足，先去探索吧。",
            cond = function(npc, player)
                return countItem(player, "HERB") < 2
                    or countItem(player, "EMPTY_BOTTLE") < 1
            end,
            jump = "no_mats",
        },
        {text = "不用了，再見。"},
    },
}

newChat{
    id = "crafted",
    text = "合成完成！請查看你的背包。",
    answers = {
        {text = "繼續合成…", jump = "welcome"},
        {text = "謝了。"},
    },
}

newChat{
    id = "no_mats",
    text = "材料不足，無法合成。到野外多採集一些吧。",
    answers = {{text = "好的。"}},
}
```
