# INDEX — tome4 專案地圖

整個專案的頂層導航。tome4 = **ToME4 (Tales of Maj’Eyal) addon 開發工作區**——工具鏈＋自製 addon＋文檔層是主體，其餘降為 `sub_proj/`。AGENTS.md 只放鐵律 + 指向本檔；細節從這裡分流出去。

---

## Repo 佈局

**非侵入式佈局**：repo 頂層只留 `AGENTS.md` / `CLAUDE.md` 兩個 agent 入口與專案自己的
`README.md`，這套工作流 kernel 的其餘部分全部收在 `wf/`（本檔就在裡面）。
理由與慣例見 `~/repo/workflows/non-invasive-import.md`。

```text
tome4/
  AGENTS.md CLAUDE.md README.md   ← 頂層只有這些 .md
  tools/     一條龍工具鏈
  self_mods/ 自製 addon 原始碼（+ build/ 暫存、dist/ 成品）
  docs/      knowledge（引擎真相層）+ analysis（索引，非權威）+ html（導覽層）
  sub_proj/  tome4-ch（漢化）
  vendor/    唯讀第三方素材（不做版控）
  wf/        工作流 kernel（本檔所在）
  .claude/   skills + commands
```

### 主體

| 路徑 | 內容 |
|------|------|
| `tools/` | 一條龍工具鏈：lint→build→deploy→verify→playtest。bash 進入點 + `lib/`（行程與檔案系統）+ `lua/`（判讀邏輯）+ `probes/`（遊戲內狀態探測）。決策表見 [tools/README.md](../tools/README.md)。|
| `self_mods/` | **自製 addon 原始碼**，一個子目錄一個 addon（含開發用測試夾具 `tome-autobirth`）。`build/` 是打包暫存產物，不保證與源碼同步（已 gitignore）；`dist/` 是確認過、帶版本、可交付的成品。|
| `docs/knowledge/` | **引擎真相層**：引擎的實際行為，每條附 `檔案:行號`。比 `docs/analysis/` 可信。|
| `docs/analysis/` | T-Engine4 架構分析與 17 篇 addon 教程。**索引性質，非權威**；API 結論一律回 `vendor/t-engine4/` 複驗。|
| `docs/html/` | knowledge / 工具鏈 / SOP 的 HTML 導覽層（`.md` 才是唯一真相來源）。|
| `.claude/` | [skills](../.claude/skills/)（冷啟動 agent 的觸發定義）+ [commands](../.claude/commands/)（slash 指令，如 `/wf-tick`）。|

### `sub_proj/` — 次要專案

| 路徑 | 內容 |
|------|------|
| `sub_proj/tome4-ch/` | 正體中文化：18 個第三方 addon 的 `zh_hant` 伴生 addon 源碼 + `_tools/` 翻譯管線 + `build/*.teaa`。動手前先讀它的 `README.md` / `GUIDE.md`。|

### `vendor/` — 唯讀第三方素材（不做版控）

| 路徑 | 內容 |
|------|------|
| `vendor/t-engine4/` | Steam 版解壓的引擎 + ToME 模組 Lua 源碼（126MB）。**權威真相層**，還原步驟見 [AGENTS.md](../AGENTS.md)「Fresh clone / 環境還原」。|
| `vendor/orig/` | 25 個實裝過的第三方職業包 / QoL addon 解壓（105MB）。`sub_proj/tome4-ch/_reference/` 以 symlink 指回此處。|
| `vendor/chn-mod/` | 簡體翻譯包範本。|

### `wf/` — 工作流 kernel（本檔所在）

| 路徑 | 內容 |
|------|------|
| `workflows/` | 各工作流的入口與 durable 知識（派發表見 [WORKFLOWS.md](WORKFLOWS.md)）。|
| `session_log/` | 一句話日誌的歷史封存（按月分檔）；活狀態在 [SESSION-LOG.md](SESSION-LOG.md)。|
| `inbox/` | agent 之間的**信件**收件匣（放信處，保持乾淨；使用方式見 [workflows/inbox/](workflows/inbox/README.md)）。|
| `WORKFLOWS.md` `INDEX.md` `DEV-GUIDE.md` `SESSION-LOG.md` `WAIT_USER.md` | kernel 的五份頂層文件 |

> 某目錄內部複雜就在該目錄放它自己的 README / INDEX，本檔只留一句話 + 連結——永遠只描述「頂層」。

## 工作流

工作流的**選擇與入口**見 **[WORKFLOWS.md](WORKFLOWS.md)** 的派發表。每個工作流的 durable 知識歸在 `workflows/<該工作流>/` 或單檔 `workflows/<該工作流>.md`（含 `archive/` 封存過時文檔），具體流程在各自入口檔。

[DEV-GUIDE](DEV-GUIDE.md) 是**被動的結構整理參考**（結構整理原則 + 四級成長軌跡）——**只在要重構/整理結構時取用**。always-on 的**鐵律**在 [AGENTS.md](../AGENTS.md)；碰原始碼的**程式碼慣例**在 [workflows/common/conventions.md](workflows/common/conventions.md)。

## 通用（跨工作流共享）

| 路徑 | 內容 |
|------|------|
| [common/README](workflows/common/README.md) | 跨工作流共通：[gotchas](workflows/common/gotchas.md) 踩坑、[conventions](workflows/common/conventions.md) 程式碼慣例 + 真相層優先級 + CODE_MAP 維護鏈、[code-map](workflows/common/code-map/CODE_MAP.md) 程式碼導航 |

## 活狀態（只列還沒完成的）

三軸：進度＝我手上的、待使用者＝卡在人、信件＝agent 之間收發（像 email）。

| 檔案 | 用途 |
|------|------|
| [SESSION-LOG](SESSION-LOG.md) | 進度 hub（repo 根）→ 各工作流 session-log（open-only）|
| [WAIT_USER](WAIT_USER.md) | 待**使用者**親自做/驗證的入口（open-only）|
| `inbox/`（放信處）+ [workflows/inbox/](workflows/inbox/README.md)（使用方式）| agent 之間的**信件**（像 email，狀態靠位置：inbox 頂層＝未處理、`done/`＝已處理）|
