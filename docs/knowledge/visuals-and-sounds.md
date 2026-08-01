# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` / `R` 見 [README.md](README.md)。
> `G = ~/.steam/steam/steamapps/common/TalesMajEyal/game/modules`

## 0. 這一整頁的前提

**粒子名、音效名、圖示路徑寫錯，都不會拋 Lua Error。**
只是安靜地什麼都不發生。`lint` 過、`verify` 過、selfcheck 全綠，遊戲裡什麼也看不到。

所以：**加了特效就必須用 `tools/playtest.sh` 實機看過**，或至少對照封包確認名字存在。

### 分工原則：三類資產，三條路

| 資產 | 怎麼來 | 為什麼 |
|---|---|---|
| **動態特效／粒子** | **自己寫 Lua** | 它本來就是 Lua 不是圖（`E/Particles.lua:66`）|
| **靜態貼圖** | **AI 生圖**（`agy`）+ 補 alpha | 本來就是死圖，生成模型做得來 |
| **音效** | **只能借原版** | `agy` 沒有音訊生成能力（2026-08-01 實測問過）|

**動態視覺一律自己寫 Lua**——形狀速查與現成範例見
[particles-parts/](particles-parts/01-core-mechanics.md)，那裡有做出來過的劍氣與枝枒蔓延。
交給生圖模型只會得到一張不會動的插畫，還繞過了引擎真正的粒子系統。

**AI 圖像生成只用在靜態貼圖**：怪物／地形／物品／天賦圖示／職業圖示這類單張 PNG。

**音效目前沒有生成管道**，實務上就是從原版 242 個 `.ogg` 裡挑（`creatures/` 110、
`ambient/` 61、`talents/` 39、`actions/` 31）。清單怎麼列見 §2。
真要自製音效，得從本 repo 之外取得檔案再放進 `overload/data/sound/`（機制見 §6，但無第三方實證）。

實務注意（`agy` 實測）：它把圖存在**自己的 scratch 目錄**而非你的工作目錄，要自己 `cp` 出來；
而且**產出的 PNG 沒有 alpha 通道**（即使你要求透明背景），要自己補：

```bash
magick in.png -fuzz 12% -transparent white out.png
magick identify -format '%[channels]\n' out.png   # 要 srgba，不是 srgb
```

**成品好不好看由使用者判斷**，AI 不讀圖自評（[AGENTS.md](../../AGENTS.md) 鐵律 6）。

## 1. 三種特效，三套 API

用錯不會報錯，只是沒有該有的樣子。

| 想要 | 怎麼寫 | 出處 |
|---|---|---|
| **飛行彈道**（法術彈） | `target` 回傳 `{type="bolt", ..., display={particle="bolt_arcane", trail="arcanetrail"}}`，再 `self:projectile(tg, x, y, dt, dam, {type="manathrust"})` | `M/data/talents/spells/arcane.lua:39,58` |
| **範圍爆炸／地面特效** | `game.level.map:particleEmitter(x, y, radius, "ball_fire", {radius=radius})` | 各 `ball_*` 粒子檔吃 `radius` |
| **光束** | `particleEmitter(self.x, self.y, dist, "light_beam", {tx=x-self.x, ty=y-self.y})` | `M/data/talents/spells/air.lua:48-50` |
| **命中特效**（不飛） | `self:project(tg, x, y, dt, dam, {type="freeze"})` ← **第 6 參數** | `M/data/talents/spells/ice.lua:45` |
| **持續光環**（buff / sustain） | `p.particle = self:addParticles(Particles.new("arcane_power", 1))`，deactivate 時 `self:removeParticles(p.particle)` | `M/data/talents/spells/aegis.lua:36` |
| **音效** | `game:playSoundNear(self, "talents/arcane")` | 全庫慣用 |

`Particles` 要自己 `local Particles = require "engine.Particles"`。

### 常見誤用（我全部踩過）

- **`projectile()` 的第 6 參數是彈體自身的粒子，不是飛行外觀。**
  飛行外觀在 `target` 的 `display`。用 `type="hit"` 當 target 就**沒有飛行過程**，
  只會在目標格閃一下。
- **`stone_spikes` 是 `project()` 的命中特效**（`M/data/talents/spells/eldritch-stone.lua:72`），
  不是彈道粒子。
- `particleEmitter` 的 `ball_*` 一定要傳 `{radius=r}`，`*_beam` 一定要傳 `{tx=…, ty=…}`。

### ⚠️ `Particles.new()` 的第 3 個參數也是同一組參數，而且**粒子檔的預設值各寫各的**

