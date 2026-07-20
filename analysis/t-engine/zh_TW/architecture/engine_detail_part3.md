## 6. Actor 介面混入 (interface/)

以下混入透過 `class.inherit(engine.Actor, interface.X, ...)` 組合到 Actor。

### ActorTalents — 技能系統

**靜態定義**（全局共用）：

```lua
self:newTalentType{type="spell/fire", name="Fire Spells"}
self:newTalent{
    name = "Fireball", type={"spell/fire",1}, mode="activated",
    cooldown=10, action=function(self, t) ... end,
}
-- 自動生成 T_FIREBALL 常數
```

**實例資料**

| 欄位 | 說明 |
|------|------|
| `talents` | `{T_FIREBALL=3}` 技能 ID → 等級 |
| `sustain_talents` | `{T_SHIELD=true}` 已開啟的持續技能 |
| `talents_cd` | `{T_FIREBALL=5}` 冷卻剩餘 |
| `talents_types` | 技能類型解鎖狀態 |
| `talents_types_mastery` | 熟練度修正 |

**技能模式**：`"activated"`（一次性）、`"sustained"`（開關）、`"passive"`（常駐，呼叫 `passives()` 套用臨時值）

**執行流程**：`useTalent()` → `preUseTalent()` 檢查 → 協程執行 `action()` → `postUseTalent()` 扣資源/設冷卻

---

### ActorStats — 屬性系統

```lua
ActorStats:defineStat("Strength", "str", 10, 1, 100, "Physical power")
-- 自動生成 getStr()、incStat("str", v) 等方法
```

| 方法 | 說明 |
|------|------|
| `getStat(stat, scale, raw)` | 取得最終值（含加成） |
| `incStat(stat, val)` | 增減基礎值 |
| `incIncStat(stat, val)` | 增減臨時加成（裝備/效果）|
| `onStatChange(stat, v)` | 屬性變更 hook（子類別覆寫） |

---

### ActorLife — 生命值與死亡

| 方法 | 說明 |
|------|------|
| `regenLife()` | 每回合生命回復（從 `act()` 呼叫） |
| `heal(value, src)` | 治療 |
| `takeHit(value, src, death_note)` | 受傷；HP ≤ 0 觸發死亡 |
| `die(src, death_note)` | 死亡流程：掉落、移除、成就判定 |
| `attack(target, x, y)` | 基礎攻擊（子類別覆寫） |

- `die_at`：死亡 HP 閾值（通常為 0，可自訂）
- `onHeal()` / `onTakeHit()` hook 可修改治療/傷害值

---

### ActorFOV — 視野計算

```lua
actor:computeFOV(range, "block_sight", function(x, y, dx, dy, sqdist)
    game.level.map:apply(x, y)
end)
```

| 方法 | 說明 |
|------|------|
| `computeFOV(radius, block, apply, ...)` | 計算圓形 FOV（呼叫 C 層 `core.fov.*`） |
| `computeFOVBeam(radius, dir, angle, ...)` | 方向性 FOV 扇形 |
| `hasLOS(x, y)` | 快速查詢兩點間直線視野 |
| `lineFOV(x, y)` | FOV 線迭代器（投射物路徑用）|
| `distanceMap(x, y, v)` | 取得/設定距離地圖值 |

- `fov.actors`：弱引用，目前 FOV 內的角色
- `fov.actors_dist`：依距離排序的角色列表
- FOV 快取：避免同回合重複計算

---

### ActorProject — 投射與傷害系統

```lua
self:project(
    {type="bolt", range=5, block_path=function(...)end},
    tx, ty, DamageType.FIRE, 100, particles
)
```

**目標形狀**：`bolt`、`beam`（貫穿）、`ball`（AOE）、`cone`（扇形）、`hit`（直接命中）、`triangle`、`wall`、`widebeam`

**執行流程**：
1. `Target:getType(t)` 解析形狀
2. `lineFOV` 迭代器逐格推進，判斷 `block_path`
3. 角落阻擋特例處理
4. 對每個命中格呼叫 `DamageType.project(src, x, y, type, dam)`
5. 若有 `create_projectile`，生成飛行實體再傷害

---

### ActorAI — AI 系統

