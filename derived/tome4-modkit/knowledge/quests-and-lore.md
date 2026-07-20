# 任務與文獻（quest / lore）

> 目標版本 **ToME 1.7.6**。附行號複驗過。路徑代號見 [README.md](README.md)。
> 實作範例：`mods/tome-runeisles/data/{quests,lore,chats}/`。

## 1. quest 是惰性載入，lore 是開機批次載入

這兩個系統的載入方式**完全不同**，是最容易搞錯的地方。

| | quest | lore |
|---|---|---|
| 何時載入 | `grantQuest()` 被呼叫的當下才 `loadfile` | 開機時一次載完 |
| 位置 | `M/mod/class/interface/ActorPartyQuest.lua:44-52` | `M/mod/load.lua:111` |
| addon 要做什麼 | **什麼都不用做**，檔案放對路徑就好 | **必須自己再 `loadDefinition` 一次** |

lore 漏了那一步的症狀：NPC 一死觸發 `on_death_lore` 就 nil index。

```lua
-- hooks/load.lua
local PartyLore = require "mod.class.interface.PartyLore"  -- mod/load.lua 裡是 local，不是全域
class:bindHook("ToME:load", function(self, data)
    PartyLore:loadDefinition("/data-<short>/lore/lore.lua")
end)
```

## 2. quest 檔案

放 `data/quests/<name>.lua`，用 `who:grantQuest("<addon>+<name>")` 授予
（`ActorPartyQuest.lua:33-42` 解析 `+` 前綴 → `/data-<addon>/quests/<name>.lua`）。

`ret.id = ret.id or quest`（`:50`）：**沒寫 `id` 的話，遊戲裡的 quest id 會是整個
`"<addon>+<name>"`**，之後 `hasQuest` / `setQuestStatus` 都得帶前綴。
在檔案裡明寫 `id = "name"` 比較乾淨。

欄位：`name` 與 `desc` 是 assert 必填（`ActorPartyQuest.lua:52-53`）。
其餘常用：`on_grant(self, who)`、`on_status_change(self, who, status, sub)`、`use_ui`（只影響彈窗美術）。
也可以塞任意自訂方法，之後自己呼叫（原版 `M/data/quests/lost-merchant.lua:39` 的 `leave_zone` 就是）。

狀態常數（`E/Quest.lua:26-29`）：`PENDING=0`、`COMPLETED=1`、`DONE=100`、`FAILED=101`。

**注意**：`M/mod/class/interface/ActorPartyQuest.lua` 覆寫了引擎版，每個方法開頭都先轉給隊伍主角
（`:29-31`），所以任務是全隊共享的。引擎的 `E/interface/ActorQuest.lua` 在 ToME 裡沒被用到。

### 在 `on_status_change` 裡設 DONE 不會無限遞迴

`E/Quest.lua:110` 有 `if self.status == status then return false end` 擋住。
子目標同理（`:105`），所以重複設定同一個子目標狀態也是安全的（`on_enter` 每次進 zone 都跑得起）。

## 3. 觸發點速查

| 手法 | 寫在哪 | 原版範例 |
|---|---|---|
| 對話裡授予 | chat 的 `answers[].action` | `M/data/chats/mage-apprentice-quest.lua:89` |
| 進入 zone | `zone.lua` 的 `on_enter(lev, old_lev, newzone)` | `M/data/zones/dreadfell/zone.lua:118` |
| 首次生成 zone | `zone.lua` 的 `post_process(level)` | `M/data/zones/high-peak/zone.lua:80` |
| 殺死 NPC | npc 的 `on_die(self, who)` | `M/data/zones/reknor/npcs.lua:101-110` |
| 踩到地形 | grid 的 `change_level_check(self, who)`（回傳 true 擋下換關）| `M/data/zones/wilderness/grids.lua:687` |
| 離開關卡即失敗 | `M/mod/class/Player.lua:238-242` | — |

## 4. lore

`newLore{ id, category, name, lore }`（`M/mod/class/interface/PartyLore.lua:42-59`）。
`lore` 內文支援 `[i]` `[b]` `[u]`。

觸發方式：
- 物件 `base="BASE_LORE"` + `lore="<id>"`，撿起時 `M/mod/class/Object.lua:2489-2491` 自動 `learnLore`
- NPC 的 `on_death_lore = "<id>"`，`M/mod/class/Actor.lua:3223` 死亡時觸發
- 程式碼直接 `game.party:learnLore(id)`
- 隨機撒點：`game:placeRandomLoreObject(define)`（`M/mod/class/Game.lua:2966-2981`）

**`on_death_lore` 的 id 對不上就是 nil index**，所以 `hooks/load.lua` 的 selfcheck 值得直接檢查
`PartyLore.lore_defs["<你的 id>"] ~= nil`。

## 5. 對話補充

（基礎見 [npc-and-chats.md](npc-and-chats.md)。）

- **一般 zone 裡的 NPC 不需要自己掛 hook**：`M/mod/class/interface/Combat.lua:42-49`——
  玩家「攻擊」一個 `can_talk` 不為空的目標時，攻擊會被攔下來改成開對話。
  只要 `newEntity{ can_talk = "<addon>+<chatfile>" }` 就行。
  （大地圖上的 `WorldNPC` 才需要 hook 放置，見 `mods/tome-talent-tutor`。）
- `can_talk_only_once = true` 讓對話結束後把 `can_talk` 設回 nil（`Combat.lua:45,49`），
  一次性劇情不用自己記狀態。
- 把 NPC 焊死在靜態地圖上：`defineTile('N', "GRID", nil, "NPC_DEFINE_AS")`
  ——第 4 個參數是 actor（`E/generator/map/Static.lua:104-107`）。比 `addSpot` + `on_enter` 簡單。

## 6. 實機測試時會咬你的一件事

接到任務時會彈出「新 任務!」（`M/mod/dialogs/QuestPopup.lua`）。
它疊在對話框上面，所以**按一次 Return 是關掉那個彈窗，不是關掉對話**。
自動化腳本如果沒算到這一下，後面所有方向鍵都會被還開著的對話框吃掉，玩家一步都不會動。
