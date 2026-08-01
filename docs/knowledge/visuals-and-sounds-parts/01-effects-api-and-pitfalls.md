# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` / `R` 見 [README.md](../README.md)。
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
[particles-parts/](../particles-parts/01-core-mechanics.md)，那裡有做出來過的劍氣與枝枒蔓延。
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

### ⚠️ 但這條「生圖 + fuzz 去背」的路對**有機造型**（樹、毛髮、煙霧）會失敗

2026-08-01 實機回報：女巫森林的兩張樹貼圖「沒有去背」。回頭查是這條路徑的結構性問題：

- `-fuzz N% -transparent` 產出的是 **1-bit alpha**——每個像素只有全透明或全不透明。
  邊緣因此沒有抗鋸齒，而且會留下**一圈沒被 key 到的殘邊**（實測是亮洋紅色斑點，
  因為生圖模型給的「白背景」其實帶色偏）。
- fuzz 開大一點想清掉殘邊，就會把**跟背景同色的主體**一起鑿穿。
  實測 tree2 的樹幹整片變蜂窩（735/4096 不透明像素，樹幹只剩碎點）。
- **alpha 資訊一旦被壓成 1-bit 就救不回來**，重新 key 沒有用，只能重做。

怎麼判斷手上的圖有沒有這個病（不必看圖）：

```bash
magick identify -verbose x.png | grep -A2 'Channel depth'      # Alpha: 1-bit 就是有病
magick x.png -alpha extract -format 'semi=%[fx:int(w*h*mean)]' info:   # 半透明像素數，0 = 沒抗鋸齒
```

**首選做法是從原版美術資產衍生**——它們本來就有乾淨的 8-bit alpha 與抗鋸齒，
而且風格自動跟遊戲一致。色調位移就能換色系：

```bash
# 綠葉 → 詛咒紫。-modulate B,S,H：H=100 不變，每 +1% 約 +1.8 度
magick vendor/.../shockbolt/terrain/swamptree2.png -modulate 95,140,212 \
       -define png:color-type=6 out.png
```

`vendor/t-engine4/modules/tome/data/gfx/shockbolt/terrain/` 底下光是樹就有 485 張。
`-define png:color-type=6` 不可省，否則會存成索引色（PaletteAlpha），引擎會噴 truecolor 警告。
實例與選色過程見 `self_mods/tome-witchwood/data/zones/witchwood/grids.lua` 的樹定義註解。

**生圖留給原版沒有的東西**（獨特 NPC、職業圖示這類），而且要選**邊緣單純**的構圖。

**成品好不好看由使用者判斷**，AI 不讀圖自評（[AGENTS.md](../../../AGENTS.md) 鐵律 6）——
但「alpha 是不是 1-bit」「有沒有殘邊」是**可量測的技術缺陷**，那個要自己用上面的指令查。

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
用 Lua console 直接把效果打開，繞過法力／冷卻／快捷鍵（見 [playtesting.md](../playtesting.md) §3.5）：

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

#### ⚠️ 只數 `map.particles` 會漏掉一整類：掛在角色身上的光環

2026-08-01 稽核 `tome-runewright` 全部 15 個粒子呼叫點時實測到的。

**角色粒子不在 `game.level.map.particles` 裡**，在 `actor.__particles`
（`E/Entity.lua:251, 290`）。持續型光環（`addParticles` / `removeParticles`）走的是後者，
所以只數 map 會得到「全部 0」的假安心。兩邊都要數：

```lua
-- 地圖粒子
print("[T] map="..#game.level.map.particles)
-- 角色粒子（是 hash 不是陣列，要自己數）
local c=0 for k in pairs(game.player.__particles) do c=c+1 end print("[T] actor="..c)
```

順便印 `e.def` 與 `e.x, e.y`（`E/Particles.lua:60` 的 `self.def` 就是粒子名）——
一眼看出殘留的是哪個粒子、留在哪一格，比只看數字有用得多。

#### ⚠️⚠️ 沒有正對照的「全部回 0」什麼都沒證明

量錯地方、或天賦根本沒真的施放，都會給你一排漂亮的 0。**跑完受測天賦後，
務必再故意製造一次已知的殘留**，確認你的量尺抓得到：

```lua
game.level.map:particleEmitter(game.player.x, game.player.y, 1, "arcane_power", {})
```

它會穩定停在 `n=1` 不掉（實測 15 秒、到 session 結束都還在）。
量尺對這個回 1、對你的天賦回 0，那個 0 才有意義。

