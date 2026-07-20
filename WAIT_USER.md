# WAIT_USER — 等待使用者的事

只列需要使用者親自做/驗證才能繼續的 open 項。完成即移除，不留完成清單。

常見類型：

- 實機或 UI 手動驗證
- 外部帳號、權限、下載、授權
- 本機環境變數或工具安裝
- 不能由 agent 代跑的指令
- 高風險操作的確認

## Open

- 2026-07-20 工作區重新納入 git（根目錄成為 repo，推到 `github.com/justty32/modding_tome4`；第三方大樹經 `.gitignore` 排除）。`derived/tome4-modkit/` 現隨此根 repo 一起版控——若仍想給它**獨立** repo（與根 repo 分開發布/歷史）是尚未決定的選項。(2) `derived/tome4-modkit/build/` 現存三個 `.teaa`（runeisles/runewright/talent-tutor，7/10 建）早於部分源碼的後續修改，可能過時，是否重建並升級為 `dist/addons/` 正式成品？

  補充（2026-07-18）：`derived/tome4-ch/build/` 的 18 個在地化 `.teaa` 同屬「暫存 build，未升格 dist」，與上方 (2) 同性質；哪天要一起決定發佈策略。

