# 引擎事實：視覺特效、音效、圖示

> 路徑代號 `E` / `M` / `R` 見 [README.md](../README.md)。
> `G = ~/.steam/steam/steamapps/common/TalesMajEyal/game/modules`

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

粒子定義檔是 **Lua 不是圖片**；寫法細節見 [particles-parts/01-core-mechanics.md](../particles-parts/01-core-mechanics.md)
與 [02-textures-and-shapes.md](../particles-parts/02-textures-and-shapes.md)。
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
