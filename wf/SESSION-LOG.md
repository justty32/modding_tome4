# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

- **2026-08-01 repo 以 modkit 為主體重整完成**——`derived/tome4-modkit/` 的內容整包上移到 repo 根，
  成為主體（`tools/` `self_mods/` `docs/knowledge/` `workflows/` `docs/html/` `.claude/`）。
  - 新佈局三層：**主體**（addon 開發本身）／**`sub_proj/`**（`tome4-ch` 漢化、`dist` 成品、
    `analysis` 引擎分析索引）／**`vendor/`**（唯讀第三方素材：`t-engine4/` `orig/` `chn-mod/`，
    原 `projects/` + `external/`，共 231MB，仍由 `.gitignore` 排除）。
  - **路徑問題已解**：使用者說的「`~/repo/tome4`」是簡稱。`~/repo/moddings/` 底下是
    elin / rimworld / skyrim / starbound / taiwu / tome4 一整排遊戲 mod 專案，tome4 留在原位不搬家。
  - 六份重複文件（根與 modkit 各一套 `AGENTS` / `WORKFLOWS` / `DEV-GUIDE` / `SESSION-LOG` /
    `WAIT_USER` / `README` + 兩個 `workflows/`）已合併成一份。兩份 `conventions.md` 是**互補**的
    （根有「真相層優先級」、modkit 有「CODE_MAP 維護鏈」），合併保留兩者。
  - 順手刪掉 modkit 頂層 13 項舊模板殘留（`ADOPTION` / `SYNC` / `UNINSTALL` / `TEMPLATE-MANIFEST` /
    `INIT-QUESTIONS` / `MAINTENANCE` / `PRINCIPLES` / `DOGFOOD` / `workflows-index` / `CHANGELOG` /
    `VERSION` / `LICENSE` / `commands/`）。**`LICENSE` 寫的是「Private/internal-use template」，
    是模板的授權而非本工作的授權，一併刪除——要給本 repo 一個真的 LICENSE 是待決事項。**
  - `tools/lib/paths.sh` 的 `MODKIT_ROOT` 由檔案自身位置推導，搬家零成本；
    `TOME_SRC` 已改指 `vendor/t-engine4`。`sub_proj/zh_mods/_reference/` 的 symlink 已重指 `vendor/`。
  - 相關背景：稍早討論過把 modkit 昇華成獨立專案 + 引進 `~/repo/workflows` 模板，
    **使用者決定不做**。這次是另一個方向（不分家，改主從）。若日後仍要導入 `~/repo/workflows`，
    對象就是本 repo 而非 modkit。

- **2026-08-01 tools 重構完成**——`tools/` 拆成
  `lib/`（bash：只做行程與檔案系統編排）＋`lua/`（判讀邏輯）＋`probes/`（遊戲內狀態探測）＋6 個進入口。
  - 分工線的理由是**能力邊界**：本機沒有 `lfs`／`luaposix`，純 Lua 5.1 沒有目錄列舉、
    mkdir、spawn/signal，硬搬過去只會變成一堆 `os.execute`。
  - 消掉 verify/playtest 之間四處重複；順帶修掉 `playtest.sh stop` 用全域 `pkill -x t-engine64`
    會誤殺使用者桌面遊戲的地雷（改成殺 setsid 建立的 process group）。
  - 入口文件 `tools/README.md`（決策表）；每支腳本 `-h` 從檔頭生成。
  - 回歸：lint ×9、`verify.sh tome-relics`、`playtest --birth` + probe ×6 全綠，無殘留行程。

