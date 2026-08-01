### 2.1 滑動動畫（角色移動）

每次 actor 成功移動到新位置後，呼叫 `setMoveAnim` 讓它看起來是「滑」過去的，而不是瞬間跳格：

```lua
-- 在 mod/class/Actor.lua 的 move() 中
function _M:move(x, y, force)
    local ox, oy = self.x, self.y
    local moved = engine.Actor.move(self, x, y, force)

    if moved and ox and oy and (ox ~= self.x or oy ~= self.y) then
        -- speed=3：動畫持續 3 個 render frames（約 0.1 秒）
        self:setMoveAnim(ox, oy, 3)
    end
    return moved
end
```

`setMoveAnim(oldx, oldy, speed, blur, twitch_dir, twitch)` 完整參數：

| 參數 | 預設 | 說明 |
|------|------|------|
| `oldx, oldy` | — | 動畫起點（舊座標） |
| `speed` | — | 動畫幀數（render frames） |
| `blur` | `0` | 動態模糊殘影幀數（`nil` 或 `0` = 無模糊） |
| `twitch_dir` | `0` | 搖晃方向（numpad 方向，0=上方） |
| `twitch` | `0` | 搖晃幅度（0.0–1.0，單位：格） |

### 2.2 攻擊搖晃動畫

攻擊時讓攻擊者短暫往目標方向「衝刺」後彈回：

```lua
function _M:attackTarget(target)
    -- 往目標方向搖晃 0.2 格，持續 3 幀
    self:setMoveAnim(
        self.x, self.y,       -- 起點（原位置）
        3,                    -- 速度
        nil,                  -- 無模糊
        util.getDir(target.x, target.y, self.x, self.y),  -- 攻擊方向
        0.2                   -- 搖晃幅度
    )
    -- 傷害計算...
end
```

### 2.3 停止移動動畫

```lua
self:resetMoveAnim()   -- 立即停止，不等動畫播完
```

---
