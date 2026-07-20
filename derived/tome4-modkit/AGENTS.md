# tome4-modkit — Agent 專案備忘

## 專案摘要

- 專案一句話：讓 AI agent 自主開發 Tales of Maj'Eyal (ToME 4, 1.7.6) addon 的工具鏈與知識庫——開發、靜態檢查、打包、佈署、無頭測試一條龍。
- 主要語言：Lua 5.1 / LuaJIT（引擎 VM）＋ Bash（工具腳本）
- 主要 lint 指令：`tools/lint.sh <addon>`
- 主要 build 指令：`tools/build.sh <addon>` → `build/tome-<name>.teaa`
- 主要 deploy 指令：`tools/deploy.sh <addon>`（目錄形式，改檔即生效）
- 主要 test 指令：`tools/verify.sh <addon>`（Xvfb 無頭）

## 先讀哪裡

- 要動手做某件事 → [WORKFLOWS.md](WORKFLOWS.md)
- 要做 addon → [workflows/addon-dev/README.md](workflows/addon-dev/README.md)
- 引擎真實行為 → [knowledge/](knowledge/)（每條附 `檔案:行號`）
- repo 結構 → [workflows/common/code-map/CODE_MAP.md](workflows/common/code-map/CODE_MAP.md)

## Always-on 鐵律

### 本專案專屬（違反會壞事）

1. **絕不在真實桌面執行 `t-engine64`。** 它沒有 `--help`；任何參數都直接開遊戲視窗，會在使用者桌面彈出對話框。一律：
   ```bash
   xvfb-run -a env LIBGL_ALWAYS_SOFTWARE=1 timeout 90 \
     ./t-engine64 --no-steam --no-web --flush-stdout --home <scratch>
   ```
   要用真桌面的滑鼠／鍵盤前**先問使用者**。
2. **`~/repo/moddings/tome4/analysis/t-engine/` 不是權威。** 那是索引。任何 API 結論都要回 `~/repo/moddings/tome4/projects/t-engine4/` 原始碼複驗，並在文件裡附 `檔案:行號`。
3. **唯讀區不准寫**：`projects/t-engine4/`、`~/.steam/.../TalesMajEyal/`、`~/repo/moddings/tome4/external/orig/`。
4. **佈署目標是 `~/.t-engine/4.0/addons/`**，不是 Steam 的 `game/addons/`。理由與行號見 `tools/deploy.sh` 檔頭。
5. **改完必跑** `tools/lint.sh`；要宣稱「能動」必須跑過 `tools/verify.sh` 並貼出輸出。沒跑就說沒跑。

### 通用

- 重構必須 behavior-preserving；改完跑對應檢查。
- 未經使用者確認，不 push、不開新大型工作。
- 不 revert 使用者或其他 agent 的未確認變更；遇衝突先停下說明。
- 非微小工作先定義 `Done when:`。
- 需要使用者親自驗證／實機確認 → 記到 [WAIT_USER.md](WAIT_USER.md)。
- 跨 session 的 open 狀態 → [SESSION-LOG.md](SESSION-LOG.md)。
- 架構圖／流程圖用 Mermaid、表格、列點；**不要 ASCII 框線圖**（中文全形寬度對不齊）。
- 輸出語言：繁體中文。

## 分層思想

```text
AGENTS.md → WORKFLOWS.md → 各工作流入口 → 工作流內容
                        ↘ knowledge/ （引擎事實，附行號）
                        ↘ mods/     （實際 addon 原始碼）
                        ↘ tools/    （冪等腳本）
```

## 本地專案規則

- **生成檔不 commit**：`build/` 已在 `.gitignore`。
- **commit 訊息**：`feat(runewright): ...` / `feat(tools): ...` / `docs(knowledge): ...`
- **測試環境限制**：無頭測試需要 `xvfb-run`；本機 Manjaro 已有。Windows 未複驗。
- **版本綁定**：addon 的 `version` 必須與模組 1.7.6 相容，否則 `engine/Module.lua:394` 的 `natural_compatible` 為 false，addon 會被靜默移除。

## 可選工作模式

- [analysis](workflows/analysis.md)、[create](workflows/create/README.md)、[patch](workflows/patch/README.md)、[research](workflows/research/README.md)、[html-guide](workflows/html-guide/README.md)
