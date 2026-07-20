## 6. 資料定義

### 6.1 傷害類型 (`data/damage_types.lua`)

```lua
-- 設定預設投射器（處理未自訂的傷害類型）
setDefaultProjector(function(src, x, y, type, dam)
    local target = game.level.map(x, y, Map.ACTOR)
    if target then
        game.logSeen(target, "%s hits %s for #RED#%d %s#LAST# damage.",
            src.name:capitalize(), target.name, dam, DamageType:get(type).name)
        target:takeHit(dam, src)
    end
end)

-- 基礎傷害類型
newDamageType{ name = "physical", type = "PHYSICAL" }
newDamageType{ name = "fire",     type = "FIRE",  text_color = "#LIGHT_RED#" }
newDamageType{ name = "cold",     type = "COLD",  text_color = "#1133F3#" }
newDamageType{ name = "acid",     type = "ACID",  text_color = "#GREEN#" }

-- 帶自訂投射器的傷害類型（例：酸液燃燒 debuff）
newDamageType{
    name = "acidburn", type = "ACIDBURN",
    projector = function(src, x, y, type, dam)
        local target = game.level.map(x, y, Map.ACTOR)
        if target then
            -- 施加 ACIDBURN 效果，持續 3 回合
            target:setEffect(target.EFF_ACIDBURN, 3, {
                src = src,
                power = dam / 3,
            })
        end
    end,
}
```

### 6.2 技能 (`data/talents.lua`)

```lua
-- 定義技能類型（分類）
newTalentType{ type = "role/combat", name = "combat", description = "Combat techniques" }

newTalent{
    name = "Kick",
    type = {"role/combat", 1},  -- {類型, 最低等級}
    points = 1,                  -- 學習所需技能點
    cooldown = 6,                -- 冷卻回合數
    power = 2,                   -- 消耗的 power 資源
    range = 1,
    action = function(self, t)
        -- 選擇目標
        local tg = {type = "hit", range = self:getTalentRange(t)}
        local x, y, target = self:getTarget(tg)
        if not target then return nil end
        if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

        -- 擊退目標
        target:knockback(self.x, self.y, 2 + self:getDex())
        return true  -- 回傳 true 表示技能成功使用
    end,
    info = function(self, t)
        return "Kicks the target, knocking it back."
    end,
}
```

技能使用流程：
1. Actor 呼叫 `self:useTalent(T_KICK)`
2. 引擎呼叫 `self:preUseTalent(t)` 檢查資源/冷卻
3. 執行 `t.action(self, t)`
4. 引擎呼叫 `self:postUseTalent(t, ret)` 扣除資源、設冷卻

### 6.3 Buff/Debuff (`data/timed_effects.lua`)

```lua
newEffect{
    name = "ACIDBURN",
    desc = "Burning from acid",
    type = "physical",
    status = "detrimental",       -- "beneficial" 或 "detrimental"
    parameters = { power = 1 },   -- 預設參數
    on_gain = function(self, err) return "#Target# is covered in acid!", "+Acid" end,
    on_lose = function(self, err) return "#Target# is free from the acid.", "-Acid" end,
    on_timeout = function(self, eff)
        -- 每回合觸發：造成酸液傷害
        DamageType:get(DamageType.ACID).projector(
            eff.src or self, self.x, self.y, DamageType.ACID, eff.power)
    end,
}
```

施加效果：`target:setEffect(target.EFF_ACIDBURN, duration, {power=10, src=self})`

### 6.4 角色創建 (`data/birth/descriptors.lua`)

```lua
-- base 類型：所有角色共有的基礎屬性
newBirthDescriptor{
    type = "base",
    name = "base",
    experience = 1.0,
    copy = {
        -- 直接複製到角色屬性
        max_level = 10,
        lite = 4,
        max_life = 25,
        resolvers.equip{
            {type="weapon", subtype="longsword", name="iron longsword"},
        },
    },
}

-- role 類型：職業選擇
newBirthDescriptor{
    type = "role",
    name = "Destroyer",
    desc = { "A powerful warrior." },
    stats = { str = 3, con = 2 },
    talents = { [ActorTalents.T_KICK] = 1 },
    copy = {
        max_life = 50,
        power_regen = 0.5,
    },
}
```

Birther 依 `type` 分組，玩家逐層選擇（base → role → …），所有選擇的 `copy`、`stats`、`talents` 累加到角色上。

---

## 7. Zone 定義

### 7.1 zone.lua — 區域設定

```lua
-- data/zones/dungeon/zone.lua
return {
    name = "Old Ruins",
    level_range = {1, 1},     -- NPC 等級範圍
    max_level = 10,            -- 最大樓層數
    decay = {300, 800},        -- 離開後多久可清除（遊戲時間 tick）
    width = 50, height = 50,   -- 地圖尺寸
    persistent = "zone",       -- 持久化策略: "zone" | "level" | false

    generator = {
        map = {
            class = "engine.generator.map.Roomer",
            nb_rooms = 10,
            rooms = {"simple", "pilar"},  -- 對應 data/rooms/*.lua
            lite_room_chance = 100,
            ['.'] = "FLOOR",              -- 字元 → Grid define_as 映射
            ['#'] = "WALL",
            up = "UP",
            down = "DOWN",
            door = "DOOR",
        },
        actor = {
            class = "engine.generator.actor.Random",
            nb_npc = {20, 30},            -- 每層生成 NPC 數量
        },
        object = {
            class = "engine.generator.object.Random",
            nb_object = {3, 5},
        },
        trap = {
            class = "engine.generator.trap.Random",
            nb_trap = {6, 9},
        },
    },

    -- 逐層覆蓋設定
    levels = {
        [10] = {
            -- 最終層特殊設定
            generator = {
                map = {
                    class = "engine.generator.map.Static",
                    map = "zones/dungeon/boss_room",
                },
            },
        },
    },
}
```

### 7.2 資料載入檔

Zone 自動載入同目錄下的 `grids.lua`、`npcs.lua`、`objects.lua`、`traps.lua`：

```lua
-- data/zones/dungeon/grids.lua
load("/data/general/grids/basic.lua")  -- 載入全域共用地形
-- 可追加區域特有地形：
-- newEntity{ define_as = "LAVA", ... }

-- data/zones/dungeon/npcs.lua
load("/data/general/npcs/kobold.lua")  -- 載入 kobold 系列 NPC
```

### 7.3 房間模板 (`data/rooms/*.lua`)

房間模板回傳一個工廠函數，在地圖生成時被呼叫：

```lua
-- data/rooms/pilar.lua
return function(gen, id)
    local w = rng.range(7, 12)
    local h = rng.range(7, 12)
    return { name="pilar"..w.."x"..h, w=w, h=h,
        generator = function(self, x, y, is_lit)
            -- 生成房間外框（牆壁）
            for i = 1, self.w do for j = 1, self.h do
                if i == 1 or i == self.w or j == 1 or j == self.h then
                    gen.map.room_map[i-1+x][j-1+y].can_open = true
                    gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
                else
                    gen.map.room_map[i-1+x][j-1+y].room = id
                    gen.map(i-1+x, j-1+y, Map.TERRAIN, gen.grid_list[gen:resolve('.')])
                end
                if is_lit then gen.map.lites(i-1+x, j-1+y, true) end
            end end

            -- 放置四根柱子
            local pilars = {{1,1},{self.w-2,1},{1,self.h-2},{self.w-2,self.h-2}}
            for _, p in ipairs(pilars) do
                gen.map(p[1]+x, p[2]+y, Map.TERRAIN, gen.grid_list[gen:resolve('#')])
            end
        end
    }
end
```
