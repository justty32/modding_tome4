### 5.1 Actor.lua — 角色基底

```lua
-- game/modules/mymod/class/Actor.lua
require "engine.class"
local Map = require "engine.Map"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorTemporaryEffects"
require "engine.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require "engine.interface.ActorResource"
require "engine.interface.ActorFOV"
require "mod.class.interface.Combat"

module(..., package.seeall, class.inherit(
    engine.Actor,
    engine.interface.ActorTemporaryEffects,
    engine.interface.ActorLife,
    engine.interface.ActorProject,
    engine.interface.ActorLevel,
    engine.interface.ActorStats,
    engine.interface.ActorTalents,
    engine.interface.ActorResource,
    engine.interface.ActorFOV,
    mod.class.interface.Combat
))

function _M:init(t, no_default)
    -- 設定預設值（在 engine.Actor.init 之前）
    t.max_life = t.max_life or 10
    t.max_stamina = t.max_stamina or 10

    engine.Actor.init(self, t, no_default)
    engine.interface.ActorTemporaryEffects.init(self, t, no_default)
    engine.interface.ActorLife.init(self, t, no_default)
    engine.interface.ActorProject.init(self, t, no_default)
    engine.interface.ActorLevel.init(self, t, no_default)
    engine.interface.ActorStats.init(self, t, no_default)
    engine.interface.ActorTalents.init(self, t, no_default)
    engine.interface.ActorResource.init(self, t, no_default)
    engine.interface.ActorFOV.init(self, t, no_default)
end

function _M:act()
    if not self:enoughEnergy() then return false end

    -- 每回合處理
    self:regenLife()
    self:regenResources()
    self:cooldownTalents()
    self:timedEffects()

    return true  -- 回傳 true 表示可以行動
end

function _M:move(x, y, force)
    local moved = engine.Actor.move(self, x, y, force)
    if not moved then return false end
    self:useEnergy()  -- 消耗行動點
    return true
end

function _M:tooltip()
    return ([[%s
#00ff00#Level: %d
#ff0000#HP: %d / %d]]):format(
        self.name, self.level or 1,
        self.life, self.max_life
    )
end
```

**重要模式**：
- `_M` 是 `module()` 建立的模組 table，即類別本身。
- 所有 mixin 的 `init` 必須在建構時呼叫。
- `act()` 回傳 `true` 表示角色有能力行動（energy 足夠）。

