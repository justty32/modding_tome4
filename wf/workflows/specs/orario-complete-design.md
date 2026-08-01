# 設計方案：歐拉麗完全版（tome-orario v1.0）

← [specs](README.md)｜討論日期 2026-08-01｜前身 [PLAN-camp-and-isekai.md §B](../plans/PLAN-camp-and-isekai.md)

```text
Done when: 「完全版」範圍定義清楚、核心系統有引擎對應與行號、劇情承載方式確定、
           規模誠實估過、與另兩個大構想的關係講明、不做範圍寫死
```

> 路徑代號 `E` / `M` 見 [docs/knowledge/README.md](../../../docs/knowledge/README.md)。
> **使用者目標（2026-08-01 原話）：「把地錯劇情整個搬進來」。** 這是本文件的第一前提。

## 1. 現況：v0.3 已經有一座能走的城

`self_mods/tome-orario/`，515 行 Lua。**地理骨架已完成**：

| 已有 | 檔案 |
|---|---|
| Eyal 大地圖 (25,18) 入口 → 歐拉麗中央廣場 | `hooks/load.lua`、`data/maps/eyal-orario-portal.lua` |
| 中央廣場 hub zone | `data/zones/orario/` 四件式 |
| 巴別塔多層地城（Roomer 程序生成，max_level=5） | `data/zones/babel/zone.lua` |
| 公會受付孃 + 討伐委託全流程 | `data/chats/guild.lua`、`data/quests/bounty.lua` |
| 酒館三名可招募冒險者（入隊、可操控、隨主人成長） | `data/chats/tavern.lua`、`zones/orario/npcs.lua` |

舊計畫的建置序 1–4 做完了，剩 5（市集商店）、6（眷族據點）。**那只是 v0.4。**

## 2. 規模先講清楚：這比原版 ToME 的主線還大

誠實的基準（實測 `M/data/` 計數）：

| 原版 ToME 全部內容 | 數量 |
|---|---|
| quest 檔 | 52 |
| chat 檔 | 100 |
| zone | 89 |

粗估一卷 = 一條 3–6 個 quest 的任務鏈 + 0–2 個新 zone + 5–10 個具名 NPC + 若干 lore。
**20 卷 ≈ 80–120 quest、25–40 zone、150+ NPC**——比原版主線大。

這不是勸退，是要據此決定做法：**必須 arc-by-arc 出貨，每卷獨立可玩**，
且內容要資料驅動到能交給 agent 量產。一次性全做完是不可能的。

**好消息是美術幾乎免費**：具名 NPC 一張 64×64（大型的 64×128），而且可以直接沿用
原版 `npc/` 現成的 636 張人形貼圖 → **多數角色美術成本 0**。
細節見 [races-and-tiles.md](../../../docs/knowledge/races-and-tiles.md)、
[npc-and-chats.md §4.5](../../../docs/knowledge/npc-and-chats.md)。

## 3. ⚠️ 引擎沒有過場動畫。劇情只有四種載體

`grep -i cinematic E/` 零命中；原版主線也是這四樣拼出來的：

| 載體 | 能做什麼 | 出處 |
|---|---|---|
| **chat** | 多分支對話、`cond` 依狀態顯示選項、`action` 改世界狀態 | [npc-and-chats.md](../../../docs/knowledge/npc-and-chats.md) |
| **quest** | 狀態機（PENDING/COMPLETED/DONE/FAILED）＋動態 `desc` | [quests-and-lore.md](../../../docs/knowledge/quests-and-lore.md) |
| **lore** | 可拾取文獻、擊殺掉落文本 | 同上 §4 |
| **zone 事件** | `on_enter` / `post_process` / grid 的 `change_level_check` | 同上 §3 |

⚠️ 實作坑：接任務會彈「新 任務!」視窗疊在對話框上，**第一次 Return 是關彈窗不是關對話**
（`M/mod/dialogs/QuestPopup.lua`）——自動化測試必踩。

