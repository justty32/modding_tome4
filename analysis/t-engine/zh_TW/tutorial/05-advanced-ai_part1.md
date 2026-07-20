# 教學 05：進階 AI 系統

> **目標**：理解 TE4 的 AI 架構，從基本移動 AI 到 ToME 的戰術評分系統（`improved_tactical`），並學會為 NPC 撰寫自訂 AI。
>
> **相關原始碼**：
> - `game/engines/engine/interface/ActorAI.lua` — AI 介面基礎（`doAI`、`runAI`、`newAI`）
> - `game/engines/engine/ai/simple.lua` — 引擎內建移動/目標 AI
> - `game/engines/engine/ai/talented.lua` — `dumb_talented`、`improved_talented`
> - `game/modules/tome-1.7.6/mod/ai/improved_tactical.lua` — ToME 戰術評分 AI（核心）
> - `game/modules/tome-1.7.6/mod/ai/target.lua` — ToME 目標選擇覆蓋

---

## 目錄

1. [AI 系統架構](#1-ai-系統架構)
2. [AI 基本組件](#2-ai-基本組件)
3. [引擎內建 AI 清單](#3-引擎內建-ai-清單)
4. [NPC 定義中的 AI 設定](#4-npc-定義中的-ai-設定)
5. [ai_state：AI 的記憶與設定](#5-ai_stateai-的記憶與設定)
6. [自訂簡單 AI](#6-自訂簡單-ai)
7. [技能的戰術表（tactical table）](#7-技能的戰術表-tactical-table)
8. [improved_tactical：三步評分系統](#8-improved_tactical三步評分系統)
9. [ai_tactic：NPC 的戰術偏好](#9-ai_tacticnpc-的戰術偏好)
10. [完整 NPC 範例](#10-完整-npc-範例)
11. [自訂新戰術（Tactic）](#11-自訂新戰術-tactic)
12. [AI 除錯技巧](#12-ai-除錯技巧)
13. [常見問題](#13-常見問題)

---

## 1. AI 系統架構

TE4 的 AI 是**函式組合系統**。每個 AI 是具名函式，可呼叫其他 AI 形成管線：

```
NPC:act()
  → self:computeFOV()          ← 先更新視野
  → self:doAI()               ← 主入口
      → self:runAI(self.ai)   ← 執行 NPC 指定的 AI
          → 可再 runAI 其他 AI（組合）
```

**三層分工**：

```
目標選擇 AI        移動 AI              技能使用 AI
─────────────  +  ────────────  +  ──────────────────
target_simple      move_simple      dumb_talented
target_closest     move_dmap        improved_talented
target_player      move_astar       use_tactical
                   flee_simple      use_improved_tactical
                   flee_dmap
```

多數頂層 AI（如 `simple`、`dumb_talented_simple`）會依序呼叫這三類。

**AI 定義語法**：

```lua
-- 在 AI 定義檔中（engine/ai/*.lua 或 mod/ai/*.lua）
newAI("ai_name", function(self, ...)
    -- self = 此 NPC Actor
    -- 回傳 true/false 表示是否成功行動
end)
```

**執行 AI**：

```lua
-- 在任何 Actor 方法中
self:runAI("ai_name")          -- 執行指定 AI
self:runAI("ai_name", arg1)    -- 帶參數
```

---

## 2. AI 基本組件

### 2.1 狀態（ai_state 與 ai_target）

每個 NPC 有兩個 AI table：

```lua
self.ai_state = {
    -- 靜態設定（NPC 定義中設定，存檔保留）
    ai_target = "target_simple",   -- 目標選擇 AI
    ai_move   = "move_simple",     -- 移動 AI
    talent_in = 3,                 -- dumb_talented 技能頻率（1/N 機率）
    no_talents = false,            -- true 則禁用技能
    -- 動態狀態（AI 運行中修改）
    blocked_turns = nil,
    target_last_seen = {x, y, turn},
}

self.ai_target = {
    actor = <Actor>,    -- 當前 AI 目標（弱引用）
}

self.ai_state_volatile = {
    -- 不存檔（每次載入重設）
    _want = {},     -- improved_tactical 的 WANT 表
    _avail = {},    -- AVAIL 表
    _actions = {},  -- 可行動列表
}
```

### 2.2 FOV（視野）

AI 執行前必須先計算 FOV：

```lua
self:computeFOV(self.sight or 20)  -- 計算視野半徑 20 格

-- 計算後可用
self.fov.actors_dist  -- 依距離排序的可見 Actor 列表
self.fov.actors[act]  -- actor → {sqdist=...}
```

### 2.3 目標追蹤：aiSeeTargetPos

AI 不一定能精確知道目標位置：

```lua
-- 取得 AI 認定的目標位置
local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
-- 視線內 → 精確座標；視線外 → 誤差估計（隨時間增大）
```

失去視線 10 回合後，位置估計誤差可達 10 格。

---

## 3. 引擎內建 AI 清單

### 目標選擇類

| AI 名稱 | 說明 |
|---------|------|
| `target_simple` | 找最近敵人，90% 保持當前目標 |
| `target_closest` | 永遠鎖定最近敵人 |
| `target_player` | 永遠以玩家為目標 |
| `target_player_radius` | 在 `sense_radius` 格內攻擊玩家 |

**ToME 覆蓋**（`mod/ai/target.lua`）的 `target_simple` 額外支援：
- 夜視（`infravision`）/ 增強感知（`heightened_senses`）
- 跳過無敵目標（`invulnerable`）
- 死亡召喚物轉攻擊召喚者

### 移動類

| AI 名稱 | 說明 | 特點 |
|---------|------|------|
| `move_simple` | 向目標最後位置直線移動 | 最快，易卡牆 |
| `move_dmap` | Dijkstra Map 尋路 | 需距離地圖 |
| `move_astar` | A* 尋路 | 最可靠，計算量大 |
| `move_wander` | 隨機遊蕩 | 無目標時用 |
| `flee_simple` | 朝反方向逃跑 | 簡單方向 |
| `flee_dmap` | Dijkstra 逃跑 | 更可靠 |
| `move_complex` | 智能複合移動 | A*/dmap/wander 依情況切換 |

### 技能使用類

| AI 名稱 | 說明 |
|---------|------|
| `dumb_talented` | 隨機用一個可用技能 |
| `improved_talented` | 改良版：最多嘗試 5 次不同技能 |
| `dumb_talented_simple` | 目標選擇 + 1/N 機率技能 + 移動（最常用）|
| `use_tactical` | 戰術評分系統（舊版）|
| `use_improved_tactical` | **戰術評分系統（新版，ToME 主要 NPC 使用）**|

### 複合頂層 AI

| AI 名稱 | 說明 |
|---------|------|
| `simple` | `target_simple` + `move_simple` |
| `dmap` | `target_simple` + `move_dmap` |
| `dumb_talented_simple` | target + 技能（1/N）+ 移動 |
| `improved_tactical` | target + 技能（戰術評分）+ 移動 |

---

## 4. NPC 定義中的 AI 設定

```lua
newEntity{
    name = "goblin archer",
    ai = "dumb_talented_simple",
    ai_state = {
        ai_target = "target_simple",
        ai_move   = "move_simple",
        talent_in = 3,                 -- 每 3 回合用一次技能（1/3）
    },
}
```

### 常用 `ai` 值與用途

| `ai` 值 | 適用 NPC |
|---------|---------|
| `"dumb_talented_simple"` | 普通雜兵（隨機技能）|
| `"improved_tactical"` | 稀有/菁英（智能技能選擇）|
| `"move_simple"` | 純近戰移動（無技能）|
| `"none"` | 靜止（植物、水晶）|
