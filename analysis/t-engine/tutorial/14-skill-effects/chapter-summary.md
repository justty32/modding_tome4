| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| 粒子定義檔格式 | `data/gfx/particles/*.lua` | 返回 `{generator=fn}`, update fn, max, texture |
| 粒子每幀物理 | generator 的欄位 | `v` 後綴 = 速度；`a` 後綴 = 加速度 |
| 飛行拖尾 | 技能 `tg.display` | `{particle="name", trail="name"}` |
| 落點爆炸 | 技能 `action` 中 | `map:particleEmitter(x, y, r, "name", args)` |
| 持續光環 | SUSTAINED `activate`/`deactivate` | `addParticles(Particles.new(...))` / `removeParticles()` |
| 自訂貼圖 | 粒子 Lua 第 4 返回值 | 放 PNG 到 `data/gfx/particles_images/`，全白背景透明 |
| args 傳遞 | `particleEmitter` / `Particles.new` | args 表在粒子 Lua 中作為全域變數可用 |
