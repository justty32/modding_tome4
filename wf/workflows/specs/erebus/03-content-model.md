# Erebus — 內容資料模型

← [README](README.md)｜這份決定「弱模型怎麼填表」

**核心原則：實作 agent 是填表，不是創作。** 表的欄位定死，內容從素材庫來。

## 1. 三層單元：文明 → 城市 → 冒險

使用者要的是**復刻全部 + 大量無數的冒險**，所以內容切成三層，
**每一層都是可以無限往下加的**：

```text
文明（分組：派系、宗教、風格、語氣——不是 zone）
  └─ 城市／地點（內容單元：一隻 agent 做一座）
       └─ 區塊（實際的 zone：市集區、神殿區、貧民窟、城堡……）
            └─ 冒險（量產單元：模板 × 素材，可以一直生）
```

> **對照三層尺度**（[02 §2.5.1](02-mechanics.md)）：文明只是分組，不是 zone；
> 城市是 L0 大地圖上的一個地點；城市**區塊**與地城是 **L2 實際活動地圖**。
> L1 中層區域地圖不在這條鏈上——它是**生成**的，不是手寫的內容單元。

**一座城市不是一個 zone，是一叢 zone。** 大城市切成數個區塊，各自是獨立 zone，
彼此用出入口相連；小聚落一個 zone 就夠。這樣做的三個理由：

1. **內容密度**：一個 zone 塞不下一座城的 NPC 與商店，塞了也難逛。
2. **量產友善**：區塊是更小的單元，可以再往下切給不同 agent，或分批出貨。
3. **引擎友善**：ToME 的 zone 本來就是這個尺度（原版城鎮都是單張圖，大城才值得切）。

⚠️ **切區塊要付的代價是連通性**：每多一道門就多一個「玩家走不走得到」的風險。
本 repo 已經在歐拉麗踩過一次（據點入口被牆完全擋死）。
**每個區塊的驗收都必須逐格走過，不准只用 `changeLevel()` 跳。**

### 1.1 城市：一隻 agent 一座，八件套

| # | 產出 | 數量 | 備註 |
|---|---|---|---|
| 1 | 城市 zone | 大城 2–4 個區塊／小聚落 1 個 | 抄 `runeisles/data/zones/town-stonemark/` |
| 2 | 周邊地城 zone | 1–2（2–4 層） | 該城的代表性地點 |
| 3 | 具名 NPC | 3–6 | 含給任務的、商人、講 lore 的 |
| 4 | **手寫冒險** | 2–3 | 有敘事、有分支的那種。品質基準 |
| 5 | **模板冒險** | 5–15 | 照 §1.2 的模板填，量產用 |
| 6 | 英雄／守關者 | 1 | 地城底層 |
| 7 | 神器或特色物品 | 1 | |
| 8 | lore 文獻 | 3–5 篇 | 世界觀傳達的主力 |

**硬性要求**：NPC 對白要有**依 AC 分檔的版本**（至少低／中／高三檔）。
這是世界「隨數字改變」的主要體感來源，也最適合弱模型填空。

### 1.2 冒險：模板 × 素材 = 無限量

**這是「無數的冒險」能成立的關鍵。** 不要一個一個手寫任務，
定義一組**冒險模板**，再用素材去填組合：

| 模板 | 骨架 | 可填的變數 |
|---|---|---|
| `hunt` 討伐 | 去 X 殺掉 Y，回報 Z | 地點／目標／委託人／獎勵／AC 影響 |
| `fetch` 尋物 | 去 X 取回 Y | 同上 + 物品 |
| `escort` 護送 | 把 N 從 A 送到 B | 同上 + 路線 |
| `cleanse` 淨化 | 清掉某地的腐化（**壓低 AC**） | 地點／腐化源 |
| `corrupt` 獻祭 | 在某地行邪儀（**推高 AC**） | 同上。惡向路線 |
| `investigate` 查訪 | 問三個人，拼出真相 | 三個 NPC + 揭露的 lore |
| `defend` 守城 | 撐過 N 波來襲 | 波次表 |
| `delve` 探索 | 下到地城第 N 層取得某物 | 地城／深度 |
| `broker` 交涉 | 在兩個派系之間選邊 | 兩派 + 後果 |

```lua
-- data/erebus/adventures.lua
{ id = "bannor-hunt-01", template = "hunt",
  civ = "bannor", giver = "ERE_BANNOR_CAPTAIN",
  zone = "erebus+bannor-ruins", depth = 2,
  target = "ERE_BLIGHTED_HOUND", count = 6,
  reward = { gold = 200, rep = { erebus_bannor = 5 } },
  ac_delta = -0.5,
  gate = { ac_min = 0, ac_max = 60, player_level = 5 },
  text = { offer = "...", progress = "...", done = "..." },   -- 只有這三段要寫字
}
```

**弱模型只需要填欄位與三段文字**，任務的狀態機由模板統一實作一次。
一座城市生 10 個這種冒險是一小時的事，而且**格式錯了 `lint.sh` 抓得到**。

