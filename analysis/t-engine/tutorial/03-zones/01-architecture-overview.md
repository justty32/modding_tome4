```
Game（全域）
 ├── game.zone   ← 當前 Zone 物件
 └── game.level  ← 當前 Level 物件（Zone 的一個樓層）
       └── game.level.map  ← 當前地圖

Zone（地區，如 "dungeon"、"town"）
 ├── short_name   ← 用於 changeLevel 的識別字串
 ├── max_level    ← 最多有幾個樓層
 └── [level 1], [level 2], ...  ← 每個樓層是一個 Level 物件

Level（樓層）
 ├── level        ← 樓層編號（1 = 第一層）
 ├── map          ← Map 物件（二維地形格陣列）
 ├── default_up   ← {x, y}：從下方進來時的出現點
 └── default_down ← {x, y}：從上方進來時的出現點
```

**地區切換流程**：

```
玩家踩上 change_level / change_zone 地形
  → Game:changeLevel(lev, zone_name)
       → zone:leaveLevel()         ← 儲存當前樓層狀態
       → Zone.new(zone_name)       ← 建立（或從快取讀取）新地區
       → zone:getLevel(lev)        ← 取得目標樓層（不存在就生成）
       → player:move(default_up/down)  ← 玩家移動到預設出現位置
       → level:addEntity(player)   ← 玩家加入新樓層
```

---
