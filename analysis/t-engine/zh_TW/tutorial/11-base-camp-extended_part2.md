
## 步驟一：農作計時器

### 核心原理

```
game.energy_to_act  = 1000   ← 角色積累到此能量才能行動
game.energy_per_tick = 100   ← 每次 tick 所有角色獲得 100 能量

→ 1 個「玩家動作」需要 10 個 game.turn（1000 / 100）
→ 農田 100 動作後成熟 = 1000 個 game.turn
```

### 修改 `mod/class/Game.lua`

```lua
-- mod/class/Game.lua

-- ── onTurn：引擎每個 tick 呼叫 ────────────────────────────────
function _M:onTurn()
    -- 原有邏輯：每 10 tick 處理地圖特效
    if self.turn % 10 ~= 0 then return end
    self.level.map:processEffects()

    -- 只在據點 Zone 內更新農作計時器
    if self.zone and self.zone.short_name == "camp" then
        self:updateCamp()
    end
end

-- ── updateCamp：農田成熟檢查 + 工人狀態日誌 ──────────────────
function _M:updateCamp()
    local cs = self.camp_state
    if not cs then return end

    -- 農田成熟檢查（遍歷所有農田格）
    if cs.buildings and cs.buildings.farm and cs.farms then
        local ticks_per_act = self.energy_to_act / self.energy_per_tick  -- = 10
        for key, farm in pairs(cs.farms) do
            if not farm.ready and farm.turn_planted > 0 then
                local turns_passed  = self.turn - farm.turn_planted
                local ticks_needed  = farm.turns_to_grow * ticks_per_act
                if turns_passed >= ticks_needed then
                    farm.ready = true
                    -- 把地圖上對應格換為 FARM_READY
                    local x, y = key:match("^(%d+)_(%d+)$")
                    x, y = tonumber(x), tonumber(y)
                    if x and y then
                        local Map = require "engine.Map"
                        self.level.map(x, y, Map.TERRAIN,
                            self.zone.grid_list["FARM_READY"])
                        self.level.map.changed = true
                    end
                    self.logPlayer(self.player,
                        "#LIGHT_GREEN#你的農田（%s）已成熟，可以收穫！（踩上農田按 > 收穫）",
                        key)
                end
            end
        end
    end

    -- 工人狀態日誌（每 50 玩家動作輸出一次）
    if cs.workers then
        local ticks_per_act = self.energy_to_act / self.energy_per_tick
        if self.turn % (50 * ticks_per_act) == 0 then
            for uid, task in pairs(cs.workers) do
                local worker = __uids[uid]
                if worker and not worker.dead then
                    self.logPlayer(self.player,
                        "%s 正在執行任務：%s。", worker.name, task)
                else
                    -- 工人已死亡或消失，清理記錄
                    cs.workers[uid] = nil
                end
            end
        end
    end
end

-- ── farmInteract：農田互動（種植 / 查詢 / 收穫） ──────────────
-- 由 setupCommands 的 CHANGE_LEVEL 鍵呼叫
function _M:farmInteract(terrain, x, y)
    local cs = self.camp_state
    if not cs or not cs.buildings or not cs.buildings.farm then
        self.logPlayer(self.player, "農田尚未建造。先與建造管理員對話吧。")
        return
    end

    cs.farms = cs.farms or {}
    local key = x .. "_" .. y
    local farm = cs.farms[key]

    local ticks_per_act = self.energy_to_act / self.energy_per_tick

    -- ── 空農田：種植 ──
    if terrain.farm_interact == "plant" then
        -- 消耗 1 個草藥種子
        local inven = self.player:getInven("INVEN")
        local found = false
        for i = #inven, 1, -1 do
            if inven[i].define_as == "HERB_SEED" then
                self.player:removeObject(inven, i)
                found = true
                break
            end
        end
        if not found then
            self.logPlayer(self.player,
                "需要草藥種子才能種植。（到野外採集或購買）")
            return
        end
        -- 把地形換成 FARM_GROWING，記錄種植時間
        local Map = require "engine.Map"
        self.level.map(x, y, Map.TERRAIN, self.zone.grid_list["FARM_GROWING"])
        self.level.map.changed = true
        cs.farms[key] = {
            turn_planted  = self.turn,
            turns_to_grow = 100,
            yield         = {HERB = 3},
            ready         = false,
        }
        self.logPlayer(self.player,
            "#LIGHT_GREEN#種植完成！約 100 個動作後成熟。")

    -- ── 生長中：查詢進度 ──
    elseif terrain.farm_interact == "check" then
        if not farm or farm.turn_planted == 0 then
            self.logPlayer(self.player, "農田尚未種植。")
            return
        end
        local elapsed  = self.turn - farm.turn_planted
        local needed   = farm.turns_to_grow * ticks_per_act
        local pct      = math.min(100, math.floor(elapsed / needed * 100))
        self.logPlayer(self.player, "農田生長進度：%d%%。", pct)

    -- ── 可收穫：收穫 ──
    elseif terrain.farm_interact == "harvest" then
        if not farm or not farm.ready then
            local pct = 0
            if farm and farm.turn_planted > 0 then
                local elapsed = self.turn - farm.turn_planted
                local needed  = farm.turns_to_grow * ticks_per_act
                pct = math.min(100, math.floor(elapsed / needed * 100))
            end
            self.logPlayer(self.player, "農田尚未成熟（%d%%）。", pct)
            return
        end
        -- 把產出加入背包
        local Map = require "engine.Map"
        for item_id, qty in pairs(farm.yield or {}) do
            for i = 1, qty do
                local obj = self.zone:makeEntityByName(self.level, "object", item_id)
                if obj then
                    self.player:addObject(self.player:getInven("INVEN"), obj)
                end
            end
        end
        self.logPlayer(self.player, "#LIGHT_GREEN#收穫完成！獲得了資源。")
        -- 把地形重置為空農田，清除種植狀態
        self.level.map(x, y, Map.TERRAIN, self.zone.grid_list["FARM_EMPTY"])
        self.level.map.changed = true
        cs.farms[key] = nil
    end
end

-- ── newGame：初始化據點狀態 ────────────────────────────────────
function _M:newGame()
    -- ... 原有初始化邏輯 ...

    self.camp_state = {
        buildings = {
            farm          = false,
            chest         = false,
            upgraded_fire = false,
        },
        farms   = {},
        workers = {},
    }
end

-- ── save：宣告需要序列化的欄位 ────────────────────────────────
-- 只有在此宣告的欄位才會被 Savefile 序列化
function _M:save()
    return class.save(self, self:defaultSavedFields{
        camp_state = true,   -- ★ 必須宣告，否則存檔後據點進度消失
    }, true)
end
```