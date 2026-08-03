# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

> 2026-08-01 完成並已移除的項目：重整、工具拆檔、女巫職業、agent 驅動工作流、
> visuals-and-sounds 拆檔、witchwood 實機驗證、runewright 特效稽核。見 git log。
> **這裡只留還沒完成的。**

- **2026-08-03 兩題最關鍵的定案，`tome-orario` v0.5「Falna」可以開工**
  - **玩家是誰**（orario §4）：**B 同時代的另一名冒險者**。C（自己眷族的團長）沒有另外採用。
  - **三構想要不要合併**（orario §8）：**歐拉麗當試驗場**——先在歐拉麗把 Falna 做出來、
    跑得通再抽成通用框架。[organic-talents-design.md](workflows/specs/organic-talents-design.md)
    與 [crafting-professions-design.md](workflows/specs/crafting-professions-design.md) 的獨立
    實作**暫不動工**，§6／§8 的細節問題留著但不急。
  - **下一步**：orario spec §5（Falna：偉業升級／五能力值／魔石經濟／技能覺醒／眷族）
    是接下來要落地的部分，且要接上 §4 定案後的「玩家＝另一名冒險者」設定。
    這需要實際開發環境（`vendor/` + luajit + verify.sh），本機 Windows 辦公室機器缺兩者，
    留到能碰 Manjaro 開發機時再動工。
  - orario §10 剩三題未答（做到第幾卷、巴別塔幾層、原文素材整理），見 [WAIT_USER.md](WAIT_USER.md)。

- **2026-08-03 新 spec：[型月魔術體系 fate-magecraft](workflows/specs/fate-magecraft-design.md)**
  - 使用者構想：FGO 世界觀的魔術體系，**全新、與 ToME 天賦體系不同**，位置**在歐拉麗隔壁**
    （Eyal 大地圖 (28,18)，待複驗）。
  - 本次對話已拍板兩題：**玩法主軸＝兩層都要**（自己是魔術師＋能召喚英靈）、
    **取得途徑＝區域門檻，任何角色可學**（不做專屬職業）。
  - 「不同」的五條具體差異：組成式術式（不花天賦點）／多回合詠唱可被打斷／
    魔力戰鬥中不回／全域回路過熱取代逐技能冷卻／刻印槽有限可重組。
  - 技術核心是 **8 個泛用「刻印槽」天賦 + 行為存在 actor 資料裡**——繞開
    「天賦定義是全域靜態、不能執行期生成」（`E/interface/ActorTalents.lua:26,91`）。
  - **⚠️ 這份 spec 寫於辦公室 Windows 機，`vendor/` 是空的、無法複驗任何行號。**
    §11 有 7 項複驗清單，其中 #1（`max_od` 吃不吃 `addTemporaryValue`）與
    #2（有沒有多回合詠唱的原版前例）**沒結論就別開工**。
  - **工序**：它是通用框架的第二個使用者，建議排在 Falna v0.7 之後。
    §16 有 5 題待使用者決定，見 [WAIT_USER.md](WAIT_USER.md)。

- **2026-08-01 `tome-director` v0.2：依實機回報大改，但還沒有任何劇情用它**
  - 讓 NPC 照腳本表演的可重用框架。38 項自我驗證通過、verify 8/8、已 deploy。
    指南在 [scripted-scenes.md](../docs/knowledge/scripted-scenes.md)，
    照抄範本在 `self_mods/tome-director/data/scenes/demo.lua`。
  - **v0.1 有兩個實機才看得到的病，都已修**：
    1. **演出跑掉幾千上萬回合**（v1 靠 `Player:act` + `useEnergy` 推回合，
       而回合推進沒有節流）。改成 `Game:registerTimer` 幀驅動，實測 `turns_spent=0`。
       `*.no_turn_cost` 那幾項斷言就是這個 bug 的回歸測試，別放寬。
    2. **台詞直接印在訊息列**，該用對話框。改走 ToME 原生 `mod.dialogs.Chat`。
  - 跳過鍵從 Enter 改成 Escape（Enter 要留給翻台詞）。
    入口從 `rawget(_G,"__tome_director")` 改成 `game.director`（xdotool 會吃掉底線）。
  - **下一步**：orario 的劇情要真的用它，才知道 step 種類夠不夠用。
    spec 的 v0.5 就是「第 1 卷走通」——那一期會驗出這套框架的真正極限。

