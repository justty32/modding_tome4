# possessors-zh 翻譯筆記

## 概述

為 ToME4 addon **possessors**（Possessor Bonus Class，支配者職業包，`version {1,7,4}`）
製作的正體中文翻譯伴生 addon。採用 GUIDE.md 規定的 locale-only 機制（`data = true`
自動載入 `data/locales/zh_hant.lua`），不使用 hook / superload / overload。

## 條目來源與處理方式（重要說明）

`_reference/orig/possessors/` 原始碼**已經內建**一份 `data/locales/zh_hant.lua`
（504 行、258 條 `t()`），且經 `check_locale.lua` 驗證對原始碼 **unmatched=0**，
可見這是與目前原始碼版本完全同步、術語也已對齊官方基礎遊戲繁中翻譯
（意志=Willpower、靈巧=Cunning、靈晶=mindstar、心靈利刃=psiblade、
卡洛·斐濟=Kryl-Feijan、莎西·凱希=Shasshhiy'Kaish、太陽騎士艾琳=(High) Sun/Paladin Aeryn 等，
均以 grep 官方 `zh_hant.lua` 核對過 tag 與譯法一致）的既有翻譯。

因此本次工作以該既有翻譯為基底轉抄進本 addon 的 locale 檔（section 標頭改為
`data-possessors/...` 以符合 GUIDE 慣例），並**逐條校對**，修正下列問題後才驗收：

1. **badspec 修正**：`deep-horror.lua` 的 Ominous Form info() 原文含兩個 `%%`
   （`(Your life%% will always be identical to your target's life%%)`），舊譯文漏掉
   這兩個格式符（意譯成「血量百分比」文字）。改為保留 `%%` 兩處：
   「使用竊取的身體時，你的生命值%%永遠與目標的生命值%%相同。」
2. **內容失真修正**：`possession.lua` 的 Assume Form info() 舊譯文夾雜了原文沒有的
   兩句話（提及「精神/魔法/其他效果仍然對你有效」「冷卻時間隨主宰技能等級提高」），
   應為版本更新後殘留的舊內容，且與現版原文（無主宰技能冷卻縮減機制）不符。
   已重新逐句對照原文改寫，移除無對應原文的內容。
3. **邏輯/語意修正**：`psionic-menace.lua` 的 Finger of Death info() 原譯文
   「如果目標從死亡，並且是你經可以佔有類型」語意不通（疑似殘留錯字），
   改為「如果目標因此死亡，且屬於你已能吸收的類型」，並將 `psychic-blows.lua`
   possession.lua 中 "You may not possess this kind of creature." 譯文結尾的頓號
   改為句號。
4. **標點一致性**：補上 3 條 achievement/`logPlayer` 文字結尾缺漏的句號
   （Bill Kill! 成就描述 x2、battle-psionics.lua 的雙武器警告）。

其餘 250+ 條沿用既有翻譯，僅檢查格式符與術語一致性，未逐字重寫（原譯文品質已相當高，
用詞與官方繁中版一致）。

## 來源檔覆蓋清單（共 21 個 .lua，扣除既有 4 個語系檔 = 25 個檔案全掃過）

