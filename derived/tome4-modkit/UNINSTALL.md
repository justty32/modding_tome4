# UNINSTALL — 移除策略

不要用全自動刪除。導入後很多文件會被 repo 客製化，移除前要判斷是否仍有本地價值。

## 通常可刪

若未客製化，可直接刪：

- `ADOPTION.md`
- `MAINTENANCE.md`
- `SYNC.md`
- `INIT-QUESTIONS.md`
- `DEV-GUIDE.md`
- `commands/`
- `examples/`
- `scripts/`
- `.github/workflows/check.yml`
- `.editorconfig`
- `TEMPLATE-MANIFEST.md`

## 謹慎刪

這些通常已有本地內容，刪前先讀：

- `AGENTS.md`
- `WORKFLOWS.md`
- `PRINCIPLES.md`
- `workflows/common/conventions.md`
- `workflows/common/code-map/CODE_MAP.md`
- `workflows/testing.md`
- `workflows/dev-env.md`

## 通常不要刪

除非確定沒有 open 狀態或已另存：

- `SESSION-LOG.md`
- `WAIT_USER.md`
- 各工作流的 `session-log.md`
- repo 本地 specs/plans/research/findings
- `workflows/common/code-map/` 中已填寫的專案導航

## 移除流程

1. 確認 git 狀態乾淨。
2. 讀 `AGENTS.md`、`WORKFLOWS.md`、`SESSION-LOG.md`、`WAIT_USER.md`。
3. 把仍有價值的本地規則移到 repo 的 README 或其他既有文件。
4. 刪除未客製化的模板文件。
5. 跑 repo 的測試或至少跑 `scripts/check-workflow.sh .` 確認沒有半殘連結。
6. commit，說明移除了 workflow template 或降級為本地文件。

