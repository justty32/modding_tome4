# tome4-modkit

讓 AI agent **自主開發 Tales of Maj'Eyal (ToME 4, 1.7.6) addon** 的工具鏈與知識庫：
開發 → 靜態檢查 → 打包 → 佈署 → 無頭測試，一條龍。

不是給人用的 GUI 工具，是給 agent 用的——skill 描述何時該做什麼、腳本提供冪等的可重複動作、
知識庫記錄引擎的**真實行為**（每條都附 `檔案:行號`，而不是憑印象）。

## 30 秒上手

```bash
tools/lint.sh   tome-relics                              # 語法 + init.lua 欄位（秒級）
tools/verify.sh tome-relics                              # Xvfb 無頭啟動，確認真的載入（1-3 分）
tools/playtest.sh start tome-relics --cheat --birth default   # 自動建角，直接進遊戲（3-5 分）
tools/playtest.sh probe actors                           # 取得遊戲內狀態（純文字）
tools/playtest.sh stop                                   # 一定要收尾
```

**完整決策表、工具鏈佈局、探測庫寫法 → [`tools/README.md`](tools/README.md)。**
每支腳本都吃 `-h`（說明從檔頭生成，不會與實作脫節）。

## 先讀哪裡

| 你要做什麼 | 讀這裡 |
|---|---|
| 動手做某件事 | [AGENTS.md](AGENTS.md) → [WORKFLOWS.md](WORKFLOWS.md) |
| 做／改一個 addon | [workflows/addon-dev/README.md](workflows/addon-dev/README.md) |
| 跑工具 | [tools/README.md](tools/README.md) |
| 引擎到底怎麼運作 | [knowledge/](knowledge/README.md) — **本專案的引擎真相層**，每條附行號 |
| 找檔案在哪 | [workflows/common/code-map/CODE_MAP.md](workflows/common/code-map/CODE_MAP.md) |

## 目錄

| 路徑 | 內容 |
|---|---|
| `tools/` | 工具鏈。bash 進入口 + `lib/`（行程與檔案系統）+ `lua/`（判讀邏輯）+ `probes/`（遊戲內狀態探測）|
| `knowledge/` | 引擎行為知識庫。比 `~/repo/moddings/tome4/analysis/t-engine/` 可信 |
| `mods/` | 實戰 addon 原始碼 |
| `workflows/` | 工作流入口與 durable 知識 |
| `.claude/skills/` | 冷啟動 agent 的 skill 定義 |
| `build/` | 打包產物，**是暫存**，不保證與源碼同步（已 gitignore）|

## `mods/` 現況

| addon | 內容 |
|---|---|
| `tome-runewright` | 新職業**盧恩術士**：3 技能樹 + 自訂資源 + 共鳴系統 |
| `tome-runeisles` | **符文諸島**：全新大世界地圖 + 城鎮 + 兩個地城 + 三階段主線 |
| `tome-talent-tutor` | 大地圖 NPC，免費傳授全部約 300 棵技能樹 |
| `tome-relics` | 考古主題的物品／神器／ego，純加法不覆寫原版 |
| `tome-crafting` / `tome-companions` | 製作系統 / 隊友系統 |
| `tome-orario` / `tome-camp` | 進行中，尚未完成 |
| `tome-autobirth` | **開發用測試夾具，不是給玩家的 addon**。由 `playtest.sh --birth` 自動加掛，用來程式化建角；沒有規格檔就完全 no-op。永遠不進 `dist/` |

## 三條鐵律

1. **絕不在真實桌面裸跑 `t-engine64`。** 它沒有 `--help`，任何參數都直接開遊戲視窗。
   自動化一律走 `verify.sh` / `playtest.sh`（自己開 Xvfb）；要用 `run.sh` 先問使用者。
2. **要宣稱「能動」必須跑過 `verify.sh` 並貼出輸出。沒跑就說沒跑。**
3. **AI 取得狀態用 `probe`（純文字）；截圖是產給使用者看的。**
   畫面、渲染、手感、平衡由使用者判斷。

完整鐵律見 [AGENTS.md](AGENTS.md)。
