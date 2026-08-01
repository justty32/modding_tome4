# agent-driving — 驅動外部 coding agent 產出內容

← [WORKFLOWS](../../WORKFLOWS.md)

用 stdin 注入驅動**外部** coding agent（`pi`）大量產出 addon 內容，自己退到
**編排＋監控＋獨立複驗**的位置。已實證跑得通：一次冷啟動、兩次注入、約 24 分鐘，
產出 `self_mods/tome-witch/` 並通過 lint / verify / playtest（[逐字紀錄](transcript-witch.md)）。

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

## 平行跑多個 agent

技術上可行，但**必須隔離 playtest 的 state dir**，否則後啟動的會 `rm -rf` 掉前一個的：

```bash
TOME_PLAYTEST_STATE=/tmp/tome4-playtest-<agent> pi -p ...
```

其餘本來就安全：`verify.sh` 用 `mktemp -d` 各自獨立（`tools/verify.sh:67`），
`pick_free_display` 會跳過已佔用的 display（`tools/lib/game.sh:10-18`）。

### ⚠️ 契約防得住 id 衝突，防不住「接縫」

**2026-08-01 三 agent 做 `tome-witchwood`（地圖／劇情／怪物）的實測結論。**
三個 agent 各自 verify 綠燈，**合起來卻是壞的**——因為沒有人負責檔案之間的交界：

| 接縫 | 後果 |
|---|---|
| A 的怪只有 `define_as` 沒有 `name` | 玩家一殺就 `all_kills[nil]` → Lua error（`M/mod/class/Actor.lua:3451`）。**verify 抓不到**，執行期才炸 |
| B 的 zone 沒把 C 的任務 NPC 載進 `npc_list` | NPC 不會出現，整條任務走不到 |

兩條都是 **C（最後跑完的那個）** 發現的，因為只有它看得到別人的成品。

所以：

1. **一定要有整合者。** 不是三個 agent 跑完就收工——編排者（你）必須在全部落地後
   自己跑一次 verify，並**主動檢查交界**：誰引用了誰、引用的欄位對方真的有嗎。
2. **排序讓最後一個當整合哨兵。** 相依性最高的（劇情＞地圖＞怪物）最後跑，
   它會順手抓出前面的漏洞。
3. **契約要明列「你依賴誰的什麼欄位」**，不只列 id。這次契約只寫了 id 名稱，
   沒寫「怪物必須有 `name`」，所以 A 沒做也不算違約。

### 共用檔要留擴充點，不要禁止修改

契約寫「不准改 `hooks/load.lua`」保證了平行安全，但 B 需要在那裡掛大地圖入口 hook，
結果變成**回報 → 編排者代改**的往返，白白多一輪。

下次改成：共用檔留一個明確的擴充點，各 agent 寫自己的 `hooks/parts/<agent>.lua`，
由 `load.lua` 迴圈載入。這樣既不互相踩，也不必經過人。

### 契約本身可能是錯的，要授權 agent 推翻它

這次契約寫 `change_zone = "witchwood"`——**錯的**。
`engine/Zone.lua:159-164` 靠 `+` 切出 addon 名，沒有 `+` 會去讀
`/data/zones/witchwood/`（原版不存在），進圖直接失敗；正解是 `"witchwood+witchwood"`。

Agent B 帶著行號證據偏離契約並回報，這是正確行為。所以契約裡要明講：

```text
契約若與引擎原始碼衝突，以原始碼為準。
偏離契約可以，但必須在回報裡說明偏離哪一條、為什麼，並附 檔案:行號。
```

## 美術／音效怎麼交代

三類資產三條路，**開工前就寫進契約**，不要讓每個 agent 各自摸索一次：

| 資產 | 怎麼來 |
|---|---|
| 動態特效／粒子 | **自己寫 Lua**（它本來就是 Lua 不是圖）|
| 靜態貼圖 | **`agy` 生圖** + 補 alpha |
| 音效 | **只能借原版**（`agy` 沒有音訊生成能力，實測問過）|

### `agy` 生圖的三個坑（都要寫進契約）

1. **它存到自己的 scratch 目錄**（`~/.gemini/antigravity-cli/scratch/`）而非工作目錄，要自己 `cp`。
2. **產出的 PNG 沒有 alpha 通道**，要自己補。
3. **它會宣稱生成成功但實際沒有產出檔案。** 生完一定要 `ls` 確認檔案真的在、
   而且 mtime 是新的——不要採信它的自我回報。

### ⚠️ 透明度：`srgba` 不等於有透明

**這是我自己犯的錯，寫在這裡免得重蹈。** 契約原本只要求檢查

```bash
magick identify -format '%[channels]\n' x.png   # 看到 srgba 就收工 ← 不夠！
```

`srgba` 只證明**通道存在**，不證明**有被用到**。實測 `tome-witchwood` 的地形圖
全是 `alpha min=255 mean=255`——通道有、透明度全無。因為 `-transparent white`
對「滿版材質、根本沒有白底」的圖什麼都去不掉。怪物圖碰巧成功，只因為它的構圖真有白底。

**正確的驗收**：

```bash
magick x.png -alpha extract -format 'min=%[fx:minima*255] mean=%[fx:mean*255]\n' info:
# 要透明的圖：min 必須是 0
```

### 三類貼圖，透明度需求不同

| 圖類 | 要透明？ | 為什麼 |
|---|---|---|
| **地面 floor** | **不要** | 要滿版不透明才能無縫平鋪，有洞會露出黑底 |
| **牆／樹** | **要** | 原版樹是兩層疊的：底圖草地 + `add_displays` 以 `z=3` 疊樹（`M/data/general/grids/forest.lua:76`、`M/mod/class/Grid.lua:251-255`）|
| **怪物／NPC／物件** | **要** | 疊在地面格上 |

地面圖另有一條**生圖 prompt 的關鍵**：要明講「無縫平鋪、正上方俯視、打光平均無方向性陰影、
不要單一焦點物件、色調壓低」。不講的話生成模型會給你一張有構圖的風景插畫，當地磚必然難看。

還有一條**檔名規則**必須交代：自製圖放 `overload/` 是 prepend 掛在 VFS 根，
**撞名會靜默覆蓋原版、全遊戲生效**。所以檔名一律加 addon 專屬前綴
（`R/deathknight` 全加 `_raz` 就是為此）。細節見 [visuals-and-sounds](../../../docs/knowledge/visuals-and-sounds.md)。

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
| [pi-cookbook.md](pi-cookbook.md) | `pi` 的指令、prompt 心得、`agy` 生圖的坑、實測數據 |
| [transcript-witch.md](transcript-witch.md) | 女巫那次的逐字紀錄（注入的 stdin + 回應）|
| `session-log.md` | 本工作流 open 項 |
