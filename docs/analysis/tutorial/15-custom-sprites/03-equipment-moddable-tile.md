裝備物品有幾個 `moddable_tile` 相關欄位，控制它顯示在角色上的方式。

### 3.1 `moddable_tile`（主要圖層）

每種裝備類型的路徑格式不同：

| 裝備類型 | `moddable_tile` 格式 | `%s` 的值 |
|---------|---------------------|-----------|
| 武器（主手） | `"%s_hand_04_01"` | `"right"` |
| 武器（副手） | `"%s_hand_04_01"` | `"left"` |
| 盾牌 | `"%s_hand_10_01"` | `"right"` / `"left"` |
| 上身護甲 | `"upper_body_25"` | 無 %s |
| 下身護甲 | 透過 `moddable_tile2` | — |
| 披風 | `"cloak_%s_07"` | `"behind"` / `"shoulder"` / `"hood"` |
| 頭盔 | `"head_05"` | 無 %s |
| 手套 | `"hands_03"` | 無 %s |
| 靴子 | `"feet_04"` | 無 %s |

> **重點**：武器的 `%s` 代表「左手」或「右手」，因為同一物品可以裝備在主手（右）或副手（左）。

### 3.2 `moddable_tile2`（下身護甲圖層）

身體護甲（BODY slot）的第二圖層，用於渲染下半身：

```lua
-- 重型護甲同時設定上半身和下半身圖層
moddable_tile  = "upper_body_25"   -- 上半身
moddable_tile2 = "lower_body_16"   -- 下半身
```

### 3.3 `moddable_tile_back`（武器後層）

武器在「手背後」的圖層，渲染在手部圖層之前，用於讓武器柄看起來被握住：

```lua
moddable_tile_back = "special/%s_my_sword_back"
-- 檔案：player/human_female/special/right_my_sword_back.png
```

### 3.4 `moddable_tile_ornament`（裝飾圖層）

顯示在武器正面圖層之上的額外裝飾：

```lua
moddable_tile_ornament = "special/%s_my_sword_glow"
```

### 3.5 `moddable_tile_particle`（圖層粒子效果）

掛在武器圖層上的粒子效果：

```lua
moddable_tile_particle = {"fire_sword", {power=10}}
-- 等同於呼叫 Particles.new("fire_sword", 1, {power=10})
```

---
