## 9. 第八步：連接 NPC 與對話觸發

玩家需按下「互動鍵」（或碰觸 NPC）才能開始對話。兩種常見做法：

**方法 A：碰觸 NPC 觸發（修改 Actor.lua 移動函數）**

於 `Player.lua` 的移動邏輯中，若目標格有 NPC，先嘗試對話而非攻擊：

```lua
-- game/modules/hellodungeon/class/Player.lua

-- 修改或加入 bump 函數（碰觸非敵對 NPC 時觸發對話）
function _M:bump(x, y)
    local target = game.level.map(x, y, engine.Map.ACTOR)
    -- 若目標有 chat 欄位且非敵對 → 觸發對話
    if target and target.chat and target.faction ~= "enemies" then
        self:talkTo(target)
        self:useEnergy()
        return true
    end
    -- 否則走正常攻擊流程
    return false
end

-- 對話入口函數
function _M:talkTo(npc)
    local chat = require "engine.Chat"
    local d = chat.new(npc.chat, npc, self)
    game:registerDialog(d)
end
```

**方法 B：按 `t` 鍵對話（於 Game.lua 的 setupCommands 加入）**

```lua
-- game/modules/hellodungeon/class/Game.lua
-- 在 setupCommands 中加入：

[{"_t"}] = function()
    if not self.player then return end
    -- 查詢玩家四周一格內是否有可對話 NPC
    for _, dir in ipairs({"n","s","e","w","ne","nw","se","sw"}) do
        local dx, dy = util.dirToCoord(util.dirToPath(dir))
        local x, y = self.player.x + dx, self.player.y + dy
        local target = self.level.map(x, y, engine.Map.ACTOR)
        if target and target.chat then
            self.player:talkTo(target)
            self.player:useEnergy()
            return
        end
    end
    self.log("附近沒有可以對話的人。")
end,
```

---

## 10. 第九步：顯示任務日誌

加入 `j` 鍵顯示任務日誌（使用 TE4 內建 UI）：

```lua
-- game/modules/hellodungeon/class/Game.lua
-- 在 setupCommands 加入：

[{"_j"}] = function()
    if not self.player then return end
    -- 若無任何任務
    if not self.player.quests or not next(self.player.quests) then
        game.log("你目前沒有任何進行中的任務。")
        return
    end

    -- 建立簡單任務清單對話框
    local d = require("engine.ui.Dialog").new("任務日誌", 500, 400)
    local text = ""
    for id, q in pairs(self.player.quests) do
        local status = engine.Quest.status_text[q.status] or "未知"
        text = text..string.format("#YELLOW#%s#LAST# [%s]\n", q.name, status)
        if type(q.desc) == "function" then
            text = text..q:desc(self.player).."\n\n"
        elseif q.desc then
            text = text..q.desc.."\n\n"
        end
    end

    local Textzone = require "engine.ui.Textzone"
    local tz = Textzone.new{
        width = d.iw,
        height = d.ih,
        scrollbar = true,
        text = text,
    }
    d:loadUI{{left=0, top=0, ui=tz}}
    d:setupUI()
    game:registerDialog(d)
end,
```

---

## 11. 完整檔案結構

```
game/modules/hellodungeon/
├── class/
│   ├── Actor.lua                 ← 修改：繼承 ActorQuest
│   ├── Player.lua                ← 修改：加入 bump、talkTo 函數
│   └── Game.lua                  ← 修改：加入 t 鍵對話、j 鍵任務日誌

├── data/
│   ├── quests/                   ← 新增目錄
│   │   └── slay-boss.lua         ← 新增：討伐頭目任務定義
│   │
│   ├── chats/                    ← 新增目錄
│   │   └── elder.lua             ← 新增：村長對話腳本
│   │
│   ├── general/
│   │   └── npcs/
│   │       └── kobold.lua        ← 修改：加入 KOBOLD_BOSS（含 on_die）
│   │
│   └── zones/
│       ├── town/
│       │   ├── zone.lua          ← 修改：加入 post_process 放置村長
│       │   └── npcs.lua          ← 修改：加入 ELDER 定義
│       └── dungeon/
│           └── zone.lua          ← 修改：加入 post_process 放置頭目
```

**共新增 3 個檔案（目錄），修改 5 個檔案**。

---

## 12. 常見錯誤排查

### 錯誤：`grantQuest: no such quest 'slay-boss'`（找不到任務檔）

**原因**：`grantQuest` 從 `/data/quests/slay-boss.lua` 載入，路徑基於虛擬檔案系統。

**解法**：確認檔案位於 `data/quests/slay-boss.lua`（相對於模組根目錄）。虛擬路徑 `/data/` 對應模組的 `data/` 目錄。

---

### 錯誤：對話框顯示後無文字

**原因**：`engine.Chat.new()` 找不到聊天腳本，或腳本中沒有 `return "welcome"`。

**解法**：
1. 確認 `data/chats/elder.lua` 存在
2. 確認腳本最後一行為 `return "welcome"`（第一個節點的 id）
3. 確認 `npc.chat = "elder"` 字串與檔名一致（不含 .lua）

---

### 錯誤：對話選項不出現（cond 回傳 false）

**原因**：`cond` 函數邏輯錯誤，或引用了不存在的 Quest。

**診斷**：於 cond 中加入 print 暫時除錯：

```lua
cond = function(npc, player)
    local q = player:hasQuest("slay-boss")
    print("[CHAT DEBUG] hasQuest:", q, "killed_boss:", q and player:isQuestStatus("slay-boss", engine.Quest.COMPLETED, "killed_boss"))
    return not q
end,
```

---

### 錯誤：`setQuestStatus` 沒有效果

**原因**：玩家尚無此任務（`hasQuest` 回傳 false），`setQuestStatus` 會靜默忽略。

**解法**：確認在呼叫 `setQuestStatus` 前已呼叫 `grantQuest`。於 `on_die` 中直接呼叫前可加保護：

```lua
on_die = function(self, who)
    if who == game.player and game.player:hasQuest("slay-boss") then
        game.player:setQuestStatus("slay-boss", engine.Quest.COMPLETED, "killed_boss")
    end
end,
```

---

### 錯誤：村長未出現於地圖上

**原因**：`post_process` 中的 `makeEntityByName` 無法找到 `ELDER`，可能是 NPC 清單未正確載入。

**解法**：`makeEntityByName` 的第二個參數應為已載入的清單或類型字串 `"actor"`。使用字串 `"actor"` 時，引擎會從 `zone.npc_list` 中尋找：

```lua
-- 確保 zone.lua 中未限制 npc 清單，或手動傳入清單
local elder = zone:makeEntityByName(level, zone.npc_list, "ELDER")
```

若 `npc_list` 中無 ELDER（因設了 `rarity=false`），需改用：

```lua
local npc_class = require "mod.class.NPC"
local list = npc_class:loadList("/data/zones/town/npcs.lua")
local elder = zone:makeEntityByName(level, list, "ELDER")
```