`Particles.new(name, zoom, params)` 的 `params` 就是粒子檔裡讀得到的那些全域。
`addParticles(Particles.new("ball_teleport", 1))` 這種「照抄別的粒子」的寫法會炸：

| 粒子檔 | 第一行怎麼寫 | 少傳 radius 的下場 |
|---|---|---|
| `ball_teleport.lua:22` | `local radius = radius` | **拋 Lua Error**（`:63` 的 `5*radius*266` 對 nil 做算術）|
| `ball_fire.lua:29,63` | `local radius = radius or 6` | 不炸，但半徑變 6 |
| `ball_arcane.lua:22` | `local radius = radius or 6` | 不炸，但半徑變 6 |
| `arcane_power.lua` | 不使用 radius | 無事 |

2026-07-10 實機：盧恩術士的 `T_RW_EHWAZ` 施放時必炸，就是 `timed_effects.lua` 裡
`Particles.new("ball_teleport", 1)` 少了 `{radius=1}`。旁邊三個效果用同樣寫法卻沒事，
因為它們的粒子檔剛好有 `or 6` 的預設值——**「隔壁那行這樣寫沒問題」不能當根據**。

粒子檔在 `tome-gfx.team`（不在 `tome.team`，也不在引擎封包）：

```bash
unzip -p $G/game/modules/tome-gfx.team data/gfx/particles/ball_teleport.lua | grep -n radius
```

### ⚠️ `arcane_power` 丟給 `particleEmitter` 會**永久留在地圖上**

`E/Map.lua:1488-1496`：地圖上的粒子只有在 `e.ps:isAlive()` 為 false 時才會被 `removeParticleEmitter` 回收。
粒子檔的「更新函式」決定它會不會停：

| 粒子 | 更新函式 | 會停嗎 |
|---|---|---|
| `arcane_power` | `self.ps:emit(8)`（無條件）| **永不停止 → 永久殘留** |
| `ball_arcane` | `if nb > 0 then … nb = nb - 1 end` | 會 |
| `ball_teleport` | `if nb < 5 then …` | 會 |
| `ball_fire` / `ball_ice` | 有 `nb` 守衛 | 會 |
| `light_beam` | `if self.nb < 4 then …` | 會 |

**`arcane_power` 只能配 `addParticles`**（掛在角色身上，`deactivate` 時 `removeParticles` 手動移除）。
2026-07-10 使用者回報「某個技能的特效施放後不會消失」，就是把它丟給了 `game.level.map:particleEmitter`。
一次性施法特效請用 `ball_*`。

#### 同一個坑的第二種形態：把「飛行粒子」拿去當「命中粒子」

2026-08-01 使用者實機回報女巫的 `T_WITCH_BREW` 特效抵達目標後不消失。根因同上，
但入口不是 `particleEmitter`，而是 **`projectile()` 的第 6 參數**：

```lua
-- ✗ 錯：bolt_slime 是飛行用的，無條件 emit(30)，永遠 isAlive → 落點永久殘留
self:projectile(tg, x, y, DamageType.POISON, dam, { type = "bolt_slime" })
-- ✓ 對：slime 是爆點用的，有 `if self.nb < 6` 守衛會自己停
self:projectile(tg, x, y, DamageType.POISON, dam, { type = "slime" })
```

一發彈道其實有**三個不同角色的粒子**，名字相近但不可互換
（原版三者並列的寫法見 `M/data/talents/spells/staff-combat.lua:60`）：

| 角色 | 填在哪 | 例 |
|---|---|---|
| 飛行中 | `target.display.particle` | `bolt_slime` |
| 拖尾 | `target.display.trail` | `slimetrail` |
| **命中爆開** | **`projectile()` 第 6 參數** | **`slime`** |

原版 9 處用到 `bolt_slime` 的地方**全部只放在 `target.display`**，
沒有任何一處把它當第 6 參數（`grep -rn 'bolt_slime' M/data/talents/` 自己看）。
實際呼叫前例：`M/data/talents/gifts/slime.lua:38` 的 `{type="slime"}`。

判定方法（不用猜）：

```bash
unzip -p $G/game/modules/tome-gfx.team data/gfx/particles/<名字>.lua | sed -n '/^function(self)/,/^end/p'
```
沒有 `nb` 之類的計數守衛 = 無限發射。

### 這類 bug 怎麼抓

`verify.sh` 抓不到（載入期不會建粒子），`playtest.sh` 按快捷鍵也常常施放不到。
用 Lua console 直接把效果打開，繞過法力／冷卻／快捷鍵（見 [playtesting.md](playtesting.md) §3.5）：

