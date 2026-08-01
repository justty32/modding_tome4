# 大地圖、zone、與新增 campaign

> 目標版本 **ToME 1.7.6**。每一條都在原始碼複驗過並附行號。路徑代號見 [README.md](../README.md)。
> 實作範例：`self_mods/tome-runeisles/`（新大地圖 + 城鎮 + 兩個地城 + 主線）。

## 1. 大地圖不是特殊物件，只是一個 zone

`M/data/zones/wilderness/zone.lua:20-39`：一個 `persistent="zone"`、`wilderness=true`、
用 `engine.generator.map.Static` 讀一份 ASCII 地圖檔的普通 zone。

`wilderness = true` **引擎完全不認識**（`E/` 全域 grep 為零），只有 ToME 模組層讀它。
它是一個包裹式開關，開了就整包拿走，不能只挑一部分：

| 效果 | 位置 |
|---|---|
| 走一步 = 過 1000 個 turn | `M/mod/class/Player.lua:350-358` |
| 走一步觸發 world director AI | 同上 `:356` |
| FOV 整條管線被換掉，只用 `wilderness_see_radius` 算亮度漸暈 | `M/mod/class/Player.lua:557-561` |
| 技能／道具／滑鼠互動大量被鎖 | `Player.lua:1362,1367,1506`、`Actor.lua:1603` |
| 掉在地上的東西會永久遺失 | `Actor.lua:7967,8037` |

`wilderness_see_radius` 不設會退回 20（`E/interface/ActorFOV.lua:52`），
但 `wild_fovdist` 查表只算到 sqdist=100，於是漸暈失效、視野邊緣變硬邊。設個 ≤10 的整數（原版是 4）。

## 2. 地圖檔：純 Lua ASCII，尺寸必須精確

`M/data/maps/wilderness/eyal.lua` 是 170x100 的字元陣列，不是圖片、不是 `.tmx`。
`E/generator/map/Static.lua:466` 會先試同名 `.tmx`，找不到才走 Lua 分支（`:467-473`）。
**大部分官方城鎮也是純 Lua**（`M/data/maps/towns/` 底下只有 `angolwen.tmx` 用 Tiled）。

回傳值可以是「每列一個字串」或「每格一個字串的巢狀表」（`Static.lua:503-518`）。
多字元的格子（如 `[[derth]]`）只能用巢狀表那種。

### ⚠️ 尺寸對不上 = 直接崩潰

- `E/Map.lua:224` 先用 `zone.width * zone.height` 預配一個扁平陣列。
- `E/generator/map/Static.lua:486` 的 `m.w` **只讀第一列的長度**，`m.h` 是總列數。
- `:546-547` 事後把 map 的 w/h 覆寫成 ASCII 的實際尺寸。
- 於是 `E/Map.lua:562` 寫 `self.map[x + y*self.w][pos]` 時索引到沒被 init 過的位置 → `index a nil value`。

**任何一列長度不同，或與 zone.lua 的 width/height 不符，都會炸。**
`self_mods/tome-runeisles` 的地圖是腳本產生的，並在產生時 assert 每列等長——手寫 40 行 ASCII 很容易錯一格。

## 3. addon 的 zone 怎麼被找到

`E/Zone.lua:155-165`：
```lua
local base = "/data"                                     -- 硬編
local _, _, addon, rname = name:find("^([^+]+)%+(.+)$")  -- "addon+zone"
if addon and rname then base = "/data-"..addon; name = rname end
return base.."/zones/"..name.."/"
```
`/data/zones/` 是寫死的，**沒有 addon 搜尋路徑清單**。兩條互斥的路：

| init.lua 旗標 | 檔案放哪 | zone 短名寫法 |
|---|---|---|
| `data = true` | `data/zones/<name>/` → 掛在 `/data-<short>/`（`E/Module.lua:500-503`）| 必須寫 `"<short>+<name>"` |
| `overload = true` | `overload/data/zones/<name>/` → 疊到根目錄（`E/Module.lua:521-524`）| 純名字，與原版 zone 無法區分 |

同一套 `+` 前綴慣例也用在地圖檔（`E/generator/map/Static.lua:50-59`）、
對話檔（`E/Chat.lua:85-88`）、quest 檔（`M/mod/class/interface/ActorPartyQuest.lua:33-42`）、
wda 腳本（`M/mod/class/GameState.lua:776-785`）。

存檔檔名帶得動 `+`：實測產生 `zone-runeisles+stone-circle.teaz`，正常存讀。
