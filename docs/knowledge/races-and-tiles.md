# 引擎事實：新增種族，與角色／裝備的美術成本

> 路徑代號見 [README.md](README.md)。2026-08-01 新建——此前 knowledge 層**沒有任何種族相關文件**。
>
> ⚠️ **`docs/analysis/tutorial/15-custom-sprites/07-custom-race-tiles.md` 有兩處錯**，見 §5。

美術是新增種族的**主要成本**，不是機制。所以本檔先講機制（短），再講美術（長）。

## 1. 機制層：種族是兩層 birth descriptor

跟職業一樣是 `race` / `subrace` 兩層（對照 `class` / `subclass`，見
[class-parts/01](class-parts/01-birth-and-talents.md)）。範本：`M/data/birth/races/human.lua`。

```lua
newBirthDescriptor{ type = "race", name = "Human",
  descriptor_choices = { subrace = { Cornac = "allow", __ALL__ = "disallow" } },
  copy = { type = "humanoid", subtype = "human" },
}
newBirthDescriptor{ type = "subrace", name = "Cornac",
  inc_stats = {...}, talents = {...},
  copy = { moddable_tile = "human_#sex#", moddable_tile_base = "base_01.png", life_rating = 10 },
}
```

**世界白名單同樣適用**：`M/data/birth/worlds.lua:20-62` 的 `default_eyal_descriptors` 對 race
也是 `__ALL__="disallow"` 白名單。不 allow 建角畫面就**看不到**——與新增 class 完全同一個坑，
判定與修法照 [class-parts/01 §1](class-parts/01-birth-and-talents.md) 那節（把 `class.Witch` 換成 `race.<你的種族>`）。

`moddable_attachement_spots` 確實存在（`M/mod/dialogs/Birther.lua:1217-1221`），
但它只決定 **cosmetic doll 的附著點**（`"dolls_"..spots.."_female"`），**不是**貼圖系統本身。

## 1.5 新增「怪物」與新增「種族」是兩種不同的東西

常見誤解：以為種族就是「一種可以玩的怪物」。**不是。**

| | 普通怪物 | 種族 |
|---|---|---|
| 定義用什麼 | `newEntity{...}`（Actor **實體範本**） | `newBirthDescriptor{type="race"／"subrace"}`（一組**建角時套用的修改**）|
| 檔案在哪 | `M/data/general/npcs/*.lua` | `M/data/birth/races/*.lua` |
| 怎麼被載入 | zone 的 `npc_list` 用 `loadList` 收 | 全域 birther 表 ＋**世界白名單**（§1）|
| 誰是實例 | 地圖上刷出來的每一隻 | **玩家角色**（一局只有一個）|
| 怎麼影響 actor | 它**就是** actor 的欄位本身 | `Birther:apply()` 把 `inc_stats`／`talents`／`copy` 疊到玩家身上（`E/Birther.lua:370-446`）|
| 貼圖 | **單張 `image=`**——實測 `M/data/general/npcs/` 底下**沒有任何一個**用 `moddable_tile` | 分層合成（§2），或沿用既有資料夾 |
| 工作量 | 小。一張表、幾十行，美術一張圖 | 機制也不大，**美術才是主成本** |

兩者在 Actor 層才交會：種族的 `copy = { type="humanoid", subtype="human" }` 設的
就是怪物也有的那組欄位。

**所以「我想要一個新種族，而且世界上要有這種怪」＝兩件事都得做，而且它們不共用定義**——
你要寫一個 NPC entity，再寫一份 birth descriptor，兩邊的數值要自己對齊。

> ⚠️ **反過來有一條會自動發生的**：隨機 boss 會從**全域 subclass 表**抽職業套用
> （`M/mod/class/GameState.lua:2309, 2668` 讀 `Birther.birth_descriptor_def.subclass`），
> 所以**你新增的子職業會自動被套到隨機 boss 身上**，不必也無法只靠不註冊來避免。
> 種族沒有這條對應機制（同一段程式只讀 class／subclass）。
> 這也是 `D/tome-orcs/data/birth/classes/tinker.lua:56` 要寫
> `can_tinker = {steamtech=1}  -- this allows randbosses to equip tinkers` 的原因。

