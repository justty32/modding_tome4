# 引擎事實：職業、天賦、資源、i18n

> 路徑代號 `E` / `M` / `R` 見 [README.md](../README.md)。
> addon 怎麼被載入見 [addon-loading.md](../addon-loading.md)——**所有定義都要手動 `loadDefinition`**。

## 4. 自訂資源池

```lua
-- E/interface/ActorResource.lua:45
defineResource(name, short_name, talent, regen_prop, desc, min, max, params)
```

- `short_name` 全域唯一，撞名 **assert 崩潰**（`:48`）。
- **`short_name` 必須是單一個字**：存取器由 `short_name:lower():capitalize()` 生成（`:68-73`），
  `"rune_charge"` 會變成醜陋的 `getRune_charge`。用 `"runecharge"` → `getRunecharge`/`incRunecharge`。
- `talent`：關聯的隱藏被動天賦。存取器只在 `knowTalent(talent)` 為真時回傳實值（`:87-94`）——**沒學那個天賦，資源讀出來恆為 0**。
- `regen_prop`：每回合把 `self[regen_prop]` 加到 `self[short_name]`（`:201`）。
- `min`/`max` 預設 `0`/`100`；傳 `false` 表示無上限（`:61-62`）。
- 必須在**任何 actor 被建立之前**呼叫（`:127-130` 的 `init` 依 `resources_def` 寫 `min_`/`max_` 欄位）。
  在 `ToME:load` hook 裡呼叫的時機正確。

持有池的隱藏被動天賦範本（`M/data/talents/misc/misc.lua:127-134`，`T_MANA_POOL`）：
`mode="passive"`、`hide="always"`、`no_unlearn_last=true`。
子職業要擁有該資源，需在 `talents` 表填 `[Talents.T_MANA_POOL] = 1`（`M/data/talents/spells/golemancy.lua:66`）。

官方資源定義在 `M/data/resources.lua`（Mana 在 `:73`）。

## 5. i18n

`_t(s, tag)` 依 `(原文, tag)` 複合鍵查表（`E/I18N.lua:65-70`）。locale 檔用 `t(src, dst, tag)` 註冊（`:141-156`），同時寫入萬用 `"nil"` tag 兜底（`:52-58`），但 **tag 對得上才保證命中**。

| 內容 | tag |
|---|---|
| 職業／子職業顯示名 | `"birth descriptor name"`（`E/Birther.lua:69`） |
| 天賦名稱 | `"talent name"`（`E/interface/ActorTalents.lua:88`） |
| 天賦分類名 | `"talent type"`（`M/data/talents/misc/objects.lua:20`） |
| 一般 `desc` 敘述 | 預設 `"_t"` |

查既有譯法：`grep` `M/data/locales/zh_hant.lua`（43k 行，**不要整檔讀**）。

### ⚠️ `t.name` 是**已翻譯**的，遊戲邏輯不准拿它比對

`E/interface/ActorTalents.lua:88` 在建立天賦時做 `t.name = _t(t.name, "talent name")`，
而 `short_name` 早在 `M/data/talents/misc/inscriptions.lua:24` 就用**英文原名**算好了。

所以在 `zh_hant` 語系下，銘文天賦的 `t.name` 是「符文：護盾」，拿 `"Shielding"` 去比對永遠不中。
**任何遊戲邏輯都要比對 `t.short_name`**（英文、與語系無關），`t.name` 只能拿來顯示。

這個 bug 只有在非英文語系實機遊玩才會現形——lint 與載入驗證都抓不到。

## 6. 銘文（inscription）

- `max_inscriptions` 預設 3（`M/mod/class/interface/ActorInscriptions.lua:30`）。
- 建角時基礎的回覆／狂暴紋身加上職業給的符文已經佔滿。
  子職業再寫 `resolvers.inscription(...)` 會在 `setInscription` 找不到空位時直接 return
  （`:72`，建角時 `vocal=false` 所以連訊息都沒有）——**靜默丟棄**。
- 銘文天賦一律帶 `is_inscription = true`（`M/data/talents/misc/inscriptions.lua:60`），
  `type[1]` 是 `inscriptions/{runes,infusions,taints}`。

## 坑清單

1. `newBirthDescriptor` 撞名靜默覆蓋，`newTalent` / `defineResource` 撞名 assert 崩潰——**三者行為不一致**。
2. `power_source` 在 `Birther:apply()` 沒被讀取，別以為填了就有效。
3. 資源存取器需 `knowTalent(pool_talent)`，否則恆回 0。
4. 資源 `short_name` 用底線會生出醜陋的存取器名。
5. **`t.name` 已被翻譯**，邏輯要用 `t.short_name`。
6. 銘文欄位滿了會靜默丟棄。
7. `passives` 只算一次，動態被動要用 `callbackOnActBase`。
8. `usedInscription()` 是死代碼，別掛它。
