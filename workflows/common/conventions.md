# 程式碼慣例

碰原始碼的工作流共用這套規矩：feature-dev、testing，以及日後長出來的 refactor / spec / plan 等。純文檔或調查類工作流按需參考。實際 addon 開發的更細慣例在 `derived/tome4-modkit/AGENTS.md`。

## 程式碼慣例

- 遵守專案既有風格，不為小改動引入新架構。
- 大檔按職責拆分；建議單檔超過 300 行就檢視（Lua addon 源碼同理）。
- 生成檔、schema、examples、fixtures 若會影響行為，視為源碼同步維護。
- breaking change 前先搜尋既有 examples、docs、tests，受影響者同一批更新。
- 新增公開 spec/API/config 欄位時，同步更新 schema、example、文件。

## 真相層優先級

引用引擎 API 或行為結論時，以較上層為準，並附 `檔案:行號`：

```text
projects/t-engine4 原始碼 / 實測 > derived/tome4-modkit/knowledge > analysis/t-engine（索引，非權威）> 一般文檔
```

規則：

1. 上層與下層衝突時，以上層為準並修正下層。
2. `analysis/t-engine/` 只是索引；任何 API 結論都要回 `projects/t-engine4/` 原始碼複驗。
3. 程式碼導航以 `derived/tome4-modkit/knowledge/` 與各 addon 自己的結構為準——本 repo 頂層不另存 CODE_MAP。

## 多 Agent 並行

- 並行前先分互斥檔案或領域。
- 每個 agent 必須有自己的 `Done when:`。
- 共享 open 狀態寫 session-log。
- 整合者負責讀產物、解衝突、跑測試、同步文檔。
