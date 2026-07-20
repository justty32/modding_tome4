## 測試檢查清單

```lua
-- 按 ` 或 F1 開啟 Cheat Console

-- 1. 進入據點
game:changeLevel(1, "camp")
print(game.zone.short_name)           -- 應印出 "camp"

-- 2. 確認持久化模式
print(game.zone.persistent)           -- 應印出 "zone"

-- 3. 確認地圖尺寸
print(game.level.map.w, game.level.map.h)   -- 應印出 25  20

-- 4. 確認篝火地形（查 ASCII 地圖中 * 的位置）
local Map     = require "engine.Map"
local terrain = game.level.map(8, 6, Map.TERRAIN)   -- * 在 (8,6)
print(terrain and terrain.name, terrain and terrain.camp_heal)
-- 預期：篝火  true

-- 5. 確認工作台 NPC（查 ASCII 地圖中 w 的位置）
local npc = game.level.map(7, 11, Map.ACTOR)        -- w 在 (7,11)
print(npc and npc.name)
-- 預期：合成工作台

-- 6. 測試持久化（離開再進來）
game:changeLevel(1, "wilderness")
game:changeLevel(1, "camp")
print("level 物件 uid:", game.level.uid)   -- 兩次進入應相同
```

---

## 常見錯誤排查

| 錯誤現象 | 原因 | 解法 |
|---------|------|------|
| 每次進入據點都重新生成 | 未設 `persistent = "zone"` | 在 Zone 定義加入 `persistent = "zone"` |
| 靜態地圖字元顯示為空或問號 | `defineTile` 的 `define_as` 找不到 | 確認 `grid_list` 已載入 `camp.lua`；確認 `define_as` 拼字正確 |
| 篝火不觸發治療 | `on_move` 未被呼叫或未分派 | 確認 `mod/class/Grid.lua` 已繼承並 override `on_move`；確認地形有 `camp_heal = true` |
| 篝火每步都觸發 | 冷卻邏輯錯誤 | 確認 `game.level.data[cd_key]` 正確讀寫；`ticks_per_act` = 1000/100 = 10 |
| 工作台 NPC 不出現 | `defineTile` 的 actor 找不到 | 確認 `npc_list` 已載入 `camp_npcs.lua`；確認 `WORKBENCH_NPC` 拼字正確 |
| 碰撞工作台沒有反應 | `on_bump` 未觸發 | 確認 NPC 的 `faction = "players"`；確認 Game 的碰撞邏輯呼叫 `npc:bumpInto(player)` |
| 合成時找不到產品 | 產品不在 `object_list` | 在 Zone 的 `object_list` 中包含含有該物品的清單 |
| 地圖尺寸不符崩潰 | ASCII 行數/列數與 Zone 的 `width`/`height` 不一致 | 數 ASCII 地圖的行列數，更新 Zone 定義的 `width`/`height` |

---

## 本章小結

| 概念 | 實作位置 | 關鍵 API |
|------|---------|---------|
| Zone 持久化 | Zone 定義 `persistent = "zone"` | `leaveLevel()` 寫 `memory_levels`；`Zone:save()` 寫磁碟 |
| 靜態地圖 | `data/maps/camp.lua` | `defineTile`, `startx`/`starty`, ASCII return |
| 地形行為（旗標模式） | `data/grids/camp.lua` + `class/Grid.lua` | 實體定義旗標；Grid class `on_move` 分派 |
| 臨時狀態存儲 | `game.level.data[key]` | 跟隨 Level 序列化，持久且安全 |
| 合成工作台 | `npcs/camp_npcs.lua` + `chats/workbench.lua` | `on_bump` 觸發 Chat；local 輔助函式操作物品 |
| 區域切換 | `grids/camp.lua` + `grids/wilderness.lua` | `change_level` + `change_zone`；`CHANGE_LEVEL` 鍵觸發 |
