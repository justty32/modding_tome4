# 教學 17：自訂動畫

TE4 動畫分為完全獨立的層次，各有不同 API：

| 系統 | 位置 | 用途 |
|------|------|------|
| 精靈圖序列 `entity.anim` | C 層 map object | 實體逐幀播放 |
| 移動動畫 `setMoveAnim` | C 層 map object | 滑動 / 攻擊搖晃 |
| `tween` 補間 | Lua thirdparty | 數值平滑過渡（UI 動畫） |
| `FlyingText` 飄字 | `engine.FlyingText` | 傷害數字、提示文字 |
| `displayCallback` | C 層 map object | 實體每幀自訂渲染 |
| OpenGL 變換 | `core.display.*` | 任意 2D 幾何動畫 |

---

## 一、精靈圖序列動畫

### 1.1 原理

N 張動畫幀水平排列在同一張 PNG 上，加 `anim` 欄位，C 層自動計算 UV 並逐幀播放。

```
frame1 | frame2 | frame3 | frame4     ← 256×64 sprite strip（每幀 64×64）
```

### 1.2 Entity 定義

```lua
newEntity{
    define_as="FIRE_TRAP", type="trap", subtype="fire", name="fire trap",
    image="trap/fire_anim.png",
    anim={
        max=4,     -- 幀數（texture 寬度 / 每幀寬度）
        speed=2,   -- 每幾個 render frames 前進一幀（越小越快）
        loop=-1,   -- -1=無限，0=播一次停，N=播 N 次停
    },
}
```

### 1.3 注意

- `image` 必須是水平精靈圖（幀左右排列）
- `anim.max` = 幀數，引擎內部做 `btexx / anim.max` 計算 UV
- 動態切換動畫需 C 層 `_mo:setAnim(start, max, speed, loop)`，通常不推薦

---

## 二、移動動畫 `setMoveAnim`

### 2.1 滑動動畫

```lua
-- 在 mod/class/Actor.lua 的 move() 中
function _M:move(x, y, force)
    local ox, oy = self.x, self.y
    local moved = engine.Actor.move(self, x, y, force)
    if moved and ox and oy and (ox~=self.x or oy~=self.y) then
        self:setMoveAnim(ox, oy, 3)  -- 3 render frames（~0.1 秒）
    end
    return moved
end
```

完整參數：`setMoveAnim(oldx, oldy, speed, blur, twitch_dir, twitch)`

| 參數 | 預設 | 說明 |
|------|------|------|
| `oldx, oldy` | — | 動畫起點（舊座標） |
| `speed` | — | 動畫幀數 |
| `blur` | 0 | 動態模糊殘影幀數 |
| `twitch_dir` | 0 | 搖晃方向（numpad 方向，0=上方） |
| `twitch` | 0 | 搖晃幅度（0.0~1.0 格） |

### 2.2 攻擊搖晃

```lua
function _M:attackTarget(target)
    self:setMoveAnim(self.x, self.y, 3, nil,
        util.getDir(target.x, target.y, self.x, self.y), 0.2)
    -- 傷害計算...
end
```

### 2.3 停止動畫

```lua
self:resetMoveAnim()   -- 立即停止
```

---

## 三、`tween` 補間（UI 動畫）

由 `Game:tick()` 每幀自動更新：

```lua
local tween = require "tween"

-- tween(幀數, 目標物件, {目標值}, 緩動名稱, 完成回調)
local id = tween(60, self, {alpha=0}, "outQuad", function()
    self.visible = false
end)
tween.stop(id)  -- 取消
```

### 3.1 緩動函式

| 名稱 | 效果 |
|------|------|
| `"linear"` | 勻速 |
| `"inQuad"` / `"outQuad"` | 加速入 / 減速出 |
| `"inCubic"` / `"outCubic"` | 三次方緩動 |
| `"inSine"` / `"outSine"` | 正弦 |
| `"inBounce"` / `"outBounce"` | 彈跳 |
| `"inElastic"` / `"outElastic"` | 彈性 |
| `"inOutQuad"` | 前半加速後半減速 |

### 3.2 範例：BigNews 大字縮放

```lua
local Notif = {}
function Notif:show(text, duration)
    self.text, self.scale, self.alpha = text, 1.0, 1.0
    if self.tw then tween.stop(self.tw) end
    self.tw = tween(duration or 60, self, {scale=0, alpha=0}, "inQuint",
        function() self.text = nil end)
end
function Notif:display()
    if not self.text then return end
    local cx, cy = game.w/2, game.h/4
    core.display.glTranslate(cx, cy, 0)
    core.display.glScale(self.scale, self.scale, self.scale)
    -- 繪製文字...
    core.display.glScale()
    core.display.glTranslate(-cx, -cy, 0)
end
```

---（續 part2）---