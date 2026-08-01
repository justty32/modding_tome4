所有介面以 mixin 方式注入，Actor 子類別透過 `class.inherit(engine.Actor, interface.ActorTalents, ...)` 組合。

### 6.1 ActorTalents — 技能系統

**靜態定義（全局共用）**：
```lua
-- 定義技能類型（分類）
self:newTalentType{type="spell/fire", name="Fire Spells", points=1}

-- 定義技能
self:newTalent{
    name = "Fireball",
    type = {"spell/fire", 1},
    mode = "activated",   -- activated | sustained | passive
    cooldown = 10,
    use_power = {base=20, add=5, ...},
    action = function(self, t) ... end,
    info = function(self, t) return "Throws a fireball" end,
}
-- 自動生成 T_FIREBALL 常數
```

**實例資料**：
- `self.talents` — `{T_FIREBALL = 3}` 技能 ID → 等級。
- `self.talents_cd` — `{T_FIREBALL = 5}` 目前冷卻剩餘。
- `self.sustain_talents` — `{T_SHIELD = true}` 已開啟的持續技能。
- `self.talents_types` — 技能類型解鎖狀態。
- `self.talents_types_mastery` — 熟練度修正（影響效果縮放）。

**Resolver 整合**：`resolvers.talents{[T_FIREBALL]=2}` 在 resolve 時呼叫 `:learnTalent()`。

### 6.2 ActorTemporaryEffects — Buff/Debuff 系統

**靜態定義**：
```lua
self:newEffect{
    name = "BURNING",
    desc = "On fire",
    type = "magical",
    status = "detrimental",
    decrease = 1,   -- 每回合減少 duration
    activation = function(self, eff) self:setAttr("on_fire", 1) end,
    deactivation = function(self, eff) self:setAttr("on_fire", -1) end,
    on_timeout = function(self, eff) self:takeDamage(eff.power) end,
}
-- 自動生成 EFF_BURNING 常數
```

**實例**：
```lua
self.tmp = {EFF_BURNING = {dur=5, power=10, ...}}
```

每回合呼叫 `:timedEffects()` 倒數，到期呼叫 `deactivation`。

### 6.3 ActorStats — 屬性系統

- 靜態定義屬性（透過 `newStat`）：名稱、最大值、加法/乘法計算。
- `self:getStat("str")` → 考慮 buff/debuff 後的最終值。
- `self:addStat("str", 10)` → 暫時性加成（TemporaryEffects 或裝備使用）。

### 6.4 ActorFOV — 視野

```lua
actor:computeFOV(range, "block_sight", function(x, y, dx, dy, sqdist)
    -- 標記 seen / los
end)
```

- 呼叫 C 層 `core.fov.calc_*`（recursive shadowcasting）。
- `actor:hasLOS(x, y)` 快速查詢兩點間直線視野。
- `actor:lineFOV(x, y)` 取得 FOV 線迭代器（用於投射物路徑）。

### 6.5 ActorProject — 投射與傷害系統

```lua
self:project(
    {type="bolt", range=5, block_path=function(...)end},
    target_x, target_y,
    DamageType.FIRE,   -- 傷害類型
    100,               -- 傷害量
    particles           -- 粒子特效
)
```

`project` 內部流程：
1. 呼叫 `Target:getType(t)` 解析形狀（bolt/beam/ball/cone/…）。
2. 用 `lineFOV` 迭代器逐格推進，判斷 `block_path`。
3. 角落阻擋特例處理（避免死角無法被打到的問題）。
4. 對每個命中格呼叫 `DamageType.project(src, x, y, type, dam)`。
5. 若有 `create_projectile`，生成 Projectile 實體做飛行動畫後再傷害。

### 6.6 ActorInventory — 揹包系統

- `self.inven` — 多個 slot table（`INVEN_MAINHAND`, `INVEN_OFFHAND`, `INVEN_BODY`, …）。
- `self:addObject(inven_id, obj)` / `self:removeObject(inven_id, slot)`。
- `self:wearObject(obj)` — 裝備到適當位置，觸發 `on_wear/on_takeoff` callback。
- Weight/encumbrance、比較物品屬性、自動合併堆疊（stack）。

### 6.7 ActorLife — 生命值與死亡

- `self:takeHit(dam, src)` — 扣血入口，觸發 `on_takehit`、`on_die`。
- `self:die(src)` — 觸發死亡流程：掉落物品、移除陣列、成就判定。
- 分離出 `canBe("dead")` 等 attr 查詢，讓模組可自訂免死條件。

### 6.8 ActorAI — AI 系統

AI 是命名行為的組合：

```lua
-- 定義 AI
newAI("move_simple", function(self)
    if self.ai_target.actor then
        self:moveDirection(self.ai_target.actor.x, self.ai_target.actor.y)
    end
end)

-- 實體使用
npc.ai = "dumb_talented"    -- 主 AI
npc.ai_state = {talent_in=3}  -- AI 狀態參數
```

**內建 AI 行為**（`engine/ai/`）：
| AI 名稱 | 說明 |
|---------|------|
| `move_simple` | 直線朝目標移動 |
| `move_dmap` | 使用距離地圖（Dijkstra）尋路 |
| `flee_simple` | 遠離目標 |
| `target_simple` | 選定最近的敵對 Actor 為目標 |
| `dumb_talented` | 隨機使用可用技能 + move_simple |
| `talented` | 智慧技能選擇（`engine/ai/talented.lua`） |
| `special_movement.*` | 飛行、穿牆、游泳等特殊移動 |

`self:runAI(name, ...)` 呼叫對應的 `ai_def[name](self, ...)`，AI 可互相組合。

**AI 目標與記憶**：
- `self.ai_target.actor` — 當前目標。
- `self.ai_state.target_last_seen` — 最後看見目標的位置（失去 LOS 後仍往此移動）。
- `self.ai_actors_seen` — 曾看見過的所有 Actor（弱引用）。

---
