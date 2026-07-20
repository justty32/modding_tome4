| 需求 | 使用系統 |
|------|---------|
| 地圖上的 NPC/怪物逐幀動畫 | `entity.anim = {max, speed, loop}` |
| 角色移動滑動效果 | `actor:setMoveAnim(ox, oy, speed)` |
| 攻擊動作（往前衝） | `actor:setMoveAnim(x, y, speed, nil, dir, 0.2)` |
| UI 元素淡入/淡出/縮放 | `tween(frames, obj, {field=target}, easing, cb)` |
| 傷害數字 / 狀態提示 | `game.flyers:add(sx, sy, dur, vx, vy, str, color)` |
| 自訂血條 / 每幀 entity 特效 | `entity._mo:displayCallback(fn)` |
| 全螢幕震動 / Dialog 彈出 | `core.display.glTranslate/Scale/Rotate` + tween |
| 持續特效（光暈、粒子環） | `actor:addParticles(Particles.new(...))` （見教學 14） |