| 方法 | 說明 |
|------|------|
| `doAI()` | 每回合 AI 入口 |
| `runAI(ai, ...)` | 執行指定 AI 行為 |
| `moveDirection(x, y, force)` | 向目標移動一步（含繞路） |
| `setTarget(target, last_seen)` | 設定目標（觸發 hook） |
| `getTarget(typ)` | 取得目標座標與 Actor |
| `aiCanPass(x, y)` | 檢查是否可通過（含敵意判斷） |
| `aiSeeTargetPos(target, add_spread)` | 取得目標位置（含誤差） |
| `aiGetAvailableTalents(...)` | 取得可用技能列表 |

**實例資料**
- `ai`：當前 AI 名稱
- `ai_state`：跨回合持久 AI 狀態
- `ai_target`：`{actor, last_seen}` 目標追蹤
- `ai_actors_seen`：弱引用，曾見過的所有角色
- `AI_LOCATION_GUESS_ERROR = 3`：目標位置猜測誤差半徑

**設計細節**：AI 對目標位置施加誤差（含慣性平滑），避免完美資訊；支援特殊移動（穿牆等）增加誤差擴散。

---

### ActorTemporaryEffects — Buff/Debuff 系統

```lua
self:newEffect{
    name = "BURNING", desc = "On fire", type = "magical",
    activation = function(self, eff) ... end,
    deactivation = function(self, eff) ... end,
    on_timeout = function(self, eff) self:takeDamage(eff.power) end,
}
-- 自動生成 EFF_BURNING 常數
```

| 方法 | 說明 |
|------|------|
| `setEffect(eff_id, dur, p, silent)` | 施加/刷新效果 |
| `removeEffect(eff, silent, force)` | 移除效果 |
| `hasEffect(eff_id)` | 是否有此效果 |
| `timedEffects(filter)` | 每回合倒數，到期呼叫 `deactivation`（從 `act()` 呼叫）|
| `effectTemporaryValue(eff, k, v)` | 效果結束時自動清除的臨時值 |
| `effectParticles(eff, ...)` | 效果結束時自動清除的粒子 |

- `tmp`：`{EFF_BURNING = {dur=5, power=10, ...}}` 活躍效果表
- 支援 `on_merge` callback：效果重疊時合併（如延長持續時間）

---

### ActorInventory — 揹包系統

| 方法 | 說明 |
|------|------|
| `addObject(inven_id, o)` / `removeObject(inven_id, item)` | 物品增刪 |
| `wearObject(o, replace, vocal)` | 裝備物品（觸發 `on_wear`）|
| `takeoffObject(inven_id, item)` | 卸下裝備（觸發 `on_takeoff`）|
| `canWearObject(o, try_slot)` | 檢查裝備需求（屬性/等級/技能）|
| `sortInven(inven)` | 排序 + 堆疊整理 |
| `pickupFloor(i, vocal)` | 撿起地板物品 |
| `dropFloor(inven, item, vocal)` | 丟棄物品 |

- `inven`：多個 slot table（`INVEN_MAINHAND`, `INVEN_BODY`, …）
- 裝備的 `carried`/`wielded` 屬性透過臨時值系統自動套用/撤銷
- 排序順序：type > subtype > name > quantity

---

### ActorLevel — 等級與經驗

| 方法 | 說明 |
|------|------|
| `gainExp(value)` | 獲得經驗（達到閾值觸發升級）|
| `levelup()` | 升級流程（使用 `_levelup_info` table）|
| `forceLevelup(lev)` | 強制升到指定等級 |
| `worthExp(target)` | 計算此角色的經驗值 |

- `exp_chart`：函數或 table，決定每級所需 XP
- `_levelup_info`：定義升級時的屬性/技能進程（kchain/k/inc/max/every）

---

### ActorResource — 資源系統

```lua
ActorResource:defineResource("Mana", "mana", nil, "mana_regen", "...")
-- 自動生成 getMana(), incMana(), getMaxMana() 等
```

- `regenResources()`：每回合回復（從 `act()` 呼叫）
- `recomputeRegenResources()`：動態編譯快速回復函數
- `useResources(costs, check)`：消耗資源（check=true 僅驗證不扣除）
- 支援反向值系統（如用盡才滿）、持續技能抑制回復
