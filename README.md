# tome4 — ToME4 addon 開發工作區

讓 AI agent **自主開發 Tales of Maj'Eyal (ToME 4, 1.7.6) addon** 的工具鏈與知識庫：
開發 → 靜態檢查 → 打包 → 佈署 → 無頭測試，一條龍。

不是給人用的 GUI 工具，是給 agent 用的——skill 描述何時該做什麼、腳本提供冪等的可重複動作、
知識庫記錄引擎的**真實行為**（每條都附 `檔案:行號`，而不是憑印象）。

> git repo，2026-07-20 起推到 `github.com/justty32/modding_tome4`。`vendor/` 下的第三方大樹由 `.gitignore` 排除，只版控自製工作。

## 30 秒上手

```bash
tools/lint.sh   tome-relics                                   # 語法 + init.lua 欄位（秒級）
tools/verify.sh tome-relics                                   # Xvfb 無頭啟動，確認真的載入（1-3 分）
tools/playtest.sh start tome-relics --cheat --birth default   # 自動建角，直接進遊戲（3-5 分）
tools/playtest.sh probe actors                                # 取得遊戲內狀態（純文字）
tools/playtest.sh stop                                        # 一定要收尾
```

**完整決策表、工具鏈佈局、探測庫寫法 → [`tools/README.md`](tools/README.md)。**
每支腳本都吃 `-h`（說明從檔頭生成，不會與實作脫節）。

## 你來找什麼？

| 你要找的 | 去哪裡 |
|---|---|
| **做好的 addon 成品**（`.teaa`，拿去部署／發佈） | [`self_mods/dist/`](self_mods/dist/README.md)。開發中 addon 的即建即部署走 `tools/build.sh` → `tools/deploy.sh`，暫存產物在 `self_mods/build/`（不保證與源碼同步）|
| 動手做某件事 | [AGENTS.md](AGENTS.md)（鐵律）→ [WORKFLOWS.md](wf/WORKFLOWS.md)（派發表）|
| 做／改一個 addon | [workflows/addon-dev/README.md](wf/workflows/addon-dev/README.md) |
| 跑工具 | [tools/README.md](tools/README.md) |
| 引擎到底怎麼運作 | [docs/knowledge/](docs/knowledge/README.md) — **本 repo 的引擎真相層**，每條附行號 |
| repo 佈局 / 找檔案在哪 | [INDEX.md](wf/INDEX.md)、[workflows/common/code-map/CODE_MAP.md](wf/workflows/common/code-map/CODE_MAP.md) |
| 正體中文化（第三方 addon 的 `zh_hant` 伴生 addon） | [`sub_proj/zh_mods/`](sub_proj/zh_mods/README.md) — 18 個 `tome-*-zh` 伴生 addon + 翻譯管線 |

## 目錄

**非侵入式佈局**：頂層只有 `AGENTS.md`、`CLAUDE.md`、本檔三個 `.md`，
工作流 kernel 的其餘部分收在 `wf/`，不把一堆 `.md` 攤在專案根目錄。

| 路徑 | 內容 |
|---|---|
| `tools/` | 工具鏈。bash 進入點 + `lib/`（行程與檔案系統）+ `lua/`（判讀邏輯）+ `probes/`（遊戲內狀態探測）|
| `self_mods/` | **自製 addon 原始碼**（一個子目錄一個 addon）＋ `build/`（打包暫存，已 gitignore）＋ `dist/`（帶版本的交付成品）|
| `docs/` | `knowledge/` 引擎真相層（附行號）+ `analysis/` 早期架構分析（**非權威**，只當索引）+ `html/` 導覽層 |
| `sub_proj/` | 次要專案：`zh_mods/`（**第三方 addon 的正體中文化**：18 個 `tome-*-zh` 伴生 addon + 翻譯管線）|
| `vendor/` | **唯讀**第三方素材：`t-engine4/`（引擎+模組 Lua 源碼）、`orig/`（25 個實裝 addon）、`chn-mod/` |
| `wf/` | 工作流 kernel：`WORKFLOWS`/`INDEX`/`DEV-GUIDE`/`SESSION-LOG`/`WAIT_USER` + `workflows/` + `session_log/` + `inbox/` |
| `.claude/` | skill 與 slash 指令定義 |

## 部署注意

- 部署目標是 `~/.t-engine/4.0/addons/`，**不是** Steam 的 `game/addons/`（理由見 `tools/deploy.sh` 檔頭）。
- **本機部署狀態**（已裝 addon 清單、`~/.t-engine/4.0/addons/` 現況、遊戲安裝狀態）**不在本 repo**
  ——歸 `~/notes` 側管理。部署前去那邊看現況、部署後回那邊記錄。

## 三條鐵律

1. **絕不在真實桌面裸跑 `t-engine64`。** 它沒有 `--help`，任何參數都直接開遊戲視窗。
   自動化一律走 `verify.sh` / `playtest.sh`（自己開 Xvfb）；要用 `run.sh` 先問使用者。
2. **要宣稱「能動」必須跑過 `verify.sh` 並貼出輸出。沒跑就說沒跑。**
3. **AI 取得狀態用 `probe`（純文字）；截圖是產給使用者看的。**
   畫面、渲染、手感、平衡由使用者判斷。

完整鐵律見 [AGENTS.md](AGENTS.md)。

## `self_mods/` 現況

| addon | 內容 |
|---|---|
| `tome-runewright` | 新職業**盧恩術士**：3 技能樹 + 自訂資源 + 共鳴系統 |
| `tome-runeisles` | **符文諸島**：全新大世界地圖 + 城鎮 + 兩個地城 + 三階段主線 |
| `tome-talent-tutor` | 大地圖 NPC，免費傳授全部約 300 棵技能樹 |
| `tome-relics` | 考古主題的物品／神器／ego，純加法不覆寫原版 |
| `tome-crafting` / `tome-companions` | 製作系統 / 隊友系統 |
| `tome-orario` / `tome-camp` | 進行中，尚未完成 |
| `tome-autobirth` | **開發用測試夾具，不是給玩家的 addon**。由 `playtest.sh --birth` 自動加掛，用來程式化建角；沒有規格檔就完全 no-op。永遠不進 `dist/` |
