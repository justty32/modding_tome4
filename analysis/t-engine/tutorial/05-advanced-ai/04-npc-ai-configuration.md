NPC 的 AI 在實體定義中指定：

```lua
newEntity{
    name = "goblin archer",
    -- ...

    -- 設定主 AI（頂層入口）
    ai = "dumb_talented_simple",

    -- AI 的參數設定
    ai_state = {
        ai_target = "target_simple",   -- 目標選擇 AI（預設已是 target_simple）
        ai_move   = "move_simple",     -- 移動 AI（預設 move_simple）
        talent_in = 3,                 -- 平均每 3 回合用一次技能（1/3 機率）
    },
}
```

### 常用 ai 值與建議用途

| `ai` 值 | 適用 NPC 類型 |
|---------|-------------|
| `"dumb_talented_simple"` | 普通雜兵（隨機技能）|
| `"improved_tactical"` | 稀有/菁英（智能技能選擇）|
| `"move_simple"` | 純近戰移動怪（無技能）|
| `"none"` | 靜止不動（植物、水晶）|

---
