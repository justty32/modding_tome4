# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

> 2026-08-01 完成並已移除的項目：重整、工具拆檔、女巫職業、agent 驅動工作流、
> visuals-and-sounds 拆檔、witchwood 實機驗證、runewright 特效稽核。見 git log。
> **這裡只留還沒完成的。**

- **2026-08-01 三個大構想已寫成 spec，等使用者定案後才動工**
  - [organic-talents-design.md](workflows/specs/organic-talents-design.md)——生長式天賦
    （POE 式節點，但靠遊戲行為長出來）。引擎可行性已驗完（`__show_special_talents`）。
    **卡在使用者要回答 §6 的四題**，最關鍵是規模與「自我練習」的累積方式。
  - [orario-complete-design.md](workflows/specs/orario-complete-design.md)——歐拉麗完全版。
    使用者目標是「把地錯劇情整個搬進來」。**卡在 §4「玩家是誰」**（建議 B：同時代的另一名
    冒險者，理由是 roguelike 的永久死亡與自訂建角與「演貝爾」根本衝突）。
  - 製作系統（WoW 式鍛造/鑲嵌/附魔/釀造）——調查已落在
    [crafting-and-imbue.md](../docs/knowledge/crafting-and-imbue.md)，還沒寫成 spec。
  - **三者底層是同一套機制**（見 orario spec §8），要不要合併是使用者要拍板的第一題。

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
