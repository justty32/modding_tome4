# SESSION-LOG — 進度日誌 hub

只放還沒完成的活狀態。完成的不留在這裡；完成後濃縮到對應工作流的 landed/archive、release note、或 git log。

待使用者親自做/驗證的事放 [WAIT_USER.md](WAIT_USER.md)。

建議單一 `session-log.md` 保持短小，只為「下一個 session 接得上」。若超過 50 行，刪舊留新，或按工作流/主題拆檔。

## 最新進度

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
