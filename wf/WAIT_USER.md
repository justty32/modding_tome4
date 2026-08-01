# WAIT_USER — 等待使用者的事

只列需要使用者親自做/驗證才能繼續的 open 項。完成即移除，不留完成清單。

常見類型：

- 實機或 UI 手動驗證
- 外部帳號、權限、下載、授權
- 本機環境變數或工具安裝
- 不能由 agent 代跑的指令
- 高風險操作的確認

## Open

- **實機確認女巫（手感／平衡）**。無頭測試證明：建角成功（Cornac/Witch）、草藥樹四技註冊、
  被動生效（毒/疾病免疫 20%、治療加成 +10%）、生命藥露回血（90→55→90＋regen）、
  女巫魔藥命中並毒殺 16HP 棕蛇（log：`巨型棕蛇中毒了`）。
  畫面、手感、數值平衡必須人眼看。
  已佈署 `tools/deploy.sh witch`（`~/.t-engine/4.0/addons/tome-witch/`），
  移除 `tools/deploy.sh witch --undeploy`。進遊戲選 class 分類「女巫」（Cornac/Witch）即可。
  目前只有草藥一棵樹（起手 3 點、升級會沒地方花點數是已知限制）。

- **實機確認盧恩術士（手感／平衡）**。無頭測試只能證明 addon 載入、定義註冊成功、沒有 Lua Error；
  畫面、手感、數值平衡必須人眼看。
  佈署 `tools/deploy.sh runewright`（裝到 `~/.t-engine/4.0/addons/tome-runewright/`），
  移除 `tools/deploy.sh runewright --undeploy`。進遊戲選 Mage → 子職業應出現「盧恩術士」。
  機制正確性已實機驗過（充能 13/13 → 0/13、泉湧共鳴讓法力回復 +0.5 顯示為 +1.00），
  但數值好不好玩只有你能判斷——特別是 ᛏ Tiwaz 吃光充能換傷害倍率的節奏。
  **這是 6 個 addon 升格 `self_mods/dist/` 批次的唯一卡關項**（見 [SESSION-LOG.md](SESSION-LOG.md)）。

- **`Odyssey of The Summoner` 這個既有 addon 是壞的**，與本 repo 無關。
  它在 New Game 時必定拋 `EFF_EXHAUSTION` 重複定義的 Lua Error
  （`neka_therianthropy_summoner/timed_effects/fire-drake.lua:216`），桌面版一樣會炸。
  你的 `~/.t-engine/4.0/settings/addons.cfg` 已把它設為 false，目前不影響遊玩——**別再打開**。

- **`.teaa` 暫存 build 的發佈策略未定**。`build/` 下的自製 addon 與
  `sub_proj/zh_mods/build/` 的 18 個在地化 `.teaa` 都屬「暫存 build，未升格 dist」，
  哪天要一起決定發佈策略。

