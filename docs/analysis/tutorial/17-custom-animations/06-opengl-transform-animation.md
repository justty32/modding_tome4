### 6.1 API 說明

這些函式操作 OpenGL 變換矩陣，影響之後的所有繪製指令：

```lua
core.display.glTranslate(dx, dy, 0)    -- 平移
core.display.glScale(sx, sy, sz)       -- 縮放
core.display.glRotate(deg, 0, 0, 1)    -- 繞 Z 軸旋轉（2D 常用）

-- 恢復（TE4 沒有矩陣 push/pop，要手動逆變換）
core.display.glScale(1/sx, 1/sy, 1/sz) -- 或 core.display.glScale()（重設為 1）
core.display.glTranslate(-dx, -dy, 0)
```

> **注意**：`core.display.glScale()` 不帶參數等同於 `glScale(1,1,1)`，重設縮放但**不**恢復 translate。變換順序：**先 translate、再 scale/rotate**，恢復時**先 scale/rotate、再 translate**。

### 6.2 搖晃畫面（受擊反饋）

```lua
-- 在 UISet:displayUI 或 Game:display 中呼叫
local tween = require "tween"

function _M:screenShake(intensity, duration)
    self._shake = {x=0, y=0, intensity=intensity}
    tween(duration or 20, self._shake, {intensity=0}, "outCubic")
end

function _M:display(nb_keyframes)
    if self._shake and self._shake.intensity > 0 then
        local ox = (rng.float(-1, 1)) * self._shake.intensity
        local oy = (rng.float(-1, 1)) * self._shake.intensity
        core.display.glTranslate(ox, oy, 0)
    end

    -- 正常畫面渲染...
    engine.Game.display(self, nb_keyframes)

    if self._shake and self._shake.intensity > 0 then
        core.display.glTranslate(-self._shake.intensity, -self._shake.intensity, 0)  -- 近似恢復
    end
end
```

### 6.3 對話框彈出動畫

在 Dialog 子類中，覆寫 `display` 做縮放彈出效果：

```lua
local tween = require "tween"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(title, w, h)
    engine.ui.Dialog.init(self, title, w, h)
    self._popup_scale = 0.1
    self._popup_alpha = 0
    tween(15, self, {_popup_scale=1, _popup_alpha=1}, "outBack")
end

function _M:display()
    local cx = self.display_x + self.w / 2
    local cy = self.display_y + self.h / 2
    local s  = self._popup_scale

    core.display.glTranslate(cx, cy, 0)
    core.display.glScale(s, s, s)
    core.display.glTranslate(-cx, -cy, 0)

    engine.ui.Dialog.display(self)   -- 繪製 Dialog 本體

    core.display.glTranslate(cx, cy, 0)
    core.display.glScale()           -- 重設
    core.display.glTranslate(-cx, -cy, 0)
end
```

---
