### 5.1 用途

`displayCallback` 在**每個 render frame** 、Entity 的 Map Object（`_mo`）被繪製時呼叫，適合：
- 在 entity 上方顯示血條
- 動態光暈、閃爍效果
- 自訂指標或圖示

### 5.2 實作血條

```lua
-- 在 Actor 子類中覆寫 defineDisplayCallback
function _M:defineDisplayCallback()
    -- 先呼叫父類（處理粒子、陣營顏色）
    engine.Actor.defineDisplayCallback(self)

    if not self._mo then return end

    -- 避免 cyclic reference 導致 GC 問題：用 weak table
    local weak = setmetatable({[1]=self}, {__mode="v"})
    local prev_cb = nil  -- 若需要保留父類 callback，先儲存

    self._mo:displayCallback(function(x, y, w, h)
        local self = weak[1]
        if not self then return end

        -- 繪製半透明黑色底條
        local bar_w = w * 0.8
        local bar_h = 4
        local bx = x + (w - bar_w) / 2
        local by = y - bar_h - 2

        core.display.drawQuad(bx, by, bar_w, bar_h, 0, 0, 0, 180)

        -- 繪製紅色血量條
        if self.life and self.max_life and self.max_life > 0 then
            local pct = math.max(0, self.life / self.max_life)
            core.display.drawQuad(bx, by, bar_w * pct, bar_h, 255, 50, 50, 220)
        end

        return true  -- 必須 return true
    end)
end
```

> **注意**：`core.display.drawQuad(x, y, w, h, r, g, b, a)` — 最後 `a` 是 0–255 的透明度。

### 5.3 閃爍效果

```lua
-- 讓 entity 以固定頻率閃爍（如受傷時）
function _M:startFlash(duration)
    self._flash_timer = duration
end

function _M:defineDisplayCallback()
    local weak = setmetatable({[1]=self}, {__mode="v"})
    self._mo:displayCallback(function(x, y, w, h)
        local self = weak[1]
        if not self then return end
        -- 閃爍時以白色半透明圖層蓋住
        if self._flash_timer and self._flash_timer > 0 then
            local alpha = math.sin(self._flash_timer * 0.5) * 128 + 128
            core.display.drawQuad(x, y, w, h, 255, 255, 255, alpha)
            self._flash_timer = self._flash_timer - 1
        end
        return true
    end)
end
```

每回合在 `act()` 中驅動：`self:defineDisplayCallback()` 在修改 `_flash_timer` 後不需要重新呼叫，callback 本身已透過 weak reference 自動讀取最新值。

---
