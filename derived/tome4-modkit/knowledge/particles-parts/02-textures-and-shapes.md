# particles — 寫「新」粒子檔（劍氣、枝枒蔓延…）

## 紋理

- 第 4 回傳值＝紋理名，相對 `data/gfx/`、自動補 `.png`（`E/Particles.lua:89-91`）；
  fallback `/data/gfx/particle.png`（:92）。省略第 4 值 → 用內建 32×32 白點。
- 自製紋理：放 `overload/data/gfx/particles_images/<name>.png`，粒子檔第 4 值寫 `"particles_images/<name>"`（不含副檔名）。
- 規格：**PNG、8-bit RGBA、白/淺色形狀＋透明底**，執行期由 `r,g,b` 染色。慣用 **32×32 或 64×64**
  （引擎內建 `particle.png`=32×32、`particle_cloud.png`=64×64），非 2 次方（如 56×54）也能載。
  並設 `base_size` = 邊長。
- **很多形狀不必畫新圖**：放射/扇形/枝枒都能只用內建白點 + 粒子分佈 + 染色做出來。先走這條，省掉生圖不確定性。
- 要生圖時：agy 會寫 Pillow 腳本產 PNG（見記憶 reference-agy-cli），對白/灰階幾何精靈比 diffusion 可靠。

## 形狀速查：想要 X → 抄 Y

geometry 的關鍵都在 generator 怎麼決定**角度**與**位置**。以下皆原版檔（`unzip` tome-gfx.team 可讀）：

| 想要 | 抄 | 幾何關鍵（行號） |
|---|---|---|
| 360° 全向爆開（球） | `ball_arcane.lua` | 角度 `rng.float(0,360)`(:26-27)，起點在中心、靠 `dir`+`vel` 往外(:41-42) |
| A→B 一條直線光束（**射線**） | `acidbeam.lua` / `light_beam.lua` | `dir=atan2(ty,tx)`、長度=`|txty|`(:26-27)，沿線 `r=rng.range(1,len)`(:31)，`x=r*cos(dir)`(:40) |
| 光束+碎屑往回甩 | `earth_beam.lua` | 側偏 `±90°`、`dir=ray.dir+180`(:45) |
| **扇形/錐形**吐息 | `breath_fire.lua` | `spread=55/2`(:22)，角度限在 `rng.float(dir-spread,dir+spread)`(:29-30) |
| 扇形+分岔閃電 | `breath_lightning.lua` | `fork_i*spread/15` 把 31 條鋪滿扇面(:28-31) |
| 角色移動時原地冒煙/殘影 | `arcanetrail.lua` | 局部小半徑全向、生成後不動靠 life 淡出(:25-29,41-42) |
| 瞬間一條完整軌跡線 | `blood_trail.lua` | `ENGINE_LINES`，16 點排成直線(:28-39)，`system_rotation=dir`(:42) |
| 彈體帶尾焰飛 | `bolt_arcane.lua` | `can_shift=true`(:20)+原地小泡泡；引擎沿彈道搬移 |
| 單張圖朝飛行方向旋轉（箭/刀） | `arrow.lua` | `system_rotation=225+atan2(...)`(:23)，`emit(1)` 只發那張圖(:38) |
| 地格長駐環境圈 | `blightzone.lua` | 小半徑侷限格內、緩慢內縮(:27,35-36) |
| 一點週期脈動擴散環 | `corpselight_wave.lua` | 尺寸隨 life 長大 `sizev=radius*2/life`(:30)，週期重發(:44-47) |

**四個地雷**（agent 實查糾正，別踩）：
- `ball_lightning_beam.lua` 檔名有 beam 但**是放射狀**（繞 360° 生 36 條分岔，無 `tx/ty`），不是點到點射線。
- `generic_wave.lua` 本質是**扇形**（沿用 breath 的 `spread` 公式），非全向波；要全向得自己把 spread 開大。
- `creeping_dark.lua` 是**矩形亂灑的地格特效**（無擴張分量），不是波。
- `shockwave.lua` **沒有 shader 時完全空白**（default 分支自承 `-- This is just an empty one`）；抄它要連 shader 分支抄。
