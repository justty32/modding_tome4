# agent-driving — 驅動外部 coding agent 產出內容

← [WORKFLOWS](../../WORKFLOWS.md)

用 stdin 注入驅動**外部** coding agent（`pi`）大量產出 addon 內容，自己退到
**編排＋監控＋獨立複驗**的位置。已實證跑得通：一次冷啟動、兩次注入、約 24 分鐘，
產出 `self_mods/tome-witch/` 並通過 lint / verify / playtest（[逐字紀錄](transcripts/witch.md)）。

```text
Done when: 產物通過「我自己跑一次」的複驗，不是 agent 說它過了
```

## 何時用 / 何時不用

| 用 | 不用 |
|---|---|
| 要產出**整包新內容**（職業、地圖、劇情、怪物）| 改幾行、修一個 bug |
| 流程已成熟、關卡明確（lint→verify→playtest）| 流程還沒定案，你自己都不知道怎麼驗 |
| 願意花 20–40 分鐘換一個完整雛形 | 要立刻看到結果 |
| 已 commit，弄壞可 `git restore` | 工作區髒的 |

**開工前一定要 commit。** 這是讓 agent 放手去試的前提，也是唯一的煞車。

## 四個階段

```text
1 定位（只讀不寫）→ 2 產出 → 3 監控 → 4 獨立複驗
```

### 1. 定位：先讓它只讀不寫

花 3 分鐘換它的計畫、它找到的範本、以及**它主動指出的文件缺口**。
最後那題回報最高，每次都要問：

```text
你現在還缺什麼資訊、或覺得哪裡文件不清楚？講白話，這題很重要。
```

女巫那次就是這樣挖出「全新 class 需要世界白名單」這個沒人寫過的坑。

### 2. 產出：把關卡編號列出來

不要說「請驗證」，要列成清單並**要求貼輸出**——這句會讓它真的去跑，
而不是宣稱跑過。指令與 prompt 範本見 [pi-cookbook.md](pi-cookbook.md)。

### 3. 監控：不要盯 stdout

`pi -p` 的輸出是**緩衝的**，跑完才吐出來。中途要看進度，改看這些：

| 看什麼 | 怎麼看 |
|---|---|
| 它寫了哪些檔 | `git status --short` |
| 它跑到哪一關 | `pgrep -x t-engine64`（有＝在 verify/playtest）|
| **它在遊戲裡看到什麼** | `grep -a '\[UPPER\]' <state>/run.log` |
| 它還活著嗎 | `pgrep -f 'session-id <id>'` |

`run.log` 那條最有用——agent 自己塞進遊戲的臨時探測會印在那裡，
等於即時看到它的除錯思路。女巫那次就是這樣看到它拿火焰當對照組去證明毒沒生效。

### 4. 獨立複驗：不採信自我回報

repo 鐵律「要宣稱能動必須跑過 verify 並貼出輸出」**對 agent 一樣適用**。
它說過了不算，自己跑一次才算。女巫那次自我回報屬實，但**它寫進知識層的行號漂了 6–9 行**
（指到函式起點而非實際那行）——這種錯只有複驗抓得到。

固定要複驗的三項：

1. `tools/lint.sh <addon>` 與 `tools/verify.sh <addon>` 自己跑
2. 它寫進 `docs/knowledge/` 的每個 `檔案:行號`，用 `sed -n '<行號>p'` 抽驗
3. 它有沒有動到**真實環境**（`~/.t-engine/4.0/addons/`）——照文件它會 deploy，要讓使用者知道

## 兩份延伸規則

| 什麼時候讀 | 讀哪份 |
|---|---|
| 要**同時開多個 agent** 做同一個 addon | [parallel.md](parallel.md)——隔離、接縫、整合者、契約可推翻 |
| 產出會**牽涉美術或音效** | [assets.md](assets.md)——三類資產分工、`agy` 的坑、透明度驗收 |

## 需要人審核的地方

AI 不判斷畫面——這是 [AGENTS.md](../../../AGENTS.md) 的鐵律，對外部 agent 一樣成立。
以下一律停下來給使用者看：

| 檢查點 | 為什麼 |
|---|---|
| **美術資產**（圖示、tileset、精靈圖）| 風格對不對、去背有沒有咬到邊緣，只有人眼判得出 |
| **手感／數值平衡** | 無頭測試證明不了好不好玩 |
| **中文文案** | 語氣、用詞、有沒有翻譯腔 |
| **要不要 deploy 到真實遊戲** | 那是使用者的環境 |

送審用 `SendUserFile`（圖片直接 render），不要自己讀圖判斷。

## 內容

| 檔案 | 內容 |
|---|---|
| [parallel.md](parallel.md) | 平行開多個 agent：state 隔離、接縫、整合者、契約可推翻 |
| [assets.md](assets.md) | 美術與音效：三類資產分工、`agy` 的坑、透明度驗收 |
| [pi-cookbook.md](pi-cookbook.md) | `pi` 的指令與 prompt 心得 |
| [experiments.md](experiments.md) | 兩次實測的數據、各 agent 表現、文件缺口 |
| [transcripts/](transcripts/) | 逐字紀錄（注入的 stdin + 回應）。**原始紀錄，不套流程文檔的 8192 bytes 門檻** |
| `session-log.md` | 本工作流 open 項 |
