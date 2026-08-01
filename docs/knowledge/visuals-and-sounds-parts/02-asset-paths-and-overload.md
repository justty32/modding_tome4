# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` / `R` 見 [README.md](../README.md)。
> `G = ~/.steam/steam/steamapps/common/TalesMajEyal/game/modules`

## 2. 有哪些名字可用

```bash
G=~/.steam/steam/steamapps/common/TalesMajEyal/game/modules
# 粒子（315 個），在 tome-gfx.team
unzip -l $G/tome-gfx.team | grep -oE 'particles/[a-z_0-9]+\.lua'
# 天賦音效（36 個），在 tome.team
unzip -l $G/tome.team | grep -oE 'sound/talents/[a-z_0-9]+\.ogg'
# 天賦圖示（1350 個），在 tome-gfx.team
unzip -l $G/tome-gfx.team | grep -oE 'talents/[a-z_0-9]+\.png'
```

常用速查：

- 彈道 `bolt_{arcane,fire,ice,light,lightning,earth}` ＋ 拖尾 `{arcane,fire,ice,light,lightning,earth}trail`
- 範圍 `ball_{arcane,fire,ice,light,lightning,teleport}`
- 光束 `{light,ice,mana,lightning}_beam`
- 自身光環 `arcane_power`
- 音效 `talents/{arcane,fire,ice,earth,teleport,heal,spell_generic}`

## 3. 圖片路徑相對於什麼根（為什麼「借用原版」會通）

所有 `image = "..."` 最後都走同一條路：`Entity` → `Tiles:get()`（`E/Entity.lua:377` 把 `self.image`
傳進去）→ **兩段查找**（`E/Tiles.lua:136-137`）：

| 順序 | 實際查的 VFS 路徑 | 由誰決定 |
|---|---|---|
| 1 | `Tiles.prefix .. image` = `/data/gfx/<tileset>/<image>` | `M/mod/class/Game.lua:589` 依畫面設定改寫成 `/data/gfx/shockbolt/` 等 |
| 2 | `baseImageFile(image)` = `/data/gfx/<image>` | `E/Tiles.lua:69-76`；`base_prefix` 固定 `/data/gfx/`（`E/Tiles.lua:28`）|

所以 `image = "talents/slime_spit.png"` 先試 `/data/gfx/shockbolt/talents/slime_spit.png`（沒有），
再試 `/data/gfx/talents/slime_spit.png`（有）。`/data` = **模組自己的 `data/`**
（`E/Module.lua:137` `fs.mount(…"/data/", "/data", false)`），內容實體在 `tome-gfx.team`。

哪些類別放 tileset 子目錄、哪些放共用層（`unzip -l $G/tome-gfx.team` 實查）：

| 類別 | 路徑 | tileset 變體 | 原版尺寸 |
|---|---|---|---|
| 天賦圖示 | `/data/gfx/talents/*.png` | 無（`shockbolt/talents/` 0 檔） | 64×64 |
| 狀態效果圖示 | `/data/gfx/effects/*.png` | 無 | 64×64 |
| 職業圖示 | `/data/gfx/class-icons/*.png` | 無 | 32×32／128×128 |
| 粒子紋理 | `/data/gfx/particles_images/*.png` | 無 | 32×32／64×64 |
| 地圖上的角色／物件／地形 | `/data/gfx/shockbolt/{npc,player,object,…}/` | **有** | 依 tileset |

小陷阱：`E/Tiles.lua:125` 有 `#image > 4` 守衛——`image` 字串長度 ≤ 4 直接不當圖片處理。

**音效走完全不同的一條路，沒有 tileset 概念**：`game:playSoundNear(who, name)`
（`M/mod/class/Game.lua:2940`，內部轉呼 `:2944` 的 `playSound`）→ `E/interface/GameSound.lua:51,60`
硬編 `/data/sound/<name>.lua` 與 `/data/sound/<name>.ogg`。
所以 `"talents/slime"` = `/data/sound/talents/slime.ogg`，**不含副檔名**。

## 3.5 ★ 地磚的 `image` 放的是**地面**，特徵疊在 `add_mos`

**一格只畫一個 TERRAIN 實體，引擎不會自動幫你在底下鋪地面。**
所以把樹、建築、傳送門這類「站在地上的東西」直接寫進 `image`，
它的透明處露出來的是**黑底**，不是林地／草地。

2026-08-01 女巫森林實機回報：「樹應該和地面 tile 重疊，目前似乎只 render tree」。
病因就是這個——貼圖的 alpha 完全正確，錯在分層。

原版所有「地面上的東西」都是同一個寫法：

```lua
-- M/data/general/grids/forest.lua:153（大地圖出口）
image = "terrain/grass.png", add_mos = {{image = "terrain/worldmap.png"}}

-- 同檔 :76（樹）——注意 image 是 grass
newEntity(class:makeNewTrees({base="TREE", define_as="TREE"..i, image="terrain/grass.png"}, treesdef))
```

`add_mos` 的元素是 `{image=, display_x=, display_y=, display_w=, display_h=}`，
合成在**同一個 map object** 上（實作見 `M/mod/class/Grid.lua:248-290` 的 `makeNewTrees`）。
`display_w/h` 預設 1，單張同尺寸疊圖只要 `add_mos = {{image = "..."}}` 就夠。

要疊**超出一格**的東西（大型 NPC、兩格高的傳送門）用 `add_displays`，
它是獨立實體、吃 `z` 與 `display_h`／`display_y`：

```lua
add_displays = { class.new{ image = "terrain/witchwood_portal.png", display_h = 2, display_y = -1 } }
```

### 這條規則的一個好用推論

