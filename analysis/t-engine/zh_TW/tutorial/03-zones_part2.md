## 4. 更新 Game.lua 支援多地區切換

從 example 模組複製 `changeLevel` 與 `CHANGE_LEVEL` 按鍵繫結，加入位置記錄與 FOV 更新：

```lua
-- game/modules/hellodungeon/class/Game.lua

function _M:changeLevel(lev, zone)
    local old_lev = (self.level and not zone) and self.level.level or -1000

    -- 離開舊地區前儲存位置
    if self.level then
        local level = self.level
        if old_lev > lev then
            level.exited = level.exited or {}
            level.exited.down = {x=self.player.x, y=self.player.y}
        else
            level.exited = level.exited or {}
            level.exited.up = {x=self.player.x, y=self.player.y}
        end
        level:removeEntity(self.player)
    end

    if zone then
        if self.zone then
            self.zone:leaveLevel(false, lev, old_lev)
            self.zone:leave()
        end
        if type(zone) == "string" then
            self.zone = Zone.new(zone)
        else
            self.zone = zone
        end
    end

    self.zone:getLevel(self, lev, old_lev)

    -- 優先使用記錄的返回位置
    if lev > old_lev then
        local pos = self.level.exited and self.level.exited.up
        if pos then
            self.player:move(pos.x, pos.y, true)
        else
            self.player:move(self.level.default_up.x, self.level.default_up.y, true)
        end
    else
        local pos = self.level.exited and self.level.exited.down
        if pos then
            self.player:move(pos.x, pos.y, true)
        else
            self.player:move(self.level.default_down.x, self.level.default_down.y, true)
        end
    end

    self.level:addEntity(self.player)
    self.player:playerFOV()
end
```

在 `setupCommands()` 加入 `CHANGE_LEVEL`：

```lua
-- 在 Game:setupCommands() 的 key:addCommands 中加入：

CHANGE_LEVEL = function()
    local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
    if self.player:enoughEnergy() and e.change_level then
        -- 有 change_zone：切換到新地區，change_level 為目標層號
        -- 無 change_zone：同地區，change_level 為相對差值
        self:changeLevel(
            e.change_zone and e.change_level or self.level.level + e.change_level,
            e.change_zone
        )
    else
        self.log("這裡沒有出口。")
    end
end,
```

確認 `load.lua` 載入了 `KeyBind:load("move,hotkeys,inventory,actions,interface,debug")`，其中 `actions` 包含 `CHANGE_LEVEL` 的預設按鍵（通常為 `<`、`>` 或 Enter）。

---

## 5. 起始地區設為城鎮

在 `Game:run()` 中將初始 `changeLevel` 改為城鎮：

```lua
-- game/modules/hellodungeon/class/Game.lua

function _M:run()
    -- ... （初始化程式碼，同教學 01）...

    -- 從城鎮開始，而非直接進入地城
    self:changeLevel(1, "town")

    -- ... （其他初始化）...
end
```

---

## 6. 地區切換保留玩家位置

**問題**：玩家在地城打了 5 層後回城鎮，再進地城會從第幾層開始？

**引擎行為**：`Zone:getLevel(game, lev, old_lev)` 若 `zone.memory_levels[lev]` 已存在則直接讀取快取，不重新生成。因此預設回到第 1 層（城鎮出口指定 `change_level=1`）。

**若要回到「最後離開地城的那一層」**，需追蹤狀態：

```lua
-- 在 Game.lua 中加入：
function _M:changeLevel(lev, zone)
    -- ... 原本程式碼 ...

    -- 記住離開地城時的層數
    if zone and zone ~= (self.zone and self.zone.short_name) then
        if self.zone and self.zone.short_name == "dungeon" then
            self.player.last_dungeon_level = self.level and self.level.level
        end
    end
end
```

---

## 7. on_enter / on_leave 回呼

Zone 支援進入/離開生命週期回呼，放在 `zone.lua` 中：

```lua
-- data/zones/town/zone.lua

return {
    -- ... 其他欄位 ...

    -- 進入城鎮時觸發
    on_enter = function(self, lev, old_lev, zone)
        game.log("#YELLOW#歡迎回到賢者城鎮！")
    end,

    -- 離開城鎮時觸發
    on_leave = function(self, lev, new_lev, new_zone)
        if new_zone == "dungeon" then
            game.log("#RED#你進入了黑暗的地城…小心！")
        end
    end,
}
```

這兩個回呼在 `Zone:getLevel()` 與 `Zone:leaveLevel()` 中被呼叫：

```lua
-- engine/Zone.lua（簡化版）
function _M:getLevel(game, lev, old_lev)
    -- ...生成或載入樓層...
    if self.on_enter then self:on_enter(lev, old_lev, old_zone) end
end

function _M:leaveLevel(no_close, lev, old_lev)
    if self.on_leave then self:on_leave(old_lev, lev, nil) end
    -- ...儲存樓層狀態...
end
```

---

## 8. 完整檔案結構

```
game/modules/hellodungeon/
├── class/
│   └── Game.lua                  ← 修改：changeLevel、CHANGE_LEVEL、run 起始地區
│
└── data/zones/
    ├── dungeon/
    │   ├── grids.lua             ← 修改：加入 DUNGEON_EXIT 地形
    │   └── zone.lua              ← 修改：UP 指向 DUNGEON_EXIT（或靠 Game 判斷）
    └── town/                     ← 新增目錄
        ├── zone.lua              ← 新增：城鎮地區設定
        ├── grids.lua             ← 新增：城鎮地形（含 EXIT_TOWN）
        ├── npcs.lua              ← 新增：城鎮 NPC（可暫時空白）
        └── objects.lua           ← 新增：城鎮物品（可暫時空白）
```

**共新增 4 檔，修改 2 檔**。

---

## 9. 常見錯誤排查

### `Zone.new: no such zone 'town'`

**原因**：Zone 從 `data/zones/<short_name>/zone.lua` 載入，路徑錯誤或拼寫不符。

**解法**：
- 確認目錄名為 `data/zones/town/`（與 `change_zone = "town"` 一致）
- 確認 `zone.lua` 中有 `short_name = "town"`

---

### 玩家進入新地區後出現在 (0,0)

**原因**：Zone 生成時找不到 `default_up`/`default_down`，預設落在 (0,0)。

**解法**：
- 地圖生成器必須設定 `up` / `down` 欄位，對應 `grids.lua` 中定義的 `define_as`
- `engine.generator.map.Roomer` 會自動找 `notice=true` 的格子作為起點/終點

---

### 切換地區後地圖沒更新（仍顯示舊地圖）

**原因**：`game.level.map.changed` 未設為 `true`，或 FOV 未重算。

**解法**：在 `changeLevel` 末尾加入：

```lua
self.player:playerFOV()
self.level.map.changed = true
```

---

### `self.level.exited` 在重新生成地區後消失

**原因**：`level.exited` 需在 `persistent = "zone"` 設定下才會持久化。

**解法**：城鎮設定 `persistent = "zone"` 即可保留。地城若未設 persistent，每次重新進入都重生樓層，`exited` 自然消失（符合 roguelike 風格）。

---

## 下一步

完成後，hellodungeon 有兩個地區（城鎮 + 地城）可互相切換。

下一個教學（**教學 04：任務系統與 NPC 對話**）將加入：
- 村長 NPC 給予討伐任務
- 對話腳本（Chat）
- Quest 狀態追蹤
- 擊殺頭目觸發任務完成
