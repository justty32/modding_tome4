# ToME4 Addon 正體中文化 — 工作指南

本指南給負責漢化單一 addon 的 agent。**讀完再動工。**

## 目標與原則

為指定的 ToME 4 (1.7.6) addon 製作一個**獨立的翻譯伴生 addon**（非侵入式 patch）：

- **絕不修改** `_reference/orig/` 下的原始 addon 檔案（唯讀參考）。
- 翻譯機制：引擎會對每個宣告 `data = true` 的 addon 自動載入
  `data/locales/<語系>.lua`（見引擎 `Module.lua:506`，路徑
  `~/repo/moddings/tome4/vendor/t-engine4/engines/te4-1.7.6/engine/Module.lua`）。
  locale 映射是**全域、以原文字串為 key**，所以一個伴生 addon 可以翻譯
  另一個 addon 的字串。
- 目標語系：**`zh_hant`（正體中文）**，使用者遊戲設定即此。
- **只用 locale 條目，不寫 hooks / superload / overload**。locale 覆蓋不到的字串
  記錄在 NOTES.md，不要硬幹。

## 交付物

輸出到 `~/repo/moddings/tome4/sub_proj/zh_mods/tome-<name>-zh/`（`<name>` 見任務指派）：

```
tome-<name>-zh/
├── init.lua                    # 用 _tools/init_template.lua 改
├── data/locales/zh_hant.lua    # 翻譯主體
└── NOTES.md                    # 正體中文：覆蓋範圍、未覆蓋字串清單+原因、術語決策
```

### init.lua 範本（`_tools/init_template.lua`）

```lua
long_name = "<原addon名> 正體中文化"
short_name = "<name>-zh"        -- 必須與資料夾名 tome-<name>-zh 的 <name>-zh 一致
for_module = "tome"
version = {1,7,6}
addon_version = {1,0,0}
weight = 1000000                -- 大權重，最後載入
author = {'tome4-ch'}
homepage = '-'
description = [[<原addon名> 的正體中文翻譯（非侵入式 locale patch）。]]
tags = {'translate'}
data = true                     -- 必要！否則 locale 不會被載入
```

## locale 檔格式

```lua
locale "zh_hant"

section "data-<原addon短名>/talents/xxx.lua"   -- 每個來源檔一節，方便維護

t([[原文字串]], [[譯文]], "tag")
t("短字串", "譯文", "tag")
```

### tag 的選擇（關鍵！tag 錯了翻譯不會生效）

**權威方法**：在官方翻譯檔找**同類型**的基礎遊戲字串，照抄它的 tag：
`~/repo/moddings/tome4/vendor/t-engine4/modules/tome/data/locales/zh_hant.lua`（43k 行，**用 grep 查，別整檔讀**）。
例：查天賦名 tag → `grep '"Fireball"' <官方檔>`；查聊天文本 → `grep -A5 'section "mod-tome/data/chats/' <官方檔> | head -30`。

官方檔 tag 使用統計（速查表）：

| tag | 用途 |
|---|---|
| `"_t"` | 一般字串（描述文、效果 desc、出生描述文…最大宗） |
| `"entity name"` | newEntity 的 name（物品/NPC 名） |
| `"tformat"` | 含 `%d` `%s` `%0.2f` 等格式符、經 `:tformat()` 顯示的字串（天賦 info 描述大多是這個） |
| `"talent name"` | newTalent 的 name |
| `"entity keyword"` / `"entity subtype"` / `"entity type"` / `"entity short_name"` | 實體對應欄位 |
| `"talent type"` / `"talent category"` | 天賦樹名 / 類別 |
| `"log"` | game.log / logSeen 訊息（幾乎都含格式符） |
| `"effect subtype"` | 狀態效果 subtype |
| `"damage type"` | 傷害類型名 |
| `"birth descriptor name"` | 出生選項（職業/種族）名 |
| `"chat"` / `"say"` | 對話文本 |

