### Q：`dumb_talented` 和 `improved_tactical` 怎麼選？

| 情境 | 建議 |
|------|------|
| 普通雜兵（rank 2）| `dumb_talented_simple`（快速、低開銷）|
| 稀有/菁英（rank 3）| `improved_talented`（仍然隨機，但更聰明）|
| Boss/特殊（rank 4+）| `improved_tactical`（完整戰術評分）|

### Q：`self_compassion` 和 `ally_compassion` 是什麼？

這兩個值控制 AI 對「傷到自己/友軍」的容忍度：

- `self_compassion = 5`（預設）：AOE 打到自己的技能，傷害值懲罰 ×5
- `ally_compassion = 1`（預設）：打到友軍的技能，傷害值懲罰 ×1

設為 `false` 則完全不在乎傷到自己/友軍：

```lua
ai_state = { self_compassion = false }  -- 完全不顧自傷
```

### Q：如何讓 NPC 保持距離？

使用 `ai_tactic.safe_range`：

```lua
ai_tactic = {
    escape    = 2,    -- 基礎逃跑欲望
    safe_range = 5,   -- 試圖保持 5 格距離
}
```

距離比 `safe_range` 近時，`want.escape` 會大幅提升，推動 AI 選擇逃跑技能或移動。

### Q：`tactical_random_range` 如何調整？

```lua
ai_state = { tactical_random_range = 0.0 }  -- 完全決定論（每次選最優）
ai_state = { tactical_random_range = 0.5 }  -- 預設（最多 50% 隨機浮動）
ai_state = { tactical_random_range = 1.0 }  -- 高隨機性（AI 更混亂）
```

### Q：能讓 NPC 只在特定條件下使用技能嗎？

用 `on_pre_use_ai` 回呼：

```lua
newTalent{
    name = "Desperate Strike",
    -- ...
    -- 只有血量低於 30% 時 AI 才使用
    on_pre_use_ai = function(self, t, silent, fake)
        return self.life / self.max_life < 0.3
    end,
    tactical = { attack = 4 },  -- 高戰術值確保被優先選
}
```

---
