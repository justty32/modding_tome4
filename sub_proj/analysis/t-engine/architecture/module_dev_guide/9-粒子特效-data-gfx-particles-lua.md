```lua
-- data/gfx/particles/acid.lua
return {
    base = 1000,                   -- 最大粒子數
    angle    = { 0, 360 },        -- 初始角度範圍
    anglev   = { 2000, 4000 },    -- 角速度
    anglea   = { 200, 600 },      -- 角加速度
    life     = { 5, 10 },         -- 粒子壽命（frame）
    size     = { 3, 6 },          -- 粒子大小
    sizev    = { 0, 0 },
    r = {0, 0}, rv = {0, 0}, ra = {0, 0},       -- 紅色通道
    g = {80, 200}, gv = {0, 10}, ga = {0, 0},   -- 綠色通道
    b = {0, 0}, bv = {0, 0}, ba = {0, 0},       -- 藍色通道
    a = {255, 255}, av = {0, 0}, aa = {0, 0},   -- 透明度
}, function(self)
    -- 發射控制函數（每幀呼叫）
    self.nb = (self.nb or 0) + 1
    if self.nb < 4 then
        self.ps:emit(100)  -- 發射 100 個粒子
    end
end
```

使用方式：`actor:addParticles(engine.Particles.new("acid", 1))`

---
