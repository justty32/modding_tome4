# PROMPT 模板 — 直接複製去注入

← [agent-driving](README.md)｜心得與由來見 [pi-cookbook.md](pi-cookbook.md)

pi-cookbook 是**心得**，這份是**成品**。對能力較弱的模型（`deepseek-v4-flash` 等），
模板比心得有用得多——照抄、填空、送出。

## 步驟 0：開工前一定要 commit

```bash
git status --short   # 必須是乾淨的
```

這是讓 agent 放手去試的前提，也是唯一的煞車。沒 commit 就不要開工。

## 注入指令

```bash
printf '%s' "$PROMPT" | timeout 1800 pi -p \
  --provider deepseek --model deepseek-v4-flash \
  --session-id <task-id>
```

- 用 `printf` 不用 `echo`，避免尾端換行被當成送出。
- **`--session-id` 是多步驟驅動的關鍵**：同一個 id 延續上下文，第二次注入不必重述背景。
  第一次會警告 `No project session found`，正常。
- 平行時每隻要不同的 `--session-id`，且 prompt 裡帶不同的 `TOME_PLAYTEST_STATE`。
- 不需要任何 slash command，純自然語言就夠。

---

## 步驟 1：定位（只讀不寫）

只花約 3 分鐘，但換到它的計畫、它找到的範本、以及**它主動指出的文件缺口**。
第 7 題回報最高，每次都要問。

```text
我要你在這個 repo 裡做 <一句話講清楚要做什麼，例如：一個新的 ToME4 職業 addon「女巫」，先只做一棵特色技能樹「草藥」>。

這一步先不要寫任何檔案。請你先自己把這個 repo 摸清楚，然後回報：

1. 你讀了哪些檔案？
2. 有沒有做這件事的專門指引？在哪？
3. 最少需要哪些檔案才做得起來？
4. 有哪些規則會讓你踩坑？
5. 完整的驗證流程是什麼？每一關要看到什麼才算過？
6. 你的計畫。
7. 你現在還缺什麼資訊、或覺得哪裡文件不清楚？講白話，這題很重要。
```

**預期它會列一串待拍板的設計問題就停住。** 這是正常的，步驟 2 會解決。

---

## 步驟 2：動手（同一個 session-id）

```text
設計上的事你自己決定，不用問我，照你第 6 點的計畫做。

規則：能自己查、自己試、自己決定的，就不要停下來問。
只有在「做下去會不可逆地弄壞使用者環境」時才停下來問。

現在開始動手，一路做到驗證通過：

1. 寫出 <產物>
2. tools/lint.sh <addon> 過
3. tools/verify.sh <addon> 過（貼出輸出）
4. tools/playtest.sh 真的 <具體看到什麼，例如：建出女巫、學到草藥樹、放技能看到數值變化>
   <若含新 zone：並且真的從入口逐格走到 <目標>，不准只用 game:changeLevel() 跳進去驗>

做壞了沒關係，這是實驗，我隨時可以 git restore。

寫進 docs/knowledge/ 的每個 檔案:行號，都要回去 sed -n '<行號>p' 確認那一行真的是你說的東西。

<若需要美術，加這段：>
美術：機器上有 agy CLI 可以生圖，規則全在 wf/workflows/agent-driving/assets.md，動手前讀一遍。
要透明的圖一律叫它畫在純洋紅 #FF00FF 底上再 key 掉；驗收要跑
magick x.png -alpha extract -format 'min=%[fx:minima*255]\n' info: 且 min 必須是 0。
identify %[channels] 看到 srgba 不算數。生完一定要 ls 確認檔案真的在。
圖好不好看由使用者判斷，你不要自己讀圖評價，把路徑列在回報裡就好。
```

### 四句缺一不可的話

| 句子 | 少了會怎樣 |
|---|---|
| 「不要停下來問」＋「只有不可逆才問」 | 它會攤出 7 題設計問題卡死；但無條件叫它別問，它可能對真桌面動手 |
| 「做壞了可以 git restore」 | 它會保守地只做最小改動，不敢反覆試 |
| 驗證關卡**逐條編號**＋「貼出輸出」 | 它會宣稱跑過但沒真的跑 |
| 「行號要 `sed -n` 複驗」 | 它的行號會漂 6–9 行（通常指到函式起點而非實際那行）|

---

## 平行時：步驟 2 的替代版

先寫好 `CONTRACT.md`（見 [CONTRACT.template.md](CONTRACT.template.md)），然後每隻注入：

```text
你是 Agent <A/B/C>，負責 <職責>。

先讀 self_mods/tome-<addon>/CONTRACT.md，那是你和另外兩隻 agent 的共用契約。
你只准碰契約裡列給你的路徑，不要碰別人的檔案。

規則：能自己查、自己試、自己決定的，就不要停下來問。
只有在「做下去會不可逆地弄壞使用者環境」時才停下來問。

契約若與引擎原始碼衝突，以原始碼為準。偏離契約可以，但必須在回報裡說明
偏離哪一條、為什麼，並附 檔案:行號。

驗證用你自己的 state 目錄，這條一定要照做，否則你會 rm -rf 掉別人的：
  TOME_PLAYTEST_STATE=/tmp/tome4-playtest-<你的代號> tools/verify.sh tome-<addon>

挖到新的引擎知識寫在回報裡，不要自己改 docs/knowledge/。
不要 commit、不要 push、不要 deploy 到真實 home。
```

**啟動錯開約 20 秒**，並讓相依性最高的那隻最後跑（它是整合哨兵）。

---

## 監控：不要盯 stdout

`pi -p` 的輸出是**緩衝的**，跑完才吐出來。中途看進度改看這些：

```bash
git status --short                              # 它寫了哪些檔
pgrep -x t-engine64                             # 有＝在 verify/playtest
grep -a '\[UPPER\]' <state>/run.log             # ★ 它在遊戲裡看到什麼
pgrep -f 'session-id <id>'                      # 它還活著嗎
```

`run.log` 那條最有用——agent 塞進遊戲的臨時探測會印在那裡，等於即時看到它的除錯思路。

---

## 收尾：獨立複驗（不採信自我回報）

「要宣稱能動必須跑過 verify 並貼出輸出」**對 agent 一樣適用**。固定四項：

1. `tools/lint.sh <addon>` 與 `tools/verify.sh <addon>` **自己跑一次**
2. 它寫的每個 `檔案:行號`，用 `sed -n '<行號>p'` 抽驗
3. 它有沒有動到**真實環境**（`~/.t-engine/4.0/addons/`）——照文件它會 deploy，要讓使用者知道
4. **平行時額外檢查交界**：誰引用了誰、引用的欄位對方真的有嗎
   （三隻各自綠燈、合起來是壞的，2026-08-01 實測）

需要人眼判斷的（美術、手感、平衡、中文文案）用 `SendUserFile` 送審，
並記進 [WAIT_USER.md](../../WAIT_USER.md)。