**繼承原版地磚時只覆寫 `image`，base 的 `add_mos` 會原樣留著。**
所以自訂樓梯很省事——`GRASS_UP2` / `GRASS_DOWN2` / `GRASS_UP_WILDERNESS`
把箭頭放在 `add_mos` 裡（`forest.lua:150-190`、`:218-236`），
你換掉 `image` 只是換掉腳下的地面，箭頭照樣顯示：

```lua
newEntity{ base = "GRASS_DOWN2", define_as = "MY_DOWN", image = "terrain/my_floor.png" }
```

實例：`self_mods/tome-witchwood/data/zones/witchwood/grids.lua`（樹與三個階梯並列，對照著看最快）。

## 4. 自製圖片放哪：`overload/` 是實務唯一解

**結論先講：自製 PNG 放 `overload/data/gfx/…`，引用字串跟借用原版一模一樣。**

理由在掛載點：

| addon 目錄 | 掛到哪 | 出處 |
|---|---|---|
| `data/` | `/data-<short_name>/`（私有，搆不到 `/data/gfx/`） | `E/Module.lua:502` |
| `overload/` | `/`（VFS 根；第 3 參數 `false` = prepend，**優先於模組**） | `E/Module.lua:523` |

`overload/data/gfx/talents/x.png` → `/data/gfx/talents/x.png`，正好落在 §3 的第 2 段查找上，
於是 `image = "talents/x.png"` 找得到。

實證（`R/deathknight`）：自製天賦圖全部在 `R/deathknight/overload/data/gfx/talents/`，
引用寫成 `image = "talents/soul_reaper_raz.png"`（`R/deathknight/data/effects.lua:28`）
——**跟借用原版的寫法沒有任何差別**。`vendor/orig` 25 個 addon 共 1945 張 PNG，
其中 **1828 張在 `overload/data/gfx/` 底下**；剩下的 117 張全是 `R/remote-designer` 的網頁 UI 素材
（`data/html/…`，走瀏覽器不走 `Tiles`）＋ `R/addon-dev` 的 1 張（見下）。
**遊戲內顯示的自製美術，實務上 100% 走 `overload/`。**

### ⚠️ `overload` 掛在根，檔名撞到就是覆蓋原版

因為是 prepend（`E/Module.lua:523`），`overload/data/gfx/talents/manathrust.png` 會**把原版秘法沖擊的
圖示換掉**，全遊戲生效，沒有任何警告。自製圖一律加專屬字尾——deathknight 全部加 `_raz`
（`soul_reaper_raz.png`、`meat_shield_raz.png`…）就是為了這個。

### 另一條路：`addon+file` 語法（引擎支援，但沒人用過）

`E/Tiles.lua:69-76` 的 `baseImageFile` 認得 `<addon>+<相對路徑>`，展開成 `/data-<addon>/gfx/<相對路徑>`：

```lua
image = "witch+talents/hex.png"   -- → /data-witch/gfx/talents/hex.png
                                  -- 檔案實體：self_mods/tome-witch/data/gfx/talents/hex.png
```

好處是私有命名空間、撞不到原版。旁證：`R/addon-dev` 確實直接從自己的私有掛載點載圖——
`R/addon-dev/superload/mod/dialogs/debug/AddonDeveloper.lua:200`
`core.display.loadImage("data-addon-dev/gfx/default_addon_preview.png")`，
檔案實體在 `R/addon-dev/data/gfx/default_addon_preview.png`。**證明私有掛載點存得住也讀得到 PNG。**

**但**：ToME 模組本身與 `vendor/orig` 全部 25 個 addon，都找不到任何一處把 `+` 用在 `image` 上
（grep `"[A-Za-z0-9_-]+\+[A-Za-z0-9_/-]+\.png"` → 0 命中）。**本 repo 未實機驗證**，要用先 playtest。
另外這條路對職業圖示與音效都不通（見 §5、§6）。

## 4b. 物品／裝備貼圖：唯一有 tileset 變體的那一類

武器、護甲、飾品也是貼圖，寫法與其他圖一樣（`image = "object/artifact/xxx.png"`），
**但它們與天賦圖示走的查找結果不同**，因為 `Tiles:get()` 是兩段查找（`E/Tiles.lua:135-137`）：
先試 `Tiles.prefix..image`（`Tiles.prefix` = `/data/gfx/<tileset>/`，由
`M/mod/class/Game.lua:589` 依畫面設定設成 `shockbolt` 等），失敗才退回 `/data/gfx/<image>`。

**哪些類別真的有 tileset 變體**（以 `R/` 實體檔統計）：

| 類別 | 有 `shockbolt/` 變體 | 意義 |
|---|---|---|
| `npc/` `object/` `player/` `trap/` | **有** | 地圖上會看到的東西，各 tileset 各畫一份 |
| `talents/` `effects/` `class-icons/` | 沒有 | UI 圖示，全 tileset 共用 |

所以自製**物品圖**放 `overload/data/gfx/object/witchwood_x.png` **仍然找得到**（走第二段），
但在 shockbolt 玩家眼裡會與周圍格格不入；要對味就放
`overload/data/gfx/shockbolt/object/witchwood_x.png`。天賦圖示沒有這個問題。

另外物品還有一層**材質換圖**機制：`resolvers.image_material("lite", {"brass","","dwarven",...})`
會依 `material_level` 挑圖（`M/data/general/objects/lites.lua:23`）。
繼承 `base = "BASE_LITE"` 這類基底時，**圖是連同繼承來的**——
本 repo 的 `self_mods/tome-relics/` 四件神器就是這樣，自己沒寫任何 `image`。
自製物品若不想要材質變體，直接寫死 `image` 覆蓋即可。

