# particles — 寫「新」粒子檔（劍氣、枝枒蔓延…）

路徑代號見 [README.md](README.md)。本檔補 [visuals-and-sounds.md](visuals-and-sounds.md) 的缺口：
那份只講「怎麼叫**現成**粒子」，這份講「怎麼**寫一個新粒子檔**」與各種發射幾何。

粒子檔實體在 `tome-gfx.team`（zip，316 個），引擎封包只有 `dummy.lua`。要讀原版粒子：
```bash
G=~/.steam/steam/steamapps/common/TalesMajEyal/game/modules
unzip -p $G/tome-gfx.team data/gfx/particles/<名字>.lua
```

## 三個承重事實（先讀）

1. **新粒子檔必須放 `overload/data/gfx/particles/`**，紋理放 `overload/data/gfx/particles_images/`。
   引擎一律從絕對路徑 `/data/gfx/particles/<name>.lua` `loadfile`（`E/Particles.lua:66`），
   addon 的私有 `/data-<addon>/` 搆不到——跟自訂 dialog 同理（見 [custom-ui.md](custom-ui.md)）。純新增、無覆寫衝突。
2. **參數靠 `setfenv` 注入**（`E/Particles.lua:70`）：`particleEmitter(x,y,radius,def,args)` 的 `args`
   表**每個 key 都變成粒子檔裡的全域變數**。`tx/ty/radius/dir/color` 全是這樣來的——呼叫端塞什麼、
   檔裡就讀得到什麼；讀不到會 fallback `_G`（`{__index=_G}`），所以要 `radius or 6` 自補預設。
   另外引擎自動附 `tile_w/tile_h`（`E/Particles.lua` 序列化段）。
3. **非 cheat 模式下，缺檔或紋理名寫錯 → 靜默替換成 dummy**（`E/Particles.lua:80-81`），不報錯。
   **測粒子一律開 `--cheat`** 才看得到 error。

## 一個粒子檔 = `return` 四個值

引擎在 `E/Particles.lua:71` 解 `_, _, _, gl, _ = f()`——只有第 1、2、3、4 位有意義：

| 位置 | 內容 | 範例 |
|---|---|---|
| 1 | `{ generator=fn, [use_shader=], [blend_mode=], [engine=], [system_rotation=] }` | 見下 |
| 2 | `function(self) ... self.ps:emit(N) end` 每幀更新 | 決定何時噴幾顆、何時停 |
| 3 | number 粒子池上限 | `30*radius*7*12` |
| 4 | **紋理名字串** `gl` | `"particles_images/beam"`；省略→內建點 |

`return` 之前還可設系統級全域欄位，`f()` 執行時被引擎讀走（`E/Particles.lua:74-79`）：
`use_shader`（套 GLSL shader）、`alterscreen`、`toback`（畫在角色後）、`can_shift`（隨鏡頭/彈道位移）、
`base_size`（zoom 參考尺寸，應等於紋理邊長）。

### generator 每顆粒子的欄位：全部是「值 / v / a」三件套

`generator()` 每誕生一顆粒子呼叫一次，回傳這顆的初始狀態。每個物理量都有
**`名`(初值) / `名v`(velocity，每幀加到值) / `名a`(acceleration，每幀加到 v)** 三件套
（引擎 Verlet 積分，`ball_arcane.lua` 逐欄可對）：

| 鍵 | 語意 | 單位 |
|---|---|---|
| `life` | 壽命 | 幀 |
| `trail` | 是否畫拖尾 | 布林/id |
| `size` `sizev` `sizea` | 大小 | 像素 |
| `x/y` `xv/yv` `xa/ya` | 位置（相對 emitter 中心） | **像素** |
| `dir` `dirv` `dira` | 移動方向角 | **弧度** |
| `vel` `velv` `vela` | 沿 `dir` 的速率 | 像素/幀 |
| `r,g,b` (各帶 v/a) | 顏色 | 0–1 浮點 |
| `a` `av` `aa` | 不透明度 | 0–1 浮點 |

**顏色靠 `r,g,b` 在執行期染色**，所以紋理畫成白/灰階透明形狀，別把顏色燒進圖裡。
傳入的 `tx/ty` 是**格**（tile），檔內要 `tx*tile_w` 才變像素（`light_beam.lua:23-24`）。

### update 的 `nb` 守衛 = 會不會停 = 會不會殘留

`self.ps:emit(n)` 請求本幀新生 n 顆。**有 `nb` 倒數守衛 → 發完自然停**（`ball_arcane.lua:50-56`
`if nb>0 then ... nb=nb-1 end`）；**無守衛 → 每幀無條件發射 → `isAlive()` 恆真 → 永久殘留**
（`arcane_power.lua:48-51` `self.ps:emit(8)`）。這就是 [visuals-and-sounds.md](visuals-and-sounds.md)
記的「arcane_power 丟給 map 會永久留在地圖上」的根。**一次性特效必須有 `nb` 守衛。**

### 兩條回收路徑

| | `map:particleEmitter`（丟地圖） | `addParticles`（掛角色） |
|---|---|---|
| 座標 | 呼叫時固定 | 跟隨角色 |
| 回收 | 引擎自動（`E/Map.lua:1488` `isAlive`→false 才收） | 角色每幀 callback（`E/Entity.lua:347,350`） |
| 無守衛粒子 | **殘留**，須手動 `removeParticleEmitter` | `deactivate` 時 `removeParticles` |

持續光環/sustain 用 `addParticles`；一次性施法特效用 `particleEmitter` + `nb` 守衛的 `ball_*`。
