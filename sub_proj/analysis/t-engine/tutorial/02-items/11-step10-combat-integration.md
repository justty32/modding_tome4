教學 01 的 `Combat.lua` 使用固定傷害。現在武器的 `wielder.combat_dam` 會透過 `addTemporaryValue` 自動累加到 `Actor.combat_dam`，所以只需確保 `Combat.lua` 使用的是 `self.combat_dam`：

```lua
-- game/modules/hellodungeon/class/interface/Combat.lua
-- （修改 attackTarget 中的傷害計算部分）

function _M:attackTarget(target)
    -- 命中判定（與教學 01 相同）
    local hit = self:checkHit(self:combatAttack(), target:combatDefense())

    if hit then
        -- 傷害 = Actor 的 combat_dam 屬性
        -- 當武器裝備時，wielder.combat_dam 已透過 addTemporaryValue 加進來
        -- 所以這裡直接讀 self.combat_dam 就包含了武器加成
        local dam = math.max(1, (self.combat_dam or 5) + rng.range(-2, 2))

        target:takeHit(dam, self)
        game.logSeen(self, "%s 攻擊 %s，造成 %d 點傷害！",
            self:getName():capitalize(),
            target:getName():capitalize(),
            dam)
        return true
    else
        game.logSeen(self, "%s 攻擊 %s，但未命中！",
            self:getName():capitalize(),
            target:getName():capitalize())
        return false
    end
end
```

**`addTemporaryValue` 的累加原理**：

```
玩家基礎 combat_dam = 5         （在 Actor init 中設定）
裝備木劍後：
  addTemporaryValue("combat_dam", 3)
  → self.combat_dam = 5 + 3 = 8  （自動累加）
卸下木劍後：
  removeTemporaryValue("combat_dam", id)
  → self.combat_dam = 5           （精確移除，不影響其他加成）
```

引擎的 `addTemporaryValue` 實作在 `engine/Entity.lua`，支援：
- 數字型：直接加減
- 表格型：深度合併（用於複合加成）
- 函數型：每次存取時動態計算

---
