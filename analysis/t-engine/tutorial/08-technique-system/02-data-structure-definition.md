### 2.1 Actor 上的連技狀態

```lua
actor.techniques = {
    -- 5 個槽位（1~5），每個儲存一個連技 ID
    slots = {nil, nil, nil, nil, nil},
    -- 已習得的連技清單 { id = {proficiency=0,...} }
    known = {},
}

actor.combo_state = {
    count  = 0,      -- 當前連擊計數
    timer  = 0,      -- 距離連擊超時還有幾回合
    active = false,  -- 是否在 combo 狀態
}
```

### 2.2 全域連技定義表

```lua
-- 類似 ActorTalents.talents_def，存在全域
_G.techniques_def = {}   -- key = technique id, value = 定義表格
```

### 2.3 單一連技定義結構

```lua
{
    id          = "T_SWIFT_SLASH",   -- 自動產生（"T_" + short_name）
    name        = "迅斬",
    short_name  = "SWIFT_SLASH",
    type        = "starter",         -- starter / linker / finisher / free
    ki_cost     = 10,                -- 消耗氣值
    cooldown    = 3,                 -- 冷卻（回合數）
    -- 熟練度：0（剛習得）→ 1.0（完全熟練）
    -- 影響效果公式
    action      = function(self, t, combo)
        -- self = Actor, t = 連技定義, combo = 當前連擊計數
    end,
    info        = function(self, t)
        return "說明文字"
    end,
}
```

---
