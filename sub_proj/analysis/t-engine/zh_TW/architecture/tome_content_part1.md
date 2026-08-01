# T-Engine 4 — ToME 1.7.6 內容層詳細分析

> 本文是 `game_detail.md` 的補充，專注分析 `game/modules/tome-1.7.6/` 中尚未深入記錄的子系統。

---

## 目錄（本部分）

1. [data/general/ — 核心內容資料](#1-datageneral--核心內容資料)
   - 1.1 [NPC 定義（npcs/）](#11-npc-定義-npcs)
   - 1.2 [物品定義（objects/）](#12-物品定義-objects)

> 其他部分請參照：Part2（grids/stores/traps/events/encounters）、Part3（dialogs）、Part4（quests/lore）、Part5（generators/uiset/overview）。

---

## 1. data/general/ — 核心內容資料

### 1.1 NPC 定義 (npcs/)

共 **72 個 NPC 定義檔案**，按生物種類組織。

#### 檔案分類

**普通生物（野生動物）**

| 檔案 | 生物類型 |
|------|---------|
| `bear.lua` | 熊類（黑熊、灰熊、大黑熊等）|
| `canine.lua` | 犬科（狼、蜘蛛犬、渡鴉等）|
| `bird.lua` | 鳥類（蝙蝠、老鷹等）|
| `feline.lua` | 貓科（山貓、豹等）|
| `rodent.lua` | 齧齒類（大鼠、松鼠等）|
| `snake.lua` | 蛇類（蛇蝎、巨蟒等）|
| `ant.lua` | 螞蟻類（兵蟻、蟻后等）|
| `aquatic_critter.lua` | 水生生物 |

**不死生物**

| 檔案 | 說明 |
|------|------|
| `skeleton.lua` | 骷髏（戰士/弓手/法師/精英）|
| `mummy.lua` | 木乃伊 |
| `ghost.lua` | 幽靈（含相位穿牆能力）|
| `ghoul.lua` | 食屍鬼 |
| `wight.lua` | 惡靈 |
| `vampire.lua` | 吸血鬼（含魅惑技能）|
| `lich.lua` | 巫妖（高等不死法師）|
| `undead-rat.lua` | 不死鼠（特殊任務相關）|

**惡魔類**

| 檔案 | 說明 |
|------|------|
| `minor-demon.lua` | 小惡魔（Imp、Quasit 等）|
| `major-demon.lua` | 大惡魔（Balrog 類等）|
| `aquatic_demon.lua` | 水生惡魔 |

**龍類**

| 檔案 | 說明 |
|------|------|
| `cold-drake.lua` | 冰龍（含冰霜吐息）|
| `fire-drake.lua` | 火龍（含火焰吐息）|
| `storm-drake.lua` | 風暴龍（含閃電吐息）|
| `venom-drake.lua` | 毒龍（含毒液吐息）|
| `wild-drake.lua` | 野性龍 |
| `multihued-drake.lua` | 多彩龍（多種吐息）|

**人形生物**

| 檔案 | 說明 |
|------|------|
| `elven-caster.lua` | 精靈法師 |
| `elven-warrior.lua` | 精靈戰士 |
| `orc.lua` | 獸人（4 地區變體：gorbat/grushnak/rak-shor/vor）|
| `thieve.lua` | 盜賊 |
| `minotaur.lua` | 牛頭人 |
| `humanoid_random_boss.lua` | 動態隨機精英人形生物 |

**特殊/BOSS**

| 檔案 | 大小 | 說明 |
|------|------|------|
| `horror.lua` | 43KB（最大）| 各類恐怖生物（含大量 Goroth 系列）|
| `horror_aquatic.lua` | — | 水生恐怖 |
| `horror-corrupted.lua` | — | 腐化恐怖 |
| `horror-undead.lua` | — | 不死恐怖 |
| `horror_temporal.lua` | — | 時空恐怖 |
| `gwelgoroth.lua` | — | 特殊 boss |
| `losgoroth.lua` | — | 特殊 boss |
| `shivgoroth.lua` | — | 特殊 boss |
| `telugoroth.lua` | — | 特殊 boss |
| `ziguranth.lua` | — | 反魔法派系成員 |
| `sandworm.lua` | — | 沙蟲（含 sandworm_tunneler AI）|

**特殊生物**

| 檔案 | 說明 |
|------|------|
| `crystal.lua` | 水晶生物（無 AI，靜止掉落）|
| `ooze.lua` / `jelly.lua` | 軟體生物（分裂、吸收等特性）|
| `swarm.lua` | 群集生物 |
| `plant.lua` / `molds.lua` | 植物/黴菌 |
| `shade.lua` | 影子生物 |
| `construct.lua` | 魔法構裝體 |
| `ritch.lua` | Ritch（巨蟲）|
| `xorn.lua` | Xorn（石化生物）|
| `yaech.lua` | Yaech（奈迦族）|
| `naga.lua` | 奈迦 |
| `shertul.lua` | Sher'Tul（古老智慧種族）|
| `spider.lua` | 蜘蛛 |

#### NPC 實體定義結構

```lua
newEntity{
    define_as = "BASE_NPC_SKELETON",
    type = "undead", subtype = "skeleton",
    name = _t"skeleton", color = colors.WHITE,
    display = 's', image = "npc/undead_skeleton_warrior.png",
    level_range = {1, 20}, exp_worth = 1,
    max_life = resolvers.rngrange(20, 30),
    stats = {str=14, dex=12, con=10, mag=10, wil=10, cun=10},
    combat = {dam=resolvers.rngrange(5,8), atk=5, apr=3},
    resists = {[DamageType.COLD]=100, [DamageType.POISON]="immune"},
    rank = 2,  -- 2=普通, 3=稀有, 3.5+=Boss
    ai = "dumb_talented", ai_state = {talent_in=3},
    autolevel = "warrior",
    talents = {[T_BONE_SHIELD]=1},
    drops = resolvers.drops{chance=100, nb=2, {type="money"}},
    ingredient_on_death = {id="BONE", nb=1},
}
```

#### 唯一怪（Unique）系統

- `define_as` 以大寫命名（如 `"RHALOREN_QUEST_BOSS"`）
- `unique = true` 標記唯一，每個存檔只出現一次
- 通常有自訂名稱、台詞、裝備和特殊掉落
- `flavor_on_death` 設定死亡時顯示的特殊訊息

---

### 1.2 物品定義 (objects/)

共 **60+ 個物品定義檔案**，按類型組織。

#### 武器類

| 檔案 | 武器類型 |
|------|---------|
| `swords.lua` | 單手劍 |
| `axes.lua` | 單手斧 |
| `maces.lua` | 單手棒錘 |
| `knifes.lua` | 匕首/短刀 |
| `whips.lua` | 鞭子 |
| `polearms.lua` | 長柄武器 |
| `2hswords.lua` / `2haxes.lua` / `2hmaces.lua` / `2htridents.lua` | 雙手武器 |
| `bows.lua` | 弓 |
| `slings.lua` | 投石器 |
| `digger.lua` | 挖掘工具 |
| `staves.lua` | 魔杖（法師專用）|
| `mindstars.lua` | 心靈星（心靈師專用）|
| `totems.lua` | 圖騰（召喚師專用）|

#### 防具類

| 檔案 | 防具位置 |
|------|---------|
| `cloth-armors.lua` | 布甲（法袍）|
| `light-armors.lua` | 輕甲（皮革）|
| `heavy-armors.lua` | 重甲（鎖甲）|
| `massive-armors.lua` | 板甲（全身甲）|
| `helms.lua` | 頭盔 |
| `leather-caps.lua` | 皮革帽 |
| `leather-boots.lua` | 皮革靴 |
| `heavy-boots.lua` | 重型靴 |
| `gauntlets.lua` | 板甲手套 |
| `gloves.lua` | 皮革手套 |
| `shields.lua` | 盾牌 |
| `leather-belt.lua` | 腰帶 |
| `jewelry.lua` | 珠寶（戒指/項鍊）|
| `lites.lua` | 光源（火把/燈籠/符文石）|

#### 消耗品

| 檔案 | 說明 |
|------|------|
| `potions.lua` | 藥水（治療/屬性/特效）|
| `scrolls.lua` | 卷軸（傳送/辨識/地圖）|
| `rods.lua` | 法杖（可充能的魔法道具）|
| `wands.lua` | 魔棒（可消耗的魔法道具）|

#### 神器（Artifacts）

| 檔案 | 大小 | 說明 |
|------|------|------|
| `world-artifacts.lua` | 313KB（最大）| 主要世界傳奇神器（數百件）|
| `world-artifacts-maj-eyal.lua` | 47KB | Maj'Eyal 地區神器 |
| `world-artifacts-far-east.lua` | 21KB | 遠東地區神器 |
| `boss-artifacts.lua` | 8KB | 通用 Boss 掉落神器 |
| `boss-artifacts-maj-eyal.lua` | 67KB | Maj'Eyal Boss 神器 |
| `boss-artifacts-far-east.lua` | 21KB | 遠東 Boss 神器 |
| `brotherhood-artifacts.lua` | 13KB | 煉金士兄弟會神器 |
| `quest-artifacts.lua` | 17KB | 任務關鍵神器 |
| `special-artifacts.lua` | 4KB | 特殊機制神器 |

#### Ego 系統（物品詞綴）

`egos/` 目錄包含物品詞綴定義：
- **前綴 ego**（如「燃燒的」、「冰冷的」）：修改物品基礎屬性
- **後綴 ego**（如「敏捷之」、「力量之」）：添加屬性加成
- **特殊 ego**：`special_on_hit`、`talent_on_hit`、`on_block` 等效果

```lua
newEntity{
    power_source = {arcane=true},
    name = _t"of striking",
    keywords = {striking=true},
    level_range = {1, 50},
    rarity = 10,
    wielder = { combat_atk = resolvers.mbonus(12, 5) },
}
```

#### 物品辨識系統

- `unided_name`：未辨識時的名稱（如 "red potion"）
- `desc`：辨識後顯示的說明
- `identified`：是否已辨識（武器/防具預設 true，藥水/卷軸預設 false）

#### 區域性物品

- `tome_drops`：控制物品出現情境（`"Maj'Eyal"`, `"Far East"` 等）
- `level_range`：物品出現的等級範圍
- `rarity`：越高越少見

#### 隨機神器（Randart）

`random-artifacts.lua` 定義隨機神器生成規則：
- 基於基礎物品加上隨機 ego 與屬性
- `GameState:generateRandart(data)` 呼叫
- 強大神器系統（Randart Power Budget）控制平衡
