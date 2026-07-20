# ~/repo/moddings/tome4 —— ToME4 modding 總資料夾

ToME4 (Tales of Maj'Eyal) modding 的開發、分析、產物集中地。**不是 git repo**(使用者決定 2026-07-17;拆除前歷史已留 bundle 備份)。

## 你來找什麼?

| 你要找的 | 去哪裡 |
|---|---|
| **做好的 addon 成品**(`.teaa`,拿去部署/發佈) | [`dist/`](dist/README.md) —— 目前尚無正式發佈版;開發中 addon 的即建即部署走 `derived/tome4-modkit/tools/`(`build.sh` → `deploy.sh`),暫存建置產物在 `derived/tome4-modkit/build/` |
| 開發中的 addon 原始碼與工具鏈 | `derived/tome4-modkit/` —— agent 自主開發 addon 的一條龍工具鏈(開發→lint→打包→部署→無頭測試)+ 引擎知識庫(`knowledge/`)+ 8 個 addon 原始碼(`mods/`);動手前先讀它的 `AGENTS.md` |
| 引擎/模組架構分析 | `analysis/t-engine/` —— T-Engine4 架構文件(`architecture/`)、17 篇 addon 開發教程(`tutorial/`)、HTML 導覽(`html/`);注意它只是索引,API 結論以 `projects/t-engine4/` 原始碼與 `derived/tome4-modkit/knowledge/` 為準 |
| 他人素材(引擎/遊戲原始碼) | `projects/t-engine4/` —— Steam 版解壓出的 T-Engine4 引擎層 + ToME 模組層(Lua,126MB,**唯讀真相層**,可從 Steam 安裝重新解壓,還原步驟見 [AGENTS.md](AGENTS.md)「Fresh clone / 環境還原」) |
| 他人素材(第三方 addon 參考) | `external/` —— 第三方 addon 解壓的唯讀參考:`orig/`(25 個實裝過的職業包/QoL addon)、`chn-mod/`(簡體翻譯包範本);由 `derived/tome4-ch` 與 `derived/tome4-modkit` 共用參照,見其 README |
| 正體中文化(第三方 addon 的 `zh_hant` 伴生 addon) | `derived/tome4-ch/` —— 非侵入式翻譯工作區:18 個 `tome-*-zh` 伴生 addon 源碼 + `_tools/` 翻譯管線 + 打包好的 `build/*.teaa`(第三方原 addon 參考走 symlink 指向 `external/orig`);動手前先讀它的 `README.md` 與 `GUIDE.md`。2026-07-18 自 `~/code/tome4-ch` 搬遷整合(原目錄已刪除,以此為唯一真相) |

## 部署注意

- **本機部署狀態(已裝 addon 清單、`~/.t-engine/4.0/addons/` 現況、遊戲安裝狀態)不在本資料夾**——歸 `~/notes` 側管理。部署前去那邊看現況、部署後回那邊記錄。
- 本資料夾只負責:開發與工具鏈(derived/tome4-modkit)、分析(analysis)、成品(dist)、引擎源碼參考(projects/t-engine4)。
- 部署目標是 `~/.t-engine/4.0/addons/`,**不是** Steam 的 `game/addons/`(理由見 `derived/tome4-modkit/tools/deploy.sh` 檔頭)。

## 要在這裡動手做事?

先讀 [AGENTS.md](AGENTS.md)(工作規則、工作流路由);實際 addon 開發再讀 `derived/tome4-modkit/AGENTS.md`(更細的鐵律,例如「絕不在真實桌面裸跑 t-engine64」)。
