# 引擎事實：NPC 與對話

> 路徑代號 `E` / `M` 見 [README.md](README.md)。
> 全部在 2026-07-10 做「技藝導師」（`self_mods/tome-talent-tutor/`）時複驗過。

## 1. 對話檔不需要 `overload`

`E/Chat.lua:85-88` 支援 `"<addon>+<file>"` 的路徑慣例：

```lua
can_talk = "talent-tutor+tutor"   -- → /data-talent-tutor/chats/tutor.lua
```

所以 addon 自己的對話放在 `data/chats/` 就好。

**不要學 `master-spell-merchants`**：它用 `overload/data/chats/*.lua` 整檔覆蓋原版對話，
任何同樣覆蓋那些檔的 addon 都會跟它打架。`overload` 只在真的要取代原版檔案時才用。

## 2. ⚠️ 對話檔必須 `return "<起始 chat id>"`

```lua
-- E/Chat.lua:70
if setid then self.default_id = f() else return f() end
```

**檔案的回傳值就是起始 chat 的 id。** 漏掉這行，`default_id` 是 nil，
一跟 NPC 說話就炸：

```
Lua Error: /engine/dialogs/Chat.lua:134: attempt to index a nil value
  At /engine/dialogs/Chat.lua:134 resolveAuto
```

原版 98 個對話檔裡有 92 個以 `return "welcome"` 收尾。**照做。**

## 3. `newChat` 的 answers

| 事實 | 出處 |
|---|---|
| 選項文字是**靜態字串**（`a[1]`），拿不到 `player` | `E/dialogs/Chat.lua:101` |
| `cond(npc, player)` 回 false 的選項不會顯示 | `E/dialogs/Chat.lua:160` 附近 |
| `action(npc, player)` 先執行；它的**回傳值可以覆蓋 `jump`** | `E/dialogs/Chat.lua:103-110` |
| `jump` 可以是字串，也可以是 `function(npc, player)` | `E/dialogs/Chat.lua:112-115` |
| `action` + `jump` 同時給 → 執行完跳過去（可以做「學完留在同一頁」） | 同上 |

**動態清單**：對話檔在**每次開啟對話時重新執行**，所以可以用迴圈生成 `newChat`，
清單會自動反映其他 addon 帶進來的內容。

### ⚠️ 對話框會被擠出畫面底部

對話框錨定在 NPC 附近，選項一多就會有一截落在畫面外（實機 1280x800 重現）。
**把「返回」「上一頁／下一頁」這類導航選項放在 answers 的最前面**，
否則玩家會卡在那一頁出不去。第一個選項預設是 highlight 的，按 Return 就能選到——
即使它根本沒被畫出來。

## 4. 在大地圖放一個固定 NPC

```lua
local class = require "engine.class"
local Map = require "engine.Map"

class:bindHook("Game:changeLevel", function(self, data)   -- M/mod/class/Game.lua:1442
    if not game.zone or not game.level then return end
    if game.zone.short_name ~= "wilderness" then return end
    if game.level.__my_npc_placed then return end

    local WorldNPC = require "mod.class.WorldNPC"
    local npc = WorldNPC.new{
        name = "技藝導師", type = "humanoid", subtype = "human",
        faction = "allied-kingdoms",
        display = '@', color = colors.LIGHT_BLUE,
        image = "npc/humanoid_human_apprentice_mage.png",
        can_talk = "myaddon+mychat",
        cant_be_moved = true, never_move = true,
    }
    npc:resolve() npc:resolve(nil, true)
    game.zone:addEntity(game.level, npc, "actor", x, y)
    game.level.__my_npc_placed = true
end)
```

- `Game:changeLevel` 在 `changeLevel` 收尾時觸發，此時 `game.zone`、`game.level` 都已就緒。
- wilderness 是 `persistent = "zone"`，放過一次會存進存檔，**務必擋重複**。
- 玩家撞上去就會開啟對話（`M/mod/class/WorldNPC.lua:50` 檢查 `can_talk`）。

