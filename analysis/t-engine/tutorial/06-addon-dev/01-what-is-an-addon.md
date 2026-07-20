ToME 的 Addon 機制讓你在**不修改遊戲原始碼**的情況下：

- 新增職業、種族、技能樹、天賦
- 替換或擴充現有的 Lua 類別方法
- 注入回調至遊戲生命週期的特定時刻
- 覆蓋資源檔案（圖片、地圖、對話腳本）

Addon 是放在 `game/addons/<short_name>/` 的目錄（開發期間），或封裝成 `.team` zip 檔案（發布時）。引擎啟動後，`bootstrap/boot.lua` 會自動掃描並掛載啟用的 Addons。

---