### 1.3 品質護欄

模板任務會稀釋品質，所以三條硬規則：

1. **每座城市至少 2 個手寫冒險**，模板任務不能取代它們。
2. **模板任務要有 `gate`**（AC 區間、等級、前置），否則玩家一進城被 15 個驚嘆號淹沒。
3. **同一個模板在同一座城市不得超過 3 個**，避免「又是去殺六隻」。

## 2. 資料表

內容全部進表，不散在 Lua 各處。表放在 addon 的 `data/erebus/`。

### 2.1 `civs.lua` — 文明

```lua
{ id = "bannor", name = "巴諾",
  align = "good",                       -- good / neutral / evil
  zone_town = "erebus+town-bannor",
  zone_dungeon = "erebus+bannor-ruins",
  faction = "erebus_bannor",
  religion_default = "order",           -- 該文明主流宗教
  ac_stance = "lower",                  -- lower / neutral / raise：任務線推動 AC 的方向
  cast = { "BANNOR_CAPTAIN", "BANNOR_PRIEST", "BANNOR_SMITH" },
  quest_chain = "bannor-law",
  hero = "BANNOR_HERO_DONAL",
  artifact = "ART_BANNOR_SHIELD",
  worldmap = { x = 0, y = 0 },          -- 世界地圖座標，由編排者統一分配
}
```

### 2.2 `cast.lua` — 具名 NPC

**一列一個角色。**`tone` 與 `stance_ac` 兩欄是文案品質的護欄：

```lua
{ id = "BANNOR_PRIEST", name = "……",
  civ = "bannor", faction = "erebus_bannor",
  image = "npc/humanoid_human_....png",  -- 預設沿用原版現成貼圖，成本 0
  role = "lore",                          -- quest / merchant / lore / hero
  tone = "虔誠、疲憊、對真相心虛",         -- 說話語氣關鍵詞，寫對白時的約束
  stance_ac = { low = "...", mid = "...", high = "..." },  -- 三檔開場白
  chat = "bannor-priest",
}
```

### 2.3 `spheres.lua` — 法球

**一個法球是一組樹**（[02 §3.1](02-mechanics.md)），不是一棵：

```lua
{ id = "SPHERE_DEATH", name = "死亡",
  align = "evil", ac_per_use = 0.2,        -- 每次使用推高 AC
  trees = {
    { kind = "shape",  id = "erebus/death-shape",  grant = "base"  },  -- 取得球就給
    { kind = "summon", id = "erebus/death-summon", grant = "deep1" },  -- 深化一次才給
    { kind = "inscribe", id = "erebus/death-insc", grant = "deep2" },
  },
}
```

`kind` 只有三種（`shape` 塑形／`summon` 召喚／`inscribe` 銘刻），**不是每球都三種齊全**。
`grant` 決定它在哪個深化階段解鎖。

### 2.4 `religions.lua` — 宗教

```lua
{ id = "order", name = "秩序",
  align = "good", ac_on_join = -5, ac_rate = -0.1,
  tree = "erebus/order",
  friendly = { "erebus_bannor" }, hostile = { "erebus_sheaim" },
}
```

### 2.5 `ac_events.lua` — 末日門檻

```lua
{ at = 30, id = "blight", once = true,
  lore = "ac-blight",
  spawn_extra = { "ERE_BLIGHTED_*" },     -- 加進野外生成表
  npc_deaths = { "..." },
}
```

### 2.6 `ac_sources.lua` — 什麼會動數字

```lua
{ id = "kill_innocent", delta = +1.0 },
{ id = "quest_bannor_law_done", delta = -5.0 },
```

**所有數值都在表裡，調平衡不必動 Lua。**

### 2.7 勢力範圍：文明的與城市的，兩層都要

這是 **L1 中層區域地圖**生成內容的主要輸入（[02 §2.5.2](02-mechanics.md)）。

```lua
-- civs.lua 每個文明多這兩欄
{ id = "bannor", ...,
  influence = { center = {x=12,y=8}, radius = 9, strength = 3 },
}

-- cities.lua 每座城市
{ id = "city-bannor-capital", civ = "bannor", name = "……",
  worldmap = { x = 12, y = 8 },
  zones = { "erebus+bannor-capital-market", "erebus+bannor-capital-keep" },  -- L2 區塊
  influence = { radius = 4, strength = 5 },   -- 城市自己的轄區
}
```

**一格屬於誰，是算出來的，不是標出來的**：

```text
該格的歸屬 = 影響力最強者
影響力 = strength × (1 - 距離 / radius)   -- 距離超過 radius 就是 0
距離檔位 = 核心（<1/3 radius）／邊陲（<2/3）／邊緣（其餘）／無主（全部為 0）
```

| 兩層各決定什麼 | |
|---|---|
| **文明勢力範圍** | 這裡的**人是誰**：建築風格、居民種族、派系、語氣、信仰 |
| **城市勢力範圍** | 這裡**歸誰管**：有沒有村落、有沒有巡邏隊、掛哪座城的委託 |

