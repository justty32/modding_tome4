# 實機遊玩測試（AI 自己開遊戲玩）

> 目標版本 **ToME 1.7.6**，Linux / Manjaro。全部經實測驗證。
> 工具：`tools/playtest.sh`。先讀 [headless-testing.md](headless-testing.md) 的 Xvfb 鐵律。

為保持檔案輕量，完整內容已拆為兩部分，放在 `playtesting-parts/` 下。

## 目錄

| 檔案 | 內容 | 行數（原） |
|---|---|---|
| [playtesting-parts/01-why-and-usage.md](playtesting-parts/01-why-and-usage.md) | 為什麼需要這一層、用法、建角座標速查 | §0-2 |
| [playtesting-parts/02-gameplay-and-debug.md](playtesting-parts/02-gameplay-and-debug.md) | 遊戲內、Developer Mode / Lua console、debug 列印、對話與大地圖、陷阱 | §3-5 |
| [playtesting-parts/03-state-probes.md](playtesting-parts/03-state-probes.md) | **狀態探測 cookbook**：讀地圖／列生物／讀配天賦／操控移動／攔截 `game.log` 觀察回合結果 | — |

## 分工鐵律

AI 要的狀態一律走 [03-state-probes.md](playtesting-parts/03-state-probes.md) 的 Lua 探測（回傳純文字）；
截圖只在要給使用者看時才產生。**畫面、渲染、手感、平衡由使用者判斷，AI 不自己讀圖**——
圖片吃 token，而且人眼在這件事上本來就比 AI 判讀截圖可靠。
