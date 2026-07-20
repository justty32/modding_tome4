TE4（T-Engine 4）是一個 **Lua 驅動的 Roguelike 引擎**。你的遊戲是一個「模組」（module），放在：

```
game/modules/<你的模組名稱>/
```

引擎載入時會掃描這個目錄，找到 `init.lua`，然後按照你的設定啟動遊戲。

**整體啟動流程**：

```
bootstrap/boot.lua
  → game/loader/init.lua     ← 引擎版本選擇 + Addon superload 設置
    → game/modules/<mod>/init.lua   ← 你的模組元資料
      → game/modules/<mod>/load.lua ← 定義遊戲系統
        → mod.class.Game:run()     ← 遊戲主迴圈開始
```

---
