```
mygame/
  mod/
    class/
      Game.lua                      ← 修改 newGame() 起始於大地圖
    data/
      grids/
        wilderness.lua              ← 大地圖地形（草地、森林、山、水、路、地點標記）
      zones/
        wilderness/
          zone.lua                  ← 大地圖 Zone 定義
        town_a/
          zone.lua                  ← 起點村莊 Zone
        town_b/
          zone.lua                  ← 海邊港口 Zone
        dungeon_forest/
          zone.lua                  ← 森林地牢 Zone
        dungeon_fortress/
          zone.lua                  ← 山區要塞 Zone
      maps/
        wilderness.lua              ← 大地圖靜態 ASCII（50×30）
        town_a.lua                  ← 起點村莊靜態地圖
```

---
