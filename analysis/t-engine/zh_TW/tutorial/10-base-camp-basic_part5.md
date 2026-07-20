## 步驟五：合成工作台（NPC 方式）

工作台本質上是一個**靜止 NPC**，透過玩家「碰撞進入」（on_bump）觸發對話腳本，提供合成功能。

使用 on_bump 而非 on_interact 的原因：TE4 玩家移入友方 NPC 的格子時，引擎呼叫 `npc:bumpInto(player)` → 最終呼叫 `npc.on_bump`，這是最通用且在存檔前後都能正確觸發的方式。

### 合成配方

```
治療藥水：草藥 × 2 + 空瓶 × 1 → POTION_HEALING
強效藥水：草藥 × 5 + 空瓶 × 1 → POTION_GREATER_HEALING
```

### 檔案：`mod/data/npcs/camp_npcs.lua`

```lua
-- mod/data/npcs/camp_npcs.lua
-- 據點 NPC 定義

-- ── 合成工作台（靜止 NPC） ───────────────────────────────────
newEntity{
    define_as = "WORKBENCH_NPC",
    type = "object", subtype = "workbench",
    name = "合成工作台",
    display = 'T', color_r=150, color_g=100, color_b=50,
    faction = "players",

    -- 靜止不動，不尋找目標
    ai       = "none",
    ai_state = {},

    -- 防止被攻擊：友方且不是有效攻擊目標
    never_move = true,
    exp_worth  = 0,
    max_life   = 9999,
    rank       = 1,
    stats      = {str=20, dex=20, con=20, mag=0, wil=20, cun=20},

    -- 玩家碰撞進入（嘗試移動到此格）時觸發對話
    on_bump = function(self, who)
        if who ~= game.player then return end
        local Chat = require "engine.Chat"
        Chat.new("mod.data.chats.workbench", self, who):invoke()
    end,
}
```

> **為什麼 `on_bump` 可以序列化？**  
> 因為 `on_bump` 不是匿名函式，而是在 `newEntity{}` 原型定義中宣告的具名函式——原型本身不需要序列化（它由 `loadList` 在載入時重建），只有**實例**才需要序列化。只要實例沒有把 `on_bump` 複製到自己身上（不呼叫 `entity:resolve()`），就不存在序列化問題。