- **2026-08-01 無頭測試鏈補上最後一環：程式化建角**——`self_mods/tome-autobirth/` 是**開發用測試夾具**
  （superload `mod/dialogs/Birther.lua`），由 `tools/playtest.sh start --birth <race>/<subrace>/<class>/<subclass>`
  自動加掛。整條 playtest 現在完全不需要滑鼠座標，不再受語系/解析度影響。
  - **這個 addon 永遠不進 `dist/`**，也不列入升格批次；它沒有 hook，`verify.sh` 對它不適用。
    所以「8 個 addon」的盤點數字不變，`self_mods/` 下多的那個目錄是夾具。
  - 手法與踩到的坑（原版 `makeDefault` 漏設 `base` 導致 `atEnd` 被擋、建角對話框吃掉 ctrl+L
    所以 Lua console 進不去、ToME 覆寫掉引擎的 `auto_birth` 流程）全記在
    `docs/knowledge/playtesting-parts/03-state-probes.md`。

- **2026-07-29 addon 升格 dist 計畫（回家後執行，需 Linux+遊戲環境）**——盤點 8 個 addon 源碼成熟度後定案，解 [WAIT_USER.md](WAIT_USER.md) 的發佈策略項。
  - 前提結論：7/10 那 3 個 `.teaa`（runeisles/runewright/talent-tutor）**確定過時，一律重建**——build 產物從沒進 git（只活在 Linux 那台），且源碼在 7/10 後還被改過。
  - **升格批次（6 個夠格）**：runewright / runeisles / talent-tutor / relics / crafting / companions（皆 addon_version 完整、指向 tome 1.7.6、無 TODO）。
  - **先不升**：orario（v0.3 進行中，市集/眷族未做）、camp（草稿，進階功能未實現）。
  - **唯一卡關**：runewright 升格前要先完成 [WAIT_USER.md](WAIT_USER.md) 的實機手感/平衡驗證（進遊戲看 ᛏ Tiwaz 節奏）；其他 5 個 verify.sh 綠燈即可升。
  - 執行步驟：
    ```bash
    cd ~/repo/moddings/tome4
    for a in runewright runeisles talent-tutor relics crafting companions; do
      tools/lint.sh tome-$a && tools/verify.sh tome-$a
    done
    tools/deploy.sh runewright   # runewright 額外做實機手感驗證
    # verify 全綠 + runewright 手感 OK 後，逐個 build 帶版本+SOURCE.md 落 self_mods/dist/addons/
    ```

## 各工作流 session-log

| 工作流 | session-log | open 摘要 |
|--------|-------------|----------|
| addon-dev | [workflows/addon-dev/session-log.md](workflows/addon-dev/session-log.md) | 見上方升格批次 |
| feature-dev | [workflows/feature-dev/session-log.md](workflows/feature-dev/session-log.md) | 無 |
| refactor | [workflows/refactor/session-log.md](workflows/refactor/session-log.md) | 無 |
| investigation | [workflows/investigation/session-log.md](workflows/investigation/session-log.md) | 無 |

## 不屬任何工作流的進度

- 無。
## 最新進度

- **2026-08-01 女巫（Witch）addon 完成第一版（草藥樹）**——`self_mods/tome-witch/`。
  - **全新 class 範本**：本 repo 第一個 `type="class"` 職業（runewright 只是 Mage 子職業）。
    關鍵新知：「新 class 要進世界白名單」——`M/data/birth/worlds.lua:20-62` 的
    `default_eyal_descriptors` 對 class 是 `__ALL__="disallow"`，已寫進
    `docs/knowledge/class-parts/01-birth-and-talents.md`。
  - 驗證全過：lint 0；verify 4/4 selfcheck（tree/class/subclass/worlds）；
    playtest 實機建角 Cornac/Witch、被動數值（毒免 20%、healing_factor 1.1）、
    生命藥露 90→55→90、女巫魔藥毒殺 16HP 棕蛇。build 打包 12K。
  - 已佈署 `tools/deploy.sh witch`；手感/平衡待使用者實機確認（WAIT_USER.md）。
  - 踩過的坑：`--birth` 的 race 要用 descriptor 英文原名（`Human` 大寫，`human` 會炸）；
    `p:takeHit` 在 Player 覆寫下需要 src；`projectile` 是飛行彈道，傷害要等主迴圈結算。
