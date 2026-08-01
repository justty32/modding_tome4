**玩家角色**在地圖上的外觀是多張 PNG 疊加而成的，每層代表身體部位或裝備槽位。這套系統由兩端共同驅動：

- **Actor 端**：`actor.moddable_tile` → 指向種族圖片資料夾
- **Object 端**：`object.moddable_tile` → 指向資料夾內的特定圖層

### 2.1 基本路徑邏輯

Actor 的 `moddable_tile` 欄位是種族/性別子資料夾名稱：

```lua
-- 在種族 birth descriptor 中設定
moddable_tile = "human_#sex#"   -- #sex# 在執行時替換為 "male" 或 "female"
moddable_tile = "dwarf_#sex#"
moddable_tile = "myrace_#sex#"
```

執行時 `updateModdableTile()` 計算出基底路徑：
```
base = "player/" .. moddable_tile:gsub("#sex#", sex) .. "/"
      → "player/human_female/"
```

所有裝備圖層的 PNG 都在這個資料夾下：
```
data/gfx/shockbolt/player/human_female/base_01.png
data/gfx/shockbolt/player/human_female/right_hand_04_01.png
data/gfx/shockbolt/player/human_female/upper_body_25.png
...
```

---
