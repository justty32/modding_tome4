# INDEX — tome4 專案地圖

整個專案的頂層導航。tome4 = **ToME4 (Tales of Maj'Eyal) modding 工作區——addon 開發工具鏈＋知識庫＋引擎架構分析**。AGENTS.md 只放主工作流 + 指向本檔；細節從這裡分流出去。

---

## Repo 佈局

| 路徑 | 內容 |
|------|------|
| `derived/tome4-modkit/` | addon 開發主場：一條龍工具鏈（開發→lint→打包→部署→無頭測試）+ 引擎知識庫（`knowledge/`）+ addon 原始碼（`mods/`）。動手前先讀它的 `AGENTS.md`（更細的鐵律）。|
| `derived/tome4-ch/` | 正體中文化工作區：第三方 addon 的 `zh_hant` 伴生 addon 源碼 + 翻譯管線 + 打包好的 `build/*.teaa`。動手前先讀它的 `README.md` / `GUIDE.md`。|
| `analysis/t-engine/` | T-Engine4 架構分析與 addon 開發教程（索引性質，非權威；API 結論回 `projects/t-engine4/` 複驗）。|
| `projects/t-engine4/` | Steam 版解壓的引擎/模組 Lua 源碼（**唯讀真相層**，不做版控，還原步驟見 [AGENTS.md](AGENTS.md)）。|
| `external/` | 第三方 addon 參考素材（`orig/` 實裝 addon 解壓 + `chn-mod/`；不做版控）。|
| `dist/` | 自製成品：打包好的 `.teaa` addon（帶版本 + `SOURCE.md`）。|
| `workflows/` | 開發工作流（入口見 [WORKFLOWS.md](WORKFLOWS.md)）。|
| `.claude/commands/` | slash 指令（如 [`/wf-tick`](.claude/commands/wf-tick.md) 驅動定期心跳）。|
| `inbox/` | agent 之間的**信件**收件匣（放信處，保持乾淨；使用方式見 [workflows/inbox/](workflows/inbox/README.md)）。|

> 某目錄內部複雜就在該目錄放它自己的 README / INDEX，本檔只留一句話 + 連結——永遠只描述「頂層」。

## 工作流

工作流的**選擇與入口**見 **[WORKFLOWS.md](WORKFLOWS.md)** 的派發表。每個工作流的 durable 知識歸在 `workflows/<該工作流>/` 或單檔 `workflows/<該工作流>.md`（含 `archive/` 封存過時文檔），具體流程在各自入口檔。

[DEV-GUIDE](DEV-GUIDE.md) 是**被動的結構整理參考**（結構整理原則 + 四級成長軌跡）——**只在要重構/整理結構時取用**。always-on 的**鐵律**在 [AGENTS.md](AGENTS.md)；碰原始碼的**程式碼慣例**在 [workflows/common/conventions.md](workflows/common/conventions.md)。

## 通用（跨工作流共享）

| 路徑 | 內容 |
|------|------|
| [common/README](workflows/common/README.md) | 跨工作流共通：[gotchas](workflows/common/gotchas.md) 踩坑 + [conventions](workflows/common/conventions.md) 程式碼慣例 |

## 活狀態（只列還沒完成的）

三軸：進度＝我手上的、待使用者＝卡在人、信件＝agent 之間收發（像 email）。

| 檔案 | 用途 |
|------|------|
| [SESSION-LOG](SESSION-LOG.md) | 進度 hub（repo 根）→ 各工作流 session-log（open-only）|
| [WAIT_USER](WAIT_USER.md) | 待**使用者**親自做/驗證的入口（open-only）|
| `inbox/`（放信處）+ [workflows/inbox/](workflows/inbox/README.md)（使用方式）| agent 之間的**信件**（像 email，狀態靠位置：inbox 頂層＝未處理、`done/`＝已處理）|
