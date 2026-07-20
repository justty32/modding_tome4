### 錯誤：`grantQuest: no such quest 'slay-boss'`（找不到任務檔案）

**原因**：`grantQuest` 從 `/data/quests/slay-boss.lua` 載入，路徑基於虛擬檔案系統。

**解法**：確認檔案在 `data/quests/slay-boss.lua`（相對於你的模組根目錄）。虛擬路徑 `/data/` 對應到模組的 `data/` 目錄。

---

### 錯誤：對話框顯示後沒有文字

**原因**：`engine.Chat.new()` 找不到聊天腳本，或腳本中沒有 `return "welcome"`。

**解法**：
1. 確認 `data/chats/elder.lua` 存在
2. 確認腳本最後一行是 `return "welcome"`（第一個節點的 id）
3. 確認 `npc.chat = "elder"` 的字串與檔案名稱一致（不含 .lua）

---

### 錯誤：對話選項不出現（cond 返回 false）

**原因**：`cond` 函數的邏輯錯誤，或引用了不存在的 Quest。

**診斷**：在 cond 中加入 print 暫時除錯：

```lua
cond = function(npc, player)
    local q = player:hasQuest("slay-boss")
    print("[CHAT DEBUG] hasQuest:", q, "killed_boss:", q and player:isQuestStatus("slay-boss", engine.Quest.COMPLETED, "killed_boss"))
    return not q
end,
```

---

### 錯誤：`setQuestStatus` 沒有效果

**原因**：玩家還沒有這個任務（`hasQuest` 返回 false），`setQuestStatus` 會靜默忽略。

**解法**：確認在呼叫 `setQuestStatus` 之前已呼叫 `grantQuest`。在 `on_die` 中直接呼叫前可加個保護：

```lua
on_die = function(self, who)
    if who == game.player and game.player:hasQuest("slay-boss") then
        game.player:setQuestStatus("slay-boss", engine.Quest.COMPLETED, "killed_boss")
    end
end,
```

---

### 錯誤：村長不出現在地圖上

**原因**：`post_process` 中的 `makeEntityByName` 無法找到 `ELDER`，可能是 NPC 清單沒有正確載入。

**解法**：`makeEntityByName` 的第二個參數要是已載入的清單或類型字串 `"actor"`。使用字串 `"actor"` 時，引擎會從 `zone.npc_list` 中尋找：

```lua
-- 確保 zone.lua 中沒有限制 npc 清單，或手動傳入清單
local elder = zone:makeEntityByName(level, zone.npc_list, "ELDER")
```

如果 `npc_list` 中沒有 ELDER（因為設了 `rarity=false`），需要用：

```lua
local npc_class = require "mod.class.NPC"
local list = npc_class:loadList("/data/zones/town/npcs.lua")
local elder = zone:makeEntityByName(level, list, "ELDER")
```
