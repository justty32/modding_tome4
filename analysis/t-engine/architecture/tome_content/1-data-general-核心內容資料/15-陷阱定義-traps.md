### 1.5 陷阱定義 (traps/)

共 **9 個陷阱類型檔案**。

#### 陷阱類型

| 檔案 | 陷阱類別 |
|------|---------|
| `alarm.lua` | 警報陷阱（召喚敵人）|
| `annoy.lua` | 騷擾陷阱（弱效果）|
| `complex.lua` | 複雜陷阱（多效果組合）|
| `elemental.lua` | 元素陷阱（火/冰/閃電/酸）|
| `natural_forest.lua` | 自然森林陷阱（荊棘/植物）|
| `teleport.lua` | 傳送陷阱（隨機/陷阱房間）|
| `temporal.lua` | 時間陷阱（減速/時間歸零）|
| `water.lua` | 水中陷阱 |
| `store.lua` | 商店陷阱（有代價的獎勵）|

#### 陷阱定義結構

```lua
newEntity{
    type = "trap", subtype = "elemental",
    name = _t"fire trap",
    display = '^', color = colors.RED,
    -- 偵測與拆除
    detect_power = 10,   -- 偵測難度
    disarm_power = 12,   -- 拆除難度
    -- 觸發效果
    triggered = function(self, x, y, who)
        game.level.map:particleEmitter(x, y, 1, "fire")
        who:takeHit(rng.avg(10, 25), self, {type="fire"})
        game.logSeen(who, "A fire trap activates!")
    end,
    -- 出現條件
    rarity = 10, level_range = {1, 30},
    -- 外觀
    disarmed = {define_as = "DISARMED_FIRE_TRAP"},
}
```

---

