# 教學 07：為 ToME 新增職業與技能樹（進階 Addon）

> **目標**：深入 ToME 的職業系統，製作一個完整的新職業「血術師（Sanguinist）」：自訂技能類型（TalentType）、五個技能（含被動、施放、持續）、依賴鏈、熟練度系統、Birther 整合、起始裝備，以及種族相容性設定。
>
> **前置條件**：閱讀並理解教學 06（Addon 基礎）。本教學是教學 06「暗影刺客」的直接延伸，聚焦在教學 06 沒有詳細說明的進階細節。


> 本文件為自動產生的索引檔，原始大檔已按章節拆分。

## 目錄

- [1. TalentType 深度解析](07-tome-class/01-talenttype-deep-dive.md)
- [2. newTalent 所有選項](07-tome-class/02-newtalent-options.md)
- [3. require：前置條件完整規格](07-tome-class/03-require-prerequisites.md)
- [4. 技能依賴鏈範例](07-tome-class/04-talent-dependency-chain.md)
- [5. Birther subclass 深度解析](07-tome-class/05-birther-subclass-deep-dive.md)
- [6. descriptor_choices：種族與職業相容性](07-tome-class/06-descriptor-choices-compatibility.md)
- [7. resolvers.equipbirth 與 resolvers.inventorybirth](07-tome-class/07-resolvers-equip-inventory-birth.md)
- [8. 熟練度系統（Mastery）](07-tome-class/08-mastery-system.md)
- [9. 完整 Addon 實作](07-tome-class/09-complete-addon-implementation.md)
- [10. 測試與除錯技巧](07-tome-class/10-testing-debugging.md)
- [11. 常見錯誤排查](07-tome-class/11-troubleshooting.md)
- [小結：製作新職業的完整檢查清單](07-tome-class/checklist-new-class.md)
