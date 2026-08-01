# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

- **2026-08-01 下一步：以 modkit 為主體重整本 repo（使用者提出，尚未開工）**
  - 目標形狀：**`derived/tome4-modkit/` 升為本 repo 的主體**；其餘降為次要的 `sub_proj`
    ——漢化（`derived/tome4-ch/`）、打包／佈署（`dist/`）、本機環境狀況等。
  - **待決**：使用者說的是「`~/repo/tome4`」，但現況在 `~/repo/moddings/tome4`。
    是單純簡稱，還是打算連帶搬出 `moddings/`？開工前要先問清楚。
  - 相關背景：稍早討論過把 modkit 昇華成獨立專案 + 引進 `~/repo/workflows` 模板
    （非侵入式佈局，頂層只留 `AGENTS.md`/`CLAUDE.md`，其餘收進 `wf/`），
    **使用者當時決定先不做**。這次的重整是另一個方向（不分家，但改主從），
    兩者要一起想：若 modkit 成為主體，`~/repo/workflows` 的導入對象就是本 repo 而非 modkit。
  - 已知的清理債（重整時一併處理）：`derived/tome4-modkit/` 頂層還留著一批**舊模板的說明書**
    ——`ADOPTION` / `SYNC` / `UNINSTALL` / `TEMPLATE-MANIFEST` / `INIT-QUESTIONS` /
    `MAINTENANCE` / `PRINCIPLES` / `DOGFOOD`。它們是 `~/repo/workflows` 的前身，已過時且重複。
    （modkit 的 `README.md` 同源、內容全錯，2026-08-01 已重寫。）
  - ⚠️ **本 repo 目前有大量未 commit 變更**（tools 重構＋autobirth 夾具＋文件），
    重整前先決定要不要先 commit，避免和搬檔混在一起難以檢視。

- **2026-08-01 tools 重構完成（已驗證，未 commit）**——`tools/` 拆成
  `lib/`（bash：只做行程與檔案系統編排）＋`lua/`（判讀邏輯）＋`probes/`（遊戲內狀態探測）＋6 個進入口。
  - 分工線的理由是**能力邊界**：本機沒有 `lfs`／`luaposix`，純 Lua 5.1 沒有目錄列舉、
    mkdir、spawn/signal，硬搬過去只會變成一堆 `os.execute`。
  - 消掉 verify/playtest 之間四處重複；順帶修掉 `playtest.sh stop` 用全域 `pkill -x t-engine64`
    會誤殺使用者桌面遊戲的地雷（改成殺 setsid 建立的 process group）。
  - 入口文件 `tools/README.md`（決策表）；每支腳本 `-h` 從檔頭生成。
  - 回歸：lint ×9、`verify.sh tome-relics`、`playtest --birth` + probe ×6 全綠，無殘留行程。

- **2026-08-01 無頭測試鏈補上最後一環：程式化建角**——`mods/tome-autobirth/` 是**開發用測試夾具**
  （superload `mod/dialogs/Birther.lua`），由 `tools/playtest.sh start --birth <race>/<subrace>/<class>/<subclass>`
  自動加掛。整條 playtest 現在完全不需要滑鼠座標，不再受語系/解析度影響。
  - **這個 addon 永遠不進 `dist/`**，也不列入升格批次；它沒有 hook，`verify.sh` 對它不適用。
    所以「8 個 modkit addon」的盤點數字不變，`mods/` 下多的那個目錄是夾具。
  - 手法與踩到的坑（原版 `makeDefault` 漏設 `base` 導致 `atEnd` 被擋、建角對話框吃掉 ctrl+L
    所以 Lua console 進不去、ToME 覆寫掉引擎的 `auto_birth` 流程）全記在
    `derived/tome4-modkit/knowledge/playtesting-parts/03-state-probes.md`。

- **2026-07-29 addon 升格 dist 計畫（回家後執行，需 Linux+遊戲環境）**——盤點 8 個 modkit addon 源碼成熟度後定案，解 [WAIT_USER.md](WAIT_USER.md) 第 2 點。
  - 前提結論：7/10 那 3 個 `.teaa`（runeisles/runewright/talent-tutor）**確定過時，一律重建**——build 產物從沒進 git（只活在 Linux 那台），且源碼在 7/10 後還被改過。
  - **升格批次（6 個夠格）**：runewright / runeisles / talent-tutor / relics / crafting / companions（皆 addon_version 完整、指向 tome 1.7.6、無 TODO）。
  - **先不升**：orario（v0.3 進行中，市集/眷族未做）、camp（草稿，進階功能未實現）。
  - **唯一卡關**：runewright 升格前要先完成 modkit `WAIT_USER.md` 的實機手感/平衡驗證（進遊戲看 ᛏ Tiwaz 節奏）；其他 5 個 verify.sh 綠燈即可升。
  - 執行步驟：
    ```bash
    cd derived/tome4-modkit
    for a in runewright runeisles talent-tutor relics crafting companions; do
      tools/lint.sh tome-$a && tools/verify.sh tome-$a
    done
    tools/deploy.sh runewright   # runewright 額外做實機手感驗證
    # verify 全綠 + runewright 手感 OK 後，逐個 build 帶版本+SOURCE.md 落 dist/addons/
    ```

## 各工作流 session-log

| 工作流 | session-log | open 摘要 |
|--------|-------------|----------|
| feature-dev | [workflows/feature-dev/session-log.md](workflows/feature-dev/session-log.md) | 無 |

## 不屬任何工作流的進度

- 無。