```bash
tools/playtest.sh start <addon> --cheat
tools/playtest.sh lua 'game.player:setEffect(game.player.EFF_你的效果, 5, {})'
tools/playtest.sh log   # 有 Lua Error 會被印出來
```

⚠️ 用 `useTalent` 驗證會得到**假綠燈**：狂戰士沒有法力，`T_RW_EHWAZ` 在資源檢查階段就被擋下，
`activate()` 根本沒跑，於是「沒有 Lua Error」什麼都沒證明。要嘛給角色資源
（`game.player.mana = 100 game.player.max_mana = 100`），要嘛直接 `setEffect`。

驗「粒子有沒有殘留」不用看畫面，數就好——`#game.level.map.particles` 應該在幾秒後掉回去：

```bash
tools/playtest.sh lua 'print("[T] n="..#game.level.map.particles)'   # 施放前
tools/playtest.sh lua 'game.player:useTalent(game.player.T_你的天賦)'
tools/playtest.sh lua 'print("[T] n="..#game.level.map.particles)'   # 施放後（+1）
# 等 8 秒
tools/playtest.sh lua 'print("[T] n="..#game.level.map.particles)'   # 應該掉回原值
```

⚠️ `playtest.sh lua` 走 `xdotool type`，**只能用 ASCII**。Lua 字串裡放中文的話那一行會整個送不進去，
不報錯、只是 print 不出來，看起來像程式碼沒執行。

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

## 5. 職業圖示（class icon）

`M/mod/dialogs/Birther.lua:59-68` 的 `setSubclassIcon`。**檔名不是你指定的，是從 class 的英文
`name` 算出來的**：`t.name:lower():gsub("[^a-z0-9]", "_")`，前綴 `class-icons/`，後綴 `_32_bg.png` / `_128_bg.png`
（`:60-61`）。

| class `name` | 必須提供的檔名 |
|---|---|
| `Witch` | `class-icons/witch_32_bg.png`＋`class-icons/witch_128_bg.png` |
| `Steam Witch` | `class-icons/steam_witch_32_bg.png`＋`…_128_bg.png` |
| `Sun Paladin` | `class-icons/sun_paladin_32_bg.png`＋`…_128_bg.png` |

- 位置：**只能** `overload/data/gfx/class-icons/`。`:62` 用 `Tiles.baseImageFile(t.image32)` 檢查，
  而 `image32` 是算出來的、永遠不含 `+`，所以 §4 那條 `addon+` 路走不通。
- 尺寸：原版 `berserker_32_bg.png` = 32×32 RGBA、`berserker_128_bg.png` = 128×128 RGBA。
- 缺圖：**不崩潰**，靜默換成 `class-icons/unknown_32_bg.png` / `unknown_128_bg.png`（`:63-64`），無 log。
- **只檢查 32 那張**（`:62`）。32 缺席時 128 也一起被換掉，即使 128 你有提供。

實證反例（`R/steamwitch`）：class 叫 `Steam Witch`（`R/steamwitch/data/birth/classes/tinker.lua:26`），
該給 `steam_witch_32_bg.png`，實際只有 `steam_witch_bg.png`（31×32）與 `steam_witch_128_bg.png`。
**兩張都白做了**，遊戲裡顯示 unknown。靜默失敗的活體標本。

### 時序：addon 的 class 趕得上那個迴圈嗎？

`Birther.lua:69` 是**頂層**迴圈，一次掃完當時已註冊的所有 subclass。
`mod.dialogs.Birther` 最早在 `M/mod/class/Game.lua:33` 被 require，而 `mod.class.Game`
要到 `M/mod/load.lua:300` 才載入——**晚於 `:267` 的 `triggerHook{"ToME:load"}`**。
所以在 `ToME:load` hook 裡 `Birther:loadDefinition` 註冊的 class **會**被掃到，圖示正常。

⚠️ 反過來說，若你的 `hooks/load.lua` 自己 `require "mod.dialogs.Birther"`，就會把這個迴圈提早跑掉，
之後註冊的 class 全都沒有 `display_entity32`；Birther UI 在 `M/mod/dialogs/Birther.lua:155`
遇到 nil 直接 `return`，那格空白、不崩潰。

## 6. 自製音效

`E/interface/GameSound.lua:51,60,62` 三處都硬編 `/data/sound/`，**完全沒有 addon 前綴機制**
（ToME 也沒有覆寫 `playSound`）。所以：

- 檔案放 `overload/data/sound/<你的目錄>/<name>.ogg`
- 呼叫 `game:playSoundNear(self, "<你的目錄>/<name>")`（不含副檔名）
- 格式 OGG Vorbis：原版全庫都是 `.ogg`，`:55` 的預設也是補 `.ogg`