同一字串在不同 tag 下是**不同條目**；若同一原文以多種身分出現（如同字串既是天賦名又出現在 log），各補一條。

### 原文字串必須逐字節精確

src 必須等於**執行期**的字串內容：

- `[[...]]` 長字串：若 `[[` 後緊接換行，**該換行不屬於字串**（Lua 規則）；
  內部的縮排、tab、換行**全部屬於字串**，原樣照抄。
- `"..."` 引號字串：`\n` 在執行期是真換行——locale 檔裡寫 `[[...]]` 包真換行，
  或同樣用 `"...\n..."`。
- 別把前後空白、引號誤含進去。

### 譯文格式規則

- `%d` `%s` `%%` `%0.2f` 等格式符：**數量與順序必須與原文完全一致**
  （Lua format 不支援位置參數，不可調換順序；中文語序自己想辦法繞）。
- 色碼與標記原樣保留：`#RED#` `#ORCHID#` `#{italic}#` `#{normal}#` `#LIGHT_GREEN#` 等。
- 換行結構儘量對應原文（描述文的排版）。

## 翻譯範圍（什麼要翻）

掃 addon 的所有 `.lua`（含 `data/`、`hooks/`、`superload/`、`overload/`），抽出**玩家可見**字串：

- newTalent：name、天賦樹 newTalentType name/description、`info()` 回傳的描述字串、short_info
- newEffect（狀態效果）：desc、long_desc、on_gain/on_lose 訊息
- newEntity（物品/NPC）：name、desc、unided_name、subtype/type、keywords
- newBirthDescriptor（職業/種族）：name、desc
- 對話（chats）：text、answers
- game.log / logSeen / logPlayer 的訊息字串
- Dialog / UI / 遊戲選項的標題與說明文字
- 任務（quests）name、desc

**不要翻**（會壞遊戲邏輯或無意義）：
- 各種 id：`define_as`、`short_name`、`T_XXX` 天賦 id、DamageType id、圖檔路徑、
  resolvers 參數、內部 key
- 純開發者用的 print/debug 字串
- 程式用 `..` 動態串接、無法整串比對的字串 → 記入 NOTES.md「未覆蓋」清單

## 術語一致性

基礎遊戲已有的名詞**必須沿用官方 zh_hant 譯法**——用 grep 在官方檔查：
傷害/回合/護甲/豁免(saves)/法術強度(Spellpower)/物理強度(Physical Power)/
精神強度(Mindpower)/暴擊(crit)/冷卻(cooldown)/枯萎(wither)…以及本 addon 相關的
職業名、天賦樹名、既有天賦名。addon 專屬新名詞自行定譯，但全檔案內部要一致，
並把主要定譯記在 NOTES.md。

## 工作方式（大 addon 必讀）

- **一個來源檔一個來源檔處理**：讀一個 `data/talents/xxx.lua` → 翻譯 → append 到
  locale 檔（配 `section` 標頭）→ 下一個。**不要一次讀入全部原始碼**。
- 官方 43k 行翻譯檔只准 grep，不准整讀。

## 驗證（必跑，過了才算完工）

```bash
lua5.1 ~/repo/moddings/tome4/sub_proj/zh_mods/_tools/check_locale.lua \
    ~/repo/moddings/tome4/sub_proj/zh_mods/tome-<name>-zh/data/locales/zh_hant.lua \
    ~/repo/moddings/tome4/sub_proj/zh_mods/_reference/orig/<name>/
```

檢查項目：locale 檔 Lua 語法、每條 src 是否逐字存在於原 addon 原始碼、
格式符是否一致、譯文是否為空。**badspec 與 empty 必須為 0**；unmatched 目標為 0，
若有殘留須逐條在 NOTES.md 說明原因。

## 完工報告（你的最終輸出）

回報：條目總數、各來源檔覆蓋情況、checker 輸出、NOTES.md 摘要（未覆蓋+術語）。
不用打包 .teaa，主控會統一處理。
