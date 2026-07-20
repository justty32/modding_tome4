# 教學 15：自訂武器、裝備與種族貼圖

TE4 圖形渲染分兩個獨立系統：
1. **`image` 欄位** — 庫存圖示及簡單 NPC 顯示
2. **`moddable_tile` 合成系統** — 玩家角色多層圖像疊加（武器顯示在身上、護甲、頭盔等）

---

## 一、`image` 欄位（簡單圖示）

任何 Entity 可設 `image`，地圖與庫存畫面的圖示：

```lua
newEntity{
    name="Iron Sword", type="weapon", subtype="sword",
    slot="MAINHAND",
    image="object/sword/iron_sword.png",  -- 相對 /data/gfx/
}
```

`auto_image = true` 時引擎根據名稱自動產生路徑："Iron Sword" → `"object/ironsword.png"`；unique 則查 `"object/artifact/ironsword.png"`。

NPC 與非玩家 Actor 的地圖圖示也用 `image`，不需 `moddable_tile`。

---

## 二、`moddable_tile` 合成系統

**玩家角色**外觀為多張 PNG 疊加，每層代表身體部位或裝備槽位：

- **Actor 端**：`actor.moddable_tile` → 種族圖片資料夾
- **Object 端**：`object.moddable_tile` → 資料夾內特定圖層

### 2.1 基本路徑

```lua
-- 在種族 birth descriptor 中設定
moddable_tile = "human_#sex#"   -- #sex# 替換為 "male"/"female"
```

執行時計算基底路徑：
```
base = "player/" .. moddable_tile:gsub("#sex#", sex) .. "/"
     → "player/human_female/"
```

所有圖層 PNG 在此資料夾下：
```
data/gfx/shockbolt/player/human_female/base_01.png
data/gfx/shockbolt/player/human_female/right_hand_04_01.png
data/gfx/shockbolt/player/human_female/upper_body_25.png
...
```

---

## 三、裝備的 `moddable_tile`

### 3.1 `moddable_tile`（主要圖層）

| 裝備類型 | 格式 | `%s` 值 |
|---------|------|---------|
| 武器（主/副手） | `"%s_hand_04_01"` | `"right"` / `"left"` |
| 盾牌 | `"%s_hand_10_01"` | `"right"` / `"left"` |
| 上身護甲 | `"upper_body_25"` | 無 |
| 披風 | `"cloak_%s_07"` | `"behind"` / `"shoulder"` / `"hood"` |
| 頭盔 | `"head_05"` | 無 |
| 手套 | `"hands_03"` | 無 |
| 靴子 | `"feet_04"` | 無 |

### 3.2 `moddable_tile2`（下身護甲）

BODY slot 的第二圖層：
```lua
moddable_tile  = "upper_body_25"   -- 上半身
moddable_tile2 = "lower_body_16"   -- 下半身
```

### 3.3 `moddable_tile_back`（武器後層）

渲染在手部之前，讓武器柄看起來被握住：
```lua
moddable_tile_back = "special/%s_my_sword_back"
```

### 3.4 `moddable_tile_ornament`（裝飾圖層）

武器正面圖層之上的額外裝飾：
```lua
moddable_tile_ornament = "special/%s_my_sword_glow"
```

### 3.5 `moddable_tile_particle`（圖層粒子）

```lua
moddable_tile_particle = {"fire_sword", {power=10}}
-- 等同 Particles.new("fire_sword", 1, {power=10})
```

---

## 四、`resolvers.moddable_tile`（批量裝備）

普通裝備據品質等級（`material_level` 1–5）隨機選取圖層：

```lua
moddable_tile = resolvers.moddable_tile("sword"),
-- material_level 1 → "%s_hand_04_01"
-- material_level 3 → "%s_hand_04_03"
-- material_level 5 → "%s_hand_04_05"
```

支援的 slot：`"sword"`, `"2hsword"`, `"dagger"`, `"axe"`, `"2haxe"`, `"mace"`, `"2hmace"`, `"bow"`, `"sling"`, `"staff"`, `"trident"`, `"whip"`, `"shield"`, `"mindstar"`, `"massive"`, `"heavy"`, `"light"`, `"robe"`, `"helm"`, `"wizard_hat"`, `"leather_cap"`, `"gauntlets"`, `"gloves"`, `"leather_boots"`, `"heavy_boots"`, `"cloak"`, `"quiver"`, `"shotbag"`, `"gembag"`。

---（續 part2）---