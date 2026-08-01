### 1.6 事件系統 (events/)

共 **34 個程序性世界事件**，隨機修改已生成的地圖。

#### 事件類型

**環境修改類**

| 事件檔 | 說明 |
|--------|------|
| `antimagic-bush.lua` | 反魔法荊棘（傷害魔法使用者）|
| `blighted-soil.lua` | 枯萎土地（腐化效果）|
| `pyroclast.lua` | 火山噴發（熔岩地形）|
| `meteor.lua` | 隕石（坑洞地形）|
| `thunderstorm.lua` | 雷暴（閃電環境效果）|
| `snowstorm.lua` | 雪暴（寒冷環境效果）|
| `drake-cave.lua` | 龍巢穴（特殊地形）|
| `damp-cave.lua` | 潮濕山洞 |

**稀有特殊事件**

| 事件檔 | 大小 | 說明 |
|--------|------|------|
| `cultists.lua` | 11KB | 邪教徒 NPC 群出現 |
| `fearscape-portal.lua` | 9.4KB | 恐懼界入口傳送門 |
| `naga-portal.lua` | 7.6KB | 奈迦界傳送門 |
| `rat-lich.lua` | 7KB | 鼠妖（特殊 Boss 遭遇）|
| `sub-vault.lua` | 6.2KB | 程序性寶庫變體 |
| `old-battle-field.lua` | 7.7KB | 古戰場殘跡（戰利品/危機）|
| `glowing-chest.lua` | 4KB | 發光寶箱（特殊獎勵）|
| `weird-pedestals.lua` | 5.7KB | 古代台座（謎題）|

#### 事件執行流程

```lua
-- 事件定義範例
newEvent{
    name = "meteor",
    rarity = 10,     -- 出現機率（越高越少見）
    -- 觸發條件
    filter = function(self, zone, level, spot)
        return zone.short_name ~= "underwater"
    end,
    -- 生成邏輯
    generate = function(self, zone, level, spot)
        local x, y = spot.x, spot.y
        -- 1. 找到地圖上的合適位置
        local gx, gy = game.state:findEventGrid(level, x, y, 8)
        if not gx then return end
        -- 2. 修改地形
        level.map(gx, gy, Map.TERRAIN, terrains.CRATER)
        -- 3. 添加視覺效果
        level.map:particleEmitter(gx, gy, 2, "smoke_cloud")
        -- 4. 設置互動回呼
        level.map(gx, gy, Map.TERRAIN).on_stand = function(self, x, y, who)
            who:takeHit(rng.avg(5, 10), nil, {type="physical"})
        end
    end,
}
```

#### 事件分組 (events/groups/)

每個地區類型使用一個事件組定義可能出現的事件：

| 分組檔 | 用途 |
|--------|------|
| `majeyal-generic.lua` | Maj'Eyal 地下城通用事件 |
| `fareast-generic.lua` | 遠東地下城通用事件 |
| `outdoor-majeyal-generic.lua` | Maj'Eyal 戶外通用事件 |
| `outdoor-majeyal-gloomy.lua` | Maj'Eyal 陰鬱戶外事件 |
| `outdoor-fareast-generic.lua` | 遠東戶外事件 |

分組中的事件有個別出現機率（如：weird-pedestals 10%出現率）。

---

