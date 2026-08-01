
## 步驟四：NPC 工人

### 設計思路

工人延伸 Tutorial 09 的 `commanded_ally` AI，新增 `"work"` 指令類型：

```lua
-- 指派後工人的 AI 狀態
worker.ai_state.command = {type = "work", task = "farm"}
-- AI 行為：找到最近的 FARM_GROWING 格，移動過去後每 20 動作加速農作 5 動作
```

### 新增工人模板到 `mod/data/npcs/camp_npcs.lua`

```lua
-- mod/data/npcs/camp_npcs.lua（追加）

-- ── 據點工人（可招募） ────────────────────────────────────────
-- 透過工人招募 NPC（Worker Recruiter）的 Chat 生成到 party
newEntity{
    define_as = "CAMP_WORKER",
    type = "humanoid", subtype = "human",
    name = "工人",
    display = 'p', color_r=180, color_g=180, color_b=180,
    faction = "players",

    ai       = "commanded_ally",   -- Tutorial 09 定義的指令 AI
    ai_state = {ai_move = "move_simple"},

    level_range = {1, 1},
    exp_worth   = 0,
    rank        = 1,

    max_life    = resolvers.rngrange(30, 50),
    life_rating = 8,
    stats       = {str=10, dex=10, con=10, mag=5, wil=8, cun=8},

    worker_task = nil,   -- 由玩家指派（"farm" / nil）
}
```

### 工人招募方式

工人透過招募 NPC 或特定地點對話加入 party，再手動指派任務：

```lua
-- 在某個 NPC 的 on_bump chat 中（例如大地圖上的招募站）
-- 建立工人實體並加入 party
local worker = game.zone:makeEntityByName(game.level, "actor", "CAMP_WORKER")
if worker then
    worker:resolve()
    game.zone:addEntity(game.level, worker, "actor",
        game.player.x + 1, game.player.y)
    game.party:addMember(worker, {
        control  = "no",
        type     = "ally",
        title    = "據點工人",
        orders   = {"follow", "attack", "standby", "flee", "work"},
    })
    game.logPlayer(game.player,
        "#LIGHT_GREEN#%s 加入了你的隊伍。", worker.name)
end
```

### 擴充 `commanded_ally` AI

```lua
-- mod/ai/commanded_ally.lua（在現有 commanded_ally AI 中追加 work 分支）

newAI("commanded_ally", function(self)
    local cmd = self.ai_state.command

    if not cmd then return self:runAI("_ally_default") end

    -- ★ 新增 work 指令分支
    if cmd.type == "work" then
        return self:runAI("_cmd_work", cmd)
    end

    -- 原有分支（Tutorial 09，保持不變）
    if cmd.type == "attack" then
        if not cmd.target or cmd.target.dead then
            self.ai_state.command = nil
            return self:runAI("_ally_default")
        end
        self:setTarget(cmd.target)
        return self:runAI("dumb_talented_simple")

    elseif cmd.type == "follow" then
        if core.fov.distance(self.x, self.y, game.player.x, game.player.y) > 2 then
            self:moveDirection(game.player.x, game.player.y)
        else
            self:useEnergy()
        end
        return true

    elseif cmd.type == "standby" then
        self:useEnergy()
        return true

    elseif cmd.type == "flee" then
        if self:runAI("target_simple") then
            return self:runAI("flee_simple")
        end
        self:useEnergy()
        return true
    end

    -- 未知指令：切回預設 AI
    self.ai_state.command = nil
    return self:runAI("_ally_default")
end)

-- ── 工作 AI：移動到農田旁，定期加速農作 ──────────────────────
newAI("_cmd_work", function(self, cmd)
    local task = cmd and cmd.task

    if task ~= "farm" then
        -- 未知任務：待命
        self:useEnergy()
        return true
    end

    -- 掃描地圖找最近的 FARM_GROWING 格
    local Map = require "engine.Map"
    local tx, ty, best_dist = nil, nil, math.huge
    for fy = 0, game.level.map.h - 1 do
        for fx = 0, game.level.map.w - 1 do
            local t = game.level.map(fx, fy, Map.TERRAIN)
            if t and t.farm_interact == "check" then  -- FARM_GROWING 的旗標
                local d = core.fov.distance(self.x, self.y, fx, fy)
                if d < best_dist then
                    best_dist, tx, ty = d, fx, fy
                end
            end
        end
    end

    if not tx then
        -- 找不到農田（尚未種植），待命
        self:useEnergy()
        return true
    end

    if best_dist > 1 then
        -- 往農田移動
        self:moveDirection(tx, ty)
        return true
    end

    -- 在農田旁：每 20 玩家動作嘗試加速農作一次
    local boost_key      = "worker_farm_boost_" .. self.uid
    local last_boost     = self.ai_state[boost_key] or 0
    local ticks_per_act  = game.energy_to_act / game.energy_per_tick
    local boost_interval = 20 * ticks_per_act

    if game.turn - last_boost >= boost_interval then
        local cs = game.camp_state
        if cs and cs.farms then
            local farm = cs.farms[tx .. "_" .. ty]
            if farm and farm.turn_planted > 0 and not farm.ready then
                -- 把種植時間往前移 5 個動作（= 加速 5%）
                local speed_up = 5 * ticks_per_act
                farm.turn_planted = math.max(
                    farm.turn_planted - speed_up,
                    0   -- 避免 turn_planted 成為負數
                )
                self.ai_state[boost_key] = game.turn
            end
        end
    end

    self:useEnergy()  -- 停在農田旁等待
    return true
end)

-- ── 預設同伴 AI（Tutorial 09，無變化） ──────────────────────
newAI("_ally_default", function(self)
    if self:runAI("target_simple") then
        return self:runAI("dumb_talented_simple")
    end
    if game.player then
        local d = core.fov.distance(self.x, self.y, game.player.x, game.player.y)
        if d > 3 then
            return self:moveDirection(game.player.x, game.player.y)
        end
    end
    self:useEnergy()
    return true
end)
```

### 指派工人任務

```lua
-- 在 Tutorial 09 的 ActorCommand mixin 中追加（mod/class/interface/ActorCommand.lua）
-- 或直接在指令選單的 action 函式中呼叫

--- 指派工人到農田工作
-- @param worker  工人 Actor
function _M:assignWorkerToFarm(worker)
    local cs = game.camp_state
    if not cs or not (cs.buildings or {}).farm then
        game.logPlayer(self, "農田尚未建造，無法指派工人。")
        return false
    end

    worker.ai_state.command = {type = "work", task = "farm"}

    -- 記錄到 camp_state.workers 以便 updateCamp 的日誌
    cs.workers = cs.workers or {}
    cs.workers[worker.uid] = "耕種農田"

    game.logPlayer(self,
        "已指派 %s 到農田工作。他會自動移動到農田旁並加速農作成熟。",
        worker.name)
    return true
end
```

---