### ⚠️ 不要把 NPC 放在區域入口格上

城鎮與地城的入口本身是「可站人、可 encounter」的地形，
只是多了 `change_zone`（`M/data/zones/wilderness/grids.lua:509-513` 的 `TOWN_DERTH`）。
把 NPC 放上去會**擋住玩家進城**。挑位置時要一併排除：

```lua
if game.level.map:checkAllEntities(x, y, "change_zone") then return false end
if game.level.map:checkAllEntities(x, y, "change_level") then return false end
```

能不能站人的兩個條件（`M/data/zones/wilderness/zone.lua:77` 挑 encounter 位置用的就是它們）：
`not block_move` 且 `can_encounter`。硬猜座標很容易落在水裡或山上——**從錨點向外搜尋**。

大地圖座標可查 `M/data/maps/wilderness/eyal.lua` 的 `addSpot`（德斯城在 `(25,17)`，`:177`）。

## 4.5 特殊／獨特 NPC：定義與貼圖

> 「怪物」與「種族」是兩種不同的東西，差別見
> [races-and-tiles.md §1.5](races-and-tiles.md)。**NPC 的美術成本比種族低兩個數量級。**

### 定義：就是一個 `newEntity`，繼承基底

原版獨特 orc 的完整寫法（`M/data/general/npcs/orc.lua:279-315`，`nice_tile` 在 `:282`）：

```lua
newEntity{ base = "BASE_NPC_ORC",
  name = "Kra'Tor the Gluttonous", unique = true,
  color = colors.DARK_KHAKI,
  resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_kra_tor_the_gluttonous.png", display_h=2, display_y=-1}}},
  desc = _t[[...]],
  level_range = {38, nil}, exp_worth = 2,
  rarity = 50,          -- 沒有 rarity 就永不隨機生成
  rank = 3.5,           -- 3.5 = boss 級
  max_life = resolvers.rngavg(600, 800), life_rating = 22,
  resolvers.auto_equip_filters("Berserker"),
  resolvers.equip{ {type="weapon", subtype="battleaxe", defined="GAPING_MAW", autoreq=true}, ... },
  resolvers.drops{chance=100, nb=2, {tome_drops="boss"}},
  autolevel = "wyrmic",
}
```

⚠️ `resolvers.equip` 要 zone 的 `object_list` 非空，否則**靜默空手**——見 §6。
⚠️ 少了 `name` 欄位，玩家一殺就 `all_kills[nil]` 崩潰（`M/mod/class/Actor.lua:3451`）。

### 貼圖：一般怪 1 張，大型怪也是 1 張

實測 `M/data/gfx/shockbolt/npc/` 共 636 張，尺寸分佈：

| 尺寸 | 張數 | 用法 |
|---|---|---|
| **64×64** | 455 | 一般怪。直接 `image = "npc/xxx.png"` |
| **64×128** | 176 | **大型／boss**。要配 `nice_tile`（見下）|
| 更大（128×256 等） | 3 | 極少數巨物 |

**所以做一隻特殊 NPC 的美術成本是「一張 PNG」**，跟種族的 ~780 張完全不是一回事。

### 佔兩格高的大型怪：`resolvers.nice_tile` 的固定咒語

64×128 的圖不能直接塞 `image`——格子只有 64×64，會被壓扁。要走 `add_mos` 疊圖並宣告高度：

```lua
resolvers.nice_tile{image="invis.png", add_mos={{image="npc/xxx.png", display_h=2, display_y=-1}}}
```

- `image="invis.png"` 讓本體那格透明，真正的圖走 `add_mos`（`E/Entity.lua:412-417`）。
- `display_h=2` ＝佔兩格高、`display_y=-1` ＝向上長一格（`E/Entity.lua:388-390, 417`）。
- `resolvers.calc.nice_tile`（`M/mod/resolvers.lua:1375-1384`）也提供簡寫：
  傳 `{tall=true}` / `{wide=true}` / 兩者，它會自動展開成上面那組（`:1377-1379`），
  並把 `e.image` 填進 `=BASE=TILE=` 佔位（`:1380`）。
