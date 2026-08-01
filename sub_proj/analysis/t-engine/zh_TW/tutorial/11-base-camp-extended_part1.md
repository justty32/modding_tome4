# 教學 11：據點系統擴展版

## 本章目標

在 Tutorial 10 基礎版的據點上加入三個進階功能：

1. **農作計時器**：種植後等待固定回合數自動產出資源，不需要玩家一直在場
2. **建造系統**：消耗採集資源解鎖新設施（農田、儲物箱、強化篝火），設施狀態持久化
3. **NPC 工人**：可指派到農田的工人 NPC，在旁邊加速農作成熟

本章在 Tutorial 09（戰術指令 + 僱傭兵）的基礎上擴展，工人 AI 複用 `commanded_ally` 框架新增 `"work"` 指令分支。

---

## 設計架構

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

## 完整新增 / 修改檔案結構

```
mygame/
  mod/
    class/
      Game.lua              ← 新增：onTurn 的 updateCamp 呼叫；farmInteract；newGame/save 初始化
      Grid.lua              ← 擴充：on_move 加農田互動分派
    ai/
      commanded_ally.lua    ← 擴充：加入 work 指令分支 + _cmd_work AI
    data/
      grids/
        camp.lua            ← 擴充：農田三態 Grid + BUILD_SITE_* + 強化篝火 + 儲物箱
      npcs/
        camp_npcs.lua       ← 擴充：加入 BUILD_MANAGER_NPC + CAMP_WORKER 模板
      chats/
        build_manager.lua   ← 新增：建造管理員對話（消耗資源、替換 Grid）
      maps/
        camp.lua            ← 修改：加入建造地塊、管理員 NPC 位置
```

---