## 3.5 演出系統（Director）：要自己造，但引擎零件齊了 ★

只靠 §3 的四種載體，劇情就只能是「站著對話」。要重現「艾絲斬殺米諾陶洛斯、貝爾癱坐在地」
這種**分鏡**，必須有一套讓 NPC 照腳本表演的機制。

**原版沒有前例**——`grep -i cinematic E/` 零命中；`M/data/general/events/` 的 31 個事件
沒有任何一個做 NPC 走位。**這是從零建的系統，不是抄的。** 但三個承重零件都在：

### 3.5.1 怎麼讓遊戲在沒有玩家輸入時繼續跑回合

這是最大的技術障礙，而**休息／跑步就是現成的答案**：

```lua
-- M/mod/class/Player.lua:415-431
if self.player and self:enoughEnergy() then
    if self:restStep() then while self:enoughEnergy() and self:restStep() do end
    elseif self:runStep() then while self:enoughEnergy() and self:runStep() do end end
    if self:enoughEnergy() then game.paused = true end   -- ← 只有這裡才停下來等輸入
```

`restStep`（`E/interface/PlayerRest.lua:72-85`）的骨架就三行：能繼續就 `useEnergy()` 回傳 true，
否則 `restStop()` 回傳 false。**演出照同一個模子做一個 `sceneStep()`**，
superload `Player:act` 插進同一條鏈。回合會自己跑，玩家不必按鍵。

### 3.5.2 怎麼讓 NPC 照腳本動

`NPC:act()`（`M/mod/class/NPC.lua:64-90`）每回合呼叫 `self:doAI()`。
**演出期間清掉 `npc.ai`**，`doAI` 就空轉，接著 `waitTurn` + 燒能量——
NPC 變成一具不會自己行動的木偶。由導演每回合下令：

```lua
npc:move(x, y, force)      -- E/Actor.lua:229，ToME 覆寫在 M/mod/class/Actor.lua:1388
```

演出結束把 `ai` 設回去。

### 3.5.3 鏡頭

`game.level.map:centerViewAround(x, y)`（`E/Map.lua:864`）、
`moveViewSurround(x, y, mx, my)`（`:872`）。

### 3.5.4 腳本格式

一個 scene 是一串 step，step 種類**刻意設得很少**——超出這幾種的敘事寫不出來，
設計時就會被逼著把小說語言轉換成遊戲事件（這是特性不是缺陷）：

```lua
scene "arc01-minotaur" {
  {t="camera", to="AIS"},
  {t="say",    who="AIS",  text="..."},          -- game.logSeen / bignews
  {t="walk",   who="AIS",  to={x=12,y=8}},       -- 每回合一步，走到為止
  {t="wait",   turns=3},
  {t="spawn",  define_as="ARC01_MINOTAUR", at={x=15,y=8}},
  {t="fx",     particle="...", at={x=15,y=8}},
  {t="chat",   who="BELL", chat="arc01-a"},      -- 模態對話，scene 暫停等它關閉
  {t="release"},                                  -- 交還控制權，戰鬥開始
}
```

導演本體是一個掛在 `game` 上的狀態機，`sceneStep()` 每回合推進一格。

### 3.5.5 四個必須正面處理的風險

| 風險 | 對策 |
|---|---|
| **演出中玩家不能動**——roguelike 玩家最討厭這個 | **每個 scene 都必須可跳過**（一個鍵直接跳到 `release`）。這是硬性要求，不是選項 |
| **演出中途存檔** | scene 期間禁存，或 scene 狀態要能序列化（建議前者，簡單很多） |
| **演出中途角色死亡** | scene 開始前 `player.__scene_invuln = true`，或整段禁止傷害 |
| **NPC 走不到目標格**（被擋、地形變動） | `walk` step 要有超時：N 回合到不了就直接瞬移到位並繼續，不能卡死整段演出 |