放 NPC、寫對話見 [npc-and-chats.md](npc-and-chats.md)。

## 2. 美術層：角色不是一張圖，是一疊圖

`M/mod/class/Actor.lua:4315-4400` 的 `updateModdableTile()` 每次穿脫裝備都重建 `add_mos`，
把十幾層 PNG 疊起來。基準路徑（`:4337`）：

```lua
local base = "player/"..self.moddable_tile:gsub("#sex#", self.female and "female" or "male").."/"
```

→ 全部檔案都在 `M/data/gfx/shockbolt/player/<資料夾>/`。疊的順序大致是
陰影（`:4339`）→ 尾巴／身後物（`:4346-4347`）→ 披風後片（`:4349`）→ 身體（`:4362`）→
刺青（`:4368`）→ 背後武器（`:4374-4378`）→ 靴（`:4383`）→ 下身／上身（`:4384-4387`）→
披風肩片（`:4388`）→ 兜帽（`:4390`）→ 頭髮（`:4392`）→ …

**關鍵：每一層都在「那個種族的資料夾」底下找檔。** 所以裝備疊圖是 per-race 的。

### 真實成本（實測數字，非估算）

原版 `M/data/gfx/shockbolt/player/` 有 16 組完整種族貼圖。以 `human_male` 為例：

| 內容 | 張數 |
|---|---|
| 資料夾本體 | **359** |
| └ 手部／武器疊圖（`right_hand_*`＋`left_hand_*`） | 116 |
| └ 上身 38、下身 19、頭 22、腳 11、手 9 | 99 |
| └ 披風（behind／shoulder／hood 各 8-9） | 25 |
| └ 裸身 base | 8 |
| └ 髮／鬚／臉（三種族裔各一套） | 13 |
| └ 雙手武器、箭袋、彈袋、寶石袋 | 40+ |
| `special/` 子夾（**每個 unique 神器一張**） | **419** |
| **合計** | **≈ 780 張／族／性別** |

各族總數 337–389（不含 `special/`），最大 `ogre_female` 389。

> **所以「畫一個新種族」的完整成本是 ~780 張 64×64 RGBA，而且要兩個性別。**
> 這不是可以硬幹的量。下面三條是實際可行的路。

### 省錢路徑 A：直接沿用既有種族的資料夾（推薦）

`moddable_tile` 就是一個資料夾名字，**沒有任何檢查說你不能指向別族的**：

```lua
copy = { moddable_tile = "human_#sex#", moddable_tile_base = "base_01.png" }
```

新種族在機制上全新，外觀借用人類。**美術成本 0**，所有裝備疊圖自動全部支援。
想做出差異可再疊一兩層自己的圖（`moddable_tile_tail` / `moddable_tile_tatoo` /
`moddable_tile_behinds`，`Actor.lua:4346-4347, 4368`）——**加幾張就有幾分辨識度**。

### 省錢路徑 B：不分性別 + 免內衣（原版 yeek／構裝體走這條）

```lua
copy = { moddable_tile = "yeek", moddable_tile_nude = 1 }   -- M/data/birth/races/yeek.lua:163-164
                                                            -- construct.lua:110-111 同款
```

- `moddable_tile` 不含 `#sex#` → **一份資料夾兩性共用，成本直接砍半**。
- `moddable_tile_nude = 1` → 跳過預設上下身內衣層（`Actor.lua:4385, 4387`），**少畫兩層**。

### 省錢路徑 C：完全不用 moddable tile

不設 `moddable_tile`，`updateModdableTile` 在 `:4335` 直接 return。角色就是單張圖，
像一般怪物那樣。**成本 1–2 張**，代價是身上永遠看不到裝備。

## 3. 新增武器／裝備：`resolvers.moddable_tile` 讓美術成本歸零

`M/mod/resolvers.lua:788-840`。這是本檔**對「新增大量裝備」最重要的一條**。

```lua
moddable_tile = resolvers.moddable_tile("mace"),   -- M/data/general/objects/maces.lua:26
```

