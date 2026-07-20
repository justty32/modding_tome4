### 9.1 目錄結構

```
mod/
├── data/
│   ├── birth/
│   │   └── races/
│   │       └── lizardman.lua           ← 種族 birth descriptor
│   ├── gfx/
│   │   └── shockbolt/
│   │       └── player/
│   │           ├── lizardman_male/
│   │           │   ├── base_shadow_01.png
│   │           │   ├── base_01.png
│   │           │   ├── base_02.png
│   │           │   ├── lower_body_01.png
│   │           │   ├── upper_body_01.png
│   │           │   ├── horn_01.png
│   │           │   └── special/
│   │           │       ├── right_venom_fang.png   ← 獨特劍主手
│   │           │       └── left_venom_fang.png    ← 獨特劍副手
│   │           └── human_female/
│   │               └── special/
│   │                   ├── right_venom_fang.png   ← 人類也要有
│   │                   └── left_venom_fang.png
│   └── general/
│       └── objects/
│           └── venom_fang.lua           ← 武器定義
```

### 9.2 武器定義

```lua
-- mod/data/general/objects/venom_fang.lua
newEntity{
    define_as = "VENOM_FANG",
    unique    = true,
    name      = "Venom Fang",
    type      = "weapon", subtype = "sword",
    slot      = "MAINHAND",
    material_level = 3,

    -- 庫存圖示（自動 auto_image = true 也可用）
    image = "object/artifact/venom_fang.png",

    -- 角色上的圖層
    -- 引擎初始化時會自動偵測 special/ 資料夾並設定此欄位
    -- 也可以手動明確設定：
    moddable_tile = "special/%s_venom_fang",

    combat = {
        dam = 30, range = 1.4,
        damtype = DamageType.NATURE,
    },
    -- 加上武器粒子效果（見教學 14）
    moddable_tile_particle = {"poison_weapon", {power=3}},
}
```

### 9.3 種族定義

```lua
-- mod/data/birth/races/lizardman.lua
newBirthDescriptor{
    type = "race",
    name = "Lizardman",
    desc = { "古老的蜥蜴人族裔，居於沼澤深處。" },
    descriptor_choices = {
        subrace = { Lizardman = "allow", __ALL__ = "disallow" },
    },
    copy = {
        type = "humanoid", subtype = "lizardman",
        faction = "enemies",
    },
}

newBirthDescriptor{
    type = "subrace",
    name = "Lizardman",
    desc = { "天生具有毒性與快速再生能力的爬蟲種族。" },
    inc_stats = { str=2, con=2, dex=1, mag=-2, wil=-1 },
    talents_types = { ["race/lizardman"]={true, 0} },
    copy = {
        moddable_tile      = "lizardman_#sex#",
        moddable_tile_base = "base_01.png",
        moddable_tile_horn = "horn_01",   -- 所有蜥蜴人都有角，固定圖層
        life_rating = 12,
        random_name_def = "lizardman_#sex#",
    },
    cosmetic_options = {
        skin = {
            {name="綠色鱗片", file="base_01"},
            {name="藍色鱗片", file="base_02"},
        },
    },
}
```

---
