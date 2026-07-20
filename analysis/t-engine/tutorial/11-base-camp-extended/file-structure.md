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