要調音量就多放一個同名 `.lua`（`:51-57` 會優先讀它），原版範例
（`unzip -p $G/tome.team data/sound/talents/fireflash.lua`）：

```lua
return { file = "talents/fireflash.ogg", volume = 50 }
```

`file` 相對 `/data/sound/`；`volume` 是百分比，在 `:75` 乘進最終音量。

⚠️ `vendor/orig` 25 個 addon **一個 `.ogg` 都沒有**（`find vendor/orig -name '*.ogg'` → 0）。
自製音效這條路只有引擎程式碼支持，**無第三方實證**。

## 7. 自製粒子與粒子紋理

粒子定義檔是 **Lua 不是圖片**；寫法細節見 [particles-parts/01-core-mechanics.md](particles-parts/01-core-mechanics.md)
與 [02-textures-and-shapes.md](particles-parts/02-textures-and-shapes.md)。
路徑面：引擎硬編 `loadfile("/data/gfx/particles/<name>.lua")`（`E/Particles.lua:66`），沒有 addon 前綴，
所以粒子檔只能放 `overload/data/gfx/particles/`；紋理放 `overload/data/gfx/particles_images/`，
粒子檔第 4 個回傳值寫**不含副檔名**的相對名（`E/Particles.lua:91` 會補成 `/data/gfx/<gl>.png`）。
實證：`R/verdant/overload/data/gfx/particles/autumntide.lua:50` 回傳 `"particles_images/autumnleaf"`，
檔案在 `R/verdant/overload/data/gfx/particles_images/autumnleaf.png`。

## 8. 資產路徑寫錯時會怎樣（全部不崩潰）

| 寫錯什麼 | 症狀 | log 有沒有線索 | 出處 |
|---|---|---|---|
| 天賦 `image` 找不到 | 顯示原版佔位圖 `talents/default.png`（**不是** ASCII `?`） | **無**，完全靜默 | `M/data/talents.lua:79-80` |
| 天賦不寫 `image` | 自動推 `talents/<short_name 或 name 小寫>.png`，找不到再退 default | 無 | `M/data/talents.lua:76-77` |
| 狀態效果 `image` 找不到 | 顯示 `effects/default.png` | **有**：印出 `=== <type> <name>` | `M/data/timed_effects.lua:60-61` |
| 職業圖示檔名不對 | 顯示 `unknown_32/128_bg.png` | 無 | `M/mod/dialogs/Birther.lua:62-64` |
| 一般 Entity（NPC／物件）`image` 找不到 | 退回用字型畫 `display` 那個 ASCII 字元 | 只有 `Loading tile <image>`（不分成敗） | `E/Tiles.lua:135-137,144-152` |
| 音效名寫錯 | 無聲；`playSound` 在 `:73` 直接 return | **有**：`[SOUND] loading from … :=: unknown file` | `E/interface/GameSound.lua:67,73` |
| 粒子名寫錯（非 cheat） | 靜默換成 `dummy` | 有：`[PARTICLES] system… does not exist` | `E/Particles.lua:61-63` |
| 粒子紋理名寫錯 | 靜默退回 `/data/gfx/particle.png` 白點 | 無 | `E/Particles.lua:91-92` |

**離線自查**（不用開遊戲看畫面）——引擎用哪個判斷，你就用哪個判斷：

```bash
tools/playtest.sh lua 'local T=require"engine.Tiles" print("[T] "..tostring(fs.exists(T.baseImageFile("talents/hex.png"))))'
```

天賦與職業圖示都是走 `Tiles.baseImageFile` + `fs.exists`（`M/data/talents.lua:79`、
`M/mod/dialogs/Birther.lua:62`），所以這一行的答案就是遊戲的答案。音效與粒子則 grep log 找
`unknown file` / `[PARTICLES]`。

## 9. 字型

- **遊戲字型沒有古弗薩克文（Elder Futhark）字符**：`ᚠᚦᚲᚹᚺᛁᛉᛊᛏᛖᛗᛟ` 會渲染成豆腐方塊 `□`。
  只能放在原始碼註解與文件裡，不要放進 `info` / `desc` / log 訊息。
- 中文本身沒問題，**但要 `locale = "zh_hant"`**。英文語系的字型缺 CJK 字符，
  中文的技能樹名會渲染成**空白**。無頭測試的 scratch home 記得設
  （`tools/lib/scratch.sh` 的 `prepare_scratch_home` 預設就是 `zh_hant`）。
