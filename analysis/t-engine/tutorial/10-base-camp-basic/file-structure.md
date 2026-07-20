```
mygame/
  mod/
    class/
      Grid.lua                          ← 覆寫 on_move，根據旗標分派行為
    data/
      grids/
        camp.lua                        ← 據點專用地形（篝火、出口、門…）
      npcs/
        camp_npcs.lua                   ← 工作台 NPC 定義
      chats/
        workbench.lua                   ← 工作台對話（含合成邏輯）
      zones/
        camp/
          zone.lua                      ← 據點 Zone 定義
      maps/
        camp.lua                        ← 靜態地圖（ASCII）
```

---
