# CONTRACT 模板 — 平行 agent 的共用契約

← [agent-driving](README.md)

複製這份到 `self_mods/tome-<addon>/CONTRACT.md`，把 `<>` 填掉、刪掉用不到的段。
**唯一實例參考**：[tome-witchwood/CONTRACT.md](../../../self_mods/tome-witchwood/CONTRACT.md)
（那份的美術段已過時，看模板這份）。

每一節都對應一次實際踩過的坑，來源見 [parallel.md](parallel.md) 與 [assets.md](assets.md)。
**不要刪節省事**——刪掉的那節就是下次整合失敗的地方。

---

以下為模板本體（從這裡往下複製）：

---

# tome-<addon> — <N> 個 agent 的共用契約

**動工前必讀。** 違反契約會導致整合失敗，而且多半是**靜默**的
（id 不符 → 東西不出現，沒有任何錯誤訊息）。

## 主題

<一段話講清楚這個 addon 是什麼、接在哪個既有內容之後、世界觀基調。>

## 誰做什麼（檔案樹互不重疊）

| Agent | 負責 | 只准碰這些路徑 |
|---|---|---|
| **A <職責>** | <產出> | `data/<...>`、`overload/data/gfx/<...>_*.png` |
| **B <職責>** | <產出> | `data/<...>` |
| **C <職責>** | <產出> | `data/<...>` |

**排序規則：相依性最高的排最後**（劇情 ＞ 地圖 ＞ 怪物）。
最後跑的那個是**整合哨兵**——只有它看得到別人的成品，要它主動檢查交界。

`init.lua` 已經寫好，任何人都不要改。`hooks/load.lua` 的擴充方式見下一節。
hook 會偵測哪些檔案存在並跳過缺的，所以你可以在別人還沒做完時就獨立跑 verify。

## 共用檔的擴充點（不要禁止修改，要給位置）

需要掛 hook（大地圖入口、birth 白名單、superload）時，**不要改 `hooks/load.lua`**，
寫成 `hooks/parts/<你的代號>.lua`，`load.lua` 尾端會迴圈載入 `parts/` 底下全部檔案。

> 契約寫「不准改 `hooks/load.lua`」保證了平行安全，但需要掛 hook 的 agent 就變成
> 「回報 → 編排者代改」的往返，白白多一輪（2026-08-01 witchwood 的 B）。

📌 **編排者的事前工作**：這個迴圈載入**目前還沒有任何 addon 實作過**（截至 2026-08-06）。
你要在開工前自己把它寫進 `hooks/load.lua`，否則 agent 寫的 `parts/*.lua` 不會被載入，
而且是**靜默**的。寫完先自己跑一次 `verify.sh` 確認空的 `parts/` 不會炸。

## id 命名（硬性，不得更動）

其他 agent 會直接引用這些字串。**先定好，不准自己改名。**

### Agent A 必須定義的 <怪物/NPC> id

| id | 中文名 | 定位 | 必填欄位 |
|---|---|---|---|
| `<PREFIX>_<X>` | <名> | <描述> | `name`、`define_as`、`image` |

⚠️ **`name` 不可省。** 少了它玩家一殺就 `all_kills[nil]` 崩潰
（`M/mod/class/Actor.lua:3451`）——**verify 抓不到，執行期才炸**。
2026-08-01 就是因為契約只寫了 id 沒寫必填欄位，A 沒做也不算違約。

### Agent B 必須使用的 id

- zone short_name：**`<zone>`**（`data/zones/<zone>/zone.lua`）
- 刷怪一律引用 A 的 id，**不要自己再定義怪**
- 大地圖入口：`change_zone = "<zone>+<zone>"`
  ⚠️ **一定要帶 `+`。** `engine/Zone.lua:159-164` 靠 `+` 切出 addon 名；
  沒有 `+` 會去讀原版的 `/data/zones/<zone>/`（不存在），進圖直接失敗。

### Agent C 必須使用的 id

- 任務 id：**`<quest-id>`**（`data/quests/<quest-id>.lua`）
- 任務 NPC：`<PREFIX>_<Y>`（定義在**你自己的**檔案，不是 A 的）
- 對話檔：`data/chats/<chat>.lua`

## 依賴宣告（只列 id 不夠）

| 我是 | 我依賴誰 | 依賴它的什麼 |
|---|---|---|
| B | A | 三個怪物 id **且每個都有 `name`** |
| C | B | zone 把 `<PREFIX>_<Y>` 載進 `npc_list` |

> 契約防得住 id 衝突，**防不住接縫**。上表就是接縫清單——
> 「B 的 zone 沒把 C 的任務 NPC 載進 `npc_list`，NPC 不會出現，整條任務走不到」
> 這種錯只有寫進依賴表才防得住。

## 美術規則

