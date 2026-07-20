`ai_tactic` 是 NPC 的**個性設定**——乘以每個 WANT 值，讓 NPC 偏好特定戰術風格：

```lua
newEntity{
    name = "aggressive berserker",
    -- ...

    -- 乘數（預設 1，不影響）
    ai_tactic = {
        attack   = 3,   -- 攻擊欲望翻 3 倍（非常侵略性）
        escape   = 0,   -- 永不逃跑
        defend   = 0.5, -- 不太在乎防禦
        disable  = 2,   -- 喜歡控制技能

        -- 安全距離：低於此距離會觸發逃跑欲望
        safe_range = 4, -- 試圖保持在 4 格外（遠程 NPC 用）
    },
}
```

### 常見風格模板

#### 近戰侵略型

```lua
ai_tactic = {
    attack  = 3,
    closein = 2,
    escape  = 0,
    defend  = 0.5,
}
```

#### 遠程狙擊型

```lua
ai_tactic = {
    attack     = 2,
    escape     = 2,
    closein    = 0.5,
    safe_range = 5,   -- 保持 5 格距離
}
```

#### 支援治療型

```lua
ai_tactic = {
    heal    = 3,
    defend  = 2,
    attack  = 0.5,
    escape  = 2,
}
```

#### 控制削弱型

```lua
ai_tactic = {
    disable = 3,
    attack  = 1.5,
    buff    = 1,
}
```

#### Boss 型（多才多藝）

```lua
ai_tactic = {
    attack    = 2,
    disable   = 2,
    buff      = 2,
    heal      = 2,
    escape    = 1,
    safe_range = 3,
}
```

---
