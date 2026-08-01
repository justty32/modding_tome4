## 步驟一：自訂 AI — `commanded_ally`

### 原理

TE4 的 AI 系統是可組合的函式集合。每個 NPC 有一個 `self.ai` 字串，指向要執行的 AI 函式。`ai_state` 是一個持久化的表格，可以存放任意欄位——我們用它來儲存玩家下達的指令。

```
self.ai = "commanded_ally"        -- 每回合執行哪個 AI
self.ai_state.command = {         -- 玩家設定的指令（可為 nil）
    type = "attack",
    target = <Actor>
}
```

### 檔案：`mod/ai/commanded_ally.lua`

```lua
-- mod/ai/commanded_ally.lua
-- 可接受外部指令的隊友 AI
-- 當有 ai_state.command 時執行指令；否則自主尋敵

-- 注意：這個檔案在 ActorAI:loadDefinition() 時被載入
-- 環境中已提供 newAI 函式和 Map 全域變數

-- ── 主要 AI 入口點 ──────────────────────────────────────────
newAI("commanded_ally", function(self)
    local cmd = self.ai_state.command

    -- ── 有玩家指令時：執行指令 ──────────────────────────────
    if cmd then
        if cmd.type == "attack" then
            return _M.ai_commanded_attack(self, cmd)
        elseif cmd.type == "follow" then
            return _M.ai_commanded_follow(self)
        elseif cmd.type == "standby" then
            return _M.ai_commanded_standby(self)
        elseif cmd.type == "flee" then
            return _M.ai_commanded_flee(self)
        end
    end

    -- ── 無指令時：自主行為（先尋敵，找到就打；否則跟隨玩家） ──
    return _M.ai_default_ally(self)
end)

-- ── 攻擊指定目標 ────────────────────────────────────────────
-- 將 ai_target 設為指令中的目標，然後用現有的 dumb_talented_simple 處理移動+攻擊
newAI("_cmd_attack", function(self, cmd)
    local t = cmd.target
    if not t or t.dead then
        -- 目標已死，清除指令
        self.ai_state.command = nil
        game.logPlayer(self, "%s 的攻擊目標已消滅。", self.name)
        return self:runAI("commanded_ally")  -- 重新決策
    end
    self:setTarget(t)
    self:runAI("dumb_talented_simple")
    return true
end)

-- ── 跟隨玩家 ────────────────────────────────────────────────
-- 距離 > 2 時往玩家方向移動
newAI("_cmd_follow", function(self)
    local px, py = game.player.x, game.player.y
    if core.fov.distance(self.x, self.y, px, py) > 2 then
        self:moveDirection(px, py)
    end
    return true
end)

-- ── 待命（原地等待） ─────────────────────────────────────────
-- 回傳 true 表示已執行動作，不再移動
-- TE4 的 useEnergy() 在 move/useTalent 時自動呼叫
-- 這裡我們手動消耗能量避免卡住
newAI("_cmd_standby", function(self)
    self:useEnergy()
    return true
end)

-- ── 撤退 ────────────────────────────────────────────────────
-- 先用 target_simple 找到敵人，然後向反方向逃跑
newAI("_cmd_flee", function(self)
    if self:runAI("target_simple") then
        self:runAI("flee_simple")
    else
        -- 沒有找到敵人：回到玩家身邊
        local px, py = game.player.x, game.player.y
        if core.fov.distance(self.x, self.y, px, py) > 2 then
            self:moveDirection(px, py)
        end
    end
    return true
end)

-- ── 預設自主行為 ─────────────────────────────────────────────
-- 找到敵人就打；沒有敵人就跟隨玩家
newAI("_ally_default", function(self)
    -- target_simple 會自動避開友方（faction 判斷）
    if self:runAI("target_simple") then
        self:runAI("dumb_talented_simple")
        return true
    end
    -- 無敵人：跟隨玩家
    if game.player then
        local px, py = game.player.x, game.player.y
        if core.fov.distance(self.x, self.y, px, py) > 3 then
            self:moveDirection(px, py)
            return true
        end
    end
    return false
end)
```

> **為什麼把子行為也定義為 newAI？**
> 
> TE4 的 `runAI(name)` 讓你可以組合已命名的 AI 片段。把每個行為獨立命名（加底線前綴表示「內部使用」）有兩個好處：
> 1. 其他 AI 可以重用這些片段（例如別的 AI 也可以 `runAI("_cmd_follow")`）
> 2. 方便日誌除錯（`config.settings.log_detail_ai > 1` 時會印出 AI 名稱）

然而為了教學清晰，上面的程式把子函式寫成局部呼叫（`_M.ai_commanded_*`）的形式。實際上 TE4 的設計建議是全部用 `newAI` 命名，並用 `self:runAI("_cmd_attack", cmd)` 傳入參數。以下是更符合 TE4 慣例的寫法：

```lua
-- 在 commanded_ally.lua 中，將各分支改寫為 runAI 呼叫

newAI("commanded_ally", function(self)
    local cmd = self.ai_state.command
    if not cmd then return self:runAI("_ally_default") end

    if cmd.type == "attack" then
        -- 目標死亡時自動清除
        if not cmd.target or cmd.target.dead then
            self.ai_state.command = nil
            return self:runAI("_ally_default")
        end
        self:setTarget(cmd.target)
        return self:runAI("dumb_talented_simple")

    elseif cmd.type == "follow" then
        local px, py = game.player.x, game.player.y
        if core.fov.distance(self.x, self.y, px, py) > 2 then
            self:moveDirection(px, py)
        end
        return true

    elseif cmd.type == "standby" then
        self:useEnergy()
        return true

    elseif cmd.type == "flee" then
        if self:runAI("target_simple") then
            return self:runAI("flee_simple")
        end
        return true
    end
end)

-- 預設自主行為
newAI("_ally_default", function(self)
    if self:runAI("target_simple") then
        return self:runAI("dumb_talented_simple")
    end
    if game.player then
        local d = core.fov.distance(self.x, self.y, game.player.x, game.player.y)
        if d > 3 then return self:moveDirection(game.player.x, game.player.y) end
    end
end)
```

**這是最終版本，之後所有程式碼使用這個版本。**

---

### 在 Game.lua 中載入自訂 AI

TE4 的 AI 定義必須在載入任何 NPC 之前完成。最佳時機是在 `Game:load()` 中：

```lua
-- mod/class/Game.lua（摘錄，加入 AI 載入）
function _M:load(...)
    engine.GameEnergyBased.load(self, ...)

    -- 載入引擎內建 AI 定義
    self.player_class:loadDefinition("/engine/ai/")

    -- 載入模組自訂 AI
    self.player_class:loadDefinition("/mod/ai/")
end
```

> `loadDefinition(dir)` 會掃描目錄下所有 `.lua` 檔並執行，每個檔案中的 `newAI(name, fn)` 呼叫都會被記錄在 `ActorAI.ai_def` 表格中，全域可用。

---

