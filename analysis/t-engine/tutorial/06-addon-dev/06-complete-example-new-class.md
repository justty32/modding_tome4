以下製作一個叫做「暗影刺客」（Shadow Assassin）的新職業，擴充現有的「亡靈」陣營。

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

    -- 載入天賦類型（必須先於天賦定義）
    ActorTalents:loadDefinition("/data-my-shadow/talents/shadow/shadow.lua")
    -- 載入具體天賦
    ActorTalents:loadDefinition("/data-my-shadow/talents/shadow/stealth-arts.lua")

    -- 載入職業描述符（newBirthDescriptor）
    Birther:loadDefinition("/data-my-shadow/birth/shadow.lua")
end)
```

### 步驟四：天賦類型定義

```lua
-- game/addons/my-shadow/data/talents/shadow/shadow.lua

-- 宣告天賦類型分組
newTalentType{
    type   = "shadow/stealth-arts",
    name   = "Stealth Arts",
    -- 這個類型是否預設可見
    generic = false,
    description = "The art of moving unseen and striking from the shadows.",
}
```

### 步驟五：天賦定義

```lua
-- game/addons/my-shadow/data/talents/shadow/stealth-arts.lua

newTalent{
    name    = "Shadow Step",
    type    = {"shadow/stealth-arts", 1},  -- 類型 / 最低精通需求
    require = { stat = { dex=16 }, },
    points  = 5,     -- 最大等級
    cooldown = 8,
    stamina = 15,
    range   = function(self, t) return math.floor(3 + t.getLevel(self, t)) end,
    -- 讓 AI 知道這個技能的用途
    tactical = { CLOSEIN = 2, ESCAPE = 1 },

    action = function(self, t)
        -- 選取目標位置
        local tg = { type="hit", range=self:getTalentRange(t) }
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        -- 瞬移到目標旁邊
        local block_actor = function(_, bx, by)
            return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move")
        end
        local tx, ty = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
        if not tx then
            game.logPlayer(self, "没有可落腳的空位！")
            return nil
        end
        self:move(tx, ty, true)

        game.logSeen(self, "%s 瞬間消失在陰影中！", self:getName():capitalize())
        return true
    end,

    info = function(self, t)
        return ([[即刻傳送至目標附近（最遠 %d 格）。
消耗 %d 體力，冷卻 %d 回合。]]):format(
            self:getTalentRange(t),
            t.stamina,
            t.cooldown
        )
    end,
}

newTalent{
    name    = "Backstab",
    type    = {"shadow/stealth-arts", 2},
    require = { stat = { dex=20, cun=16 }, },
    points  = 5,
    cooldown = 5,
    stamina = 20,

    -- 傷害隨等級成長的輔助函式
    getDamage = function(self, t)
        return self:combatTalentWeaponDamage(t, 1.2, 2.5)
    end,

    tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 1 } },

    action = function(self, t)
        local tg = { type="hit", range=1 }
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end

        -- 必須相鄰
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        -- 攻擊
        local dam = t.getDamage(self, t)
        self:attackTarget(target, DamageType.PHYSICAL, dam, true)

        -- 暈眩
        if target:canBe("stun") then
            target:setEffect(target.EFF_STUNNED, 2 + math.floor(t.getLevel(self, t)/2), {})
        end

        return true
    end,

    info = function(self, t)
        return ([[背刺鄰近目標，造成 %d%% 武器傷害，並暈眩 %d 回合。]]):format(
            t.getDamage(self, t) * 100,
            2 + math.floor(self:getTalentLevelRaw(t)/2)
        )
    end,
}
```

### 步驟六：職業描述符

```lua
-- game/addons/my-shadow/data/birth/shadow.lua

-- 允許「亡靈」陣營選擇此職業
-- （如果不想限制，可以不寫這行，預設所有陣營可選）
getBirthDescriptor("class", "Rogue").descriptor_choices.subclass["Shadow Assassin"] = "allow"

newBirthDescriptor{
    type = "subclass",
    name = "Shadow Assassin",

    desc = {
        "暗影刺客是潛行與瞬殺的大師，他們在黑暗中穿梭，在目標察覺之前便已結束戰鬥。",
        "他們的核心屬性是：靈巧（Dexterity）與狡黠（Cunning）",
        "#GOLD#屬性加成：",
        "#LIGHT_BLUE# * +2 敏捷、+3 靈巧、+2 狡黠、-1 體質",
        "#GOLD#每級生命：#LIGHT_BLUE# -3",
    },

    -- 可選的陣營限制（"allow" | "disallow" | "never"）
    -- 這裡不設限，讓所有陣營都能選
    -- descriptor_choices = { ... },

    power_source = {technique=true, antimagic=false},

    stats = { str=0, dex=2, con=-1, mag=0, wil=0, cun=3 },

    -- 可學的天賦類型與初始精通
    talents_types = {
        -- {true/false=是否預設解鎖, 0.3=精通加成}
        ["shadow/stealth-arts"] = {true,  0.3},
        ["technique/combat-training"] = {true,  0},
        ["cunning/survival"]    = {true,  0},
        ["cunning/stealth"]     = {true,  0.3},
    },

    -- 出生時學會的天賦
    talents = {
        [ActorTalents.T_SHADOW_STEP] = 1,
        [ActorTalents.T_WEAPON_COMBAT] = 1,
        [ActorTalents.T_STEALTH] = 1,
    },

    -- 出生時的屬性直接修改
    copy = {
        max_life = 90,
        -- 裝備
        resolvers.equipbirth{ id=true,
            {type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
            {type="armor",  subtype="light",  name="rough leather armour", autoreq=true, ego_chance=-1000},
        },
    },

    copy_add = {
        life_rating = -3,
    },
}
```

---
