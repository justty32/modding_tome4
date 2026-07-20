所有據點進度存在掛載於 `game` 物件上的 `camp_state` 表：

```lua
game.camp_state = {
    buildings = {
        farm          = false,   -- 農田是否已建造
        chest         = false,   -- 儲物箱是否已建造
        upgraded_fire = false,   -- 強化篝火是否已建造
    },
    farms = {
        -- 以 "x_y" 字串為 key，支援多格農田
        ["14_10"] = {
            turn_planted  = 12000,   -- 種下的 game.turn
            turns_to_grow = 100,     -- 成熟所需玩家動作次數
            yield         = {HERB=3},-- 成熟後產出
            ready         = false,   -- 是否可收穫
        },
    },
    workers = {
        -- uid = 任務描述字串（用於日誌）
        [42] = "耕種農田",
    },
}
```

**回合計時機制：**

```
Game:onTurn()  ← 引擎每個 game.turn 都呼叫
  └─ 條件：game.turn % 10 == 0（每 10 tick = 1 玩家動作）
       └─ game:updateCamp()
             └─ 遍歷 camp_state.farms
                   └─ (game.turn - turn_planted) >= turns_to_grow * 10
                         → farm.ready = true，提示玩家
```

---
