# 教學 15：自訂武器、裝備與種族貼圖（續）

## 五、獨特裝備自訂貼圖

```lua
newEntity{
    define_as = "DRAGON_SWORD", unique=true,
    name="Dragon Sword", type="weapon", subtype="sword", slot="MAINHAND",
    image="object/artifact/dragon_sword.png",  -- 庫存圖示
    moddable_tile = "special/%s_dragon_sword",
    -- 每個種族性別組合都要有對應檔案：
    -- player/human_female/special/right_dragon_sword.png
    -- player/human_male/special/right_dragon_sword.png
    -- player/dwarf_female/special/right_dragon_sword.png ...
}
```

> `special/` 位於每個種族資料夾內。引擎在 `Object:init` 時自動偵測 `special/` 圖層是否存在並啟用。

---

## 六、圖層疊加順序

`updateModdableTile()` 依序建立 `add_mos` 列表（由下而上）：

```
[image]          ← 陰影底圖 base_shadow_01.png（不在 add_mos 中）
add_mos[1]   ← 尾巴
add_mos[2]   ← 背後飾物
add_mos[3]   ← 披風後擺
add_mos[4]   ← Shader 光環
add_mos[5]   ← 身體基底 base_01.png
              Hook: updateModdableTile:skin
add_mos[6]   ← 刺青
add_mos[7]   ← 主手武器後層（right）
add_mos[8]   ← 副手武器後層（left）
add_mos[9]   ← 靴子
add_mos[10]  ← 下身護甲/內衣
add_mos[11]  ← 上身護甲/內衣
add_mos[12]  ← 披風肩部
add_mos[13]  ← 披風兜帽
add_mos[14]  ← 頭髮
add_mos[15]  ← 面部特徵
add_mos[16]  ← 頭盔
              Hook: updateModdableTile:middle
add_mos[17]  ← 角/冠
add_mos[18]  ← 手套
add_mos[19]  ← 箭袋
add_mos[20]  ← 主手武器正面（right）+ ornament
add_mos[21]  ← 副手武器正面（left）+ ornament
              Hook: updateModdableTile:front
```

---

## 七、自訂種族貼圖

### 7.1 資料夾結構

```
mod/data/gfx/shockbolt/player/
    lizardman_male/
        base_shadow_01.png   ← 必要：陰影
        base_01.png          ← 必要：皮膚 01
        base_02.png          ← 選用：皮膚 02
        lower_body_01.png    ← 必要：下身內衣
        upper_body_01.png    ← 必要：上身內衣
        hair_01.png          ← 選用
        head_01.png          ← 選用
        hands_01.png         ← 選用
        feet_01.png          ← 選用
        left_hand_04_01.png  ← 選用
        right_hand_04_01.png ← 選用
        cloak_behind_01.png  ← 選用
        ...
    lizardman_female/       [同上，女性版本]
```

> PNG 規格：64×64 像素、RGBA 透明、背景完全透明、所有圖層同畫布尺寸像素對齊。

### 7.2 最小可用貼圖集

只需 4 張 PNG 即可在地圖上顯示（無法顯示裝備）：
```
base_shadow_01.png  — 陰影
base_01.png         — 裸體身形
lower_body_01.png   — 下身內衣
upper_body_01.png   — 上身內衣
```

### 7.3 Birth Descriptor

```lua
newBirthDescriptor{
    type="race", name="Lizardman",
    desc={"蜥蜴人，爬蟲族裔，擅長潛行與毒術。"},
    descriptor_choices={subrace={Lizardman="allow", __ALL__="disallow"}},
    moddable_attachement_spots="race_lizardman",
    copy={type="humanoid", subtype="lizardman"},
}
newBirthDescriptor{
    type="subrace", name="Lizardman",
    desc={"標準蜥蜴人。"},
    inc_stats={str=2, con=2, dex=1, mag=-2},
    copy={
        moddable_tile="lizardman_#sex#",
        moddable_tile_base="base_01.png",
        moddable_tile_horn="horn_01",  -- 種族固有外觀
        life_rating=12,
    },
    cosmetic_options={
        skin={
            {name="綠色鱗片", file="base_01"},
            {name="藍色鱗片", file="base_02"},
        },
        hairs={
            {name="無", file="hair_none"},
            {name="紅羽冠", file="hair_crest_red_01"},
        },
    },
}
```

Birth 結束後 `copy` 欄位複製到 Actor，玩家選外觀後 `updateModdableTile()` 重建 `add_mos`。

---

## 八、`add_mos` 直接使用（NPC）

```lua
newEntity{
    define_as="BOSS_DRAGON", name="Dragon Boss",
    image="npc/dragon/dragon_base.png",
    add_mos={
        {image="npc/dragon/dragon_wings.png", auto_tall=1},
        {image="npc/dragon/dragon_crown.png", auto_tall=1,
         particle="fire_aura", particle_args={power=5}},
    },
}
```

`auto_tall=1`：圖層佔 2 格高度渲染。

---（續 part3）---