> **這一節是整個計畫的技術核心。** v0.5 若這套做不出來，20 卷劇情就只能是站樁對話——
> 那時候該回頭重新定義「完全版」的意思，而不是硬做。

## 4. 最重要的一個決定：玩家是誰？

這題決定其他所有事，**必須先答**。

| 方案 | 玩家身分 | 優點 | 代價 |
|---|---|---|---|
| **A 演貝爾** | 固定主角 | 最忠實 | **與 roguelike 根本衝突**：ToME 是永久死亡、角色由玩家自訂 race/class/subclass。鎖主角＝廢掉建角系統；而且一死劇情就斷 |
| **B 同時代的另一名冒險者** ★ | 自訂角色 | 建角系統完整保留；劇情在你身邊發生，你會遇到、可介入；死了重開換一個冒險者完全合理 | 主線的高潮不是你的高潮，要另外設計「你的線」 |
| **C 自己眷族的團長** | 自訂角色＋自己的眷族 | 同 B，且多一條經營軸 | 內容量再加一層 |

> 主 agent 強烈建議 **B**（或 B 的擴充 C）。
> 理由是硬的：ToME 的角色由 birth descriptor 在建角時組出來（`E/Birther.lua:370-446`），
> 永久死亡是核心規則。A 案要對抗這兩者，等於重寫遊戲。
> **B 案還有一個好處**：小說劇情變成「世界正在發生的事」，你可以只做你想做的卷，
> 沒做的卷就是「聽說最近某某眷族出事了」，缺口不會變成斷裂。

## 5. Falna 系統：劇情之外的第二根支柱

《地錯》的骨幹不只是劇情，還有**「你做了什麼就長成什麼」的恩惠系統**。
以下引擎對應全部已複驗。

### 5.1 偉業升級：`max_level` 就是現成的閘門 ★

```lua
-- E/interface/ActorLevel.lua:95-107
function _M:gainExp(value)
    self.exp = math.max(0, self.exp + value)      -- ← 經驗照樣累積
    while ... do
        if self.max_level and self.level >= self.max_level then return end   -- :101 擋在這
```

- 平時 `player.max_level = player.level` → **升不上去，但經驗值繼續存**。
- 達成偉業（如殺死 `target.level > self.level` 的 rank≥3 怪）→ `max_level + 1` → 自動補升。
- **不用 superload，設一個欄位而已。** 這是本設計最幸運的一點。

### 5.2 五能力值：走 `inc_stats` 繞開屬性上限

```lua
-- E/interface/ActorStats.lua:123-137
val = math.max(util.bound(val, min, max) + ((not no_inc) and inc or 0), min)
--               └─ 基礎值被 max 夾住 ─┘   └─ inc_stats 疊上去，不受夾 ─┘
```

→ `addTemporaryValue("inc_stats", {...})` 的量**不受 `stats_def.max` 限制**，
所以 0–999 的能力值可以自由對映，不會撞天花板。顯示用 S–I 分級。

累積掛回呼（總表 `M/mod/class/Actor.lua:6050-6060`）。
⚠️ 攔天賦使用**沒有 `postUseTalent` hook，只能 superload**。
⚠️ 重算務必先 `removeTemporaryValue` 再 add，否則每次更新都在疊。

### 5.3 魔石經濟：用基礎遊戲的 `PartyIngredients`，不要用背包

`M/mod/class/interface/PartyIngredients.lua`（**基礎遊戲原生**）：
`collectIngredient` `:72` / `hasIngredient` `:94` / `useIngredient` `:106`。
**魔石不佔背包格**——這是「每隻怪都掉魔石」不變成背包地獄的關鍵。
公會兌換＝`useIngredient` + `incMoney`。詳見 [crafting-and-imbue.md](../../../docs/knowledge/crafting-and-imbue.md)。

### 5.4 技能覺醒：`__show_special_talents`

スキル**不是選的，是隨行為長出來的**——與 [生長式天賦 spec](organic-talents-design.md) §2.2 同一套機制。

