# workflow — 可移植專案工作流

這份目錄是從 ModForge 抽出的通用 `.md` 工作流骨架，用來放進其他專案後快速建立同一套工作方式。

## Quickstart

```bash
# 最小導入
scripts/install.sh ~/repo/target --minimal

# 標準導入（預設）
scripts/install.sh ~/repo/target

# 完整導入
scripts/install.sh ~/repo/target --full

# 健康檢查
scripts/check-workflow.sh ~/repo/target

# 模板自身 smoke test
tests/smoke.sh
```

核心思想：

- 頂層只做路由，不堆細節。
- durable 知識放在所屬工作流，不往上層塞。
- open 狀態只列還沒完成的事，完成後移除或濃縮到 landed/archive。
- 碰原始碼時維持「程式碼 → CODE_MAP → 文檔」一致。
- 重構必須行為不變，一次只動一個面向。
- 小事可以跳流程；工作流只在它能降低交接、同步或設計風險時啟用。

## 怎麼放進新專案

1. 先讀 [ADOPTION.md](ADOPTION.md)，選最小導入、標準導入或研究導入。
2. 把需要的 `.md` 和 `workflows/` 複製到目標 repo 根目錄。
3. 依專案改寫 `AGENTS.md` 的「專案摘要」「開發環境」「本地鐵律」。
4. 依 repo 結構填 `workflows/common/code-map/CODE_MAP.md`。
5. 把測試、build、lint、package 指令填進 `workflows/testing.md` 和 `workflows/dev-env.md`。
6. 開始工作前從 `WORKFLOWS.md` 選工作流入口。

## 檔案角色

| 路徑 | 用途 |
|------|------|
| `AGENTS.md` | agent 最頂層備忘：專案摘要、always-on 鐵律、路由入口 |
| `WORKFLOWS.md` | 依使用者意圖派發到工作流 |
| `PRINCIPLES.md` | 輕量使用原則：何時啟用/跳過流程、Done when |
| `ADOPTION.md` | 導入既有 repo 的分階段方式 |
| `MAINTENANCE.md` | 定期清理、刪除規則、CODE_MAP/session-log 維護 |
| `SYNC.md` | 已導入 repo 如何跟模板更新 |
| `INIT-QUESTIONS.md` | 新 repo 導入問答 |
| `TEMPLATE-MANIFEST.md` | minimal/standard/full 檔案清單 |
| `UNINSTALL.md` | 移除/降級策略 |
| `DOGFOOD.md` | 實戰導入摩擦與下一版候選 |
| `DEV-GUIDE.md` | 被動參考：結構整理原則 |
| `SESSION-LOG.md` | open 進度 hub |
| `WAIT_USER.md` | 需要使用者親自做/驗證的事 |
| `workflows/` | 各工作流入口與 durable 知識 |

## Core

新專案優先導入這些：

| 工作流 | 用途 |
|--------|------|
| `AGENTS.md` | always-on 鐵律與入口 |
| `WORKFLOWS.md` | 工作流派發 |
| `PRINCIPLES.md` | 輕量使用原則 |
| `feature-dev` | 在本 repo 新增/修改功能 |
| `refactor` | behavior-preserving 拆分與整理 |
| `investigation` | bug 真因、可行性、現有系統調查 |
| `testing.md` | 測試/驗證命令 |
| `dev-env.md` | 開發環境矩陣 |
| `common/` | conventions + CODE_MAP |

## Optional

需要時再導入：

| 工作流 | 用途 |
|--------|------|
| `analysis` | 初次接觸陌生專案，建立 Level 1-6 分析 |
| `create` | 基於分析產物建立獨立衍生小專案 |
| `patch` | 建立冷啟動 agent 可套用的 patch 包 |
| `research` | paper/長文閱讀、摘要、翻譯、索引 |
| `html-guide` | 大量 `.md` 的 HTML 導覽層 |
| `commands/` | 可選 agent command 模板 |
| `scripts/` | 安裝、健康檢查 |
| `tests/` | smoke test |

## 範例

本 repo 以 `--standard` 導入，未包含模板的 `examples/`。填寫實例直接看本專案的 [AGENTS.md](AGENTS.md)。
