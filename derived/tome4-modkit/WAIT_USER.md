# WAIT_USER — 等待使用者的事

只列需要使用者親自做/驗證才能繼續的 open 項。完成即移除，不留完成清單。

常見類型：

- 實機或 UI 手動驗證
- 外部帳號、權限、下載、授權
- 本機環境變數或工具安裝
- 不能由 agent 代跑的指令
- 高風險操作的確認

## Open

- **實機確認盧恩術士**。無頭測試只能證明 addon 載入、定義註冊成功、沒有 Lua Error；
  畫面、手感、數值平衡必須人眼看。
  佈署 `tools/deploy.sh runewright`（裝到 `~/.t-engine/4.0/addons/tome-runewright/`），
  移除 `tools/deploy.sh runewright --undeploy`。
  進遊戲選 Mage → 子職業應出現「盧恩術士」。

- **`Odyssey of The Summoner` 這個既有 addon 是壞的**，與本專案無關。
  它在 New Game 時必定拋 `EFF_EXHAUSTION` 重複定義的 Lua Error
  （`neka_therianthropy_summoner/timed_effects/fire-drake.lua:216`），桌面版一樣會炸。
  使用者的 `~/.t-engine/4.0/settings/addons.cfg` 已把它設為 false，目前不影響遊玩——**別再打開**。

- **平衡感受**：實機已驗證機制正確（充能 13/13 → 0/13、泉湧共鳴讓法力回復 +0.5 顯示為 +1.00），
  但數值好不好玩只有你能判斷。特別是 ᛏ Tiwaz 吃光充能換傷害倍率的節奏。

