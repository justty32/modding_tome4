### 三種附加粒子的方式

| 方式 | 使用時機 | API |
|------|---------|-----|
| **投射物拖尾** | `project`/`projectile` 的飛行過程 | `tg.display = {particle="name", trail="name"}` |
| **落點爆炸** | 命中格子後（`project` callback 或技能 `action`） | `game.level.map:particleEmitter(x, y, radius, "name", {args})` |
| **持續光環** | SUSTAINED 技能的 activate/deactivate | `self:addParticles(Particles.new("name", radius, args))` |

### 檔案：`mod/data/talents/ice.lua`

```lua
-- mod/data/talents/ice.lua
-- 冰系技能：展示三種粒子附加方式

local Particles = require "engine.Particles"

newTalentType{
    type        = "spell/ice",
    name        = "冰系魔法",
    description = "操控寒氣的冰系魔法。",
}

-- ─────────────────────────────────────────────────────────────
-- 技能一：冰錐術（方式 A：投射物拖尾 + 方式 B：落點爆炸）
-- ─────────────────────────────────────────────────────────────
newTalent{
    name    = "冰錐術",
    type    = {"spell/ice", 1},
    points  = 5,
    cooldown = 4,
    range   = 10,
    proj_speed    = 8,         -- 投射物飛行速度（越高越快）
    requires_target = true,
    reflectable   = true,      -- 可被反射牆彈回

    action = function(self, t)
        -- ★ 定義投射物目標（飛行時使用 ice_bolt 拖尾）
        local tg = {
            type  = "bolt",
            range = self:getTalentRange(t),
            talent = t,

            -- ── 方式 A：投射物飛行時的粒子 ──
            display = {
                -- particle：投射物頭部的粒子系統
                particle = "ice_bolt",
                -- trail：投射物拖尾（也用 ice_bolt，也可分開）
                -- 注意：trail 是附加在投射物每個路徑格的粒子
                trail    = "ice_bolt",
            },
        }

        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        -- 計算傷害：基礎 + 每技能等級遞增
        local dam = (15 + self:getTalentLevel(t) * 10)

        -- ★ 方式 B：project 完成後呼叫 callback 在落點爆炸
        self:project(tg, x, y, DamageType.COLD, dam, function(px, py)
            -- 在命中格爆發冰晶特效（radius = 0 代表單格爆炸）
            game.level.map:particleEmitter(
                px, py,
                0,            -- 半徑（0 = 只在命中格）
                "ice_explosion",
                {
                    radius = 0,   -- 傳給粒子 Lua 的 args
                    tx = px,      -- 命中格座標（部分特效需要）
                    ty = py,
                }
            )
        end)

        return true
    end,

    info = function(self, t)
        local dam = 15 + self:getTalentLevel(t) * 10
        return ("向目標發射一根冰錐，造成 %d 點寒冷傷害。"):format(dam)
    end,
}

-- ─────────────────────────────────────────────────────────────
-- 技能二：冰霜爆裂（方式 B：直接落點爆炸，無投射物）
-- ─────────────────────────────────────────────────────────────
newTalent{
    name    = "冰霜爆裂",
    type    = {"spell/ice", 2},
    points  = 5,
    cooldown = 8,
    range   = 8,
    requires_target = true,

    action = function(self, t)
        local tg = {
            type   = "ball",
            range  = self:getTalentRange(t),
            radius = 1 + math.floor(self:getTalentLevelRaw(t) / 2),
            talent = t,
            selffire = false,
        }

        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        -- 直接 project，不用投射物（瞬間施放）
        self:project(tg, x, y, DamageType.COLD,
            20 + self:getTalentLevel(t) * 8)

        -- ★ 落點爆炸特效（球形，半徑與技能範圍一致）
        game.level.map:particleEmitter(
            x, y,
            tg.radius,       -- radius 傳給粒子 Lua 的 sradius 計算
            "ice_explosion",
            {
                radius = tg.radius,
                tx = x,
                ty = y,
            }
        )
        return true
    end,

    info = function(self, t)
        local r = 1 + math.floor(self:getTalentLevelRaw(t) / 2)
        return ("在目標位置製造半徑 %d 格的冰霜爆炸。"):format(r)
    end,
}

-- ─────────────────────────────────────────────────────────────
-- 技能三：冰護盾（方式 C：SUSTAINED + 持續光環）
-- ─────────────────────────────────────────────────────────────
newTalent{
    name    = "冰護盾",
    type    = {"spell/ice", 3},
    points  = 5,
    mode    = "sustained",   -- ★ SUSTAINED：開啟/關閉切換型技能
    cooldown = 20,
    sustain_power = 10,      -- 維持成本（每回合消耗的能量/法力）

    activate = function(self, t)
        -- ★ 方式 C：開啟時在施法者身上附加粒子光環
        -- Particles.new(def, radius, args, shader)
        -- radius 影響 base_size 的縮放（1 = 正常大小）
        local particle = self:addParticles(
            Particles.new("ice_aura", 1, {})
        )

        -- 把粒子 handle 存在 eff（effect 狀態表）裡
        -- 以便 deactivate 時取消
        return {
            particle = particle,
            absorb   = 5 + self:getTalentLevel(t) * 3,  -- 防護值
        }
    end,

    deactivate = function(self, t, p)
        -- ★ 關閉時移除粒子光環
        self:removeParticles(p.particle)
        return true
    end,

    info = function(self, t)
        local absorb = 5 + self:getTalentLevel(t) * 3
        return ("持續消耗能量，形成冰護盾吸收 %d 點傷害。"):format(absorb)
    end,
}
```

> **`activate` 的返回值**：SUSTAINED 技能的 `activate` 必須 `return {...}` 一個狀態表（即使是空表 `{}`）——這個表就是 `p`（eff 狀態），會傳給 `deactivate` 和 `on_timeout`。如果 `return nil` 或沒有 return，技能會立刻被取消。

---
