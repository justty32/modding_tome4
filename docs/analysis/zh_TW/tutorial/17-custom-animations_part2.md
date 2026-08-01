# 教學 17：自訂動畫（續）

## 四、`FlyingText` 飄字

### 4.1 初始化

```lua
-- Game:load() 中
local FlyingText = require "engine.FlyingText"
self.flyers = FlyingText.new("/data/font/DroidSans.ttf", 14,
    "/data/font/DroidSans-Bold.ttf", 16)
self.flyers:enableShadow(0.6)
self:setFlyingText(self.flyers)
```

### 4.2 顯示飄字

```lua
local function actorScreenPos(actor)
    local map = game.level.map
    return map.display_x + (actor.x-map.mx)*map.tile_w,
           map.display_y + (actor.y-map.my)*map.tile_h
end

-- 傷害數字
function _M:onTakeHit(value, src)
    local sx, sy = actorScreenPos(self)
    game.flyers:add(sx, sy, 30, (rng.range(0,2)-1)*0.5, -3,
        tostring(math.ceil(value)), {255,80,80}, false)
    return value
end

-- 升級提示
local sx, sy = actorScreenPos(game.player)
game.flyers:add(sx, sy, 80, 0.5, -2, "LEVEL UP!", {0,255,255}, true)
```

`FlyingText:add(x, y, duration, xvel, yvel, str, color, bigfont)`：

| 參數 | 說明 |
|------|------|
| `x, y` | 螢幕像素座標 |
| `duration` | 持續幀數 |
| `xvel, yvel` | 水平/垂直速度（負值=向上） |
| `str` | 顯示文字 |
| `color` | `{r,g,b}` 0~255 |
| `bigfont` | true=大號字 |

---

## 五、`displayCallback`（逐幀自訂渲染）

在**每個 render frame**、Entity 的 `_mo` 被繪製時呼叫。適合血條、光暈、閃爍。

### 5.1 血條

```lua
function _M:defineDisplayCallback()
    engine.Actor.defineDisplayCallback(self)
    if not self._mo then return end
    local weak = setmetatable({[1]=self}, {__mode="v"})

    self._mo:displayCallback(function(x, y, w, h)
        local self = weak[1]
        if not self then return end
        local bar_w, bar_h = w*0.8, 4
        local bx = x+(w-bar_w)/2
        local by = y-bar_h-2
        core.display.drawQuad(bx, by, bar_w, bar_h, 0,0,0,180)
        if self.life and self.max_life and self.max_life>0 then
            local pct = math.max(0, self.life/self.max_life)
            core.display.drawQuad(bx, by, bar_w*pct, bar_h, 255,50,50,220)
        end
        return true  -- 必須
    end)
end
```

> `core.display.drawQuad(x,y,w,h,r,g,b,a)` — a 為 0~255 透明度。

### 5.2 閃爍效果

```lua
function _M:startFlash(duration) self._flash_timer = duration end

function _M:defineDisplayCallback()
    local weak = setmetatable({[1]=self}, {__mode="v"})
    self._mo:displayCallback(function(x,y,w,h)
        local self = weak[1]
        if not self then return end
        if self._flash_timer and self._flash_timer>0 then
            local alpha = math.sin(self._flash_timer*0.5)*128+128
            core.display.drawQuad(x,y,w,h,255,255,255,alpha)
            self._flash_timer = self._flash_timer - 1
        end
        return true
    end)
end
```

---

## 六、OpenGL 變換動畫

### 6.1 API

```lua
core.display.glTranslate(dx, dy, 0)       -- 平移
core.display.glScale(sx, sy, sz)          -- 縮放
core.display.glRotate(deg, 0, 0, 1)       -- 繞 Z 旋轉
core.display.glScale()                    -- 重設縮放為 1
```

> 無矩陣 push/pop，需手動逆變換。順序：**先 translate、再 scale/rotate**，恢復順序相反。

### 6.2 畫面搖晃

```lua
function _M:screenShake(intensity, duration)
    self._shake = {x=0, y=0, intensity=intensity}
    tween(duration or 20, self._shake, {intensity=0}, "outCubic")
end

function _M:display(nb_keyframes)
    if self._shake and self._shake.intensity>0 then
        local ox=rng.float(-1,1)*self._shake.intensity
        local oy=rng.float(-1,1)*self._shake.intensity
        core.display.glTranslate(ox, oy, 0)
    end
    engine.Game.display(self, nb_keyframes)
    if self._shake and self._shake.intensity>0 then
        core.display.glTranslate(-self._shake.intensity, -self._shake.intensity, 0)
    end
end
```

### 6.3 Dialog 彈出動畫

```lua
local tween = require "tween"
module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(title, w, h)
    engine.ui.Dialog.init(self, title, w, h)
    self._popup_scale, self._popup_alpha = 0.1, 0
    tween(15, self, {_popup_scale=1, _popup_alpha=1}, "outBack")
end

function _M:display()
    local cx, cy = self.display_x+self.w/2, self.display_y+self.h/2
    local s = self._popup_scale
    core.display.glTranslate(cx, cy, 0)
    core.display.glScale(s, s, s)
    core.display.glTranslate(-cx, -cy, 0)
    engine.ui.Dialog.display(self)
    core.display.glTranslate(cx, cy, 0)
    core.display.glScale()
    core.display.glTranslate(-cx, -cy, 0)
end
```

---

## 七、完整範例：技能命中特效系統

```lua
function _M:hitEffect(target, damage, dtype)
    local map = game.level.map
    local sx = map.display_x+(target.x-map.mx)*map.tile_w
    local sy = map.display_y+(target.y-map.my)*map.tile_h

    -- 1. 傷害飄字
    local color
    if dtype == DamageType.FIRE   then color={255,120,30}
    elseif dtype == DamageType.ICE then color={80,200,255}
    else                               color={255,255,80} end
    game.flyers:add(sx, sy-map.tile_h/2, 35,
        (rng.range(0,2)-1)*0.3, -2.5,
        tostring(math.ceil(damage)), color, false)

    -- 2. 攻擊搖晃
    self:setMoveAnim(self.x, self.y, 4, nil,
        util.getDir(target.x, target.y, self.x, self.y), 0.25)

    -- 3. 粒子（教學 14）
    map:particleEmitter(target.x, target.y, 1, "melee_attack",
        {color=target.blood_color or {255,0,0}})

    -- 4. 大傷害震動螢幕
    if damage > 50 then
        game.uiset:screenShake(damage/20, 15)
    end
end
```

---

## 總結

| 需求 | 使用系統 |
|------|---------|
| NPC/怪物逐幀動畫 | `entity.anim={max, speed, loop}` |
| 移動滑動 | `actor:setMoveAnim(ox, oy, speed)` |
| 攻擊動作 | `actor:setMoveAnim(x,y,speed,nil,dir,0.2)` |
| UI 淡入/出 | `tween(frames, obj, {field=target}, easing, cb)` |
| 傷害數字 | `game.flyers:add(sx,sy,dur,vx,vy,str,color)` |
| 自訂血條 | `entity._mo:displayCallback(fn)` |
| 畫面震動 / Dialog 彈出 | `core.display.glTranslate/Scale/Rotate` + tween |
| 持續特效 | `actor:addParticles(Particles.new(...))`（教學 14） |