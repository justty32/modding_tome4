### 1.1 NPC 定義 (npcs/)

共 **72 個 NPC 定義檔案**，以生物種類組織。

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
| `orc.lua` | 獸人（4 個地區變體：gorbat/grushnak/rak-shor/vor）|
| `thieve.lua` | 盜賊 |
| `minotaur.lua` | 牛頭人 |
| `humanoid_random_boss.lua` | 動態隨機菁英人形生物 |

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
| `crystal.lua` | 水晶生物（無AI，靜止掉落）|
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
    -- 等級與屬性
    level_range = {1, 20}, exp_worth = 1,
    max_life = resolvers.rngrange(20, 30),
    stats = {str=14, dex=12, con=10, mag=10, wil=10, cun=10},
    -- 戰鬥屬性
    combat = {dam=resolvers.rngrange(5,8), atk=5, apr=3},
    resists = {[DamageType.COLD]=100, [DamageType.POISON]="immune"},
    -- AI 與行為
    rank = 2,  -- 2=普通, 3=稀有, 3.5+=Boss
    ai = "dumb_talented", ai_state = {talent_in=3},
    autolevel = "warrior",  -- 自動升級方案
    -- 技能
    talents = {[T_BONE_SHIELD]=1},
    -- 掉落
    drops = resolvers.drops{chance=100, nb=2, {type="money"}},
    -- 材料
    ingredient_on_death = {id="BONE", nb=1},
}
```

#### 唯一怪（Unique）系統

- `define_as` 以大寫命名（如 `"RHALOREN_QUEST_BOSS"`）
- `unique = true` 標記唯一，每個存檔只出現一次
- 通常有自訂名稱、台詞、裝備和特殊掉落
- `flavor_on_death` 設定死亡時顯示的特殊訊息

---

