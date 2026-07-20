```
玩家第一次進入據點
│
├─ camp_state.buildings 全部 false
├─ 地圖上顯示 BUILD_SITE_* 格（?）
│
├─ 玩家到野外採集：木材×5
│
├─ 碰撞建造管理員 NPC（M）→ 建造農田
│   ├─ build() 消耗木材×5
│   ├─ camp_state.buildings.farm = true
│   └─ _applyBuildingToMap("farm")
│       → 掃描到 BUILD_SITE_FARM（build_tag="farm"）
│       → 替換為 FARM_EMPTY
│
├─ 玩家踩上農田（FARM_EMPTY），按 >
│   ├─ farmInteract() 消耗草藥種子×1
│   ├─ 地圖：FARM_EMPTY → FARM_GROWING
│   └─ camp_state.farms["x_y"] = {turn_planted=game.turn, ...}
│
├─ （可選）招募工人，指派到農田
│   └─ worker.ai_state.command = {type="work", task="farm"}
│       → 工人移動到農田旁
│       → 每 20 動作：farm.turn_planted -= 5 * ticks_per_act
│
├─ 每 10 game.turn（= 1 玩家動作）
│   └─ Game:onTurn() → updateCamp()
│       └─ turn - turn_planted >= 100 * 10 = 1000
│             → farm.ready = true
│             → 地圖：FARM_GROWING → FARM_READY
│             → 提示玩家
│
├─ 玩家踩上農田（FARM_READY），按 >
│   ├─ farmInteract() 把 yield 加入背包（HERB×3）
│   ├─ 地圖：FARM_READY → FARM_EMPTY
│   └─ camp_state.farms["x_y"] = nil
│
└─ 玩家離開據點（按 < 使用 EXIT_TO_WORLD）
    ├─ Zone:leaveLevel() → memory_levels[1] = level
    └─ Zone:save() 寫入 .teaz 磁碟檔
        → 地圖 Grid 替換狀態持久化（農田格保留）
        → camp_state 隨 game:save() 持久化（種植進度保留）
```

---