### 5.5 眷族：party 欄位，不要做成 birth descriptor

眷族可以加入、轉會、被逐出；birth descriptor 是建角時一次性套用（`E/Birther.lua:370-446`），語意不合。
用 `game.party.familia = {id, rank, favor}` 搭配對話切換。

## 6. 劇情資料化：把小說變成可量產的表

**這是讓 20 卷變得可行的關鍵決定。** 劇情不要一條條手寫 chat，
要先定義一張 arc 資料表，再由它生成 quest / chat 骨架。

```lua
-- data-orario/story/arcs.lua
{ id = "arc01", title = "...", volume = 1,
  gate = { player_level = 3, babel_depth = 5 },     -- 何時開放（見 §6.2）
  zones = { "orario+babel-mid" },
  cast  = { "BELL", "HESTIA", "AIS" },              -- 指向 cast.lua
  beats = {                                          -- 一個 beat = 一次「對話→行動→對話」
    { kind="chat",  npc="HESTIA", chat="arc01-open" },
    { kind="kill",  target="ARC01_MINOTAUR", zone="orario+babel", depth=5 },
    { kind="lore",  id="arc01-aftermath" },
  },
}
```

- `beats` 只有四種 kind（對應 §3 的四種載體），**這是刻意的限制**——
  超出四種的敘事寫不出來，設計時就會被逼著轉換成遊戲事件。
- `cast.lua` 一列一個角色：名字、眷族、陣營、貼圖、說話語氣關鍵詞。
  貼圖預設沿用原版 `npc/humanoid_*`，成本 0。
- 這張表可以交給 pi + deepseek 依卷產出，`lint.sh` 驗格式。

### 6.1 我需要的原文形式（使用者提議提供小說）

**不要小說原文貼進 mod。** 兩個實際理由：

1. 那是受著作權保護的文字，逐字搬進公開發佈的 addon 是重製。改寫、摘要、
   在該世界觀下寫原創對白都沒問題——**我們要做的本來就是後者**。
2. 小說散文的節奏跟遊戲對話框完全不同（一段 300 字的心理描寫塞進 chat 框是災難）。
   照抄反而難讀。

**真正有用的是結構化素材**，這些是事實性資訊，整理出來就能直接餵進 §6 的表：

| 我需要 | 用來填 |
|---|---|
| 分卷大綱（每卷 5–10 句：誰、在哪、發生什麼、結果） | `arcs.lua` 的 `beats` |
| 角色表：名字、所屬眷族、立場、與主角群關係、說話語氣 | `cast.lua` |
| 地點表：名稱、在歐拉麗的相對位置、性質 | `zones` |
| 巴別塔分層設定：層數、生態、階層主 | §7 的 v0.9 |
| 時間線：哪些事件有先後依賴 | `gate` |

### 6.2 劇情推進的計時器：用深度與等級，不用「時間」

小說靠時間推進，roguelike 沒有時間軸。**用玩家的進度當閘門**：
`gate = { player_level = N, babel_depth = M, prev_arc = "arcXX" }`。
這樣沒做的卷自然不會被觸發，而且玩家的成長節奏與劇情節奏對得上。

## 7. 分期

每一期都要能獨立 playtest。**劇情層與系統層交錯做**，不要先做完系統才碰劇情。

| 期 | 內容 | 為什麼這個順序 |
|---|---|---|
| **v0.4 補完城市** | 市集商店（抄 town-derth/traps.lua）、2–3 個眷族據點 zone | 純抄現成手法，低風險，先讓城市不空 |
| **v0.5 劇情框架** | §6 的 `arcs.lua` / `cast.lua` 格式定案 ＋ **第 1 卷走通** | **先驗一卷，證明格式撐得住**，再量產 |
| **v0.6 魔石經濟** | 怪掉魔石、公會兌換、素材 drop | 後續系統的資源底座 |
| **v0.7 Falna 核心** | 五能力值累積＋S–I 面板＋`inc_stats` 換算 | 心臟。**單獨一期**，存檔往返要驗透 |
| **v0.8 偉業升級** | `max_level` 閘門＋偉業判定＋升級演出 | 依賴 v0.7 的資料結構 |
| **v0.9 眷族＋技能覺醒** | 眷族加入／favor、スキル 覺醒目錄 | 內容量大，可交給 pi + deepseek |
| **v0.10+ 逐卷** | 一期一到兩卷 | 框架驗過後這裡是純內容 |
| **v1.0** | 巴別塔分層生態、階層主、平衡、文案、美術收尾 | — |

