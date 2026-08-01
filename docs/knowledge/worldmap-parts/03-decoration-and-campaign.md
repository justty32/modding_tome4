# 大地圖、zone、與新增 campaign

> 目標版本 **ToME 1.7.6**。每一條都在原始碼複驗過並附行號。路徑代號見 [README.md](../README.md)。
> 實作範例：`self_mods/tome-runeisles/`（新大地圖 + 城鎮 + 兩個地城 + 主線）。

## 7. 大地圖上的裝飾層全部可省

`wda`（world director AI，隨機遭遇）、`prepareEntitiesList`、`auto_placelists`、
`post_nicer_tiles`、`addSpot`、`addZone`、`can_encounter`——**全部可選**，省掉不會崩。

但有一個地雷：**只要設了 `data.wda = {script="X"}` 而 `/data/wda/X.lua` 不存在，
`M/mod/class/GameState.lua:787` 會 `error(err)`，玩家第一步移動就崩。**
要就完整提供，不要就整段別寫（`:773` 沒有 `wda.script` 就直接 return，安全）。

## 8. ⚠️ 別繼承 `GRASS` 當自訂地面

`M/data/general/grids/forest.lua:29`：
```lua
nice_tiler = { method="replace", base={"GRASS_PATCH", 100, 1, 14} }
```
**100% 機率**把貼圖換成草地變體。`newEntity{ base="GRASS", image="terrain/frozen_ground.png" }`
的 `image` 永遠不會出現在畫面上。實機第一次進碑港，整座雪港是綠草地就是這麼來的。

想要自訂地面就不要繼承 base，整個從頭寫（`type`/`subtype`/`name`/`image`/`display`）。
`nice_tiler` / `nice_editer` 只影響美觀，不寫也能跑。

## 9. 大地圖上的入口格

- `change_level` + `change_zone` 兩個欄位，消費點在 `M/mod/class/Game.lua:2277-2292`（CHANGE_LEVEL 鍵）。
- `glow = true` 會替「還沒進去過的入口」自動加一個發光標記
  （`M/mod/class/Grid.lua:38-44` 的 `initGlow`，需要 `change_zone` 且開了 nicer_tiles）。
- **沒有 `add_displays` / `add_mos` 的話，那一格在畫面上就只是一片草地／雪地，玩家找不到入口。**
  原版慣例：傳送門用 `terrain/maze_teleport.png`（`wilderness/grids.lua:527`），
  城鎮用 `terrain/village_01.png`（`:510`），地城入口用 `terrain/dungeon_entrance02.png`（`:585`）。
- 地城第 1 層的上樓梯要通回大地圖：`levels[1].generator.map.up = "<你的 grid>"`，
  那個 grid 帶 `change_level=1, change_zone="<你的大地圖短名>"`。
  原版同款：`M/data/zones/norgos-lair/zone.lua:74-78` 的 `ROCKY_UP_WILDERNESS`。

## 10. campaign（type="world" 描述子）

沒做，但查清楚了，留給下一次：

- ToME 只有 3 個 campaign，宣告在 `M/data/birth/worlds.lua:66,121,197`。
- **新增一個 `newBirthDescriptor{type="world", ...}` 就會自動出現在建角畫面**——
  `E/Birther.lua:231-247` 對沒被明確 disallow 的 world 預設放行，不必改原版 `descriptors.lua`。
- `copy.before_starting_zone` 在 `M/mod/class/Game.lua:285` 被呼叫，**早於** `:297` 讀
  `default_wilderness`，所以能在那裡把大地圖與起始 zone 整組換掉，不必碰種族檔。
- `game:isCampaign(name)`（`Game.lua:1466-1468`）比對的是描述子的 `name`。
- **三個官方 DLC 沒有一個真的另開世界地圖**，全都疊在 Eyal 上。要做全新 campaign 沒有前例可抄。

## ★ Static zone 生成失敗＝「Level unconnected」（2026-07-11 實測）

一個看起來沒問題的 Static 房間地圖，遊戲卻永遠進不去、run.log 反覆刷
`[Zone:newLevel] Level unconnected, no way from entrance X Y to exit X Y` 然後
`Level Generation Failure: Unable to create level`（重試 50 次後放棄，changeLevel 靜默失敗、玩家留在原地）。

**根因**：引擎會檢查「入口 (startx,starty) 到出口」有沒有路可走。出口若沒在地圖裡明確定義，
**預設落在地圖正中心**（Static.lua:520-522 `endx/endy = floor(w/2), floor(h/2)`）。
若你把中心圍在牆裡（例如中央放一個有牆的營火房），出口就搆不到 → 判定不連通 → 生成失敗。

**解法**：讓地圖是連通的開放空間（entrance 與中心之間有路）；或在地圖用 `endx/endy`／下樓梯 tile
明確指定一個可達的出口。tome-camp 一開始把營火圍牆就中這坑，改成開放房間即解。
（這是 verify 抓不到、只有實機 changeLevel 才現形的坑。）

## change_level/change_zone 地磚：走上去不會自動進，要按 '<'/'>'（2026-07-11 實測）

在大地圖（或任何地方）走到一個帶 `change_level`/`change_zone` 的地磚上，**不會自動換關**——
`mod/class/Player.lua:288-292` 只印一行「There is X here (press '<', '>' or right click to use)」，
真正的換關要玩家按 `<`／`>`／右鍵。自動化測試時 `playtest.sh do ... key greater` 送 `>` 才會觸發。
（把入口貼上大地圖後，玩家要「走上去再按 >」才進得去，這是正常 ToME UX，不是 bug。）
tome-camp 的大地圖入口（德斯城旁 24,17，紫色傳送圈）就是這樣：走上去按 > 進營地、營地內走到 '<' 按 > 回大地圖並精準回到入口格。
