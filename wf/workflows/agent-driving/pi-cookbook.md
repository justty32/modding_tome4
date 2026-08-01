# finding — 用 stdin 驅動外部 coding agent（pi）做完一個職業 addon

2026-08-01。**結論：跑得通，而且不需要人在中間接手。**

一次冷啟動、兩次 stdin 注入，pi 就從「沒看過這個 repo」做到
「addon 寫完、lint 綠、verify 綠、playtest 實際建角放技能、build、deploy、文件補回知識層」。

產物：`self_mods/tome-witch/`（女巫 + 草藥樹），已獨立複驗。

---

## 環境

| 項目 | 值 |
|---|---|
| CLI | `pi` 0.83.0（`~/.local/share/fnm/.../bin/pi`）|
| 模型 | `deepseek-v4-flash`（`--provider deepseek`，吃 `DEEPSEEK_API_KEY`）|
| 輔助 | `agy` 1.1.7（文本／圖像生成，本次未實際動用）|

驅動指令（`printf` 而非 `echo`，避免尾端換行被當成送出）：

```bash
printf '%s' "$PROMPT" | timeout 1800 pi -p \
  --provider deepseek --model deepseek-v4-flash \
  --session-id witch-experiment
```

- `-p`／`--print`：非互動，處理完就結束。
- `--session-id <id>`：**多步驟驅動的關鍵**。同一個 id 會延續上下文，
  第二次注入不必重述背景。第一次會警告 `No project session found`，正常。
- pi 會自動探索 `AGENTS.md` / `CLAUDE.md`（除非 `-nc`）。本 repo 的
  非侵入式佈局（頂層只有 `AGENTS.md`）對它完全沒造成困擾。
- **本次沒有下任何 slash command**，純自然語言就足夠。

## 心得：怎麼下 prompt 更好

### 1. 一定要明講「不要停下來問」

**最重要的一條。** 預設它會把設計決定攤出來等你拍板（本次列了 7 題）。
精簡 prompt 模式下這等於卡死。固定加這句：

```text
能自己查、自己試、自己決定的，就不要停下來問。
只有在「做下去會不可逆地弄壞使用者環境」時才停下來問。
```

後半句是必要的煞車——不能無條件叫它別問，否則它可能對真桌面動手。

### 2. 明說「做壞了可以 git restore」

它會因此放手去試（例如直接改 `p.life`、反覆重跑 playtest），
而不是保守地只做最小改動。前提是**你自己要先 commit**。

### 3. 驗證關卡要逐條列出來，並要求貼輸出

列成編號清單（lint → verify → playtest → 要看到什麼）比說「請驗證」有效得多。
「貼出輸出」這句會讓它真的去跑，而不是宣稱跑過。

### 4. 先來一輪「只讀不寫的定位」很划算

步驟 1 只花 171 秒，但換到：它的計畫、它找到的範本、**它主動指出的文件缺口**。
缺口那題（第 7 題「你覺得哪裡文件不清楚？講白話」）是整個實驗回報最高的一問，
以後每次都該問。

### 5. 多步驟一定要用 `--session-id`

否則第二次注入等於冷啟動，前面 171 秒白花。

### 6. 要求它複查自己引用的行號

它的行號會漂 6–9 行（通常指到函式起點而非實際那一行）。
這個 repo 的規矩是行號必須可複驗，所以要補一句：

```text
寫進 knowledge/ 的每個 檔案:行號，都要回去 sed -n 確認那一行真的是你說的東西。
```

### 7. 不需要 slash command

純自然語言就夠。本次沒用到任何 slash command。

---

## 實測數據

兩次驅動的耗時、各 agent 表現、文件缺口見 [experiments.md](experiments.md)。