它**不是**指定一張圖，而是查表對應到**既有的 per-race 檔名**，並依物品的
`material_level`（1–5）自動選五階之一（`:832-833`）。可用的 slot 名有 27 種：

| 類別 | slot 名 |
|---|---|
| 身體護甲 | `massive` `heavy` `light` `robe` |
| 頭 | `helm` `leather_cap` `wizard_hat` |
| 手腳 | `gauntlets` `gloves` `leather_boots` `heavy_boots` |
| 披風 | `cloak` |
| 單手武器 | `sword` `mace` `axe` `dagger` `whip` `trident` `mindstar` |
| 雙手武器 | `2hsword` `2hmace` `2haxe` `staff` |
| 遠程 | `bow` `sling` |
| 其他 | `shield` `quiver` `shotbag` `gembag` `mummy_wrapping` |

**只要你的新裝備落在這 27 種之一，美術成本就是 0**——所有 16 個種族的疊圖白拿，
還自動有五階外觀。`massive`/`heavy`/`light` 還會一併設 `moddable_tile2`（下身，`:834-837`）。

### 什麼時候才真的要畫圖

只有**要獨一無二外觀的神器**：

```lua
moddable_tile = "special/%s_weapon_spellblade",   -- M/data/general/objects/world-artifacts-maj-eyal.lua:310
moddable_tile_big = true,
```

`%s` 由引擎填 `left`/`right`（`Actor.lua:4375, 4378`）。檔案落在
`player/<族>/special/`——**所以一件神器要 16 族 × (左右手) 張圖**。原版每族 `special/` 419 張就是這樣來的。

> 自製 addon 的實務結論：
> **新裝備一律用 `resolvers.moddable_tile(...)`；真的要專屬外觀，就接受它只在你支援的那幾族身上顯示。**
> 沒有 `moddable_tile` 欄位的裝備，`Actor.lua:4383-4388` 的 `if i and i.moddable_tile` 直接跳過——
> **靜默不畫疊圖，不會報錯**，物品功能完全正常。

## 4. 物品的背包圖示是另一回事

疊圖（`moddable_tile`）＝穿在身上的樣子。背包／地上的圖示是物品的 `image` 欄位，
**單張、與種族無關**，做法見 [visuals-and-sounds.md](visuals-and-sounds.md)（物品貼圖那節）。
兩者互相獨立：可以只做 `image` 不做疊圖。

## 5. `docs/analysis` 那份的兩處錯

`docs/analysis/tutorial/15-custom-sprites/07-custom-race-tiles.md`：

1. **路徑錯**：它寫 `mod/data/gfx/shockbolt/player/`。addon 的 `data/` 是私有掛載點
   （`/data-<short_name>/`，見 [addon-loading.md §0](addon-loading.md)），
   自製 PNG **必須放 `overload/data/gfx/`** 才找得到。
2. **`moddable_attachement_spots` 的作用被寫成「自訂附著點」**，實際上只影響 cosmetic doll
   （`M/mod/dialogs/Birther.lua:1217-1221`），與貼圖疊層無關。

「最小 4 張 PNG 就能顯示」那條**方向正確**（陰影＋base＋上下身內衣），
但配 `moddable_tile_nude = 1` 其實 **2 張就夠**（陰影＋base）。

## 6. 坑

1. **種族沒進世界白名單 → 建角畫面靜默看不到**（同新增 class，`M/data/birth/worlds.lua:20-62`）。
2. `moddable_tile` 指到不存在的資料夾 → 角色不顯示，**沒有錯誤訊息**。
3. `#sex#` 是字面字串，靠 `:gsub` 替換（`Actor.lua:4337`）。拼錯不會報錯，只是找不到檔。
4. **自製角色 PNG 放 addon 的 `data/` 而不是 `overload/data/gfx/` → 永遠找不到**（同 §5.1）。
5. `M/data/gfx/` 來自**獨立的 `tome-gfx.team`**（306MB），與 `tome.team` 分開。
   fresh clone 時要另外解，見 [AGENTS.md](../../AGENTS.md) 的「Fresh clone / 環境還原」。