**v0.5 與 v0.7 是兩個生死關**：

- v0.5 若第 1 卷用 §6 的表寫不出來 → 格式要重設計，此時只賠一卷。
- v0.7 要驗三件事：存檔往返 Falna 數值正確、連續更新 20 次屬性沒膨脹
  （忘了 `removeTemporaryValue` 的典型症狀）、與 ToME 原生升級並存不打架。

## 8. 與你另外兩個構想的匯流 ★

**這三件事底層是同一套機制**，先決定要不要合併，會省下大量重工：

| 你的構想 | 在歐拉麗裡叫什麼 | 共用機制 |
|---|---|---|
| [生長式天賦](organic-talents-design.md) | **スキル覺醒** | `__show_special_talents` |
| 生長式天賦的「領域進度」 | **Falna 能力值累積** | 回呼計數 + `inc_stats` |
| [製作系統](../../../docs/knowledge/crafting-and-imbue.md) | **巴別塔素材鍛造** | `PartyIngredients` + tinker 槽位 |

1. **合併**：做一套通用框架，歐拉麗是第一個「皮」。最省工，但框架要先定案。
2. **各做各的**：快，但同樣的東西寫兩次。
3. **歐拉麗當試驗場** ★：先在歐拉麗把 Falna 做出來，跑得通再抽成通用框架。
   風險最低——有具體題材比抽象框架好設計，抽象化可以等有第二個使用者再說。

## 9. 明確不做

- **不做 A 案（玩家演貝爾）**，除非使用者推翻 §4 的建議。
- **不做獨立 campaign**。維持「從 Eyal 入口進歐拉麗」——三個官方 DLC 沒一個真的另開世界地圖，無前例可抄。
- **不取代 ToME 的升級系統**。Falna 是疊加的第二條軸；動原本那條會炸掉所有既有 addon 與平衡。
- **不逐字搬小說原文**（§6.1）。
- **不做 War Game 大規模眷族戰爭**，至少 v1.0 前不做——那需要大規模 NPC 陣營對抗機制。
- **不做過場動畫**。引擎沒有，自己寫是另一個量級的工（§3）。

## 10. 待使用者決定

1. **§4：玩家是誰**（A／B／C）。這題不答，後面全部動不了。
2. **§8 的三選一**——決定接下來三個大構想的全部工序。
3. **要做到第幾卷**？全 20 卷是 v2.0 級的目標；v1.0 建議先鎖前 4–5 卷。
4. **巴別塔要幾層**？現在 max_level=5。決定內容量級。
5. **原文素材**：能否照 §6.1 的五張表整理？（分卷大綱／角色／地點／分層／時間線）

## 11. 產出分工（依 [agent-driving](../agent-driving/README.md)）

| 工作 | 交給誰 |
|---|---|
| v0.4 的 zone／商店（純抄現成手法） | sonnet agent |
| §6 劇情表格式定案 ＋ 第 1 卷 | 主 agent（格式定生死） |
| 逐卷 `arcs.lua` / `cast.lua` 資料列 | pi + deepseek |
| Falna 核心（v0.7–0.8） | 主 agent，機制敏感、要複驗 |
| 具名角色貼圖、魔石／素材圖示 | 先沿用原版 `npc/`；真要自製走 `agy`，**送使用者肉眼審核** |
| 中文文案 | **一律使用者審**（語氣、翻譯腔）|
