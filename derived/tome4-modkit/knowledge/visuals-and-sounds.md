# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` 見 [README.md](README.md)。
> `G = ~/.steam/steam/steamapps/common/TalesMajEyal/game/modules`

## 0. 這一整頁的前提

**粒子名、音效名、圖示路徑寫錯，都不會拋 Lua Error。**
只是安靜地什麼都不發生。`lint` 過、`verify` 過、selfcheck 全綠，遊戲裡什麼也看不到。

所以：**加了特效就必須用 `tools/playtest.sh` 實機看過**，或至少對照封包確認名字存在。

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

## 3. 天賦圖示

不指定 `image` 的天賦顯示成 `?`。直接借用既有圖示：

```lua
image = "talents/manathrust.png",
```

## 4. 字型

- **遊戲字型沒有古弗薩克文（Elder Futhark）字符**：`ᚠᚦᚲᚹᚺᛁᛉᛊᛏᛖᛗᛟ` 會渲染成豆腐方塊 `□`。
  只能放在原始碼註解與文件裡，不要放進 `info` / `desc` / log 訊息。
- 中文本身沒問題，**但要 `locale = "zh_hant"`**。英文語系的字型缺 CJK 字符，
  中文的技能樹名會渲染成**空白**。無頭測試的 scratch home 記得設
  （`tools/lib/scratch.sh` 的 `prepare_scratch_home` 預設就是 `zh_hant`）。
