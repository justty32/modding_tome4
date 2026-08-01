# docs — 文檔層

三塊，職責與**權威性**完全不同：

| 路徑 | 是什麼 | 權威性 |
|---|---|---|
| [`knowledge/`](knowledge/README.md) | **引擎真相層**——ToME 1.7.6 引擎的實際行為，每條都在原始碼複驗過並附 `檔案:行號` | **權威**（agent 動手前必讀）|
| [`analysis/`](analysis/) | T-Engine4 架構分析與 17 篇 addon 開發教程，2026-07 早期產出 | **非權威**，只當索引 |
| [`html/`](html/index.html) | **導覽層**——把 `.md` 整理成可瀏覽的頁面 | 非真相（產給人看的）|

## `knowledge/` 才是真相，`analysis/` 只是索引

這條分野是 always-on 鐵律（見根 [AGENTS.md](../AGENTS.md)）：

```text
vendor/t-engine4 原始碼 / 實測  >  docs/knowledge/  >  docs/analysis/（索引）  >  一般文檔
```

- 任何來自 `analysis/` 的 API 結論，都要回 `vendor/t-engine4/` 原始碼複驗才能用。
- 複驗完的結論寫進 `knowledge/`，**必須附 `檔案:行號`**——不附就等於沒複驗過。
- 兩者衝突時以 `knowledge/` 為準，並回頭修正 `analysis/`。
- 路徑代號 `E`（引擎）／`M`（ToME 模組）／`R`（第三方 addon 參考）的實際位置見
  [`knowledge/README.md`](knowledge/README.md)。

## `html/` 不是真相

`.md` 才是唯一真相來源，`html/` 只是導覽層。改了 `.md` 而沒同步 `html/`，一律以 `.md` 為準。
維護方式見 [`../wf/workflows/html-guide/README.md`](../wf/workflows/html-guide/README.md)。

> `analysis/` 底下另有自己的 `html/`，那是它自帶的導覽層，與本層的 `html/` 各自獨立。
