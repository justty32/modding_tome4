---

## 5. `data/` 目錄

不直接 `require`，透過各系統 `loadDefinition`、`loadList` 載入。掛載後路徑為 `/data-<short_name>/`。

```
data/
├── birth/          ← Birther:loadDefinition()
├── talents/        ← ActorTalents:loadDefinition()
├── timed_effects.lua ← ActorTemporaryEffects:loadDefinition()
├── achievements/   ← WorldAchievements:loadDefinition()
├── zones/          ← Zone 實例化時讀取
└── npcs/           ← Entity:loadList()
```

---

## 6. 完整範例：新增職業「暗影刺客」

擴充「亡靈」陣營。

### 步驟一：目錄結構

```
game/addons/my-shadow/
├── init.lua
├── hooks/
│   └── load.lua
└── data/
    ├── birth/
    │   └── shadow.lua
    └── talents/
        └── shadow/
            ├── shadow.lua         ← 天賦類型定義
            └── stealth-arts.lua   ← 天賦定義
```

### 步驟二：`init.lua`

```lua
-- game/addons/my-shadow/init.lua

long_name  = "Shadow Assassin Class"
short_name = "my-shadow"
for_module = "tome"
version    = {1, 0, 0}
author     = { "你的名字", "" }
description = [[Adds the Shadow Assassin class.]]

hooks = true
data  = true
```

### 步驟三：`hooks/load.lua`

```lua
-- game/addons/my-shadow/hooks/load.lua

class:bindHook("ToME:load", function(self, data)
    local ActorTalents = require "engine.interface.ActorTalents"
    local Birther = require "engine.Birther"

    -- 先載入天賦類型，再載入天賦定義
    ActorTalents:loadDefinition("/data-my-shadow/talents/shadow/shadow.lua")
    ActorTalents:loadDefinition("/data-my-shadow/talents/shadow/stealth-arts.lua")

    -- 載入職業描述符
    Birther:loadDefinition("/data-my-shadow/birth/shadow.lua")
end)
```

### 步驟四：天賦類型定義

```lua
-- game/addons/my-shadow/data/talents/shadow/shadow.lua

newTalentType{
    type   = "shadow/stealth-arts",
    name   = "Stealth Arts",
    generic = false,
    description = "The art of moving unseen and striking from the shadows.",
}
```

### 步驟五：天賦定義

```lua
-- game/addons/my-shadow/data/talents/shadow/stealth-arts.lua

newTalent{
    name    = "Shadow Step",
    type    = {"shadow/stealth-arts", 1},
    require = { stat = { dex=16 }, },
    points  = 5,
    cooldown = 8,
    stamina = 15,
    range   = function(self, t) return math.floor(3 + t.getLevel(self, t)) end,
    tactical = { CLOSEIN = 2, ESCAPE = 1 },

    action = function(self, t)
        local tg = { type="hit", range=self:getTalentRange(t) }
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        local block_actor = function(_, bx, by)
            return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move")
        end
        local tx, ty = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
        if not tx then
            game.logPlayer(self, "沒有可落腳的空位！")
            return nil
        end
        self:move(tx, ty, true)

        game.logSeen(self, "%s 瞬間消失在陰影中！", self:getName():capitalize())
        return true
    end,

    info = function(self, t)
        return ([[即刻傳送至目標附近（最遠 %d 格）。
消耗 %d 體力，冷卻 %d 回合。]]):format(
            self:getTalentRange(t), t.stamina, t.cooldown)
    end,
}

newTalent{
    name    = "Backstab",
    type    = {"shadow/stealth-arts", 2},
    require = { stat = { dex=20, cun=16 }, },
    points  = 5,
    cooldown = 5,
    stamina = 20,

    getDamage = function(self, t)
        return self:combatTalentWeaponDamage(t, 1.2, 2.5)
    end,

    tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 1 } },

    action = function(self, t)
        local tg = { type="hit", range=1 }
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end

        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        local dam = t.getDamage(self, t)
        self:attackTarget(target, DamageType.PHYSICAL, dam, true)

        if target:canBe("stun") then
            target:setEffect(target.EFF_STUNNED, 2 + math.floor(t.getLevel(self, t)/2), {})
        end

        return true
    end,

    info = function(self, t)
        return ([[背刺鄰近目標，造成 %d%% 武器傷害，並暈眩 %d 回合。]]):format(
            t.getDamage(self, t) * 100,
            2 + math.floor(self:getTalentLevelRaw(t)/2))
    end,
}
```
