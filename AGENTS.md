# tome4 — Agent 專案備忘

這份檔案是最頂層路由器，只放 always-on 規則與入口連結；細節放到各工作流。

## 專案摘要

- 專案一句話：ToME4 (Tales of Maj'Eyal) modding 工作區——`derived/tome4-modkit/` 是讓 agent 自主開發 addon 的工具鏈與知識庫（開發→靜態檢查→打包→佈署→無頭測試一條龍），`analysis/t-engine/` 是引擎架構分析索引。
- 主要語言/框架：Lua 5.1 / LuaJIT（T-Engine4 VM）＋ Bash（工具腳本）。
- 主要 build 指令：`derived/tome4-modkit/tools/build.sh <addon>` → `build/tome-<name>.teaa`
- 主要 test 指令：`derived/tome4-modkit/tools/verify.sh <addon>`（Xvfb 無頭載入驗證）
- 其他常用工具腳本（皆在 `derived/tome4-modkit/tools/`）：`lint.sh`（靜態檢查）、`deploy.sh`（冪等佈署到 `~/.t-engine/4.0/addons/`）、`playtest.sh`（無頭實際操作截圖）、`run.sh`（真桌面開遊戲留 log）。
- 實際工作先讀 `derived/tome4-modkit/AGENTS.md`——那份文件的 always-on 鐵律更細（例如「絕不在真實桌面裸跑 t-engine64」），本檔只是頂層索引。

## 先讀哪裡

- 使用者要你動手做某件事 → [WORKFLOWS.md](WORKFLOWS.md)：依意圖派發到對應工作流。
- 想看 repo 結構 → 專案自己的 `INDEX.md` 或 `README.md`。
- 碰原始碼 → 先讀 [workflows/common/conventions.md](workflows/common/conventions.md)，再讀 [CODE_MAP](workflows/common/code-map/CODE_MAP.md)。

## Always-on 鐵律

- 重構/整理必須 behavior-preserving；改完跑對應測試。
- 未經使用者確認，不 push、不開新大型工作。
- 不 revert 使用者或其他 agent 的未確認變更；遇到衝突先停下說明。
- 各工作流的具體流程在自己的 README，不在本檔重複。
- 小事可以跳流程；完整規則見 [PRINCIPLES.md](PRINCIPLES.md)。
- 非微小工作先定義 `Done when:`。
- 需要使用者親自驗證、外部環境、權限、實機、帳號或手動操作時，記到 [WAIT_USER.md](WAIT_USER.md)。
- 跨 session 的 open 狀態記到 [SESSION-LOG.md](SESSION-LOG.md) 或對應工作流的 `session-log.md`。
- 引用外部專案程式碼或技術結論時，盡量附來源位置：`path/to/file:line`、函式名、URL、paper id、或命令輸出摘要。
- 架構圖/流程圖優先用 Mermaid、表格、列點；不要用需要字元對齊的 ASCII 框線圖。

## 分層思想

整個 repo 是分層樹，每一層只指向下一層：

```text
AGENTS.md → WORKFLOWS.md / INDEX.md → 各工作流入口 → 工作流內容 → 子工作流
```

- `README.md` = 初入一個資料夾先讀的入口/導引。
- `INDEX.md` = 描述該資料夾頂層結構的索引。
- 小資料夾可以 README 兼 index；變大後才拆出獨立 INDEX。
- durable 知識歸到它所屬的工作流，不堆在頂層。

## 本地專案規則

把專案專屬規則放這裡，保持精簡；太長就移到對應工作流。

- **目錄佈局**：`derived/tome4-modkit/`（addon 開發工具鏈＋知識庫＋8 個 addon 原始碼，實際開發的主場）、`derived/tome4-ch/`（正體中文化工作區：第三方 addon 的 `zh_hant` 伴生 addon 源碼＋翻譯管線＋打包好的 `build/*.teaa`；2026-07-18 自 `~/code/tome4-ch` 搬遷整合，原目錄已刪除）、`analysis/t-engine/`（引擎架構分析與教程，索引性質）、`projects/t-engine4/`（Steam 版解壓的引擎/模組 Lua 源碼，唯讀真相層）、`external/`（第三方 addon 參考素材：`orig/` 25 個實裝 addon 解壓＋`chn-mod/`，`derived/tome4-ch/_reference/` 以 symlink 指回此處，modkit 知識庫真相層代號 `R` 亦指向 `external/orig`）、`dist/`（自製成品：打包好的 `.teaa` addon；在地化 `.teaa` 目前仍在 `derived/tome4-ch/build/`，升格與否見其 README）。
- **根 README.md 是外來 agent 的入口**（設計情境：`~/notes` 側的 agent 被派來「找做好的 addon 去部署」，會先讀 README.md）——它必須永遠答得出「成品在哪」（`dist/`）與「部署狀態歸 `~/notes` 側管」。新增產物類型或改佈局時同步更新它。
- **本資料夾不是 git repo**（使用者決定 2026-07-17）：原本的根 repo（2 個 commit、無 remote）已拆除，完整歷史備份在 bundle（拆除當日置於 agent scratchpad `tome4-history.bundle`）。不要在 `~/repo/moddings/tome4` 執行 `git init`/commit；文件直接改檔即可。子專案目前也都不是 git repo；若日後為 `derived/tome4-modkit` 建獨立 repo，commit 訊息沿用既有慣例：`feat(runewright): ...` / `feat(tools): ...` / `docs(knowledge): ...`。
- **測試環境限制**：無頭測試（`verify.sh`／`playtest.sh`）需要 `xvfb-run`，本機 Manjaro 已有；Windows 未複驗。跑 `t-engine64` 一律經 Xvfb，絕不在真實桌面裸跑（它沒有 `--help`，任何參數都直接開遊戲視窗）：
  ```bash
  xvfb-run -a env LIBGL_ALWAYS_SOFTWARE=1 timeout 90 \
    ./t-engine64 --no-steam --no-web --flush-stdout --home <scratch>
  ```
- **生成檔/二進位檔是暫存**：`derived/tome4-modkit/build/` 是開發迴圈暫存產物，不保證與源碼同步；要交付的成品放 `dist/addons/`（帶版本＋`SOURCE.md`）。
- **release/package 注意事項**：addon 的 `version` 必須與目標模組版本相容（現以 ToME 1.7.6 為準），否則 `engine/Module.lua` 的 `natural_compatible` 檢查會為 false，addon 被靜默移除；佈署目標是 `~/.t-engine/4.0/addons/`，不是 Steam 的 `game/addons/`。
- **`projects/t-engine4/` 是唯讀真相層**：C 層原始碼（`src/`）不在本地——本地只有 Steam 版隨附的 Lua 層。要對照 C 碼需另從官方 git（te4.org）取得。
- **`analysis/t-engine/` 不是權威**，只是索引；任何 API 結論都要回 `projects/t-engine4/` 原始碼複驗，並在文件裡附 `檔案:行號`。`derived/tome4-modkit/knowledge/` 是比 `analysis/t-engine/` 更可信的引擎真相層（同樣附行號）。

## Fresh clone / 環境還原

`projects/t-engine4/` 是 126MB 外部解壓源碼，可重新取得，不做版控。在新機器搬移/還原本工作區後，若要做需要引擎原始碼的工作，須手動還原：

1. 取得 Tales of Maj'Eyal 1.7.6 的 Steam 安裝（或對應版本的遊戲本體）。
2. 從遊戲目錄找到 `te4-1.7.6.teae`（引擎層）與 `tome.team`（ToME 模組內容層）——這兩者是 zip 格式的封包。
3. 解壓到：
   - `te4-1.7.6.teae` → `projects/t-engine4/engines/te4-1.7.6/`
   - `tome.team` → `projects/t-engine4/modules/tome/`
4. 待補：確切解壓指令（`unzip` 參數、Steam 安裝目錄的確切路徑）未留檔重現，2026-07-05 那次操作只在 `analysis/t-engine/session_log.md` 留了一句話紀錄，沒有留腳本。下次做這件事時應把指令固化成 `derived/tome4-modkit/tools/` 下的腳本。
5. `derived/tome4-modkit/mods/` 下的實裝 addon（runewright / talent-tutor / runeisles）若要佈署測試，另需 `tools/deploy.sh`，佈署目標是 `~/.t-engine/4.0/addons/`（不是 Steam 目錄，理由見 `tools/deploy.sh` 檔頭）。

## 使用者必須親自做的事

- 提供／維護 Tales of Maj'Eyal 的 Steam 安裝（本工作區不含遊戲本體授權內容）。
- 任何要用到真實桌面滑鼠/鍵盤操作 `t-engine64` 的驗證，須先徵得同意（見上方鐵律）。
- 若要在 Windows 上使用本工作區的腳本，需自行複驗——目前只驗證過 Manjaro/Linux。
- 待補：`derived/tome4-modkit/WAIT_USER.md` 內可能還有其他待人工確認事項，遷移後尚未逐條複核，之後工作應先讀該檔。
