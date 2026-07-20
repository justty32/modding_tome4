### Chat 系統回顧

Chat 腳本（`engine/Chat.lua`）透過 `newChat{id, text, answers}` 定義對話節點。每個 `answers` 項目可有：
- `cond(npc, player)` — 決定這個選項是否顯示
- `action(npc, player)` — 選擇後執行的函式
- `jump` — 跳轉到哪個 Chat id（`nil` 表示結束對話）

### 傭兵費用與金幣

為保持教學獨立性，我們在玩家身上用一個簡單的 `gold` 欄位表示金幣：

```lua
-- 在玩家 init() 中初始化
self.gold = self.gold or 0

-- 增加 / 減少
player.gold = player.gold + 100
player.gold = player.gold - 200

-- 查詢
player.gold   -- 目前金幣
```

> 如果在 ToME addon 中使用，請改用 `player:getMoney()` / `player:incMoney(-200)`。

### 招募流程核心：`zone:makeEntityByName` + `zone:addEntity`

```lua
-- 1. 從模板產生一個完全解析的實例（clone + resolve）
local merc = game.zone:makeEntityByName(game.level, "actor", "MERC_WARRIOR")
-- 注意：makeEntityByName 會自動 resolve() 所有 resolvers
-- 若找不到模板（define_as 不存在），回傳 nil

-- 2. 找一個玩家附近的空格
local x, y = util.findFreeGrid(player.x, player.y, 5, true, {[Map.ACTOR]=true})
-- 參數：起點(x,y)、搜尋半徑、是否需要 LOS、阻擋條件表

-- 3. 放到地圖上（addEntity 會呼叫 merc:added() 等初始化鉤子）
game.zone:addEntity(game.level, merc, "actor", x, y)

-- 4. 加入隊伍
game.party:addMember(merc, {
    control          = "no",             -- 玩家不能直接切換控制
    title            = "傭兵",
    keep_between_levels = true,          -- 切換樓層時保留（跟著走）
})
-- addMember 會自動設定：
--   merc.ai_state.tactic_leash_anchor = game.player
--   merc.ai_state.tactic_leash = 10
```

### 檔案：`mod/data/chats/recruiter.lua`

