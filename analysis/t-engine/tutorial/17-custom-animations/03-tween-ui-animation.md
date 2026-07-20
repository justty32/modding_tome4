### 3.1 基本用法

`tween` 庫位於 `game/thirdparty/tween.lua`，由 `Game:tick()` 每幀自動更新：

```lua
local tween = require "tween"

-- 基本格式：tween(幀數, 目標物件, {目標值}, 緩動名稱, 完成回調)
local id = tween(60, self, {alpha=0}, "outQuad", function()
    -- 動畫完成後執行
    self.visible = false
end)

-- 取消動畫
tween.stop(id)
```

`subject`（目標物件）的對應欄位會被平滑更新至 `target_table` 中的值。欄位必須是**數字**。

### 3.2 緩動函式

| 名稱 | 效果 |
|------|------|
| `"linear"` | 勻速 |
| `"inQuad"` / `"outQuad"` | 加速入 / 減速出（二次方） |
| `"inCubic"` / `"outCubic"` | 加速入 / 減速出（三次方） |
| `"inSine"` / `"outSine"` | 正弦緩動 |
| `"inQuint"` / `"outQuint"` | 強加速入 / 強減速出 |
| `"inBounce"` / `"outBounce"` | 彈跳 |
| `"inElastic"` / `"outElastic"` | 彈性 |
| `"inOutQuad"` | 前半加速、後半減速 |

### 3.3 範例：BigNews 大字通知（帶縮放漸出）

```lua
-- 仿 mod/class/BigNews.lua 的寫法
local tween = require "tween"

local Notif = {}

function Notif:show(text, duration)
    self.text = text
    self.scale = 1.0    -- 從 1.0 縮到 0
    self.alpha = 1.0
    if self.tw then tween.stop(self.tw) end
    -- 60 幀後縮小消失
    self.tw = tween(duration or 60, self, {scale=0, alpha=0}, "inQuint", function()
        self.text = nil
    end)
end

function Notif:display()
    if not self.text then return end
    local cx, cy = game.w / 2, game.h / 4

    core.display.glTranslate(cx, cy, 0)
    core.display.glScale(self.scale, self.scale, self.scale)

    -- 繪製文字（略）
    self.tex:toScreenFull(-self.tw/2, -self.th/2, self.tw, self.th,
        self.ttw, self.tth, 1, 1, 1, self.alpha)

    core.display.glScale()           -- 恢復 scale
    core.display.glTranslate(-cx, -cy, 0)  -- 恢復 translate
end
```

---
