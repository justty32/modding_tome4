## 步驟七：城鎮 Zone 設定

在城鎮 Zone 的靜態地圖或 NPC 列表中加入招募者：

### 方法 A：在靜態地圖 Lua 中直接定義 NPC

```lua
-- mod/data/zones/town/map.lua（Static map）
-- 在特定座標放置招募者

-- 地圖格: R = 招募者 NPC
return {
    w = 20, h = 20,
    map = {
        -- ...（省略地形格）
    },
    -- 特殊格子上的 NPC 定義
    add_actor = {
        R = function(x, y)
            local npc = game.zone:makeEntityByName(game.level, "actor", "RECRUITER_BUTOK")
            if npc then
                game.zone:addEntity(game.level, npc, "actor", x, y)
            end
        end,
    },
}
```

### 方法 B：在 Zone 定義中加入固定 NPC 列表

```lua
-- mod/data/zones/town.lua
local Zone = require "engine.Zone"

return Zone.new("town", {
    name        = "洛克港鎮",
    level_range = {1, 1},
    level_scheme = "player",
    max_level   = 1,

    width = 40, height = 40,
    all_remembered   = true,   -- 城鎮全部可見
    all_lited        = true,
    persistent       = "zone", -- 城鎮狀態持久化

    generator = {
        map   = {class="engine.generator.map.Static", map="mod/maps/town"},
        actor = {class="engine.generator.actor.OnceAtCoord",
                 -- 在特定座標放置固定 NPC
                 actors = {
                     {defined="RECRUITER_BUTOK", x=10, y=8},
                 }},
    },

    -- 載入傭兵模板（讓 makeEntityByName 可以找到）
    npc_list  = require("mod.class.NPC"):loadList{
        "mod/data/npcs/town.lua",
        "mod/data/npcs/mercenaries.lua",  -- ← 必須包含
    },
})
```

### 招募者 NPC 定義

```lua
-- mod/data/npcs/town.lua（摘錄）
newEntity{
    define_as   = "RECRUITER_BUTOK",
    type        = "humanoid", subtype = "human",
    name        = "布托克",
    display     = "@", color = {r=255, g=200, b=100},
    faction     = "players",
    level_range = {1, 1},
    exp_worth   = 0,
    rank        = 1,
    
    -- 不自動移動
    ai = "none",
    ai_state = {},
    
    -- 對話腳本路徑
    chat = "mod.data.chats.recruiter",
    
    -- 點擊 / 互動觸發對話
    on_interact = function(self, who)
        local chat = require "engine.Chat"
        local c = chat.new(self.chat, self, who)
        c:invoke()
    end,
    
    stats = {str=12, dex=12, con=12, mag=5, wil=10, cun=10},
    max_life = resolvers.rngrange(50, 70),
}
```

> **`ai = "none"`**：定義在 `simple.lua` 中的一個空 AI（`newAI("none", function(self) end)`），讓 NPC 完全靜止，不尋找目標也不移動。城鎮 NPC 通常使用這個 AI。

---

## 步驟八：持久化考量

### 指令（`ai_state.command`）的存檔

`ai_state` 是普通的 Lua 表，由 TE4 序列化系統（`serial.c`）自動存檔。但 `command.target` 是一個 Actor 參考：

```lua
ally.ai_state.command = {type = "attack", target = <Actor>}
--                                                  ↑ 這是 Actor 物件
```

TE4 的序列化系統使用 `uid` 來重建物件參考。Actor 物件有 `__ATOMIC = true` 標記（見 `engine/Entity.lua`），因此它們**不會被深度複製**，而是透過 `uid` 記錄參考。載入後，弱引用表 `__uids` 會重建這個參考。

**實際上你不需要額外處理**——TE4 已正確處理 Actor 作為表值的存檔。只需注意：如果目標在存檔時已死亡，重載後 `cmd.target.dead == true`，`commanded_ally` AI 會自動清除這個指令。

### 傭兵的跨樓層跟隨

`game.party:addMember(merc, {keep_between_levels=true})` 設定後，`Party:leftLevel()` 函式會在切換樓層時保留此成員（不觸發 `removeMember`）。引擎會在新樓層的安全區域重新放置傭兵。

---

## 步驟九：整合到 `load.lua`

```lua
-- mod/load.lua（摘錄）

-- 確保 Party 系統已初始化
dofile("/mod/class/Party.lua")

-- 載入 NPC 模板（包含傭兵）
-- （通常在 Zone 的 npc_list 中已指定，這裡是確保全域可用）

-- 初始化 game.party（如果你的模組使用 Party 系統）
game.party = require("mod.class.Party").new()
game.party:addMember(game.player, {
    main    = true,
    control = "full",
    title   = "主角",
    keep_between_levels = true,
})
```

