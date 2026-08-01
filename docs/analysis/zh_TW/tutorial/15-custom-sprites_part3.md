# 教學 15：自訂武器、裝備與種族貼圖（續）

## 九、完整範例：獨特劍 + 新種族

### 9.1 目錄結構

```
mod/
  data/birth/races/lizardman.lua   ← 種族 descriptor
  data/gfx/shockbolt/player/
    lizardman_male/
      base_shadow_01.png / base_01.png / base_02.png
      lower_body_01.png / upper_body_01.png / horn_01.png
      special/
        right_venom_fang.png   ← 獨特劍主手
        left_venom_fang.png    ← 獨特劍副手
    human_female/special/
      right_venom_fang.png     ← 人類也要有
      left_venom_fang.png
  data/general/objects/venom_fang.lua
```

### 9.2 武器定義

```lua
-- mod/data/general/objects/venom_fang.lua
newEntity{
    define_as="VENOM_FANG", unique=true,
    name="Venom Fang", type="weapon", subtype="sword", slot="MAINHAND",
    material_level=3,
    image="object/artifact/venom_fang.png",
    moddable_tile="special/%s_venom_fang",
    combat={dam=30, range=1.4, damtype=DamageType.NATURE},
    moddable_tile_particle={"poison_weapon", {power=3}},
}
```

### 9.3 種族定義

```lua
-- mod/data/birth/races/lizardman.lua
newBirthDescriptor{
    type="race", name="Lizardman",
    desc={"古老的蜥蜴人族裔，居於沼澤深處。"},
    descriptor_choices={subrace={Lizardman="allow", __ALL__="disallow"}},
    copy={type="humanoid", subtype="lizardman", faction="enemies"},
}
newBirthDescriptor{
    type="subrace", name="Lizardman",
    desc={"天生具有毒性與快速再生能力的爬蟲種族。"},
    inc_stats={str=2, con=2, dex=1, mag=-2, wil=-1},
    talents_types={["race/lizardman"]={true, 0}},
    copy={
        moddable_tile="lizardman_#sex#",
        moddable_tile_base="base_01.png",
        moddable_tile_horn="horn_01",
        life_rating=12,
        random_name_def="lizardman_#sex#",
    },
    cosmetic_options={
        skin={
            {name="綠色鱗片", file="base_01"},
            {name="藍色鱗片", file="base_02"},
        },
    },
}
```

---

## 十、常見問題

| 現象 | 原因 | 解法 |
|------|------|------|
| 裝備不顯示 | 對應種族資料夾缺少 PNG | 為每個 `moddable_tile` 種族都新增同名 PNG |
| 角色不顯示 | 缺少 `base_shadow_01.png` 或 `base_01.png` | 確認最小必要圖層存在 |
| 武器方向顛倒 | `%s` 格式化寫錯 | 主手 `right`，副手 `left` |
| 護甲只顯示上半身 | 缺少 `moddable_tile2` | 設定 `moddable_tile2` 或提供 `lower_body_01.png` |
| 獨特武器不顯示 | `special/` 路徑不存在 | 確認每個種族的 `special/` 下有對應 PNG |

---

## 總結

- **`image`** — 庫存圖示與簡單實體顯示
- **`moddable_tile`（Actor）** → 種族圖片資料夾，如 `"lizardman_#sex#"`
- **`moddable_tile`（Object）** → 裝備圖層名稱，武器用 `%s` 代表左/右手
- **`resolvers.moddable_tile("sword")`** → 按品質等級選預設劍圖層
- **圖層順序**：陰影 → 尾巴 → 披風後擺 → 光環 → 身體 → 刺青 → 武器後層 → 靴子 → 下身 → 上身 → 披風肩 → 頭髮 → 臉部 → 頭盔 → 角 → 手套 → 箭袋 → 武器前層
- **最小種族貼圖**：`base_shadow_01.png`、`base_01.png`、`lower_body_01.png`、`upper_body_01.png`
- **獨特裝備**：每個種族 `special/` 子目錄都需要對應 PNG