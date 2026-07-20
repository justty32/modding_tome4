### 讓特效在低效能設備上正常縮放

玩家可以在設定中調整粒子密度（`config.settings.particles_density`，0~100%）。引擎的 C 層會根據這個值縮減 `emit` 的數量。你不需要手動處理，只需確保在最高密度時的粒子數量合理（建議不超過 1000 顆）。

### 常見調整參數

```lua
-- 讓粒子「向心」匯聚（從外往內飛）
vel  = sradius / 10,   -- 初始速度（向外）
velv = -sradius / 100, -- 逐幀減速
vela = 0,

-- 讓粒子「離心」爆散（從內往外飛）
vel  = 0,
velv = sradius / 20,   -- 逐幀加速往外

-- 讓粒子「旋轉」：改變 dir 而不是 x/y
dir  = math.rad(rng.float(0, 360)),
dirv = math.rad(rng.range(2, 5)),  -- 每幀旋轉 2~5 度

-- 讓粒子「閃爍」：透明度先增後減
a  = 0,
av = 0.1,      -- 先變亮
aa = -0.01,    -- 加速度讓 av 漸減 → 最終反轉 → 變暗
```

### 觀察現有特效調參的訣竅

```lua
-- 在 Cheat Console 中即時添加粒子到當前格子測試
game.level.map:particleEmitter(
    game.player.x, game.player.y,
    2,
    "ice_explosion",     -- 替換成你正在調整的粒子名稱
    {radius=2, tx=game.player.x, ty=game.player.y}
)
```

---
