`data/` 下的檔案不被直接 `require`，而是透過各系統的 `loadDefinition`、`loadList` 等函式載入。在掛載後，路徑是 `/data-<short_name>/`。

```
data/
├── birth/          ← Birther:loadDefinition() 使用
├── talents/        ← ActorTalents:loadDefinition() 使用
├── timed_effects.lua ← ActorTemporaryEffects:loadDefinition() 使用
├── achievements/   ← WorldAchievements:loadDefinition() 使用
├── zones/          ← Zone 實例化時讀取
└── npcs/           ← Entity:loadList() 使用
```

---