```lua
-- mod/data/chats/recruiter.lua
-- 招募者 NPC 的對話腳本
-- 透過 Chat.new("mod.data.chats.recruiter", npc, player) 呼叫

local Map = require "engine.Map"

-- ── 首次見面 ─────────────────────────────────────────────────
newChat{
    id = "welcome",
    text = [[我是僱傭兵公會的布托克。如果你手頭寬裕，我可以為你安排幾位精銳戰士。

每位傭兵的招募費用是 200 金幣。你已有 %d 金幣，最多可再招募 %d 名隊友（上限 3 名）。

你想招募哪種傭兵？]],
    text_resolver = function(npc, player)
        local slots = 3 - (#game.party.m_list - 1)   -- 扣掉玩家本人
        return player.gold, math.min(slots, math.floor(player.gold / 200))
    end,
    answers = {
        -- 鐵衛士
        {text = "招募一名鐵衛士（近戰）— 200 金幣",
         cond = function(npc, player)
             local slots = 3 - (#game.party.m_list - 1)
             return player.gold >= 200 and slots > 0
         end,
         action = function(npc, player)
             _M.recruitMerc(npc, player, "MERC_WARRIOR", "鐵衛士")
         end,
         jump = "hired"},

        -- 森林弓手
        {text = "招募一名森林弓手（遠程）— 200 金幣",
         cond = function(npc, player)
             local slots = 3 - (#game.party.m_list - 1)
             return player.gold >= 200 and slots > 0
         end,
         action = function(npc, player)
             _M.recruitMerc(npc, player, "MERC_ARCHER", "森林弓手")
         end,
         jump = "hired"},

        -- 流浪法師
        {text = "招募一名流浪法師（魔法）— 200 金幣",
         cond = function(npc, player)
             local slots = 3 - (#game.party.m_list - 1)
             return player.gold >= 200 and slots > 0
         end,
         action = function(npc, player)
             _M.recruitMerc(npc, player, "MERC_MAGE", "流浪法師")
         end,
         jump = "hired"},

        -- 沒錢
        {text = "（金幣不足，無法招募）",
         cond = function(npc, player)
             return player.gold < 200
         end,
         jump = "no_money"},

        -- 隊伍已滿
        {text = "（隊伍已滿，無法再招募）",
         cond = function(npc, player)
             return #game.party.m_list > 3
         end,
         jump = "full_party"},

        {text = "沒有，再見。"},
    },
}

-- ── 招募成功 ─────────────────────────────────────────────────
newChat{
    id = "hired",
    text = [[好，已為你安排完畢。記得好好指揮你的隊友。

（提示：按 C 鍵開啟戰術指令選單）]],
    answers = {
        {text = "繼續招募...", jump = "welcome"},
        {text = "謝了，再見。"},
    },
}

-- ── 金幣不足 ─────────────────────────────────────────────────
newChat{
    id = "no_money",
    text = [[我不是在做慈善。至少帶 200 金幣來再說吧。]],
    answers = {{text = "...我去想辦法。"}},
}

-- ── 隊伍已滿 ─────────────────────────────────────────────────
newChat{
    id = "full_party",
    text = [[你已經帶了夠多人了。先讓幾個人離隊再來吧。]],
    answers = {{text = "好的。"}},
}

-- ── 招募執行函式（非對話節點，純 Lua） ────────────────────────
-- Chat 腳本中的函式只能存放在 _M（Chat 物件的 metatable）裡
function _M.recruitMerc(npc, player, template_id, label)
    -- 扣除金幣
    player.gold = player.gold - 200

    -- 從模板生成傭兵
    local merc = game.zone:makeEntityByName(game.level, "actor", template_id)
    if not merc then
        game.logPlayer(player, "#RED#招募失敗：找不到傭兵模板 %s。", template_id)
        player.gold = player.gold + 200   -- 退款
        return
    end

    -- 設定名字（加入隊主名稱以區分）
    merc.name = label

    -- 尋找玩家附近的空格
    local x, y = util.findFreeGrid(player.x, player.y, 5, true, {[Map.ACTOR]=true})
    if not x then
        game.logPlayer(player, "#RED#招募失敗：附近沒有足夠的空間。")
        player.gold = player.gold + 200
        return
    end

    -- 放入地圖
    game.zone:addEntity(game.level, merc, "actor", x, y)

    -- 加入隊伍
    game.party:addMember(merc, {
        control             = "no",
        title               = "傭兵",
        keep_between_levels = true,
    })

    game.logPlayer(player, "#LIGHT_GREEN#%s 加入了你的隊伍！按 C 鍵開啟戰術指令選單。", label)
end
```

> **`text_resolver`** 不是 TE4 原生欄位——標準 Chat 系統的 `text` 是純字串，不支援動態內容。若你需要在對話文字中插入數值，有兩種做法：
> 1. 在 `action` 函式中用 `game.logPlayer` 顯示額外資訊
> 2. 或在進入 Chat 前計算好字串，作為 `text` 傳入（進階做法）
>
> 上面的 `text_resolver` 欄位只是教學標注，實際上你應該把動態內容放到 `game.logPlayer` 或改用方法一。以下是實用版的正確做法：

```lua
-- 實用版：動態文字用 text 函式（TE4 支援 text 為 function）
newChat{
    id = "welcome",
    text = function(npc, player)
        local slots = math.max(0, 3 - (#game.party.m_list - 1))
        return ("我是布托克。費用 200 金幣/人。你有 %d 金幣，可再招募 %d 人。"):format(
            player.gold,
            math.min(slots, math.floor(player.gold / 200))
        )
    end,
    -- ...answers 同上
}
```

> **TE4 的 `text` 欄位支援 function**：引擎在渲染對話時會呼叫 `util.getval(node.text, npc, player)`，若是函式就傳入 npc/player 並取回字串。這是安全的動態文字做法。

---