- **2026-08-01 `tome-orario` v0.4 完成並修好入口（已 deploy）**
  - 市集三家店 + 三個眷族據點（hearth / loki / freya，各 2 NPC + 1 本 lore）+ 6 支對話。
    順手修掉巴別塔 `object_list` 為空（之前**完全不掉落物**）。
  - **實機回報「進不去眷族據點」已修**：三棟建築被畫成密閉 3x3 盒子，傳送門格周圍八格全是牆。
    漏掉的原因是當初用 `game:changeLevel()` 直接跳進去驗，從沒驗過「玩家走得到入口嗎」。
    → **教訓：新 zone 的驗收一定要包含一條 A\* 連通性斷言，不能只驗 changeLevel。**
    又因為 zone 是 `persistent`（整個 level 會存進 `.teaz`），光改地圖字串對現有存檔無效，
    所以另外加了進場遷移 hook。
  - verify **22/22**、六個方向 A\* 全部有路、真的逐格走進去又走回來。
  - **還沒做的是 v0.5「劇情框架」**——那才是 orario spec 的生死關，而且要先等使用者回答
    「玩家是誰」。

- **2026-08-01 延後：女巫森林的地板與樹要多樣化**（使用者決定「之後有需要再做」）
  - 現況只有 2 種樹 + 2 種地板，鋪一整張圖很重複。原版森林是用
    `nice_tiler = { method="replace", base={"TREE",100,1,30} }` 配 **30 個變體**
    打散重複感（`M/data/general/grids/forest.lua:72,75-77`）。
  - 使用者的打算是「讓 agy 多產出一些圖」。**動工前先讀這一段**：
    | | 需要 alpha？ | 用 agy 安全嗎 |
    |---|---|---|
    | **地板** | **不需要**（整格都是圖）| **安全，就交給 agy** |
    | **樹** | 需要 | **危險**——這正是剛修掉的 bug |
  - 樹的坑：agy 產出沒有 alpha，補 alpha 只能靠 `magick -fuzz N% -transparent`，
    而那條路產出的是 **1-bit alpha**：邊緣鋸齒＋清不掉的殘邊，fuzz 開大又把樹幹鑿穿。
    2026-08-01 兩張樹就是這樣壞的，最後改成從原版資產色調位移才乾淨。
    → **樹優先從原版 485 張衍生**（換 src 檔名重跑一行 magick 就是一棵新樹）；
    真要用 agy 就得檢查 `magick x.png -alpha extract -format '%[fx:int(w*h*mean)]' info:`
    有沒有半透明像素。細節見
    [visuals-and-sounds-parts/01](../docs/knowledge/visuals-and-sounds-parts/01-effects-api-and-pitfalls.md)。
  - 另外：加了變體就要把 `nice_tiler = false` 換成 replace 規則，否則新圖不會被用到。

- **本 repo 沒有 LICENSE**（重整時刪掉的那份是舊模板的「Private/internal-use template」，
  不是本工作的授權）。repo 是公開的，要不要補一份真的由使用者決定。

- **2026-07-29 addon 升格 dist 計畫（6 個夠格，仍卡關）**
  - 批次：runewright / runeisles / talent-tutor / relics / crafting / companions
  - **唯一卡關**：runewright 的實機手感/平衡驗證（見 [WAIT_USER.md](WAIT_USER.md)）。
    其他 5 個 verify.sh 綠燈即可升。
  - 注意：runewright 2026-08-01 剛修好一個「整個職業載入不起來」的 bug
    （`require("data.…")` 用在私有掛載點上），升格前值得再實機看一次。
  - 步驟：
    ```bash
    cd ~/repo/moddings/tome4
    for a in runewright runeisles talent-tutor relics crafting companions; do
      tools/lint.sh tome-$a && tools/verify.sh tome-$a
    done
    # 全綠 + 手感 OK 後，逐個 build 帶版本+SOURCE.md 落 self_mods/dist/addons/
    ```

## 各工作流 session-log

| 工作流 | session-log | open 摘要 |
|--------|-------------|----------|
| addon-dev | [workflows/addon-dev/session-log.md](workflows/addon-dev/session-log.md) | 見上方升格批次 |
| agent-driving | [workflows/agent-driving/session-log.md](workflows/agent-driving/session-log.md) | orario v0.4 由 pi 產出中 |
| feature-dev | [workflows/feature-dev/session-log.md](workflows/feature-dev/session-log.md) | 無 |
| refactor | [workflows/refactor/session-log.md](workflows/refactor/session-log.md) | 無 |
| investigation | [workflows/investigation/session-log.md](workflows/investigation/session-log.md) | 無 |

## 不屬任何工作流的進度

- **`vendor/` 2026-08-01 補齊了兩包**：`vendor/dlc/`（三包官方 DLC，338MB）與
  `tome-gfx.team` 的美術資產（331MB，解進 `vendor/t-engine4/modules/tome/data/gfx/`）。
  還原步驟已寫進 [AGENTS.md](../AGENTS.md) 的「Fresh clone / 環境還原」，
  但**還沒固化成 `tools/` 下的腳本**。
