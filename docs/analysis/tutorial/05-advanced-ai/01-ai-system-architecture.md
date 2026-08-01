TE4 的 AI 是**函式組合系統**（composable AI functions）。每個 AI 是一個具名函式，可以呼叫其他 AI，類似管線：

```
NPC:act()
  → self:computeFOV()          ← 先更新視野
  → self:doAI()               ← 主入口
      → self:runAI(self.ai)   ← 執行 NPC 指定的 AI
          → 可以再 runAI 其他 AI（組合）
```

**三層分工**：

```
目標選擇 AI        移動 AI              技能使用 AI
─────────────  +  ────────────  +  ──────────────────
target_simple      move_simple      dumb_talented
target_closest     move_dmap        improved_talented
target_player      move_astar       use_tactical
                   flee_simple      use_improved_tactical
                   flee_dmap
```

大多數頂層 AI（如 `simple`、`dumb_talented_simple`）會依序呼叫這三類 AI。

**AI 定義語法**：

```lua
-- 在 AI 定義檔中（engine/ai/*.lua 或 mod/ai/*.lua）
newAI("ai_name", function(self, ...)
    -- self = 這個 NPC Actor
    -- 回傳 true/false 表示是否成功行動
end)
```

**執行 AI**：

```lua
-- 在任何 Actor 方法中
self:runAI("ai_name")          -- 執行指定 AI
self:runAI("ai_name", arg1)    -- 帶參數
```

---
