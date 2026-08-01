# 實測紀錄：兩次驅動的數據與觀察

← [agent-driving](README.md)

操作方式見 [pi-cookbook.md](pi-cookbook.md)，編排規則見 [parallel.md](parallel.md)。
逐字紀錄在 [transcripts/](transcripts/)。

## 實測時間

| 步驟 | 內容 | 耗時 |
|---|---|---|
| 1 | 冷啟動定位（只讀不寫，回報計畫）| 171 秒 |
| 2 | 寫 addon → lint → verify → playtest → build → deploy → 補文件 | 1282 秒（約 21 分）|

---

## 步驟 1：冷啟動定位

注入的 stdin（節錄要點）：

```text
我要你在這個 repo 裡做一個新的 ToME4 職業 addon：女巫（Witch），先只做一棵特色技能樹「草藥」。
這一步先不要寫任何檔案。請你先自己把這個 repo 摸清楚，然後回報：
1. 你讀了哪些檔案…  2. 有沒有做新職業的專門指引…  3. 最少需要哪些檔案…
4. 有哪些會讓你踩坑的規則…  5. 完整驗證流程…  6. 你的計畫…
7. 你現在還缺什麼資訊、或覺得哪裡文件不清楚？講白話，這題很重要。
```

**它自己找到的東西**（沒有任何提示）：

- 走對工作流：`wf/WORKFLOWS.md` → `wf/workflows/addon-dev/README.md`
- 知識層全讀：`docs/knowledge/{README,addon-loading,class-parts/*,playtesting}.md`
- 自家範本：`self_mods/tome-runewright/` 全套
- **自己去翻 `vendor/orig/`**，挖到 `verdant/data/talents/cunning/herbalism.lua`
  （現成的草藥樹）與 `neka_therianthropy_summoner`（全新 class 的唯一實證範本）
- 回引擎原始碼複驗 `worlds.lua` / `Birther.lua`

**它指出的文件缺口**（原話）：

> 「全新 class（type="class"）」的完整套路 repo 沒有成文文件——我是在引擎原始碼裡自己挖出來的。
> `docs/knowledge/class-parts/01` 只教「子職業掛進既有 class」。

這個缺口**經查證屬實**，見下方「文件缺口」一節。

**問題**：它列了 7 個待拍板的設計問題就停住了。這是精簡 prompt 模式下最大的摩擦點——
見「怎麼下 prompt」。

## 步驟 2：精簡指令，讓它自己做完

注入的 stdin（全文）：

```text
設計上的事你自己決定，不用問我，照你第 6 點的計畫做。

規則：能自己查、自己試、自己決定的，就不要停下來問。只有在「做下去會不可逆地弄壞使用者環境」時才停下來問。

現在開始動手，一路做到驗證通過：
1. 寫出 addon
2. tools/lint.sh 過
3. tools/verify.sh 過（貼出輸出）
4. tools/playtest.sh 真的建出女巫、真的學到草藥樹、真的放技能看到數值變化

做壞了沒關係，這是實驗，我隨時可以 git restore。

補充：如果需要生成文本或圖像（例如職業圖示、背景故事），機器上有 `agy` CLI 可以用
（`agy -p "..."`）。但美術非必要，缺圖示不影響驗證，自己判斷要不要做。
```

加上那段「不要停下來問」之後，它一路做到底沒再回頭問任何事。

### 它在遊戲裡自己 debug

最有價值的一段。它沒有用 `probe`，而是**自己寫臨時 Lua 探測**丟進 Lua console，
用對照組定位問題：

```text
[WITCH] DamageType=nil require=function            ← 發現 DamageType 不是全域
[WITCH] fire  ok=table pre=20 post=-30 dead=true    ← 火焰：生效，直接打死
[WITCH] proj POISON ok=table pre=16 post=16 dead=nil ← 毒：看起來完全沒作用
[WITCH] actor ... poisoned=false （本層 23 隻全部）
```

它拿「火焰能生效」當對照組證明毒這條路有問題，最後自己得出真因（**不是 bug**）：

> `projectile` 是飛行彈道，傷害要等主迴圈結算（讀太快會看到 0 傷害）

後續 log 出現「巨型棕蛇中毒了！」→ 蛇死亡消失，確認毒其實是好的。

### 它自己踩到並解掉的坑

- `--birth` 的種族要用 descriptor 英文原名（`Human` 大寫；小寫 `human` 會在建角 `setTile` 炸掉）
- `p:takeHit` 被 Player 覆寫需要 `src`，改用直接改 `p.life` 測回血
- 上述 projectile 結算時機

