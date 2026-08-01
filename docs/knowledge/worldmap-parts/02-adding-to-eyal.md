# 大地圖、zone、與新增 campaign

> 目標版本 **ToME 1.7.6**。每一條都在原始碼複驗過並附行號。路徑代號見 [README.md](../README.md)。
> 實作範例：`self_mods/tome-runeisles/`（新大地圖 + 城鎮 + 兩個地城 + 主線）。

## 4. 往既有 Eyal 大地圖加東西：唯一乾淨的接點

**不要 overload 整份 `data/maps/wilderness/eyal.lua`**（`master-spell-merchants` 就是這樣）。
overload 是整檔取代，載入順序由 `weight` 決定（`E/Module.lua:437`），
兩個都這樣做的 addon 會互相靜默吃掉對方的改動，而且會把地圖凍結在複製當時的版本。

官方 DLC（orcs / Embers of Rage）用的是這組接點，是加法不是取代：

1. **`Entity:loadList` hook**（`E/Entity.lua:1267`）——原版 grid 清單載完後廣播，
   把同一個 `res` 表交出來。用同一個 res 再載一次自己的檔案就等於 append，
   所以 `newEntity{ base="PLAINS" }` 找得到已定義的 PLAINS（`E/Entity.lua:1228` 查 `res[t.base]`）。
   ```lua
   class:bindHook("Entity:loadList", function(self, data)
       if data.file ~= "/data/zones/wilderness/grids.lua" then return end
       self:loadList("/data-<short>/zones/wilderness-add/grids.lua",
                     data.no_default, data.res, data.mod, data.loaded)
   end)
   ```

2. **`MapGeneratorStatic:subgenRegister` hook**（`E/generator/map/Static.lua:696`）——
   Static 生成器畫完主地圖後廣播，往 `data.list` 塞一筆就會生成一張子地圖並貼上去
   （`:698-720`）。
   ```lua
   class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
       if data.mapfile ~= "wilderness/eyal" then return end
       data.list[#data.list+1] = { x=22, y=16, w=3, h=3, overlay=true,
           generator = "engine.generator.map.Static",
           data = { map = "<short>+eyal-portal" } }
   end)
   ```

**留白的關鍵**：子地圖裡沒有 `defineTile` 過的字元，`Static:resolve` 回 nil（`:557`），
`:578` 的 `if g then` 整格跳過；`E/Map.lua:1063` 的 `overlay()` 也只複製有東西的格子。
所以可以只貼一格、周圍 8 格保留原樣。只要各 addon 的矩形視窗不重疊，就能無限共存。

（`overlay=true` 走 `Map:overlay`；不加則是 `Map:import`，會整片蓋掉。）

## 5. ⚠️ 第二張大地圖的固有 bug：`wild_x/wild_y` 只有一組

`M/mod/class/Game.lua:1238-1248`：進入任何 `wilderness` zone 時，玩家被放到 `player.wild_x/wild_y`，
接著 `:1248` 把 `player.last_wilderness` 設成該 zone 短名。

**但 `wild_x/wild_y` 是全域一對，不是每張大地圖各存一份。**
`M/mod/class/Player.lua:354` 每走一步就覆寫它。於是在第二張大地圖上走動之後，
回到 Eyal 會被丟到島上的座標——輕則跳海，重則越界崩潰。

原版沒這個 bug，因為原版只有一張大地圖。官方 DLC 也沒遇過，因為它們全都是往 Eyal 上疊加。

**解法**：在傳送門 grid 上掛 `change_level_check`，它在 `M/mod/class/Game.lua:2291` 被呼叫，
早於 `:2292` 的 `changeLevel`。在那裡把座標依「目的地 zone 短名」存取：

```lua
change_level_check = function(self, who)
    who.ri_wild_pos = who.ri_wild_pos or {}
    if game.zone and game.zone.wilderness and game.zone.short_name then
        who.ri_wild_pos[game.zone.short_name] = { x = who.wild_x, y = who.wild_y }
    end
    local saved = who.ri_wild_pos[self.change_zone]
    if saved then who.wild_x, who.wild_y = saved.x, saved.y
    elseif self.ri_arrive then who.wild_x, who.wild_y = self.ri_arrive.x, self.ri_arrive.y end
    return false   -- 回傳 true 會取消換關
end
```

**這個函式不可以有 upvalue**：它會被序列化進 persistent 大地圖的存檔。
（可行性有原版背書：`M/data/zones/wilderness/grids.lua:528` 的安格文傳送門
也在同一張 persistent 圖上掛 `change_level_check`。）

`change_level_check` 回傳 true 就擋下換關，很適合當劇情門檻——
原版瑞爾島隧道就是這樣做的（`grids.lua:687`）。

## 6. zone.lua 必填欄位

| 欄位 | 缺了會怎樣 |
|---|---|
| `max_level` | **assert 崩潰**（`E/Zone.lua:124`）|
| `width` / `height` | **崩潰**（`E/Map.lua:224` 對 nil 做算術）|
| `generator.map` + `.class` | **崩潰**（`E/Zone.lua:1015-1016` assert）|
| `generator.map.map` 指向不存在的檔 | **崩潰**（`Static.lua:465-473` error）|
| `level_range` | 預設 `{1,1}`，不崩 |
| `generator.actor` / `.object` / `.trap` | 完全可選，沒有 `.class` 就跳過（`E/Zone.lua:1141,1147,1153`）|
| `grids.lua` | 不崩，但 grid_list 是空表 → **整張圖靜默變成空白** |
| `npcs.lua` / `objects.lua` / `traps.lua` | 不崩，清單為空（`E/Entity.lua:1197-1206` 只印警告）|

`levels[n]` 是**深合併**進 zone 資料的（`E/Zone.lua:867` 的 `table.merge(res, ..., true)`），
所以 `levels[1] = { generator = { map = { up = "X" } } }` 不會把 `generator.map.class` 洗掉。