---

## 完整測試流程

### 1. 測試 AI 指令

```lua
-- 在 cheat console 測試（按 ` 或 F1 進入）
-- 取得第一個隊友
local ally = game.party.m_list[2]
if ally then
    -- 下達跟隨指令
    ally.ai_state.command = {type = "follow"}
    print("指令設定成功，隊友 AI:", ally.ai)
    
    -- 確認 AI 是否正確
    assert(ally.ai == "commanded_ally", "AI 未設定！")
    
    -- 下達攻擊指令（需要有敵人）
    local enemy = game.level.map(5, 5, require("engine.Map").ACTOR)
    if enemy and game.player:reactionToward(enemy) < 0 then
        ally.ai_state.command = {type = "attack", target = enemy}
    end
end
```

### 2. 測試招募流程

```lua
-- 在 cheat console 給玩家金幣
game.player.gold = 500
print("金幣設定完成:", game.player.gold)

-- 手動觸發招募
local merc = game.zone:makeEntityByName(game.level, "actor", "MERC_WARRIOR")
if merc then
    local x, y = util.findFreeGrid(game.player.x, game.player.y, 5, true,
        {[require("engine.Map").ACTOR]=true})
    game.zone:addEntity(game.level, merc, "actor", x, y)
    game.party:addMember(merc, {control="no", keep_between_levels=true})
    print("招募成功！隊伍人數:", #game.party.m_list)
else
    print("ERROR: 找不到 MERC_WARRIOR 模板！")
    print("確認 mercenaries.lua 已被載入到 zone.npc_list")
end
```

---

## 常見錯誤排查

| 錯誤現象 | 可能原因 | 解法 |
|---------|---------|------|
| `[runAI] UNDEFINED AI "commanded_ally"` | `mod/ai/` 未被載入 | 在 `Game:load()` 中呼叫 `self.player_class:loadDefinition("/mod/ai/")` |
| 傭兵招募後不移動 | `ai = "none"` 設在傭兵身上 | 確認傭兵模板的 `ai = "commanded_ally"` |
| `makeEntityByName` 回傳 nil | 傭兵模板未加入 zone.npc_list | 在 Zone 定義的 `npc_list` 中包含 `mercenaries.lua` |
| 傭兵攻擊玩家 | faction 設定錯誤 | 傭兵模板中設 `faction = "players"` |
| 指令對話框無法開啟 | `ActorCommand` 混入 未繼承 | 在 Player.lua 的 `class.inherit(...)` 中加入 `ActorCommand` |
| 切換樓層後傭兵消失 | `keep_between_levels` 未設為 true | 在 `addMember` 的 def 表格中設 `keep_between_levels = true` |
| 傭兵在 standby 時凍結（能量不消耗） | 沒有呼叫 `useEnergy()` | 在 `_cmd_standby` AI 中確認有 `self:useEnergy()` |
| 攻擊指令無效（目標死後繼續攻擊 nil） | 沒有清除 dead 目標 | `commanded_ally` AI 中 `if not cmd.target or cmd.target.dead then` 清除指令 |

---

## 進階擴展方向

### 1. 指令優先序與指令佇列

目前設計是「最後一個指令覆蓋前一個」。若要支援佇列：

```lua
-- ai_state.command_queue 是一個陣列
ally.ai_state.command_queue = ally.ai_state.command_queue or {}
table.insert(ally.ai_state.command_queue, {type="attack", target=enemy})
-- AI 每次執行完一個指令後 table.remove(queue, 1)
```

### 2. 傭兵等級隨玩家提升

在 `Party:addMember` 後立即同步等級：

```lua
-- 強制傭兵達到玩家等級
if merc.forceLevelup then
    merc:forceLevelup(game.player.level)
end
```

### 3. 傭兵死亡後的處理

在傭兵身上加入 `on_die` 回呼：

```lua
on_die = function(self, who)
    if game.party and game.party.members[self] then
        game.party:removeMember(self)
        game.logPlayer(game.player, "#RED#%s 陣亡了！", self.name)
    end
end,
```

### 4. 多人傭兵的群體指令

```lua
-- 對所有隊友同時下達指令
function Player:issueCommandToAll(cmd_type, target)
    local allies = self:getCommandableAllies()
    for _, ally in ipairs(allies) do
        self:issueCommand(ally, cmd_type, target)
    end
end
```

---

