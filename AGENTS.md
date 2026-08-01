# tome4 — Agent 專案備忘

最頂層路由器：只放 always-on 鐵律與入口連結，細節在各工作流。

## 專案摘要

- 專案一句話：讓 AI agent **自主開發 Tales of Maj'Eyal (ToME 4, 1.7.6) addon** 的工具鏈與知識庫——開發 → 靜態檢查 → 打包 → 佈署 → 無頭測試，一條龍。
- 主要語言：Lua 5.1 / LuaJIT（T-Engine4 VM）＋ Bash（工具進入點）
- lint：`tools/lint.sh <addon>`
- build：`tools/build.sh <addon>` → `self_mods/build/tome-<name>.teaa`
- deploy：`tools/deploy.sh <addon>`（目錄形式，改檔即生效）
- test：`tools/verify.sh <addon>`（Xvfb 無頭）／`tools/playtest.sh`（無頭實機遊玩）

## 先讀哪裡

- 要動手做某件事 → [WORKFLOWS.md](wf/WORKFLOWS.md)：依意圖派發到對應工作流
- 要做 addon → [workflows/addon-dev/README.md](wf/workflows/addon-dev/README.md)
- **要跑工具 → [tools/README.md](tools/README.md)**（決策表：我想做 X 就跑哪支；每支腳本也吃 `-h`）
- 引擎真實行為 → [docs/knowledge/](docs/knowledge/README.md)（每條附 `檔案:行號`）
- repo 結構 → [INDEX.md](wf/INDEX.md)｜程式碼導航 → [workflows/common/code-map/CODE_MAP.md](wf/workflows/common/code-map/CODE_MAP.md)

## Always-on 鐵律

### 本專案專屬（違反會壞事）

1. **絕不在真實桌面執行 `t-engine64`。** 它沒有 `--help`；任何參數都直接開遊戲視窗，會在使用者桌面彈出對話框。自動化一律走 `tools/verify.sh` / `tools/playtest.sh`（它們自己開 Xvfb）：
   ```bash
   xvfb-run -a env LIBGL_ALWAYS_SOFTWARE=1 timeout 90 \
     ./t-engine64 --no-steam --no-web --flush-stdout --home <scratch>
   ```
   要用真桌面的滑鼠／鍵盤或 `tools/run.sh` 前**先問使用者**。
2. **`docs/analysis/` 不是權威**，那是索引。任何 API 結論都要回 `vendor/t-engine4/` 原始碼複驗，並在文件裡附 `檔案:行號`。
3. **唯讀區不准寫**：`vendor/`（含 `t-engine4/`、`orig/`、`chn-mod/`）、`~/.steam/.../TalesMajEyal/`。
4. **佈署目標是 `~/.t-engine/4.0/addons/`**，不是 Steam 的 `game/addons/`。理由與行號見 `tools/deploy.sh` 檔頭。
5. **改完必跑** `tools/lint.sh`；要宣稱「能動」必須跑過 `tools/verify.sh` 並貼出輸出。沒跑就說沒跑。
6. **實機測試時，AI 取得狀態一律用 `tools/playtest.sh probe`（回傳純文字）**；截圖照產但那是**給使用者看的**——畫面、渲染、手感、平衡由使用者判斷，AI 不自己讀圖（人眼更可靠，圖片也很吃 token）。
7. **`verify.sh` / `playtest.sh` 跑的是拋棄式 scratch home。** 要交給使用者玩，得另外明確跑一次 `tools/deploy.sh <addon>`（不帶 `--home`），否則他的遊戲裡什麼都沒有。
8. **使用者不能從 Steam 開遊戲**——引擎自身的工坊同步回呼會 SIGSEGV，與 addon 無關。用 `tools/run.sh`（帶 `--no-steam`）。詳見 `docs/knowledge/real-machine.md`。

### 通用

- 重構必須 behavior-preserving；改完跑對應檢查。
- 未經使用者確認，不 push、不開新大型工作。
- 不 revert 使用者或其他 agent 的未確認變更；遇衝突先停下說明。
- 各工作流的具體流程在自己的入口檔，不在本檔重複。
- 小事可以跳流程；工作流只在能降低交接／同步／設計風險時才啟用（見 [WORKFLOWS.md](wf/WORKFLOWS.md)）。
- 非微小工作先定義 `Done when:`。
- 需要使用者親自驗證／實機確認 → 記到 [WAIT_USER.md](wf/WAIT_USER.md)。
- 跨 session 的 open 狀態 → [SESSION-LOG.md](wf/SESSION-LOG.md) 或對應工作流的 `session-log.md`。
- 引用外部程式碼或技術結論時附來源位置：`path/to/file:line`、函式名、URL、命令輸出摘要。
- 架構圖／流程圖用 Mermaid、表格、列點；**不要 ASCII 框線圖**（中文全形寬度對不齊）。
- 輸出語言：繁體中文。

