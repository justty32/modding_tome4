### 1.1 原理

把 N 張動畫幀水平排列在**同一張 PNG** 上，然後在 entity 定義中加上 `anim` 欄位，引擎的 C 層會自動計算 UV 偏移並逐幀播放。

```
frame1 | frame2 | frame3 | frame4     ← 一張 256×64 的 sprite strip（每幀 64×64）
```

### 1.2 Entity 定義

```lua
newEntity{
    define_as = "FIRE_TRAP",
    type = "trap", subtype = "fire",
    name = "fire trap",

    -- sprite strip：4 幀、每幀 64×64，整張圖是 256×64
    image = "trap/fire_anim.png",

    anim = {
        max   = 4,    -- 幀數（texture 寬度 / 每幀寬度）
        speed = 2,    -- 每幾個 render frames 前進一幀（越小越快）
        loop  = -1,   -- -1=無限循環，0=播一次後停，N=播N次後停
    },
    ...
}
```

### 1.3 注意事項

- `image` 必須是水平精靈圖（所有幀左右排列）
- `anim.max` = 幀數（不是像素寬）；引擎內部做 `btexx / anim.max` 計算每幀 UV
- Entity 實體化時若要動態改變動畫（例如切換「行走」↔「攻擊」幀段），需要呼叫 C 層 `_mo:setAnim(start, max, speed, loop)`，但這需要直接操作 map object，通常不推薦

---
