# agent-driving — session log

只列 open/in-flight。完成的濃縮到 git log 或 [experiments.md](experiments.md)。

## Open

- **`tome-orario` v0.4 由 pi + deepseek 產出中**（2026-08-01 起）。市集商店 + 三個眷族據點。
  prompt 留在 `/tmp/tome4-pi/orario-v04.txt`，輸出在 `/tmp/tome4-pi/orario-v04.out`。
  **編排者必須自己複驗**（lint / verify / playtest / 抽驗行號），不採信自我回報。

- **共用檔擴充點還沒實作**。之前契約禁止 agent 改 `hooks/load.lua`，
  造成 B「回報 → 我代改」的往返。下個 addon 試 `hooks/parts/<agent>.lua` + 迴圈載入。

## 2026-08-01 新增：sonnet subagent 也跑得通，而且很划算

同日開了四隻 subagent（Claude 的 Agent 工具，非 `pi`），全部達標：

| 工作 | 模型 | 結果 |
|---|---|---|
| 拆 `visuals-and-sounds.md` | sonnet | 三份 part 全 <300 行，**逐字一致是真的驗過的**（去掉新增標題後拼回去跟 `git show HEAD:` diff，0 差異）|
| `tome-witchwood` 實機 playtest | sonnet | 六項逐一結論，自己抓出兩個真 bug（葛薇每層各生成一份、兩張索引色 PNG 觸發引擎 truecolor 警告）|
| `tome-witchwood` NPC 空手 bug | sonnet | 找到真因（`objects.lua` 沒 `load` 任何清單）而非盲抄修法，實機證明七隻老嫗全拿到法杖、`**FAILED**` 歸零 |
| `tools/fetch-vendor.sh` | sonnet | 冪等、`--only`/`--force`、實跑輸出貼齊 |
| 盧恩術士特效稽核 | opus | 15 個粒子點逐一複驗，**用正對照證明量尺有效**；順帶查出整個職業載入不起來 |

**結論：機械性、範圍明確、有現成範本可抄的工作交給 sonnet 完全夠用**，
只有「機制敏感 + 需要判斷」的（特效生命週期稽核）才值得用 opus。

三個關鍵編排心得：

1. **明講「只准改哪個目錄」**。四隻並行時這是唯一能防檔案衝突的手段——
   單獨切出「你若挖到新知識就寫在回報裡，不要自己改 `docs/knowledge/`」，
   由編排者統一併入。實測零衝突。
2. **`TOME_PLAYTEST_STATE` 一定要每隻不同**（`parallel.md` 已記）。四隻同時跑遊戲沒問題。
3. **兩隻 agent 獨立撞到同一個引擎事實**（guardian 只在 `zone.max_level` 生成）
   ——這種重複命中是「該進知識層」的強訊號，已補進 `worldmap-parts/02`。

- **`agy` 的文本生成沒測過**。兩次實驗都只用到它的圖像生成。
  劇情長文本、addon description 這類要不要交給它，未知。

## 已驗證可行（不必再試）

- `pi -p --session-id <id>` 多步驟驅動、`printf '%s' | pi` 注入
- 三 agent 平行 + `TOME_PLAYTEST_STATE` 隔離
- `agy` 圖像生成 + 洋紅 key color 去背
- `agy` **沒有**音訊生成能力