**無主之地不是空的**，是另一種內容：盜匪、隱士、廢墟、野生的東西、以及最好的意外收穫。

### 2.8 `region_gen.lua` — 中層區域地圖生成什麼

**這張表就是「無數的冒險」的產生器**，也是最值得花時間調的一張表。

```lua
{ terrain = "forest",              -- L0 那格的地形
  owner_kind = "city",             -- city / civ_only / none（無主）
  band = "邊陲",                   -- 核心 / 邊陲 / 邊緣
  ac_range = { 0, 40 },            -- 世界狀態檔位
  generator = "engine.generator.map.Forest",   -- 用現成的，不要自己寫演算法
  spots = {                        -- 這張圖上會有什麼
    { kind = "village", chance = 70, size = "small" },
    { kind = "patrol",  chance = 50, faction = "<owner>" },
    { kind = "loner",   chance = 40 },
    { kind = "ruin",    chance = 25 },
    { kind = "delve",   chance = 30 },   -- 通往 L2 的入口
  },
  npc_list = { "ERE_FOREST_*", "<owner_civ>_PATROL_*" },
}
```

同一組 `terrain × owner_kind × band` 要備**多個 AC 檔位的版本**——
低 AC 是興盛的村落與商隊，高 AC 是荒廢的村落與劫掠團。
**這是「世界隨數字改變」最強的體感來源**，也是弱模型最適合量產的表。

## 3. 素材怎麼從 gameplots 進來

來源：`C:/code/mine/gameplots/results/Fall_from_Heaven/`（**唯讀，一個字都不要改**）。

| 我們的表 | 素材檔 | 要補的欄位 |
|---|---|---|
| `civs.lua` | `factions.md` | zone id、座標、faction id |
| `cast.lua` | `characters.md` + `characters/*.md` | 貼圖檔名、`define_as`、對白 |
| `spheres.lua` | `items.md`（Mana / Spheres of Magic 一節） | 天賦定義 |
| `religions.lua` | `factions.md`（宗教教團一節） | 樹 id、陣營關係 |
| lore | `concepts.md`、`events.md`、`timeline.md` | 改寫成遊戲內文獻 |
| 神器 | `items.md` | `wielder` 數值、貼圖 |

⚠️ **素材是「事實與設定」的來源，不是文字的來源。** 描述與對白一律原創重寫
（[README](README.md) 著作權註記）。

詳細的欄位對照與可抄程度評估見 [08-gameplots-reuse.md](08-gameplots-reuse.md)。

## 4. 命名規則（硬性）

撞名會**靜默覆蓋原版、全遊戲生效**，所以前綴是強制的：

| 東西 | 規則 | 例 |
|---|---|---|
| addon | `tome-erebus`，`short_name = "erebus"` | 私有掛載點是 `/data-erebus/` |
| entity id | `ERE_` 前綴 | `ERE_BANNOR_PRIEST` |
| zone short_name | `erebus+<name>` 引用時**一定帶 `+`** | `erebus+town-bannor` |
| 自製貼圖 | `overload/data/gfx/…`，檔名加 `ere_` | `ere_bannor_shield.png` |
| selfcheck tag | `[EREBUS]` | `verdict.lua` 靠它判定 |

⚠️ **怪物與 NPC 一定要有 `name` 欄位**——少了它玩家一殺就崩，而且 verify 抓不到。

## 5. 檔案樹（每個文明一組，互不重疊）

```text
self_mods/tome-erebus/
  init.lua                      ← 編排者寫，agent 不准改
  hooks/load.lua                ← 編排者寫；agent 掛 hook 寫進 hooks/parts/<civ>.lua
  hooks/parts/
  data/erebus/                  ← 共用資料表（§2），由編排者定案
  data/zones/town-<civ>/        ← 一個 agent 一組
  data/zones/<civ>-dungeon/
  data/npcs/<civ>.lua
  data/chats/<civ>-*.lua
  data/quests/<civ>-*.lua
  data/lore/<civ>.lua
  overload/data/gfx/            ← 自製圖（多數情況用原版現成的，成本 0）
```

**檔案樹的切法就是平行分工的切法**——一個 civ 一組資料夾，天然不撞車。
契約照 [CONTRACT.template.md](../../agent-driving/CONTRACT.template.md) 寫。

## 6. 美術成本：幾乎為零

具名 NPC 一張 64×64，而**原版 `npc/` 有 636 張現成人形貼圖可直接沿用**
（[orario spec §2](../orario-complete-design.md) 已記）。第一版原則：

- NPC、怪物：**全部沿用原版貼圖**，不生圖
- 神器圖示：沿用原版物品圖
- 只有**地獄地形**值得自製，而那是地面圖——不需要透明，`agy` 生圖最安全的一類

生圖規則見 [assets.md](../../agent-driving/assets.md)，驗收條件寫進契約。
