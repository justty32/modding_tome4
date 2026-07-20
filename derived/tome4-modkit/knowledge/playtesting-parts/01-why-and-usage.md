# 實機遊玩測試（AI 自己開遊戲玩）

> 目標版本 **ToME 1.7.6**，Linux / Manjaro。全部經實測驗證。
> 工具：`tools/playtest.sh`。先讀 [headless-testing.md](../headless-testing.md) 的 Xvfb 鐵律。

## 0. 為什麼需要這一層

`tools/verify.sh` 只能證明三件事：addon 被載入、定義註冊成功、載入過程沒有 Lua Error。
**它證明不了遊戲邏輯是對的。**

2026-07-10 實機遊玩盧恩術士，在 `verify.sh` 全綠（7/7 selfcheck）的情況下抓到三個 bug：

| bug | 為什麼靜態檢查與 verify 抓不到 |
|---|---|
| 共鳴判定拿 `t.name` 比對英文字串 | `t.name` 被 `_t()` 翻譯過；只有在**非英文語系下實際持有銘文**時才會失敗 |
| 起始銘文被靜默丟棄（欄位已滿） | `setInscription` 在建角時 `vocal=false`，不報錯、不 log |
| 古弗薩克文字符是豆腐方塊 | 純渲染問題，只有人眼（或截圖）看得到 |

三個都是「載入成功但行為錯誤」。**只有真的建角、真的按下技能才看得到。**

驗證分層，越後面越貴也越真：

```
lint  →  verify（載入 + selfcheck）  →  playtest（建角 + 施放 + 截圖）  →  使用者實機
靜態      無頭，~1-3 分鐘              無頭，~3-5 分鐘                   人眼判斷手感
```

## 1. 用法

```bash
tools/playtest.sh start <addon>      # 開遊戲，停在建角畫面，截圖
tools/playtest.sh do <名字> <動作...>  # 動作: click X Y | key K | type TEXT | wait N
tools/playtest.sh shot <名字>
tools/playtest.sh zoom <名字> W H X Y  # 裁切放大，看清數字用
tools/playtest.sh log [regex]         # 預設印 addon 自報的 selfcheck / hook / dbg 行
tools/playtest.sh status
tools/playtest.sh stop                # 一定要收尾
```

截圖落在 `/tmp/tome4-playtest/shots/`，路徑會印出來，直接用 Read 工具看。

**`stop` 是必要的**，遊戲以 `setsid` 脫離 shell，不收尾會一直留在背景。

## 2. 建角座標速查（1024x768，`locale = zh_hant`）

⚠️ **座標隨語系變動**：中文與英文的清單行距不同（中文 25px，英文 27px）。
`prepare_scratch_home` 預設寫 `zh_hant`，與使用者真實環境一致。

Character Creation 畫面：

| 目標 | 座標 | 備註 |
|---|---|---|
| 種族「人類」 | `340 300` | 點一下展開子種族 |
| 子種族「科納克人」 | `270 350` | 展開後才出現 |
| 職業「法師系」 | `600 350` | 點一下展開子職業 |
| 子職業（法師系第 4 列） | `560 451` | 盧恩術士的位置 |
| 名稱輸入框 | `420 213` | 點一下取得焦點，再 `type` |
| 「遊玩!」按鈕 | `270 742` | 輸入名字後才出現 |

完整一輪：

```bash
tools/playtest.sh do sel \
    click 340 300 wait 1 click 600 350 wait 2 \
    click 270 350 wait 1 click 560 451 wait 2 \
    click 420 213 wait 1 type Smoke wait 1 key Return wait 2
tools/playtest.sh do levelup click 270 742 wait 10
```

升級畫面：技能樹圖示第一列在 `y≈455`，`x≈300, 355, 410, 465`。
左鍵點圖示 = 加點。按 `Escape` 接受目前配點並進入遊戲，再按兩次 `Return` 跳過開場劇情。
