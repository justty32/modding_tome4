### 7.1 資料夾結構

```
mod/data/gfx/shockbolt/player/
    lizardman_male/
        base_shadow_01.png   ← 必要：角色陰影剪影
        base_01.png          ← 必要：皮膚 01
        base_02.png          ← 選用：皮膚 02
        lower_body_01.png    ← 必要：預設下身內衣
        upper_body_01.png    ← 必要：預設上身內衣
        hair_01.png          ← 選用：頭髮
        head_01.png          ← 選用：支援頭盔 01
        hands_01.png         ← 選用：支援手套 01
        feet_01.png          ← 選用：支援靴子 01
        left_hand_04_01.png  ← 選用：支援單手劍（副手）
        right_hand_04_01.png ← 選用：支援單手劍（主手）
        cloak_behind_01.png  ← 選用：支援披風
        cloak_shoulder_01.png
        ...
    lizardman_female/
        [同上，但女性版本]
```

> **PNG 規格**：
> - 尺寸：64×64 像素（現代標準）
> - 格式：RGBA（需有透明通道）
> - 背景：完全透明（alpha = 0）
> - 所有圖層需使用相同畫布尺寸，像素對齊

### 7.2 最小可用貼圖集

只需 4 張 PNG，角色就能在地圖上顯示（無法顯示任何裝備）：

```
base_shadow_01.png  — 陰影（通常是橢圓形深色半透明底）
base_01.png         — 裸體身形 01
lower_body_01.png   — 預設下身內衣（防止裸體）
upper_body_01.png   — 預設上身內衣（防止裸體）
```

若要支援標準武器/護甲圖層，需新增對應的武器/護甲 PNG（以 `resolvers.moddable_tile` 所使用的檔案名稱為準）。

### 7.3 在 Birth Descriptor 中宣告種族

```lua
-- mod/data/birth/races/lizardman.lua
newBirthDescriptor{
    type = "race",
    name = "Lizardman",
    desc = { "蜥蜴人，爬蟲族裔，擅長潛行與毒術。" },
    descriptor_choices = {
        subrace = { Lizardman = "allow", __ALL__ = "disallow" },
    },
    moddable_attachement_spots = "race_lizardman",  -- 可選：自訂附著點
    copy = {
        type = "humanoid", subtype = "lizardman",
    },
}

newBirthDescriptor{
    type = "subrace",
    name = "Lizardman",
    desc = { "標準蜥蜴人。" },
    inc_stats = { str=2, con=2, dex=1, mag=-2 },
    copy = {
        moddable_tile      = "lizardman_#sex#",   -- 對應資料夾名稱
        moddable_tile_base = "base_01.png",       -- 預設皮膚
        -- 種族固有外觀（不受玩家更改）
        moddable_tile_horn = "horn_01",            -- 每個角色都有角
        life_rating        = 12,
    },
    cosmetic_options = {
        skin = {
            {name="綠色鱗片",  file="base_01"},
            {name="藍色鱗片",  file="base_02"},
            {name="黑色鱗片",  file="base_03"},
        },
        hairs = {   -- 蜥蜴人可以有羽冠，用 hair 槽位
            {name="無", file="hair_none"},
            {name="紅羽冠", file="hair_crest_red_01"},
        },
    },
}
```

### 7.4 角色建立時的流程

Birth 結束後，`newBirthDescriptor.copy` 中的欄位會複製到 Actor，然後：

1. 玩家在 birth 畫面選擇外觀（skin、hair 等）
2. 所選值存入 `actor.moddable_tile_base`、`actor.moddable_tile_hair` 等
3. 每次裝備/卸下裝備時呼叫 `actor:updateModdableTile()` 重建 `add_mos`

---
