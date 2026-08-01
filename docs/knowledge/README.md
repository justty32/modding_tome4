# knowledge — 引擎事實（真相層）

目標版本 **ToME 1.7.6**。這裡的每一條都在原始碼複驗過並附 `檔案:行號`。

**這裡比 `~/repo/moddings/tome4/docs/analysis/` 可信。** 那份只是索引。

## 路徑代號

本目錄的文件一律用這三個代號：

| 代號 | 實際路徑 | 性質 |
|---|---|---|
| `E` | `~/repo/moddings/tome4/vendor/t-engine4/engines/te4-1.7.6/engine` | 引擎原始碼，唯讀 |
| `M` | `~/repo/moddings/tome4/vendor/t-engine4/modules/tome` | ToME 模組原始碼，唯讀 |
| `R` | `~/repo/moddings/tome4/vendor/orig` | 實裝過的第三方 addon，唯讀 |

## 索引

| 文件 | 什麼時候讀 |
|---|---|
| [addon-loading.md](addon-loading.md) | 建 addon 骨架、`init.lua` 欄位、為什麼東西沒被載入 |
| [class-and-talents.md](class-and-talents.md) | 做職業、技能、自訂資源、i18n、找不到 hook 時 |
| [visuals-and-sounds.md](visuals-and-sounds.md) | 加特效、音效、天賦圖示（叫**現成**粒子） |
| [particles.md](particles.md) | 寫**新**粒子檔、發射幾何速查、劍氣／枝枒蔓延、自製紋理 |
| [custom-ui.md](custom-ui.md) | 做自訂面板／Dialog、開啟入口、測 UI |
| [npc-and-chats.md](npc-and-chats.md) | 放 NPC、寫對話、授予技能樹 |
| [crafting-and-imbue.md](crafting-and-imbue.md) | 附魔（gem→applyEgo）、配方煉製骨架（材料→產物） |
| [companions-and-party.md](companions-and-party.md) | 招募同伴、隨主人成長（清 max_level）、對主人免傷（superload onTakeHit） |
| [items-and-egos.md](items-and-egos.md) | 做神器、ego 詞綴、套裝、可成長物品、掉落／商店整合 |
| [worldmap-and-zones.md](worldmap-and-zones.md) | 做新 zone／城鎮／地城、往大地圖加東西、新增大地圖或 campaign |
| [quests-and-lore.md](quests-and-lore.md) | 寫劇情線、任務、可拾取文獻 |
| [headless-testing.md](headless-testing.md) | 跑 `verify.sh`、無頭啟動出問題 |
| [playtesting.md](playtesting.md) | 跑 `playtest.sh`、要在遊戲裡實際操作 |
| [real-machine.md](real-machine.md) | 要交給使用者實機玩、遊戲從 Steam 開會崩、在真桌面開遊戲 |

## 貫穿全部的一件事：這個引擎**很愛靜默失敗**

寫錯了不會拋錯，只是安靜地什麼都不發生。這是本專案要有三層驗證的根本原因。

| 你做錯的事 | 症狀 |
|---|---|
| addon 資料夾名前綴不對 | addon 消失，無訊息 |
| `version` 與模組不相容 | addon 消失，無訊息 |
| `data/` 底下的定義沒手動 `loadDefinition` | 檔案在，東西不存在 |
| `newBirthDescriptor` 撞名 | 靜默覆蓋（但 `newTalent` / `defineResource` 撞名是 assert 崩潰） |
| 銘文欄位已滿還想再塞 | 靜默丟棄 |
| i18n 的 tag 對不上 | 翻譯不生效，顯示原文 |
| 粒子／音效名稱寫錯 | 什麼都不發生 |
| 遊戲邏輯拿 `t.name` 比對英文 | 在非英文語系永遠不成立 |
| 對話檔忘了 `return "welcome"` | 一跟 NPC 說話就 nil index 崩潰（這個**會**報錯） |
| NPC 放在城鎮入口格 | 玩家進不了城，無訊息 |
| 自訂地面繼承 `base="GRASS"` | 你設的 `image` 永遠不顯示（`nice_tiler` 100% 換成草地變體） |
| 自訂 dialog 放在 `data/` | `require("mod.dialogs.X")` 找不到（要放 `overload/`） |
| `arcane_power` 丟給 `map:particleEmitter` | 永不停止發射，粒子永久留在地圖上 |
| 大地圖入口格沒給 `add_displays` | 那格看起來只是普通草地，玩家找不到入口 |
| zone 的 `grids.lua` 缺席 | 整張地圖靜默變空白 |
| 靜態地圖某一列長度不對 | **崩潰**（這個不靜默，但錯因離現場很遠）|
| 設了 `wda.script` 但腳本檔不存在 | **崩潰**，且是玩家走第一步的時候才炸 |
| 只在 scratch home 測過，忘了 `deploy.sh` 到真 home | 三層驗證全綠，使用者的遊戲裡什麼都沒有 |

上表前三條已由 `tools/lua/check_init.lua` 自動擋下。其餘只能靠 `verify.sh` 與 `playtest.sh`。

## 新增知識的規矩

- **一定附 `檔案:行號`。** 沒有行號的結論不要寫進來。
- 結論來自實測（跑過、看過）就註明是實測，並寫下辨識症狀。
- 只寫「會讓下一個 agent 少踩一次坑」的東西，不寫百科。
