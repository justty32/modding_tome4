### 1.7 遭遇系統 (encounters/)

共 **4 個遭遇定義檔案**，用於世界地圖上的特殊 NPC 遭遇。

#### 遭遇檔案

| 檔案 | 大小 | 說明 |
|------|------|------|
| `maj-eyal.lua` | 10KB | 主大陸遭遇事件 |
| `fareast.lua` | 3.5KB | 遠東地區遭遇事件 |
| `maj-eyal-npcs.lua` | 4.2KB | 遭遇中使用的 NPC 定義 |
| `fareast-npcs.lua` | 2.5KB | 遠東遭遇 NPC |

#### 遭遇機制

```lua
-- 遭遇定義結構
newEntity{
    define_as = "ENCOUNTER_MERCHANT",
    type = "encounter",
    name = _t"lost merchant",
    -- 生成條件
    level_range = {5, 25}, rarity = 15,
    min_lore = 0,
    -- 是否立即觸發（或需要玩家踩上去）
    immediate = true,
    -- 觸發邏輯
    on_encounter = function(self, who, x, y)
        -- 生成 WorldNPC 並設置對話
        local npc = game.zone:makeEntityByName(game.level, "worldnpc", "LOST_MERCHANT")
        game.zone:addEntity(game.level, npc, "worldnpc", x, y)
        npc:talkTo(who)
    end,
    -- 特殊條件過濾
    special_filter = function(self, who)
        return not who:hasQuest("lost-merchant")
    end,
}
```

**遭遇觸發鏈**：世界地圖行走 → 觸發遭遇 → 生成 WorldNPC → 啟動對話/任務 → 更新任務狀態

---