- ⚠️ **整段只在 `nicer_tiles` 開啟時生效**（`:1376`）。關掉美化貼圖的玩家看到的是 `image` 本身。

### 自製 NPC 的 PNG 放哪

`overload/data/gfx/shockbolt/npc/<你的檔>.png`，**不是** addon 的 `data/`
（私有掛載點，見 [addon-loading.md §0](addon-loading.md)）。
引用時寫 `image = "npc/<你的檔>.png"`（不含 `shockbolt/`，那層由 tileset 決定）。
完整規則見 [visuals-and-sounds-parts/02](visuals-and-sounds-parts/02-asset-paths-and-overload.md)。

## 5. 技能樹的授予

```lua
player:knowTalentType(tt)   -- nil = 沒聽過 / false = 已顯現但未解鎖 / true = 已解鎖
```

### `learnTalentType` 的短路條件只擋 `true`

```lua
-- E/interface/ActorTalents.lua:987-993
function _M:learnTalentType(tt, v)
    if v == nil then v = true end
    if self.talents_types[tt] then return end   -- ← 只有 `true` 是 truthy，會擋
    self.talents_types[tt] = v
    ...
end
```

所以：`nil → true` 可以，**`false → true` 也可以**（`false` 是 falsy，會通過並被覆寫）。
唯一擋住的是已經 `true` 的情況，而那本來就不需要再做什麼。

要注意的是它**不會**幫你補熟練度。完整的「授予」長這樣：

```lua
player:learnTalentType(tt, true)
if player:getTalentTypeMastery(tt) < 1 then player:setTalentTypeMastery(tt, 1.0) end
player.changed = true
```

（`getTalentTypeMastery` 回傳的是 `mastery + 1`，預設 1.0——見 `E/interface/ActorTalents.lua:936-938`。）

### 列舉所有技能樹

`ActorTalents.talents_types_def` **同時有陣列部分與字串鍵**
（`E/interface/ActorTalents.lua:59-60`），列舉時要濾掉數字鍵，否則每棵樹會出現兩次：

```lua
for tt, def in pairs(ActorTalents.talents_types_def) do
    if type(tt) == "string" then ... end
end
```

`def.name` 已經被 `_t()` 翻譯過（顯示用）；`tt` 本身（`"spell/fire"`）才是穩定的鍵。

實機清點（含 DLC）：法術 56、戰技 47、蒸汽科技 33、自然／腐化 各 30、靈能 29、
星辰 26、時空 25、詛咒 23、靈巧 16、種族 14、不死／傳奇 各 7、傀儡 5……合計約 300 棵。
`base/*`（資源池）與 `inscriptions/*`（銘文）是引擎管線，不該當技能樹傳授。

## 6. ⚠️ NPC 的 `resolvers.equip` 需要 zone 的 `object_list` 非空

`resolvers.equip` 是 `__resolve_last`（`M/mod/resolvers.lua:233`），在 `Zone:finishEntity` 的
第二解析階段（`E/Zone.lua` 的 `e:resolve(nil, true)`）才跑；它靠 `game.zone:makeEntity(level, "object", filter)`
從 **該 zone 的 `object_list`** 撈物品。

**城鎮 zone 常把 `objects.lua` 留空**（「不放掉落物」），於是 `object_list` 是空的——
NPC 的 `resolvers.equip` 撈不到任何武具，**靜默空手**（沒有 Lua Error，只是 NPC 光著手）。
症狀：`npc:getInven("MAINHAND")` 是空的、`run.log` 的 `[resolveObject] **FAILED**`。

解法：在該 zone 的 `objects.lua` 補一行載入原版基底清單（抄 `town-derth/objects.lua`）：
```lua
load("/data/general/objects/objects-maj-eyal.lua")
```
（2026-07-11 做 tome-orario 酒館可招募冒險者時實測：補這行前三個 NPC 全空手，補後長劍／長弓／法杖都正確裝上。）
