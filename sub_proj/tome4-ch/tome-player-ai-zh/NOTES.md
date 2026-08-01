# player-ai 正體中文化筆記

## 覆蓋範圍摘要

`tome-player-ai-zh` 共翻譯 **9 條**字串，皆為 `game.log()` / `aiStop(msg)` 產生的
固定字面量提示訊息（`aiStop` 內部最終仍呼叫 `game.log(msg)`）。

這 9 條之所以可用 locale 覆蓋，是因為 `game.log()` 最終會流向
`engine/LogDisplay.lua:125` 的 `str = str:tformat(...)`，這一步**不需要**原始碼
自行呼叫 `_t()`／`_t[[...]]`，只要傳入的字串是「執行期不變的固定字面量」，
locale 表就能以原文字串為 key 命中並替換（沿用官方慣例，tag 用 `"log"`）。

其餘本 addon 中出現的可見文字，經逐一追蹤其呼叫鏈後，判定**無法**透過
locale 機制覆蓋，原因分兩大類，詳列於下。

## 未覆蓋清單與原因

### 類別 A：原始碼直接把字面量丟給 UI 元件，元件本身不會呼叫 _t()

ToME4 的翻譯機制是「呼叫端（或 engine 特定欄位處理函式）主動呼叫 `_t()`／
`:tformat()`」才會查表，**不是**任何顯示在畫面上的字串都會自動查表。
本 addon 下列字串都是直接傳給 `Dialog:listPopup`、`Textzone.new{text=...}`、
`GetQuantity.new(title, prompt, ...)`、`data.tab(title, fct)`、
`defineAction{name=...}` 等 UI/註冊函式；逐一確認
`engine/ui/Dialog.lua`、`engine/ui/Textzone.lua`、`engine/ui/List.lua`、
`engine/dialogs/GetQuantity.lua`、`engine/ui/Tabs.lua`／`Tab.lua`、
`engine/KeyBind.lua` 原始碼後，**皆未見對這些欄位呼叫 `_t()`**，
故即使在 locale 檔中寫入對應條目也不會在遊戲中生效（無法命中查表點）。

來源：`overload/mod/class/PlayerAIOptions.lua`（Game Options 內「Player AI」分頁的
選項說明文字與 Textzone/GetQuantity 標題，共 16 條字串，含重覆的
`"From 0% to 100%"`）：

- `"Maximum number of turns the AI can run consecutively. The AI can get stuck in loops and is difficult to cancel manually, so adjust this value to match your patience with it."`
- `"#GOLD##{bold}#Maximum AI runtime#WHITE##{normal}#"`
- `"Enter maximum AI runtime in turns"`
- `"If character health drops below this percentage, the AI will disable itself and notify you that health is low."`
- `"#GOLD##{bold}#Disable-AI health threshold#WHITE##{normal}#"`
- `"Enter disable-AI health threshold"`
- `"From 0% to 100%"`（出現兩次：disable-AI 與 avoid-combat 門檻欄位共用）
- `"Experimental AI state to respond to attacks from unseen enemies. Use at your own risk, the AI often gets itself killed with this still."`
- `"#GOLD##{bold}#Use experimental HUNT state#WHITE##{normal}#"`
- `"If character health drops below this percentage, the AI will attempt to flee attacks from unseen enemies and find a safe place to rest."`
- `"#GOLD##{bold}#Avoid-combat health threshold#WHITE##{normal}#"`
- `"Enter avoid-combat health threshold"`
- `"If the AI is out-of-combat and attacked by unseen enemies, it will enter \"hunting\" state. This value is the number of turns the AI continues to hunt (or flee) after the last time it was hit before returning to rest state."`
- `"#GOLD##{bold}#Hunt state timeout#WHITE##{normal}#"`
- `"Enter hunt state timeout"`
- `"Number of turns"`
- `"AI wil stop on sighting monsters of this rank.\n\n0 = Don't stop (disable this feature)\n10 = Critter\n20 = Normal\n30 = Elite\n32 = Rare\n35 = Unique\n40 = Boss\n50 = Elite Boss\n100 = God\n\nThe savvy player will know that these numbers are 10 times too big. This is because ToME settings do not allow decimals, but ranks 3.2 and 3.5 exist in unmodded ToME."`
- `"#GOLD##{bold}#Stop on rank#WHITE##{normal}#"`
- `"Enter (decimal) rank to stop on. 10 = normal, 50 = elite boss, 100 = god"`
- `"rank number 0-100"`

來源：`hooks/load.lua`：