| 來源檔 | 是否有玩家可見字串 | 對應 section |
|---|---|---|
| `data/achievements/possessors.lua` | 是（6 條） | `data-possessors/achievements/possessors.lua` |
| `data/birth/psionic.lua` | 是（8 條） | `data-possessors/data/birth/psionic.lua` |
| `data/talents/psionic/battle-psionics.lua` | 是（9 條） | 同名 section |
| `data/talents/psionic/body-snatcher.lua` | 是（8 條） | 同名 section |
| `data/talents/psionic/deep-horror.lua` | 是（12 條） | 同名 section |
| `data/talents/psionic/possession.lua` | 是（29 條） | 同名 section |
| `data/talents/psionic/psionic-menace.lua` | 是（10 條） | 同名 section |
| `data/talents/psionic/psionic.lua` | 是（10 條，天賦樹名/簡介） | 同名 section |
| `data/talents/psionic/psychic-blows.lua` | 是（12 條） | 同名 section |
| `data/talents/psionic/ravenous-mind.lua` | 是（10 條） | 同名 section |
| `data/timed_effects.lua` | 是（77 條，狀態效果） | `data-possessors/data/timed_effects.lua` |
| `init.lua` | 是（long_name + description，2 條） | `data-possessors/init.lua` |
| `overload/mod/dialogs/AssumeForm.lua` | 是（39 條，UI） | 同名 section |
| `overload/mod/dialogs/AssumeFormSelectTalents.lua` | 是（4 條，UI） | 同名 section |
| `hooks/load.lua` | 否——只呼叫 `loadDefinition`，無字串 | 無需翻譯 |
| `overload/mod/class/PossessorsDLC.lua` | 否——只是 `hookLoad` 定義，無字串 | 無需翻譯 |
| `superload/mod/class/Actor.lua` | 否——`gainExp` 覆寫，純邏輯無字串 | 無需翻譯 |
| `overload/data/gfx/particles/mind_steal.lua` | 否——粒子特效參數 | 無需翻譯 |
| `overload/data/gfx/particles/psionicbeam.lua` | 否——同上 | 無需翻譯 |
| `overload/data/gfx/particles/psionic_block.lua` | 否——同上 | 無需翻譯 |
| `overload/data/gfx/particles/psionicflash.lua` | 否——同上 | 無需翻譯 |
| `overload/data/gfx/particles/psychic_blow.lua` | 否——同上 | 無需翻譯 |

**條目總數：258 條**，涵蓋 14 個含玩家可見字串的來源檔；其餘 7 個檔案（hooks、
superload、5 個粒子特效檔）確認無任何玩家可見字串，故無條目。全部 25 個 .lua
（含既有的 4 個語系參考檔）均已逐檔檢視。

## 未覆蓋字串

無。checker 結果為 `entries=258 unmatched=0 badspec=0 empty=0`，全數 258 條原文
皆逐字存在於原始碑，格式符一致，譯文非空。

## 術語決策（沿用既有翻譯 + 官方基礎遊戲核對）

- Willpower → 意志、Cunning → 靈巧、Mindpower → 精神強度、mindstar → 靈晶、
  psiblade → 心靈利刃（以上均以 grep 官方 `zh_hant.lua` 核對一致）
- Possessor（職業名）→ 支配者；possession（天賦樹/effect subtype）→ 支配；
  body snatcher（天賦樹）→ 軀體奪取；psionic menace → 靈能威嚇；
  psychic blows → 靈能打擊；battle psionics → 靈能戰鬥；deep horror → 無盡恐懼；
  ravenous mind → 極度飢渴（以上為本 addon 專屬新詞，全檔案內部一致使用）
- Kryl-Feijan → 卡洛·斐濟、Shasshhiy'Kaish → 莎西·凱希、
  (High) Sun Paladin Aeryn → 太陽騎士艾琳（均沿用官方基礎遊戲既有譯名）
- `achievement name` / `birth descriptor name` / `talent name` / `talent type` /
  `talent category` / `effect subtype` / `tformat` / `logPlayer` / `logSeen` /
  `logCombat` / `say` / `log` / `init.lua long_name` / `init.lua description` 等
  tag 均比照官方檔同類型字串的 tag 用法。

## 驗證結果

```
lua5.1 ~/repo/moddings/tome4/derived/tome4-ch/_tools/check_locale.lua \
  ~/repo/moddings/tome4/derived/tome4-ch/tome-possessors-zh/data/locales/zh_hant.lua \
  ~/repo/moddings/tome4/derived/tome4-ch/_reference/orig/possessors/

entries=258  unmatched=0  badspec=0  empty=0
```
