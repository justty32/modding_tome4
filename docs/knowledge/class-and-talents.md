# 引擎事實：職業、天賦、資源、i18n

此文件已依主題拆分為 2 個子檔案（合計 < 8192 位元組），位於 `class-parts/` 下：

## [01-birth-and-talents.md](class-parts/01-birth-and-talents.md)

涵蓋 §1-3，5,180 位元組：
- `newBirthDescriptor`：必填欄位、子職業、`descriptor_choices`、`type=subclass` 欄位套用機制
- `newTalentType` / `newTalent`：必填欄位、讀取處、`short_name` 規則、動態被動效果
- 沒有 hook 時的 superload 做法

## [02-resources-i18n-inscriptions.md](class-parts/02-resources-i18n-inscriptions.md)

涵蓋 §4-6 + 坑清單，3,948 位元組：
- 自訂資源池：`defineResource` API、`short_name` 限制、與隱藏被動天賦的綁定、regen 機制
- i18n：`_t` tag 系統、`t.name` vs `t.short_name` 的翻譯陷阱
- 銘文：`max_inscriptions`、靜默丟棄、`is_inscription` 旗標
- 8 項坑清單
