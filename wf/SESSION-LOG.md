# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

> 2026-08-01 的重整、工具拆檔、女巫職業、agent 驅動工作流等**已完成項目已移除**
> （見 git log `ea9b503..a9617ff`）。這裡只留還沒完成的。

- **2026-08-01 使用者實機回報：盧恩術士有技能特效殘留（未修）**
  - 症狀：某些技能的特效在技能結束、角色離開後仍留在原地。使用者說「先不管」，下次再處理。
  - **已有線索**：掃描自製 addon 用到的粒子名時，`arcane_power` 確實出現在用字裡——
    那正是 `docs/knowledge/visuals-and-sounds.md` 點名「更新函式無條件 emit、永不停止」的粒子。
    **從它查起**。
  - 同一天已修掉女巫 `T_WITCH_BREW` 的同類 bug（把飛行粒子 `bolt_slime` 當成命中粒子填進
    `projectile()` 第 6 參數）。判定方法與三粒子角色對照表都已寫進 knowledge，照著查即可。

- **2026-08-01 `tome-witchwood`（女巫森林）只跑過 verify，沒實機 playtest**
  - 三 agent 平行產出：三隻怪 + zone + 支線任務 `witchwood-curse`，verify 三項 selfcheck 全過，
    美術（3 怪 + 5 地形）已通過使用者肉眼審核。
  - **但沒有人真的走進去玩過**——大地圖入口是否出現、葛薇是否真的生成在可達位置、
    任務能否走完，全部未驗。下次要跑 `tools/playtest.sh` 實機確認。
  - 也**還沒 deploy** 到真實 home（女巫 `tome-witch` 已 deploy）。

- **`docs/knowledge/visuals-and-sounds.md` 已 380+ 行，超過 DEV-GUIDE 的 300 行門檻，待拆**
  - 它有 12 個清楚章節（特效 API／路徑／自製資產／物品貼圖／職業圖示／音效／粒子／失敗模式／字型），
    該拆成 `visuals-and-sounds-parts/`，與 `class-parts/`、`particles-parts/` 一致。
  - 沒有立刻拆是因為它剛被大幅改寫兩次，跟內容新增混在一起難以檢視。單獨做比較乾淨。

- **本 repo 沒有 LICENSE**（重整時刪掉的那份是舊模板的「Private/internal-use template」，
  不是本工作的授權）。repo 是公開的，要不要補一份真的由使用者決定。

- **2026-07-29 addon 升格 dist 計畫（6 個夠格，仍卡關）**
  - 批次：runewright / runeisles / talent-tutor / relics / crafting / companions
  - **唯一卡關**：runewright 的實機手感/平衡驗證（見 [WAIT_USER.md](WAIT_USER.md)）。
    其他 5 個 verify.sh 綠燈即可升。注意上面那條特效殘留可能也要一併修掉再升。
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
