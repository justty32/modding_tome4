# roadmap — 路線圖入口

放確定會做、但還不一定何時做的項目。不要把完整設計塞在這裡；設計升到 specs，動工細節升到 plans。

## 規則

- 開始前寫 `Done when: <項目被歸類、狀態清楚、下一步明確>`。
- 每個項目要有狀態：候選 / 排隊 / 冷凍 / 已升 spec / 已落地。
- 缺口從 investigation 來，成熟後升 specs。
- 已落地項目移出 roadmap，必要時在 feature-dev/landed 留濃縮記錄。

## Roadmap

| 項目 | 狀態 | 下一步 |
|------|------|--------|
| **符文盤（Rune Board）自訂 UI 面板** | 排隊（使用者明確要求，但說先不做） | 先查 ToME 的 `engine.ui.Dialog` 與面板掛載方式，寫 `docs/knowledge/ui-dialogs.md` |
| ~~盧恩術士剩餘 2 個技能樹~~ → 改為古弗薩克文三族，已實作 | 已落地 | `runic-wards`/`glyphs` 取消，由 futhark-freyr/heimdall/tyr 取代 |
| 共鳴的實際戰鬥效果 | 已落地 | 4 個共鳴皆有宣告式 effects，實機驗證 mana_regen 加成生效 |
| playtest 無法施放「升級後新學」的天賦 | 排隊 | 快捷鍵只有 1-5 綁定、Minimalist UI 不顯示快捷鍵列。解法：改綁鍵 / 測試用 birth talents / Classic uiset |
| 彈道、範圍、光束特效未經人眼確認 | 排隊 | 程式碼已對齊原版慣用法，但只親眼看過 arcane_power 光環 |
| i18n：技能與描述接進 `~/repo/moddings/tome4/sub_proj/zh_mods` 漢化管線 | 冷凍 | 等內容穩定 |
| Windows 支援 | 冷凍 | 目前全部標「未複驗」 |

### 符文盤 UI — 已預留的約束（不要破壞）

共鳴是湧現式機制：玩家需要看到「目前刻了什麼、充能多少、**再刻上 X 會觸發 Y**」。
內建技能列表表達不了，所以面板是玩法的必需品，不是裝飾。

- `self_mods/tome-runewright/data/lib/resonance.lua` 是**純函數模組**，不碰 actor 狀態。
  `M.predict(list, candidate)` 就是給面板做預測提示用的。
  任何把共鳴判定搬進 `on_learn` 或 actor 方法的重構，都會讓面板得重寫。
- `Actor:runewrightInscriptionList()` / `runewrightResonances()`（superload）已把資料備好。

動工前要查（**都還沒查，不要假設**）：面板範本 `modules/tome/mod/dialogs/CharacterSheet.lua`；
怎麼掛到技能列按鈕 + 快捷鍵（`game:registerDialog`？）；有沒有 hook 可加 UI 元素，
還是只能 superload `mod/class/uiset/Minimalist.lua`；addon 的圖片資源路徑怎麼解析。

## 何時不用

- 只是未成熟靈感，走 idea。
- 已經要設計，走 specs。
- 已經要動工，走 plans/feature-dev。
