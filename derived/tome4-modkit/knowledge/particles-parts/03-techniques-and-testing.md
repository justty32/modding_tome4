# particles — 寫「新」粒子檔（劍氣、枝枒蔓延…）

## 劍氣（blade wave / 弧形斬）

三條路，建議先做 1（純幾何、免 shader、免新圖）：

1. **fork `generic_wave.lua`**（扇形）→ 把 `spread`(:22) 收窄成細弧、把出生半徑（目前粒子同一點）
   改成沿一條彎線排列（generator 裡讓每顆的起點 `x,y` 落在 `基準dir` 的圓弧上），即得新月刀光。零新紋理。
2. **fork `tk_rotating_weapon.lua`**（`ORIG:26-58`，真幾何弧線）：粒子在半徑 `r=14` 的圓上
   `x=r*cos(a),y=r*sin(a)`(:44-45)、方向取切線 `dir=rad(ad+90)`(:28)。把角度範圍從整圈限成一段區間 emit
   → 從「繞圈」變「半月斬」。紋理 `shockbolt/*`。
3. **直接用 `meleestorm2.lua`**：只發 1 顆大粒子、弧光全靠 `use_shader={type="spinningwinds"}`(:24)+
   `system_rotation`(:29)。最省事但外觀是旋風不是單刀。原版近戰天賦就用它
   （`M/data/talents/techniques/2hweapon.lua:53`、`dualweapon.lua:429`）。
   要飛行的新月刃彈：畫一張白色新月 PNG，`emit(1)` + `system_rotation` 對準行進方向，配尾跡。

## 枝枒蔓延（分叉延伸）

兩種明確做法：

- **做法 A ─「forks 分支表」（最像藤蔓分叉，且免紋理）**：建分支表，主幹 2 條，迴圈生子分支，
  子分支從父分支上某點以 `±30°` 岔出（`f.dir = m.dir + math.rad(rng.range(-30,30))`），generator 隨機挑
  一條分支沿其方向撒點。**同一套演算法被多檔複用**：
  - **`tanglevine.lua`**（R/verdant，`overload/data/gfx/particles/tanglevine.lua`，81 行）：綠色木色、**無紋理用內建點**。分支表 :20-53、岔角 :47、沿分支撒點 :55-77。→ **最該 fork 的**。改：岔角範圍(:47)、fork 數(:41 迴圈)、顏色(:72-74)、粗細 `f.thick`。
  - **`lightning.lua`**（原版）：同演算法、藍白閃電配色，也無紋理。原版 `M/data/talents/spells/storm.lua:53` 用它。
  - **`fissure.lua`**（R/verdant）：同演算法、土黃＋原地淡出＝地裂蔓延。
- **做法 B ─「ENGINE_LINES 連線逐段生長」**：`engine=core.particles.ENGINE_LINES`，維護 `points[]`，
  每點 `prev` 連上一點成折線；update 每幀只消費若干點 → 折線**逐段長出來**。
  - **`stonevine.lua`**（原版）：`make_beam`(:29-55)、`prev=#points-1`(:49)、`ENGINE_LINES`(:62)、10 條 fork(:57)、紋理 `"particles_images/beam"`(:90)。
  - **`null_blood_beam.lua`**（R/nullpack）：同做法、20 條 fork。
  - 要真正「樹狀分枝」：在中間點遞迴再生較短的子 beam（起點=該中點）。

**選型**：要顆粒感藤蔓/雷枝 → 做法 A（`tanglevine`）；要平滑連續、逐段生長的枝條線 → 做法 B（`stonevine`，需 `beam.png`）。

## 測試

- **一定開 `--cheat`**（否則缺檔/錯名靜默變 dummy，看不出錯）。
- 呼叫：`game.level.map:particleEmitter(self.x, self.y, dist, "sword_qi", {tx=x-self.x, ty=y-self.y, color={r=..,g=..,b=..}})`。
- 殘留檢查不看畫面、用數的：`#game.level.map.particles` 幾秒後應掉回原值（見 [visuals-and-sounds.md](visuals-and-sounds.md) §驗殘留）。
- `playtest.sh lua` 走 xdotool 只吃 ASCII——粒子名與 define 用 ASCII。