**完整規則見 [assets.md](../../wf/workflows/agent-driving/assets.md)，動手前讀一遍。**
（模板本體的相對連結都是**從 `self_mods/tome-<addon>/` 出發**寫的，複製過去就是對的。）
這裡只列驗收條件。

**自製圖一律放 `overload/data/gfx/…`，引用時寫相對 `data/gfx/` 的路徑。**
`overload/` 是 prepend 掛在 VFS 根（`E/Module.lua:523` 第三參數 `false`），
所以 `overload/data/gfx/npc/<x>.png` 在遊戲裡就是 `/data/gfx/npc/<x>.png`，
引用寫 `image = "npc/<x>.png"`——和借用原版資產寫法一樣。
**addon 的 `data/` 掛在私有點 `/data-<short>/`，放 PNG 在那裡讀不到。**

⚠️ **檔名一律加 `<prefix>_` 前綴。** prepend 代表撞名會**靜默覆蓋原版、全遊戲生效**。

### 生圖：要透明的圖一律洋紅底

```bash
agy --dangerously-skip-permissions -p "…，背景必須是純洋紅色 #FF00FF 的實心底色，
不允許任何其他顏色、漸變、陰影、雜訊；主體不許含任何接近洋紅的像素；
單一物件置中佔畫面約 60-70%，輪廓清晰"
magick in.png -fuzz 12% -transparent '#FF00FF' out.png
```

三個必做的檢查：

1. **`ls` 確認檔案真的在、mtime 是新的。** `agy` 會宣稱生成成功但實際沒產出檔案。
2. **它存到自己的 scratch**（`~/.gemini/antigravity-cli/scratch/`），要自己 `cp` 出來。
3. **透明度驗收**：
   ```bash
   magick x.png -alpha extract -format 'min=%[fx:minima*255] mean=%[fx:mean*255]\n' info:
   ```
   ⚠️ **`identify %[channels]` 看到 `srgba` 不算數**——那只證明通道存在，不證明有被用到。
   要透明的圖 **`min` 必須是 0**。

| 圖類 | 要透明？ | 尺寸 |
|---|---|---|
| 地面 floor | **不要**（要滿版才能無縫平鋪，有洞露黑底）| 64×64 |
| 牆／樹 | 要（原版樹是地面 `image` + `add_mos` 兩層）| 64×64 |
| 怪物／NPC／物件 | 要 | 64×64 |

⚠️ **有機造型（樹、毛髮）不要用 agy + `-fuzz` 去背**——產出是 1-bit alpha，
邊緣鋸齒＋殘邊清不掉，fuzz 開大又把主體鑿穿。**優先從原版 485 張樹色調位移衍生。**

**美術品質由使用者肉眼判斷，你不要自己讀圖評價。** 生完把路徑列在回報裡。

## 驗證（每個 agent 各自跑）

```bash
tools/lint.sh tome-<addon>
TOME_PLAYTEST_STATE=/tmp/tome4-playtest-<你的代號> tools/verify.sh tome-<addon>
```

⚠️ **`TOME_PLAYTEST_STATE` 一定要設成你自己的**，否則會 `rm -rf` 掉別人的 state。
症狀是**假綠燈**：`start` 說建角成功，但 addon 根本沒載入、`probe` 全報「沒拿到焦點」。
代號用 `a` / `b` / `c`，同一個變數要一路帶到 `probe` / `lua` / `log` / `stop`。

hook 結尾會印 `[<SHORT>] selfcheck <你的部分> = OK/FAIL`，verify 靠這個判定。

<若含新 zone，加這條：>
**新 zone 必須有一條連通性斷言**：從入口格到目標格（下樓梯／傳送門／任務 NPC）
真的逐格走過去。只用 `game:changeLevel()` 跳進去**驗不到「玩家走不走得到」**——
2026-08-01 orario 三個據點就是這樣出貨的，玩家被牆完全擋在外面。

## 契約可能是錯的，授權你推翻它

```text
契約若與引擎原始碼衝突，以原始碼為準。
偏離契約可以，但必須在回報裡說明偏離哪一條、為什麼，並附 檔案:行號。
```

（`change_zone` 那條就是契約寫錯、agent 帶著行號證據推翻的實例。）

## 鐵律（違反會壞事）

- **絕不執行 `t-engine64`、`tools/run.sh`**。自動化只走 `verify.sh` / `playtest.sh`。
- 不要碰 `vendor/`（唯讀）、不要碰別的 agent 的檔案、不要改 `init.lua`。
- 不要 commit、不要 push、不要 `deploy.sh` 到真實 home。
- 挖到新的引擎知識**寫在回報裡，不要自己改 `docs/knowledge/`**——由編排者統一併入
  （四隻並行實測零衝突的關鍵）。
- 引擎行為結論要附 `檔案:行號`，寫完用 `sed -n '<行號>p'` 複驗那一行真的是你說的東西。
- 輸出繁體中文，不要 ASCII 框線圖。
