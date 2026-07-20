# CODE_MAP — 程式碼導航 index

修改前先在這裡定位。只列會幫助定位的檔案，不寫百科。
若 CODE_MAP 缺資料，以程式碼為準補上。

## 工具鏈（`tools/`）

| 檔案 | 職責 |
|------|------|
| `lib.sh` | 共用路徑與偵測。`source` 引入。所有路徑可用同名環境變數覆寫 |
| `lib_scratch.sh` | 共用：準備可拋棄的 scratch home（關彈窗、關第三方 addon、設語系）、挑空 X display、啟動遊戲。`verify.sh` 與 `playtest.sh` 都用它 |
| `lint.sh` | 每個 `.lua` 過 `luajit -b` 語法檢查，再跑 `check_init.lua` |
| `check_init.lua` | `init.lua` 欄位語意：必填、版本相容、`weight`、旗標↔目錄一致、`data/` 是否有對應的 `loadDefinition` |
| `build.sh` | 打包成 `.teaa`（zip）。會先跑 lint |
| `deploy.sh` | 冪等佈署到 `~/.t-engine/4.0/addons/`。`--home` 指向 scratch（verify 用）、`--undeploy` 移除 |
| `verify.sh` | Xvfb 無頭啟動遊戲，grep log 判定 addon 真的載入 |
| `playtest.sh` | Xvfb 裡**實際遊玩**：建角、按技能、截圖。子命令 `start/do/shot/zoom/log/status/stop` |

## 知識層（`knowledge/`）

每條都附 `檔案:行號`。**這裡是本專案對引擎行為的真相層**，比 `~/repo/moddings/tome4/analysis/t-engine/` 可信。

| 檔案 | 內容 |
|------|------|
| `README.md` | 索引 + 路徑代號 + 「這個引擎很愛靜默失敗」總表 |
| `addon-loading.md` | init.lua 欄位、`/data-<name>/` 私有掛載、版本相容、weight、hook 要自己 require |
| `class-and-talents.md` | Birther、newTalent、自訂資源、i18n、`t.name` 已翻譯、沒有 postUseTalent hook |
| `visuals-and-sounds.md` | 粒子／音效／圖示的三套 API 與常見誤用 |
| `npc-and-chats.md` | `<addon>+<chat>` 路徑慣例、對話檔要 return、大地圖放 NPC、授予技能樹 |
| `headless-testing.md` | Xvfb 啟動、為何跳不過 boot 主選單、預裝 addon 地雷、addon 自報格式 |
| `playtesting.md` | 為何 verify 綠燈不等於做完、建角座標速查、TEMP-DEBUG 手法、陷阱 |

## Addon（`mods/tome-talent-tutor/`）

| 檔案 | 職責 |
|------|------|
| `hooks/load.lua` | `Game:changeLevel` → 在大地圖德斯城旁放置 NPC（避開 `change_zone` 入口格）；結尾印 selfcheck |
| `data/chats/tutor.lua` | 對話。每次開啟重新執行 → 技能樹清單動態產生。**結尾必須 `return "welcome"`** |

## Addon（`mods/tome-runewright/`）

| 檔案 | 職責 |
|------|------|
| `init.lua` | 旗標與版本。`weight` 不可省 |
| `hooks/load.lua` | **一切的入口**。`ToME:load` 裡手動 `loadDefinition` 所有定義，順序有依賴。結尾印 selfcheck 供 `verify.sh` 判定 |
| `data/lib/resonance.lua` | 共鳴判定，**純函數**。之後的 UI 面板靠 `M.predict()` 做預測提示——不要把它變成 actor 方法 |
| `data/resources.lua` | `defineResource("Rune Charge", "runecharge", ...)` |
| `data/talents/misc/pool.lua` | `T_RUNE_CHARGE_POOL`。沒學會它，`getRunecharge()` 恆回 0 |
| `data/talents/spells/*.lua` | 三個技能樹（runecraft / runic-mastery / inscription-lore） |
| `data/timed_effects.lua` | `newEffect`，被 runecraft 引用 |
| `data/birth/classes/mage.lua` | `newBirthDescriptor` + 加進 Mage 子職業白名單 |
| `superload/mod/class/Actor.lua` | 包住 `postUseTalent`，攔截銘文使用累積充能 |
| `data/locales/zh_hant.lua` | **`data/` 底下唯一會自動載入的檔** |

## 唯讀外部素材（不准寫）

| 路徑 | 用途 |
|------|------|
| `~/repo/moddings/tome4/projects/t-engine4/engines/te4-1.7.6/` | 引擎原始碼（權威） |
| `~/repo/moddings/tome4/projects/t-engine4/modules/tome/` | ToME 模組原始碼（權威） |
| `~/.steam/steam/steamapps/common/TalesMajEyal/` | 遊戲安裝、執行檔、45 個既有 addon |
| `~/repo/moddings/tome4/external/orig/` | arcanum / nullpack / midnight 等實裝職業包 |
| `~/repo/moddings/tome4/analysis/t-engine/` | 舊分析，**只當索引，非權威** |
