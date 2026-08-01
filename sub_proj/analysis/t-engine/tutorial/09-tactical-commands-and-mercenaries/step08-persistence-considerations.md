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