- `"Player AI"` — `data.tab("Player AI", fct)` 掛在 `GameOptions:tabs` hook 上的分頁標題；
  追蹤 `mod/dialogs/GameOptions.lua` 與 `engine/ui/Tabs.lua`/`Tab.lua`，
  分頁標題全程未經 `_t()` 處理。
- `"Toggle Player AI"` — `defineAction{name="Toggle Player AI", ...}` 的按鍵名稱，
  顯示於按鍵設定畫面（`engine/dialogs/KeyBinder.lua:211` 直接用 `k.name`），
  `engine/KeyBind.lua:defineAction` 註冊時也未呼叫 `_t()`。

### 類別 B：字串在到達 game.log 之前已被動態串接／格式化，執行期字串不固定

`superload/mod/class/Player.lua`：

- 第 223 行：
  `("#RED#AI cancelled for low health while hostile spotted to the %s (%s%s)"):format(dir or "???", name, ...)`
  ——`name`／`dir` 為敵人名稱與方位，隨機局而變，`:format()` 在進入
  `game.log`/`aiStop` 之前就已把值代入，成品字串不是固定值，無法逐字比對。
- 第 310 行：
  `("%s enemy sighted! #LIGHT_RED#AI Stopping!#WHITE#"):format(msg or "#CYAN#Mysterious")`，
  其中 `msg` 取自第 292–308 行 9 種敵人階級片段
  （`"#FF4000#God"`、`"#LIGHT_RED#Extremely scary boss"`、`"#GOLD#Elite Boss"`、
  `"#ORANGE#Boss"`、`"#SANDY_BROWN#Unique"`、`"#SALMON#Rare"`、
  `"#YELLOW#Elite"`、`"#ANTIQUE_WHITE#Normal"`、`"#C0C0C0#Critter"`）之一。
  這些片段雖然在原始碼中逐字存在，但它們**從未單獨經過 `_t()`／`tformat()`**——
  只有 `:format()` 組合後的完整字串才會流向 `game.log` 觸發一次 `tformat()`查表，
  而組合後的完整字串本身並不會逐字出現在原始碼中（是執行期才拼出來的），
  因此無論是翻譯片段或翻譯組合結果都不會生效，故不列入 locale。
- 第 501 行：
  `"#LIGHT_RED#AI Disabled due to timeout after ".. aiTurnCount .." turns. Did it get stuck?"`
  ——`aiTurnCount` 為數字，`..` 字串串接，成品字串隨回合數變動，無法逐字比對。

### 類別 C：判定為內部除錯字串，非自然語言說明文字，刻意不翻譯

- 第 324 行：`game.log(aiStateString())`——`aiStateString()` 回傳
  `"PAI_STATE_REST"` / `"PAI_STATE_EXPLORE"` / `"PAI_STATE_HUNT"` /
  `"PAI_STATE_FIGHT"` / `"Unknown State"` 其中之一。這 5 個字串雖然技術上
  可經由 `game.log` 的 tformat 查表命中，但其內容是程式內部狀態常數名稱
  （全大寫加底線），不是自然語言提示文字，性質上更接近「內部 key」而非
  玩家導向說明；比照 GUIDE「各種 id／內部 key 不要翻」的精神，判定不翻譯。

### 類別 D：已停用（註解）程式碼，不會執行

- 第 243 行 `--game.log("#GOLD#AI Turns Rested: "..tostring(turns))`
- 第 454、457、460 行 `--game.log("#RED#Path not found, trying beeline")` 等 3 行
- 第 479–482 行 `Dialog:simplePopup("AI active!", ...)` 整段

以上皆為 `--` 註解掉的死碼，不會在執行期呼叫，故不翻譯。

### 類別 E：addon 中介資料（非遊戲內字串）

`init.lua` 的 `long_name`／`description`（含版本更新記錄）是 ToME4
addon 選單/官網用來介紹此 addon 的中介資料，不經過遊戲內
`_t()` 翻譯流程顯示，且與本專案「翻譯遊戲內可見字串」的範圍不同，
本次不處理（與其餘 3 個 addon 的判定一致）。

## 術語決策

- AI 保留原文「AI」，不譯「人工智慧」（ToME 社群慣用簡稱）。
- wilderness → 沿用官方 zh_hant 譯法「野外」。
- suffocating → 沿用官方 zh_hant 譯法「窒息」。
- 顏色碼（`#GOLD#`、`#RED#`、`#LIGHT_RED#`、`#WHITE#` 等）原樣保留，不翻譯、不刪除。
