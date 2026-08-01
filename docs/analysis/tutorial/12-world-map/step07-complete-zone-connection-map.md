```
wilderness（大地圖）
│
├─ TOWN_A_ENTRANCE（A）  ──>  town_a Zone (lev 1)
│                                  └─ TOWN_EXIT <  ──> wilderness
│
├─ TOWN_B_ENTRANCE（B）  ──>  town_b Zone (lev 1)
│                                  └─ TOWN_EXIT <  ──> wilderness
│
├─ CAMP_ENTRANCE（C）    ──>  camp Zone (lev 1)      [Tutorial 10]
│                                  └─ EXIT_TO_WORLD < ──> wilderness
│
├─ DUNGEON_FOREST（D）   ──>  dungeon_forest Zone
│                                  ├─ lev 1  >─────> lev 2
│                                  ├─ lev 2  >─────> lev 3
│                                  ├─ lev 3（Boss）
│                                  └─ lev 1  <（from lev 1）──> wilderness
│
└─ DUNGEON_FORTRESS（F） ──>  dungeon_fortress Zone
                                   └─ ...（同上結構）
```

---
