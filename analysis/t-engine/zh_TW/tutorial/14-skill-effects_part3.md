# 教學 14：技能視覺特效（續）

### 技能二：冰霜爆裂（直接爆炸）

```lua
newTalent{
    name="冰霜爆裂", type={"spell/ice",2}, points=5,
    cooldown=8, range=8, requires_target=true,
    action = function(self, t)
        local tg = {type="ball", range=self:getTalentRange(t),
            radius=1+math.floor(self:getTalentLevelRaw(t)/2),
            talent=t, selffire=false}
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end
        self:project(tg, x, y, DamageType.COLD, 20+self:getTalentLevel(t)*8)
        game.level.map:particleEmitter(x, y, tg.radius, "ice_explosion",
            {radius=tg.radius, tx=x, ty=y})
        return true
    end,
    info = function(self, t)
        local r = 1+math.floor(self:getTalentLevelRaw(t)/2)
        return ("在目標位置製造半徑 %d 格的冰霜爆炸。"):format(r)
    end,
}
```

### 技能三：冰護盾（SUSTAINED + 持續光環）

```lua
newTalent{
    name="冰護盾", type={"spell/ice",3}, points=5,
    mode="sustained", cooldown=20, sustain_power=10,
    activate = function(self, t)
        local particle = self:addParticles(Particles.new("ice_aura", 1, {}))
        return {particle=particle, absorb=5+self:getTalentLevel(t)*3}
    end,
    deactivate = function(self, t, p)
        self:removeParticles(p.particle)
        return true
    end,
    info = function(self, t)
        return ("持續消耗能量，形成冰護盾吸收 %d 點傷害。"):format(5+self:getTalentLevel(t)*3)
    end,
}
```

> SUSTAINED 的 `activate` 必須 `return {...}`（即使空表 `{}`）—— `p` 傳給 `deactivate`。`return nil` 會立刻取消技能。

---

## 步驟六：particleEmitter 完整簽名

```lua
game.level.map:particleEmitter(
    x, y,            -- 格座標（非像素）
    radius,          -- 半徑（格數，0=單格）
    "def_name",      -- 粒子定義名（不含 .lua，相對 data/gfx/particles/）
    {                -- args：粒子 Lua 中作為全域變數
        radius=radius, tx=x, ty=y, color={r=1,g=0,b=0},
    }
)
```

> `args` 在粒子 Lua 環境中以 `setfenv` 設為函式環境，`args.tx` 可直接寫 `tx`。

---

## 步驟七：貼圖路徑

```
粒子定義第 4 返回值："particles_images/ice_shard"
→ 引擎查找：/data/gfx/particles_images/ice_shard.png
→ 實體路徑：mod/data/gfx/particles_images/ice_shard.png
```

內建可用貼圖：

| 路徑（省略 `/data/gfx/`） | 外觀 |
|--------------------------|------|
| `particle`（預設） | 圓形高斯模糊光點 |
| `particle_cloud` | 較大雲狀光點 |
| `particle_torus` | 環形（donut） |
| `particles_images/beam` | 細長光束 |

---

## 步驟八：調整技巧

- 粒子密度由 `config.settings.particles_density`（0~100%）控制，引擎 C 層自動縮減 `emit` 數量
- 建議最高密度時不超過 1000 顆

```lua
-- 向心匯聚
vel=sradius/10, velv=-sradius/100, vela=0

-- 離心爆散
vel=0, velv=sradius/20

-- 旋轉
dir=math.rad(rng.float(0,360)), dirv=math.rad(rng.range(2,5))

-- 閃爍（透明度先增後減）
a=0, av=0.1, aa=-0.01
```

### Cheat Console 即時測試

```lua
game.level.map:particleEmitter(game.player.x, game.player.y, 2,
    "ice_explosion", {radius=2, tx=game.player.x, ty=game.player.y})
```

---

## 常見問題

| 現象 | 原因 | 解法 |
|------|------|------|
| 粒子不顯示 | Lua 語法錯誤或貼圖路徑不對 | 看 Cheat Console 錯誤訊息 |
| 粒子瞬間消失 | `life` < 5 或 `av` 過大 | 增大 `life`、減小 `av` 絕對值 |
| 光環不跟隨角色 | 未設 `can_shift = true` | 粒子 Lua 頂層加此變數 |
| 自訂貼圖顯示方塊 | PNG 背景不透明 | 確認背景 Alpha=0 |
| 顏色不對 | 貼圖非全白 | 貼圖畫純白，讓 r/g/b 控制 |
| SUSTAINED 光環立即消失 | `activate` 無 `return {...}` | 確保 return 狀態表 |
| 移動時粒子抖動 | `can_shift=true` 時 shift 更新不及 | TE4 已知行為，一般可接受 |

---

## 總結

| 概念 | 實作位置 | 關鍵 API |
|------|---------|----------|
| 粒子定義檔 | `data/gfx/particles/*.lua` | `{generator=fn}`, update fn, max, texture |
| 粒子每幀物理 | generator 欄位 | `v`=速度, `a`=加速度 |
| 飛行拖尾 | `tg.display` | `{particle="name", trail="name"}` |
| 落點爆炸 | `action` 中 | `map:particleEmitter(x,y,r,"name",args)` |
| 持續光環 | activate/deactivate | `addParticles(Particles.new(...))` / `removeParticles()` |
| 自訂貼圖 | 第 4 返回值 | PNG 放 `data/gfx/particles_images/`，全白背景透明 |
| args 傳遞 | `particleEmitter` / `Particles.new` | args 表在粒子 Lua 中為全域變數 |