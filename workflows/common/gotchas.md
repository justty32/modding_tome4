# 共通踩坑（跨工作流）

← [INDEX](../../INDEX.md)

不專屬任一工作流、任何人都可能撞到的坑，記/查這裡。某工作流專屬的坑記在該工作流自己的 `gotchas.md`（長出來後在下表加一列導流）。

## 哪類坑記哪裡

| 坑的性質 | 記/查這裡 |
|---------|----------|
| 不專屬任一工作流的共通坑 | **common/gotchas**（本檔）|

> 條目格式：一條一個坑，**粗體標題 + 一兩句現象與對策**，必要時連結細節。

---

- **絕不在真實桌面裸跑 `t-engine64`**：它沒有 `--help`，任何參數都直接開遊戲視窗。所有無頭跑一律經 `xvfb-run`（見 [AGENTS.md](../../AGENTS.md)）。
- **addon `version` 不相容會被靜默移除**：`version` 必須與目標模組版本相容（現以 ToME 1.7.6 為準），否則 `engine/Module.lua` 的 `natural_compatible` 檢查為 false，addon 不報錯、直接消失。
- **佈署目標是 `~/.t-engine/4.0/addons/`**，不是 Steam 的 `game/addons/`。
