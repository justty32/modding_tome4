## 7. 定義 NPC（npcs/）

先建全域 NPC 庫，再於地區引用。

**全域庫 `data/general/npcs/kobold.lua`**：

```lua
-- game/modules/hellodungeon/data/general/npcs/kobold.lua

local Talents = require("engine.interface.ActorTalents")

-- 科博德基底（共用屬性）
newEntity{
    define_as = "BASE_NPC_KOBOLD",
    type = "humanoid", subtype = "kobold",
    display = "k", color = colors.WHITE,
    desc = _t[[醜陋的綠色小傢夥！]],

    -- AI：dumb_talented_simple，talent_in=3 平均 3 回合用一次技能
    ai = "dumb_talented_simple", ai_state = { talent_in = 3 },

    stats = { str=5, dex=5, con=5 },
    combat_armor = 0,
}

-- 科博德戰士（繼承基底）
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "kobold warrior", color = colors.GREEN,
    level_range = {1, 4},
    exp_worth = 1,
    rarity = 4,         -- 越高越少見
    max_life = resolvers.rngavg(5, 9),
    combat = { dam = 2 },
}

-- 重甲科博德（高層出現）
newEntity{ base = "BASE_NPC_KOBOLD",
    name = "armoured kobold", color = colors.AQUAMARINE,
    level_range = {5, 10},
    exp_worth = 1,
    rarity = 4,
    max_life = resolvers.rngavg(10, 12),
    combat_armor = 3,
    combat = { dam = 5 },
}
```

**地區引用 `data/zones/dungeon/npcs.lua`**：

```lua
-- game/modules/hellodungeon/data/zones/dungeon/npcs.lua

load("/data/general/npcs/kobold.lua")

-- 也可在此加入地區專屬 NPC
```

**NPC 屬性速查**：

| 屬性 | 說明 |
|------|------|
| `define_as` | 唯一識別符（大寫），用於 `base` 繼承和 `guardian` |
| `base` | 繼承基底（複製全部屬性後覆蓋）|
| `display` | 顯示字元 |
| `level_range` | 出現樓層等級範圍 |
| `rarity` | 稀有度（越高越少）|
| `exp_worth` | 擊殺經驗值係數 |
| `ai` | AI 類型（`"dumb_talented_simple"` 最常用）|
| `combat.dam` | 裸手近戰傷害 |
| `combat_armor` | 護甲值 |
| `max_life` | 最大生命值（可用 `resolvers.rngavg(min, max)`）|

---

## 8. 定義技能（talents.lua）

```lua
-- game/modules/hellodungeon/data/talents.lua

-- 技能類型（分組顯示）
newTalentType{
    type = "role/combat",
    name = "combat",
    description = "戰鬥技巧"
}

-- 踢擊：擊退目標
newTalent{
    name = "Kick",
    type = {"role/combat", 1},  -- 所屬組，第一個位置
    points = 1,                  -- 最多學習幾點
    cooldown = 6,                -- 冷卻回合數
    power = 2,                   -- 消耗能量

    action = function(self, t)
        local tg = {type="hit", range=self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not x or not y or not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        target:knockback(self.x, self.y, 2 + self:getDex())
        return true  -- 回傳 true 才消耗能量和觸發冷卻
    end,

    info = function(self, t)
        return ("踢開目標，將其擊退 %d 格。"):format(2 + self:getDex())
    end,
}

-- 酸液噴射：範圍傷害
newTalent{
    name = "Acid Spray",
    type = {"role/combat", 1},
    points = 1, cooldown = 6, power = 2, range = 6,

    action = function(self, t)
        local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
        local x, y = self:getTarget(tg)
        if not x or not y then return nil end

        self:project(tg, x, y, DamageType.ACID, 1 + self:getDex(), {type="acid"})
        return true
    end,

    info = function(self, t)
        return ("向目標噴射酸液，造成 %d 點酸液傷害。"):format(1 + self:getDex())
    end,
}
```

**技能定義速查**：

| 欄位 | 說明 |
|------|------|
| `type` | `{技能組名, 需求等級}` |
| `mode` | `"activated"`（主動/預設）、`"sustained"`（持續）、`"passive"`（被動）|
| `cooldown` | 冷卻回合數 |
| `power` | 消耗 Power |
| `range` | 使用距離 |
| `action(self, t)` | 執行邏輯（回傳 `true` 才消耗）|
| `info(self, t)` | 說明文字（可動態計算）|

**投射形狀（`tg.type`）**：

| 形狀 | 說明 |
|------|------|
| `"hit"` | 單一目標（近戰/遠程）|
| `"ball"` | 圓形範圍（需 `radius`）|
| `"beam"` | 直線穿透 |
| `"cone"` | 扇形（需 `cone_angle`）|
| `"bolt"` | 直線彈道（不穿透）|

---

## 9. 定義傷害類型（damage_types.lua）

```lua
-- game/modules/hellodungeon/data/damage_types.lua

-- 物理傷害
newDamageType{
    name = "physical", type = "PHYSICAL",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:takeHit(dam, src)
            game.logSeen(target, "%s takes %d physical damage!",
                target.name:capitalize(), dam)
        end
    end,
}

-- 酸液傷害
newDamageType{
    name = "acid", type = "ACID",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            target:takeHit(dam, src)
            game.logSeen(target, "%s is burned by acid for %d damage!",
                target.name:capitalize(), dam)
            -- 施加持續效果（燃燒）
            if not target:attr("acid_immune") then
                target:setEffect(target.EFF_ACIDBURN, 3, {power=dam/3, src=src})
            end
        end
    end,
}
```

---

## 10. 定義角色創建（birth/descriptors.lua）

`Birther` 是 TE4 的角色創建流程。定義描述符（職業/種族）供玩家選擇：

```lua
-- game/modules/hellodungeon/data/birth/descriptors.lua

-- 基礎描述符：所有角色共有屬性
newBirthDescriptor{
    type = "base",
    name = "base",
    desc = {},
    experience = 1.0,       -- 經驗值倍率

    -- 直接複製到玩家
    copy = {
        max_level = 10,
        lite = 4,           -- 照明範圍（格）
        max_life = 25,
    },
}

-- 職業：破壞者（近戰）
newBirthDescriptor{
    type = "role",
    name = "Destroyer",
    desc = {
        "以蠻力席捲一切！",
        "起始技能：踢擊",
    },
    talents = {
        [ActorTalents.T_KICK] = 1,
    },
    copy = {
        stats = {str=14, dex=8, con=12},
    },
}

-- 職業：酸液狂（法術）
newBirthDescriptor{
    type = "role",
    name = "Acid-maniac",
    desc = {
        "以酸液溶解一切！",
        "起始技能：酸液噴射",
    },
    talents = {
        [ActorTalents.T_ACID_SPRAY] = 1,
    },
    copy = {
        stats = {str=8, dex=14, con=10},
    },
}
```

**角色創建流程**：引擎自動生成選擇畫面，玩家依序從各 `type` 選一個描述符，最後合併所有 `copy` 和 `talents`。

在 `Game.lua` 中啟動 Birther：

```lua
-- 玩家依序選擇 "base" 和 "role"
Birther.new(nil, self.player, {"base", "role"}, function()
    -- 創建完成後回呼
    self:changeLevel(1, "dungeon")
end)
```
