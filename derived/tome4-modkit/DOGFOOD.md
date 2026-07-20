# DOGFOOD — 實戰試用記錄

記錄把模板裝到真 repo 後的摩擦。只把實戰中真的痛到的問題升到下一版。

## 2026-07-04 — `noval_assist` minimal install

Command:

```bash
scripts/install.sh /home/lorkhan/repo/narratives/noval_assist --minimal
scripts/check-workflow.sh /home/lorkhan/repo/narratives/noval_assist
```

Result:

- Existing `WORKFLOWS.md` was preserved.
- Missing workflow support files were installed.
- Health check passed.

Friction:

- `AGENTS.md` installs as a generic TODO template. This is correct but easy to forget; adoption is not complete until `INIT-QUESTIONS.md` is answered and AGENTS is customized.
- `--minimal` is larger than the name suggests because it installs every file linked by `WORKFLOWS.md`, avoiding broken links. The name means "minimal self-contained docs", not "fewest files".
- Existing repo-specific `WORKFLOWS.md` may not point at newly installed generic workflows. This is good for preserving local workflow, but adoption docs should make the merge step more explicit.

0.1.1 candidates:

- Add `POST-INSTALL.md` or a short post-install checklist to make customization explicit.
- Consider renaming modes in docs: `minimal` → `self-contained-minimal`, or explain the meaning more prominently.
- Improve `check-workflow.sh` with an optional `--strict` mode that warns about unfilled `TODO` placeholders.
- Add an installer summary line when existing critical files are skipped, telling the user to manually merge.