## 分層思想

**非侵入式佈局**：repo 頂層只有 `AGENTS.md`（本檔）、`CLAUDE.md`、`README.md` 三個 `.md`，
工作流 kernel 的其餘部分收在 `wf/`。慣例見 `~/repo/workflows/non-invasive-import.md`。

```text
AGENTS.md → wf/WORKFLOWS.md / wf/INDEX.md → 各工作流入口 → 工作流內容
                        ↘ tools/                 （冪等腳本）
                        ↘ docs/knowledge/        （引擎事實，附行號）
                        ↘ docs/analysis/         （早期分析，非權威，只當索引）
                        ↘ docs/html/             （導覽層，.md 才是真相）
                        ↘ self_mods/             （自製 addon 原始碼 + build/ + dist/）
                        ↘ sub_proj/              （次要專案：目前只有漢化）
                        ↘ vendor/                （唯讀第三方素材）
```

- `README.md` = 初入一個資料夾先讀的入口／導引。
- `INDEX.md` = 描述該資料夾頂層結構的索引。
- 小資料夾可以 README 兼 index；變大後才拆出獨立 INDEX。
- durable 知識歸到它所屬的工作流，不堆在頂層。

## 本地專案規則

- **目錄佈局**：主體是 `tools/`（工具鏈）＋`self_mods/`（自製 addon）＋`docs/`（knowledge 真相層 + html 導覽層）；
  次要專案在 `sub_proj/`（目前只有漢化）；唯讀第三方素材在 `vendor/`；工作流 kernel 在 `wf/`。
  完整說明見 [INDEX.md](wf/INDEX.md)。
- **`vendor/t-engine4/` 是唯讀真相層**：C 層原始碼（`src/`）不在本地——本地只有 Steam 版隨附的 Lua 層。
  要對照 C 碼需另從官方 git（te4.org）取得。
- **`docs/knowledge/` 是比 `docs/analysis/` 更可信的引擎真相層**（同樣附行號）。
- **根 `README.md` 是外來 agent 的入口**（設計情境：`~/notes` 側的 agent 被派來「找做好的 addon 去部署」）
  ——它必須永遠答得出「成品在哪」（`self_mods/dist/`）與「部署狀態歸 `~/notes` 側管」。改佈局時同步更新它。
- **本機部署狀態**（已裝 addon 清單、`~/.t-engine/4.0/addons/` 現況）**不在本 repo**，歸 `~/notes` 側管理。
- **生成檔不 commit**：`self_mods/build/` 已在 `.gitignore`，它是開發迴圈暫存產物，
  不保證與源碼同步。要交付的成品放 `self_mods/dist/addons/`（帶版本＋`SOURCE.md`）。
- **git**：2026-07-20 起推到 `github.com/justty32/modding_tome4`（`main`）。`vendor/` 全部由 `.gitignore` 排除。
  commit / push 須經使用者確認。
- **commit 訊息**：`feat(runewright): ...` / `feat(tools): ...` / `docs(knowledge): ...`
- **測試環境限制**：無頭測試需要 `xvfb-run`；本機 Manjaro 已有。Windows 未複驗。
- **版本綁定**：addon 的 `version` 必須與模組 1.7.6 相容，否則 `engine/Module.lua:394` 的
  `natural_compatible` 為 false，addon 會被**靜默移除**（沒有任何錯誤訊息）。

## Fresh clone / 環境還原

`vendor/` 是 231MB 外部素材，可重新取得，不做版控。在新機器還原本工作區後，須手動補回：

1. 取得 Tales of Maj'Eyal 1.7.6 的 Steam 安裝。
2. 從遊戲目錄找出 `te4-1.7.6.teae`（引擎層）與 `tome.team`（ToME 模組內容層）——兩者都是 zip。
3. 解壓到：
   - `te4-1.7.6.teae` → `vendor/t-engine4/engines/te4-1.7.6/`
   - `tome.team` → `vendor/t-engine4/modules/tome/`
4. `vendor/orig/`（第三方 addon 解壓參考）與 `vendor/chn-mod/`（簡體翻譯包範本）另從各 addon 的
   `.teaa` 解壓；`sub_proj/tome4-ch/_reference/` 以 symlink 指回此處。
5. **待補**：確切解壓指令未留檔重現。下次做這件事時應固化成 `tools/` 下的腳本。

## 使用者必須親自做的事

- 提供／維護 Tales of Maj'Eyal 的 Steam 安裝（本 repo 不含遊戲本體授權內容）。
- 任何要用到真實桌面滑鼠／鍵盤操作 `t-engine64` 的驗證，須先徵得同意（見上方鐵律 1）。
- 畫面、渲染、手感、數值平衡的判斷（見上方鐵律 6）。
- 若要在 Windows 上使用本 repo 的腳本，需自行複驗——目前只驗證過 Manjaro/Linux。