---

## 獨立複驗（不採信它的自我回報）

| 項目 | 結果 |
|---|---|
| `tools/lint.sh tome-witch` | 5 個 `.lua` 語法通過、`init.lua` 欄位 0 警告，退出碼 0 |
| `tools/verify.sh tome-witch` | `selfcheck tree/class/subclass/worlds` 四項全 OK，`hook complete`，驗收通過 |
| 它寫的知識層引用行號 | 實質正確，**行號有 6–9 行偏移**，已由本 session 修正 |

它寫的 `hooks/load.sh` 品質值得一提：selfcheck 用了 `verify.sh` 抓得到的格式、
註解附引擎行號、`require ActorTalents` 的理由還引了 `arcanum`/`nullpack` 的實證。

---

## 文件缺口（已補）

**全新 class（`type="class"`）比子職業多一道「世界白名單」閘門，而且失敗是靜默的。**

`Maj'Eyal` / `Infinite` / `Arena` 三個世界共用 `default_eyal_descriptors`
（`M/data/birth/worlds.lua:20-62`，分別在 `:78`／`:136`／`:211` 引用），其中
`class` 是 `__ALL__ = "disallow"` 白名單（`:36-38`）。沒 allow 的話
`Birther:generateClasses`（`M/mod/dialogs/Birther.lua:943`）裡的
`isDescriptorAllowed`（`:952`）直接不放行——**建角畫面上這個 class 根本不存在，
沒有任何錯誤訊息**。

已補進 `docs/knowledge/class-parts/01-birth-and-talents.md`。

---

## 還沒測到的

- **`agy` 實際整合**：本次它判斷美術非必要，沒有動用。要測文本／圖像生成
  得指定「這次一定要做職業圖示」。
- **多棵技能樹、跨 addon 互動、自訂資源池**：本次只做一棵樹、用現成法力池。
- **它自己寫 `tools/probes/*.lua`**：它是丟臨時 Lua 而非固化成探測。
  下次可要求「把用到的探測固化進 `tools/probes/`」。

## 未決

- `self_mods/tome-witch/` 是**實驗產物**，要不要留在 repo、要不要升格 `dist/`，等使用者決定。
- pi 已把它 deploy 到真實 home（`~/.t-engine/4.0/addons/tome-witch/`）——
  那是照 repo 文件的指示做的。不要的話跑 `tools/deploy.sh witch --undeploy`。

---

## 第二次實測：三 agent 平行做 `tome-witchwood`（2026-08-01）

| 項目 | 值 |
|---|---|
| 編排 | 一個 addon、三個 pi 平行、共用 `CONTRACT.md` |
| 分工 | A 怪物／B 地圖／C 劇情，檔案樹互不重疊 |
| 隔離 | 各自 `TOME_PLAYTEST_STATE=/tmp/tome4-playtest-{a,b,c}`，啟動錯開 20 秒 |
| 結果 | 三個都跑完並各自 verify 綠燈；**但整合後才發現兩個接縫 bug** |

### 三個 agent 各自的表現

- **A（怪物）**：完全照契約走——agy 生圖 → 從 scratch `cp` 出 → 補 alpha → `identify` 驗證。
  三隻怪 + 三張 64×64 圖。**唯一漏的是沒給 `name` 欄位**（契約沒要求，不算違約）。
- **B（地圖）**：zone 七件套 + 五張地形圖。**主動抓到契約寫錯的 `change_zone`** 並帶
  `engine/Zone.lua:159-164` 的證據偏離、回報。因為契約禁止改 `hooks/load.lua`，
  它把大地圖入口的 hook 程式碼寫好交回給編排者代掛。
- **C（劇情）**：任務 + 對話 + 任務 NPC，還**自己用 LuaJIT 模擬引擎載入環境跑了一輪
  流程冒煙測試**（授予→進度→完成→領賞→重複對話）。並抓出上面兩個接縫 bug。

### 教訓（已寫進 [README](README.md)）

1. 契約防 id 衝突，**防不住接縫**——要有整合者，且讓相依性最高的最後跑。
2. 共用檔要留**擴充點**，不要禁止修改，否則變成回報－代改的往返。
3. 契約可能是錯的，要明確**授權 agent 帶證據推翻它**。
4. `identify %[channels]` 顯示 `srgba` **不等於有透明**，要用 `-alpha extract` 看 minima。
5. 地面圖**不要**透明、樹和怪物**要**透明——三類需求不同。
6. `agy` 會宣稱生成成功但實際沒產出檔案，要 `ls` 驗。
