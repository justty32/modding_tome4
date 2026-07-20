# PROJECT — tome4-modkit

## 衍生目標

一套讓 **AI agent 能自主開發 Tales of Maj'Eyal (ToME 4) addon** 的工具鏈與知識庫：開發 → 靜態檢查 → 打包 → 佈署 → 無頭測試，一條龍。

不是給人用的 GUI 工具，是給 agent 用的：skill 描述何時該做什麼、腳本提供冪等的可重複動作、知識庫記錄引擎真實行為（附 `檔案:行號`）。

實戰產物（`mods/`）：

| addon | 內容 |
|---|---|
| `tome-runewright` | 新職業 **盧恩術士**，3 技能樹 + 自訂資源 + 共鳴系統 |
| `tome-talent-tutor` | 大地圖 NPC，免費傳授全部約 300 棵技能樹 |
| `tome-runeisles` | **符文諸島**——全新大世界地圖 + 城鎮 + 兩個地城 + 三階段主線劇情 |

## 參照素材

| 素材 | 路徑 | 角色 |
|---|---|---|
| 引擎原始碼 1.7.6 | `~/repo/moddings/tome4/projects/t-engine4/engines/te4-1.7.6/` | 權威真相層（唯讀） |
| ToME 模組原始碼 | `~/repo/moddings/tome4/projects/t-engine4/modules/tome/` | 權威真相層（唯讀） |
| 遊戲安裝 | `~/.steam/steam/steamapps/common/TalesMajEyal/` | 執行檔與實裝 addon（唯讀） |
| 既有分析 | `~/repo/moddings/tome4/analysis/t-engine/` | 索引用，**非權威**，結論一律回原始碼複驗 |
| 範例 addon | `~/repo/moddings/tome4/external/orig/` | arcanum / nullpack / midnight 等真實職業包 |
| 漢化工作區 | `~/repo/moddings/tome4/derived/tome4-ch/` | locale 伴生 addon 模式的既有實作 |

## 技術棧

- **Lua 5.1 / LuaJIT**（T-Engine4 的 VM）
- **Bash** 工具腳本（Linux / Manjaro 優先）
- **Xvfb + xdotool** 無頭測試
- **PhysFS** 掛載語意決定 addon 佈署方式

## 完成定義（Done when）

本專案的 v1 完成，當且僅當下列全部成立：

1. `tools/lint.sh` 能對任一 addon 目錄做語法 + init.lua 欄位檢查，退出碼有意義。
2. `tools/build.sh` 能把 addon 目錄打包成合法 `.teaa`。
3. `tools/deploy.sh` 能冪等地把 addon 佈署到 `~/.t-engine/4.0/addons/`，且 `--undeploy` 能乾淨移除。
4. `tools/verify.sh` 能在 Xvfb 中啟動遊戲、載入 addon、確認無載入錯誤，並以退出碼回報。
5. `tools/playtest.sh` 能在 Xvfb 中實際建角、操作技能、截圖，讓 agent 自己驗證遊戲邏輯。
6. `tools/run.sh` 能在使用者真桌面（Wayland/XWayland）開遊戲並留下完整 stdout log。
7. `.claude/skills/` 下有可觸發的 skill，讓冷啟動 agent 不讀本檔也能正確做完一輪開發。
8. `mods/tome-runewright/` 通過上述 1–5 全部關卡，並已 `deploy.sh` 到真 home、經使用者實機確認載入。

**不包含**：Windows 支援（標「未複驗」）、Steam Workshop 上傳、多語言翻譯（沿用 tome4-ch 的既有管線）。

## 現況

見 [SESSION-LOG.md](SESSION-LOG.md)（open 進度）與 [session_log.md](session_log.md)（PAS 慣例的一句話日誌）。
